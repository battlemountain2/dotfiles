(function() {
  const params = new URLSearchParams(window.location.search);
  const channel = (params.get('channel') || '').toLowerCase().trim();
  const theme = params.get('theme') || 'matcha';
  const fadeSeconds = parseInt(params.get('fade') || '18', 10);
  const maxMessages = parseInt(params.get('max') || '10', 10);
  const isDemo = params.get('demo') === 'true';

  function applyTheme(t) {
    if (!t) return;
    document.body.className = '';
    if (t !== 'matcha') {
      document.body.classList.add('theme-' + t);
    }
  }

  if (theme) {
    applyTheme(theme);
  }

  function pollTheme() {
    if (!params.get('theme')) {
      fetch('/api/theme')
        .then(res => res.json())
        .then(data => {
          if (data && data.theme) {
            applyTheme(data.theme);
          }
        })
        .catch(() => {});
    }
    setTimeout(pollTheme, 3000);
  }
  pollTheme();

  const container = document.getElementById('chat-container');

  function addMessage({ username, color, badges, text }) {
    const pill = document.createElement('div');
    pill.className = 'chat-pill';

    // Timestamp
    const timeEl = document.createElement('span');
    timeEl.className = 'time';
    const now = new Date();
    timeEl.textContent = now.toTimeString().slice(0, 5);
    pill.appendChild(timeEl);

    // Add Badges
    if (badges && badges.length > 0) {
      badges.forEach(b => {
        const badgeEl = document.createElement('span');
        badgeEl.className = `badge ${b.toLowerCase()}`;
        badgeEl.textContent = b;
        pill.appendChild(badgeEl);
      });
    }

    // Username
    const userEl = document.createElement('span');
    userEl.className = 'username';
    userEl.textContent = username;
    if (color) {
      userEl.style.color = color;
    }
    pill.appendChild(userEl);

    // Text
    const textEl = document.createElement('span');
    textEl.className = 'message-text';
    textEl.textContent = text;
    pill.appendChild(textEl);

    container.appendChild(pill);

    // Keep message count within max
    while (container.children.length > maxMessages) {
      container.removeChild(container.firstChild);
    }

    // Auto fade-out
    if (fadeSeconds > 0) {
      setTimeout(() => {
        pill.classList.add('fade-out');
        setTimeout(() => {
          if (pill.parentNode === container) {
            container.removeChild(pill);
          }
        }, 700);
      }, fadeSeconds * 1000);
    }
  }

  if (isDemo) {
    // Simulated demo messages for instant testing in OBS
    const demoUsers = [
      { username: 'cachy_dev', color: '#a3be8c', badges: ['MOD'], text: 'OBS setup is looking clean!' },
      { username: 'hypr_fanatic', color: '#7dcfff', badges: ['VIP'], text: 'JetBrains Mono on stream is so aesthetic.' },
      { username: 'audio_geek', color: '#cba6f7', badges: ['SUB'], text: 'PipeWire audio capture is unmatched.' },
      { username: 'streamer', color: '#ff6b6b', badges: ['BROADCASTER'], text: 'Welcome in everyone! Testing the new rice overlay.' }
    ];
    let idx = 0;
    setInterval(() => {
      addMessage(demoUsers[idx % demoUsers.length]);
      idx++;
    }, 3500);
    return;
  }

  if (!channel) {
    addMessage({
      username: 'SYSTEM',
      color: '#ff6b6b',
      badges: ['SETUP'],
      text: 'Add ?channel=your_twitch_username to the Browser Source URL!'
    });
    return;
  }

  // Connect to Twitch IRC via standard WebSocket
  let ws = null;
  function connect() {
    ws = new WebSocket('wss://irc-ws.chat.twitch.tv:443');

    ws.onopen = () => {
      ws.send('CAP REQ :twitch.tv/tags twitch.tv/commands');
      ws.send('PASS oauth:SCHMOOPIIE');
      ws.send(`NICK justinfan${Math.floor(Math.random() * 80000 + 1000)}`);
      ws.send(`JOIN #${channel}`);
    };

    ws.onmessage = (event) => {
      const line = event.data.trim();
      if (line.startsWith('PING')) {
        ws.send('PONG :tmi.twitch.tv');
        return;
      }

      if (line.includes('PRIVMSG')) {
        parseTwitchMessage(line);
      }
    };

    ws.onclose = () => {
      setTimeout(connect, 3000);
    };

    ws.onerror = () => {
      ws.close();
    };
  }

  function parseTwitchMessage(raw) {
    try {
      const parts = raw.split(' :');
      const text = parts.slice(2).join(' :');
      const header = parts[0];
      const tagsPart = header.startsWith('@') ? header.slice(1).split(' ')[0] : '';
      
      const tags = {};
      tagsPart.split(';').forEach(tag => {
        const [k, v] = tag.split('=');
        tags[k] = v;
      });

      const userMatch = raw.match(/:([^!]+)!/);
      const username = tags['display-name'] || (userMatch ? userMatch[1] : 'Anonymous');
      const color = tags['color'] || null;

      const badges = [];
      if (tags['badges']) {
        const bList = tags['badges'].split(',');
        bList.forEach(b => {
          const type = b.split('/')[0].toUpperCase();
          if (['BROADCASTER', 'MODERATOR', 'VIP', 'SUBSCRIBER', 'PRIME'].includes(type)) {
            badges.push(type === 'MODERATOR' ? 'MOD' : (type === 'SUBSCRIBER' ? 'SUB' : type));
          }
        });
      }

      addMessage({ username, color, badges, text });
    } catch (e) {
      console.error('Error parsing IRC line:', e);
    }
  }

  connect();
})();
