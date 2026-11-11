#!/usr/bin/env python3
"""
OBS Music Overlay Server
Reads MPRIS player data (Spotify, Cider, Firefox, etc.) via D-Bus
Serves minimal JetBrains Mono overlay on http://localhost:9860
"""

import os
import sys
import json
import time
import urllib.parse
import urllib.request
import threading
from http.server import HTTPServer, SimpleHTTPRequestHandler
import dbus

PORT = 9860
OVERLAY_DIR = os.path.dirname(os.path.abspath(__file__))

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

def get_active_mpris_player():
    try:
        bus = dbus.SessionBus()
        player_names = [s for s in bus.list_names() if s.startswith('org.mpris.MediaPlayer2')]
        if not player_names:
            return None, None, None

        # Priority: Playing players first, then Spotify/Cider, then others
        best_player = None
        best_name = None

        for name in player_names:
            try:
                obj = bus.get_object(name, '/org/mpris/MediaPlayer2')
                props = dbus.Interface(obj, 'org.freedesktop.DBus.Properties')
                status = str(props.Get('org.mpris.MediaPlayer2.Player', 'PlaybackStatus'))
                if status == 'Playing':
                    return name, obj, props
                if best_player is None or ('spotify' in name.lower() or 'cider' in name.lower()):
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

            player_clean = name.replace('org.mpris.MediaPlayer2.', '').split('.')[0].capitalize()

            new_data = {
                "status": status,
                "title": title,
                "artist": artist,
                "album": album,
                "art_url": art_url,
                "position_sec": pos_sec,
                "length_sec": length_sec,
                "progress_percent": progress,
                "player": player_clean,
                "updated_at": time.time()
            }

            with data_lock:
                changed = (
                    latest_data["title"] != new_data["title"] or
                    latest_data["status"] != new_data["status"] or
                    latest_data["artist"] != new_data["artist"] or
                    abs(latest_data.get("position_sec", 0) - new_data["position_sec"]) >= 1
                )
                latest_data = new_data
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
        super().__init__(*args, directory=OVERLAY_DIR, **kwargs)

    def log_message(self, format, *args):
        return

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == '/api/now-playing':
            with data_lock:
                payload = json.dumps(latest_data).encode('utf-8')
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.send_header('Cache-Control', 'no-cache')
            self.end_headers()
            self.wfile.write(payload)
            return

        elif parsed.path == '/api/stream':
            import queue
            q = queue.Queue()
            with subscribers_lock:
                subscribers.append(q)

            self.send_response(200)
            self.send_header('Content-Type', 'text/event-stream')
            self.send_header('Cache-Control', 'no-cache')
            self.send_header('Connection', 'keep-alive')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()

            with data_lock:
                initial = f"data: {json.dumps(latest_data)}\n\n".encode('utf-8')
            self.wfile.write(initial)
            self.wfile.flush()

            try:
                while True:
                    payload = q.get()
                    self.wfile.write(payload)
                    self.wfile.flush()
            except (BrokenPipeError, ConnectionResetError):
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
                    ext = os.path.splitext(file_path)[1].lower()
                    mime = 'image/png' if ext == '.png' else 'image/jpeg'
                    try:
                        with open(file_path, 'rb') as f:
                            content = f.read()
                        self.send_response(200)
                        self.send_header('Content-Type', mime)
                        self.send_header('Access-Control-Allow-Origin', '*')
                        self.send_header('Cache-Control', 'public, max-age=3600')
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
    chmod_x = os.chmod('/home/bry/.config/obs-overlays/music/server.py', 0o755)
    server = HTTPServer(('127.0.0.1', PORT), OverlayRequestHandler)
    print(f"OBS Music Overlay running on http://127.0.0.1:{PORT}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass

if __name__ == '__main__':
    main()
