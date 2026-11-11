(function() {
  const params = new URLSearchParams(window.location.search);
  const theme = params.get('theme');

  function applyTheme(t) {
    if (!t) return;
    document.body.className = '';
    if (t !== 'matcha') {
      document.body.classList.add('theme-' + t);
    }
  }

  if (theme) {
    applyTheme(theme);
  } else {
    // Dynamic theme polling
    function pollTheme() {
      fetch('/api/theme')
        .then(res => res.json())
        .then(data => {
          if (data && data.theme) applyTheme(data.theme);
        })
        .catch(() => {});
      setTimeout(pollTheme, 3000);
    }
    pollTheme();
  }

  // Allow custom initial values via URL or defaults
  const follower = params.get('follower');
  const sub = params.get('sub');
  const goal = params.get('goal');

  if (follower) document.getElementById('val-follower').textContent = follower;
  if (sub) document.getElementById('val-sub').textContent = sub;
  if (goal) {
    document.getElementById('val-goal').textContent = goal;
  } else {
    document.getElementById('goal-divider').style.display = 'none';
    document.getElementById('goal-item').style.display = 'none';
  }
})();
