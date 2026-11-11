#!/usr/bin/env python3
"""Suppress Noctalia popups while a competitive game owns fullscreen focus."""
import json, os, signal, subprocess, time, tomllib
from pathlib import Path
GAMES = {'cs2','deadlock','dota2','steam_app_730','steam_app_1422450','steam_app_2767030','steam_app_2356550','steam_app_105600'}
STATE = Path('/home/bry/.local/state/game-quiet-mode.json')
running = True

def command(*args):
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL, timeout=4).strip()

def msg(*args):
    return command('noctalia', 'msg', *args)

def restore():
    if not STATE.exists(): return
    saved = json.loads(STATE.read_text())
    msg('notification-dnd-set', saved['dnd'])
    msg('osd-enable' if saved['osd'] else 'osd-disable')
    STATE.unlink()
    print('Restored notification and OSD preferences', flush=True)

def enter():
    config = tomllib.loads(command('noctalia','config','export','full'))
    saved = {'dnd':msg('notification-dnd-status'), 'osd':config['osd']['enabled']}
    if saved['dnd'] not in ('on','off'): raise ValueError('Unexpected DND state')
    STATE.write_text(json.dumps(saved))
    msg('osd-disable')
    msg('notification-dnd-set','on')
    msg('notification-clear-active')
    print('Gaming quiet mode enabled', flush=True)

def stop(*_):
    global running
    running = False

signal.signal(signal.SIGTERM,stop)
signal.signal(signal.SIGINT,stop)
try:
    restore()
    while running:
        try:
            window=json.loads(command('hyprctl','activewindow','-j'))
            quiet=window.get('class','').lower() in GAMES and window.get('fullscreen') == 2
            if quiet and not STATE.exists(): enter()
            elif not quiet and STATE.exists(): restore()
        except (subprocess.SubprocessError, ValueError, OSError) as exc:
            print(f'Waiting for desktop services: {exc}', flush=True)
        time.sleep(0.3)
finally:
    try: restore()
    except Exception as exc: print(f'Restore pending in {STATE}: {exc}',flush=True)
