(function() {
  const urlParams = new URLSearchParams(window.location.search);
  let currentTheme = urlParams.get('theme') || '';
  const autoHide = urlParams.get('autohide') !== 'false';

  function applyTheme(themeName) {
    if (!themeName) return;
    document.body.className = '';
    if (themeName !== 'matcha') {
      document.body.classList.add(`theme-${themeName}`);
    }
  }

  if (currentTheme) {
    applyTheme(currentTheme);
  }

  const widget = document.getElementById('widget');
  const albumArt = document.getElementById('album-art');
  const timeDisplay = document.getElementById('time-display');
  const trackTitle = document.getElementById('track-title');
  const trackArtist = document.getElementById('track-artist');
  const progressFill = document.getElementById('progress-fill');
  const titleWrapper = document.getElementById('title-wrapper');
  const eqBars = document.getElementById('eq-bars');

  let currentTitle = '';
  let currentArtUrl = '';
  let pauseTimer = null;

  function formatTime(seconds) {
    if (!seconds || isNaN(seconds) || seconds < 0) return '0:00';
    const m = Math.floor(seconds / 60);
    const s = Math.floor(seconds % 60);
    return `${m}:${s < 10 ? '0' : ''}${s}`;
  }

  function updateUI(data) {
    if (!data) return;

    if (data.status === 'Stopped' || !data.title) {
      if (autoHide) {
        widget.classList.add('hidden');
      } else {
        widget.classList.remove('hidden');
        trackTitle.textContent = 'No music playing';
        trackArtist.textContent = '—';
        timeDisplay.textContent = '0:00 / 0:00';
        progressFill.style.width = '0%';
        albumArt.classList.remove('loaded');
      }
      if (eqBars) eqBars.classList.add('paused');
      return;
    }

    const isPlaying = data.status === 'Playing';
    if (eqBars) {
      eqBars.classList.toggle('paused', !isPlaying);
    }
    
    if (!isPlaying && autoHide) {
      if (!pauseTimer) {
        pauseTimer = setTimeout(() => {
          widget.classList.add('hidden');
        }, 10000);
      }
    } else {
      if (pauseTimer) {
        clearTimeout(pauseTimer);
        pauseTimer = null;
      }
      widget.classList.remove('hidden');
    }

    // Title & Marquee
    if (data.title !== currentTitle) {
      currentTitle = data.title;
      trackTitle.textContent = data.title;
      trackTitle.classList.remove('scrolling');
      void trackTitle.offsetWidth;
      if (trackTitle.scrollWidth > titleWrapper.clientWidth) {
        trackTitle.classList.add('scrolling');
      }
    }

    trackArtist.textContent = data.artist || (data.album ? data.album : 'Unknown Artist');

    // Progress & Time
    const curTime = formatTime(data.position_sec);
    const totalTime = formatTime(data.length_sec);
    timeDisplay.textContent = `${curTime} / ${totalTime}`;
    progressFill.style.width = `${Math.min(100, Math.max(0, data.progress_percent))}%`;

    // Album Art
    if (data.art_url && data.art_url !== currentArtUrl) {
      currentArtUrl = data.art_url;
      const proxyUrl = `/api/art?url=${encodeURIComponent(data.art_url)}`;
      albumArt.onload = () => albumArt.classList.add('loaded');
      albumArt.onerror = () => albumArt.classList.remove('loaded');
      albumArt.src = proxyUrl;
    } else if (!data.art_url) {
      currentArtUrl = '';
      albumArt.classList.remove('loaded');
    }
  }

  // Poll now-playing
  function poll() {
    fetch('/api/now-playing')
      .then(res => {
        if (!res.ok) throw new Error('HTTP ' + res.status);
        return res.json();
      })
      .then(data => {
        updateUI(data);
        setTimeout(poll, 800);
      })
      .catch(() => {
        setTimeout(poll, 2000);
      });
  }

  // Poll global theme (syncs with theme.json)
  function pollTheme() {
    if (!urlParams.get('theme')) {
      fetch('/api/theme')
        .then(res => res.json())
        .then(data => {
          if (data && data.theme && data.theme !== currentTheme) {
            currentTheme = data.theme;
            applyTheme(currentTheme);
          }
        })
        .catch(() => {});
    }
    setTimeout(pollTheme, 3000);
  }

  poll();
  pollTheme();
})();
