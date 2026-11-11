#!/usr/bin/env python3
"""
OBS Unified Overlays Server
Reads MPRIS player data via D-Bus and serves local OBS overlays on http://localhost:9860
Filters out web browsers (Firefox, Chrome, etc.) so only real music (Cider, Spotify) is shown.
"""

import os
import sys
import json
import time
import re
import urllib.parse
import urllib.request
import threading
from http.server import ThreadingHTTPServer, SimpleHTTPRequestHandler
import dbus

PORT = 9860
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Blacklist browsers so background stream previews / YouTube tabs never override music
IGNORED_BROWSERS = [
    'firefox', 'zen', 'librewolf', 'waterfox', 'chrome',
    'google-chrome', 'brave', 'edge', 'opera', 'vivaldi', 'tor'
]

latest_data = {
    "status": "Stopped",
    "title": "",
    "artist": "",
    "album": "",
    "art_url": "",
    "position_sec": 0,
    "length_sec": 0,
    "progress_percent": 0,
    "player": "",
    "updated_at": 0
}
data_lock = threading.Lock()
subscribers = []
subscribers_lock = threading.Lock()

def is_cider_process(bus_name):
    m = re.search(r'instance(\d+)', bus_name)
    if m:
        pid = m.group(1)
        cmdline_path = f"/proc/{pid}/cmdline"
        if os.path.exists(cmdline_path):
            try:
                with open(cmdline_path, 'rb') as f:
                    cmd = f.read().decode('utf-8', errors='ignore').lower()
                    if 'cider' in cmd:
                        return True
            except Exception:
                pass
    return False

def is_ignored_player(bus_name):
    lower = bus_name.lower()
    for b in IGNORED_BROWSERS:
        if b in lower:
            return True
    # If it's chromium, only allow if it is Cider
    if 'chromium' in lower and not is_cider_process(bus_name):
        return True
    return False

def detect_player_name(bus_name):
    lower = bus_name.lower()
    if 'spotify' in lower:
        return 'Spotify'
    if is_cider_process(bus_name) or 'cider' in lower:
        return 'Cider'
    if 'vlc' in lower:
        return 'VLC'
    if 'mpd' in lower:
        return 'MPD'
    return bus_name.replace('org.mpris.MediaPlayer2.', '').split('.')[0].capitalize()

def get_active_mpris_player():
    try:
        bus = dbus.SessionBus()
        all_players = [s for s in bus.list_names() if s.startswith('org.mpris.MediaPlayer2')]
        if not all_players:
            return None, None, None

        # Filter out web browsers entirely
        valid_players = [p for p in all_players if not is_ignored_player(p)]
        if not valid_players:
            return None, None, None

        best_player = None
        best_name = None

        # Priority 1: Any dedicated music player that is actively Playing
        for name in valid_players:
            try:
                obj = bus.get_object(name, '/org/mpris/MediaPlayer2', introspect=False)
                props = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
                status = str(props.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus'))
                if status == 'Playing':
                    return name, obj, props
                if best_player is None:
                    best_name = name
                    best_player = obj
            except Exception:
                continue

        if best_player:
            props = dbus.Interface(best_player, 'org.freedesktop.DBus.Properties')
            return best_name, best_player, props

        return None, None, None
    except Exception:
        return None, None, None

def control_mpris_player(action):
    try:
        bus = dbus.SessionBus()
        all_players = [s for s in bus.list_names() if s.startswith('org.mpris.MediaPlayer2')]
        valid_players = [p for p in all_players if not is_ignored_player(p)]
        if not valid_players:
            return False, "No active media player found"

        target = None
        for name in valid_players:
            try:
                obj = bus.get_object(name, '/org/mpris/MediaPlayer2', introspect=False)
                props = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
                status = str(props.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus'))
                if status == 'Playing':
                    target = obj
                    break
                if target is None:
                    target = obj
            except Exception:
                continue

        if not target and valid_players:
            target = bus.get_object(valid_players[0], '/org/mpris/MediaPlayer2', introspect=False)

        if target:
            iface = dbus.Interface(target, 'org.mpris.MediaPlayer2.Player')
            if action == 'playpause':
                iface.PlayPause()
            elif action == 'next':
                iface.Next()
            elif action == 'previous':
                iface.Previous()
            elif action == 'stop':
                iface.Stop()
            return True, "OK"
        return False, "Player unresponsive"
    except Exception as e:
        return False, str(e)

def update_now_playing_file(data):
    try:
        txt_path = os.path.join(BASE_DIR, 'now_playing.txt')
        if data.get("status") == "Playing" and data.get("title"):
            artist = data.get("artist", "").strip()
            title = data.get("title", "").strip()
            content = f"{artist} - {title}" if artist else title
        else:
            content = ""
        with open(txt_path, 'w', encoding='utf-8') as f:
            f.write(content)
    except Exception:
        pass

def poll_mpris():
    global latest_data
    while True:
        try:
            name, player, props = get_active_mpris_player()
            if not player or not props:
                with data_lock:
                    if latest_data["status"] != "Stopped":
                        latest_data["status"] = "Stopped"
                        latest_data["updated_at"] = time.time()
                        update_now_playing_file(latest_data)
                        notify_subscribers(latest_data)
                time.sleep(1)
                continue

            status = str(props.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus'))
            metadata = props.Get('org.mpris.MediaPlayer2.Player', 'Metadata')
            
            title = str(metadata.get('xesam:title', ''))
            
            artists = metadata.get('xesam:artist', [])
            if isinstance(artists, (list, tuple, dbus.Array)):
                artist = ', '.join([str(a) for a in artists])
            else:
                artist = str(artists)
                
            album = str(metadata.get('xesam:album', ''))
            art_url = str(metadata.get('mpris:artUrl', ''))
            length_us = int(metadata.get('mpris:length', 0))
            length_sec = round(length_us / 1000000)

            try:
                pos_us = int(props.Get('org.mpris.MediaPlayer2.Player', 'Position'))
                pos_sec = round(pos_us / 1000000)
            except Exception:
                pos_sec = 0

            progress = 0
            if length_sec > 0:
                progress = min(100, round((pos_sec / length_sec) * 100, 1))

            player_name = detect_player_name(name)

            new_data = {
                "status": status,
                "title": title,
                "artist": artist,
                "album": album,
                "art_url": art_url,
                "position_sec": pos_sec,
                "length_sec": length_sec,
                "progress_percent": progress,
                "player": player_name,
                "updated_at": time.time()
            }

            with data_lock:
                track_changed = (
                    latest_data["title"] != new_data["title"] or
                    latest_data["status"] != new_data["status"] or
                    latest_data["artist"] != new_data["artist"]
                )
                changed = (
                    track_changed or
                    abs(latest_data.get("position_sec", 0) - new_data["position_sec"]) >= 1
                )
                latest_data = new_data
                if track_changed:
                    update_now_playing_file(new_data)
                if changed:
                    notify_subscribers(new_data)

        except Exception:
            pass

        time.sleep(0.5)

def notify_subscribers(data):
    with subscribers_lock:
        dead = []
        payload = f"data: {json.dumps(data)}\n\n".encode('utf-8')
        for q in subscribers:
            try:
                q.put_nowait(payload)
            except Exception:
                dead.append(q)
        for d in dead:
            subscribers.remove(d)

class OverlayRequestHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=BASE_DIR, **kwargs)

    def log_message(self, format, *args):
        return

    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)

        # Redirect root and /music to /music/index.html
        if parsed.path in ('/', '/music', '/music/'):
            self.path = '/music/index.html'
            if parsed.query:
                self.path += '?' + parsed.query
            return super().do_GET()

        if parsed.path in ('/chat', '/chat/'):
            self.path = '/chat/index.html'
            if parsed.query:
                self.path += '?' + parsed.query
            return super().do_GET()

        if parsed.path in ('/ticker', '/ticker/'):
            self.path = '/ticker/index.html'
            if parsed.query:
                self.path += '?' + parsed.query
            return super().do_GET()

        if parsed.path in ('/cam', '/cam/'):
            self.path = '/cam/index.html'
            if parsed.query:
                self.path += '?' + parsed.query
            return super().do_GET()

        if parsed.path == '/deck':
            self.send_response(301)
            loc = '/deck/'
            if parsed.query:
                loc += '?' + parsed.query
            self.send_header('Location', loc)
            self.end_headers()
            return

        if parsed.path == '/deck/':
            self.path = '/deck/index.html'
            if parsed.query:
                self.path += '?' + parsed.query
            return super().do_GET()

        if parsed.path == '/api/song-text':
            with data_lock:
                if latest_data["status"] == "Playing" and latest_data["title"]:
                    if latest_data["artist"]:
                        resp_text = f"Now playing: {latest_data['artist']} - {latest_data['title']}"
                    else:
                        resp_text = f"Now playing: {latest_data['title']}"
                else:
                    resp_text = "No music playing right now."
            payload = resp_text.encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'text/plain; charset=utf-8')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(payload)
            return

        if parsed.path == '/api/clip':
            import subprocess
            try:
                subprocess.run(['gsr-ui-cli', 'replay-save'], check=True, timeout=3)
                self.send_response(200)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(b'{"success": true, "message": "Replay saved"}')
            except Exception as e:
                self.send_response(500)
                self.send_header('Content-Type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({"success": false, "error": str(e)}).encode('utf-8'))
            return

        if parsed.path == '/api/sink':
            import subprocess
            query = urllib.parse.parse_qs(parsed.query)
            act = query.get('action', [None])[0]
            if act == 'toggle':
                subprocess.run(['/home/bry/.local/bin/audio-launcher-control', 'toggle-sink'], check=False)
            elif act in ('fiio', 'speaker'):
                subprocess.run(['/home/bry/.local/bin/audio-launcher-control', act], check=False)
            try:
                res = subprocess.check_output(['/home/bry/.local/bin/audio-launcher-control', 'status'], text=True).strip()
            except Exception:
                res = '{"current_sink":"unknown"}'
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(res.encode('utf-8'))
            return

        if parsed.path == '/api/media':
            query = urllib.parse.parse_qs(parsed.query)
            action = query.get('action', ['playpause'])[0].lower()
            ok, msg = control_mpris_player(action)
            self.send_response(200 if ok else 400)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps({"success": ok, "message": msg}).encode('utf-8'))
            return

        if parsed.path == '/api/theme':
            theme_file = os.path.join(BASE_DIR, 'theme.json')
            query = urllib.parse.parse_qs(parsed.query)
            set_theme = query.get('set', [None])[0]
            if set_theme:
                try:
                    with open(theme_file, 'w') as tf:
                        json.dump({'theme': set_theme}, tf)
                except Exception:
                    pass
            theme_data = {'theme': 'matcha'}
            if os.path.exists(theme_file):
                try:
                    with open(theme_file, 'r') as tf:
                        theme_data = json.load(tf)
                except Exception:
                    pass
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(json.dumps(theme_data).encode('utf-8'))
            return

        if parsed.path == '/api/now-playing':
            with data_lock:
                payload = json.dumps(latest_data).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(payload)
            return

        elif parsed.path == '/api/stream':
            import queue
            q = queue.Queue(maxsize=50)
            with subscribers_lock:
                subscribers.append(q)

            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream')
            self.send_header('Connection', 'keep-alive')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()

            with data_lock:
                initial = f"data: {json.dumps(latest_data)}\n\n".encode('utf-8')
            try:
                self.wfile.write(initial)
                self.wfile.flush()
                while True:
                    payload = q.get()
                    self.wfile.write(payload)
                    self.wfile.flush()
            except Exception:
                pass
            finally:
                with subscribers_lock:
                    if q in subscribers:
                        subscribers.remove(q)
            return

        elif parsed.path == '/api/art':
            query = urllib.parse.parse_qs(parsed.query)
            art_url = query.get('url', [''])[0]
            if art_url.startswith('file://'):
                file_path = urllib.parse.unquote(art_url[7:])
                if os.path.exists(file_path):
                    try:
                        with open(file_path, 'rb') as f:
                            content = f.read()
                        mime = 'image/jpeg'
                        if content.startswith(b'\x89PNG'):
                            mime = 'image/png'
                        elif content.startswith(b'RIFF') and content[8:12] == b'WEBP':
                            mime = 'image/webp'
                        self.send_response(200)
                        self.send_header('Content-Type', mime)
                        self.send_header('Access-Control-Allow-Origin', '*')
                        self.end_headers()
                        self.wfile.write(content)
                        return
                    except Exception:
                        pass
            elif art_url.startswith(('http://', 'https://')):
                try:
                    req = urllib.request.Request(art_url, headers={'User-Agent': 'Mozilla/5.0'})
                    with urllib.request.urlopen(req, timeout=3) as resp:
                        content = resp.read()
                        mime = resp.headers.get('Content-Type', 'image/jpeg')
                        self.send_response(200)
                        self.send_header('Content-Type', mime)
                        self.send_header('Access-Control-Allow-Origin', '*')
                        self.end_headers()
                        self.wfile.write(content)
                        return
                except Exception:
                    pass

            self.send_response(404)
            self.end_headers()
            return

        super().do_GET()

def main():
    t = threading.Thread(target=poll_mpris, daemon=True)
    t.start()
    server = ThreadingHTTPServer(('0.0.0.0', PORT), OverlayRequestHandler)
    server.daemon_threads = True
    print(f"OBS Unified Overlays Server running on http://127.0.0.1:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass

if __name__ == '__main__':
    main()
