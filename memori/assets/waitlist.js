// memori — waitlist + small shared helpers.
//
// Set WAITLIST_ENDPOINT to a Google Apps Script web app URL (see
// docs/memori-v2/waitlist-setup.md). Until it is set, the form refuses to
// submit instead of silently dropping sign-ups.
const WAITLIST_ENDPOINT = '';

function utmParams() {
  const params = new URLSearchParams(location.search);
  const out = {};
  ['utm_source', 'utm_medium', 'utm_campaign', 'utm_content'].forEach((k) => {
    if (params.get(k)) out[k] = params.get(k);
  });
  return out;
}

function initWaitlist(form) {
  const status = form.querySelector('.form-status');
  const button = form.querySelector('button[type="submit"]');

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    status.className = 'form-status';

    const email = form.email.value.trim();
    if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      status.textContent = '이메일 주소를 다시 확인해주세요.';
      status.classList.add('err');
      return;
    }

    if (!WAITLIST_ENDPOINT) {
      status.textContent = '대기자 명단이 아직 연결되지 않았습니다. 잠시 후 다시 시도해주세요.';
      status.classList.add('err');
      console.warn('memori: WAITLIST_ENDPOINT is not configured.');
      return;
    }

    const data = new FormData(form);
    // Multi-select chips arrive as repeated keys; flatten them for the sheet.
    const flat = new URLSearchParams();
    for (const key of new Set(data.keys())) {
      flat.set(key, data.getAll(key).join(', '));
    }
    Object.entries(utmParams()).forEach(([k, v]) => flat.set(k, v));
    flat.set('referrer', document.referrer || '');
    flat.set('submitted_at', new Date().toISOString());

    button.disabled = true;
    try {
      // Apps Script does not return CORS headers, so the response is opaque.
      await fetch(WAITLIST_ENDPOINT, { method: 'POST', mode: 'no-cors', body: flat });
      form.reset();
      status.textContent = '명단에 올렸습니다. 첫 번째 소식은 출시 전에 보내드릴게요.';
      status.classList.add('ok');
    } catch (err) {
      status.textContent = '전송에 실패했습니다. 네트워크를 확인하고 다시 시도해주세요.';
      status.classList.add('err');
    } finally {
      button.disabled = false;
    }
  });
}

function initReveal() {
  const els = document.querySelectorAll('.reveal');
  if (!('IntersectionObserver' in window)) {
    els.forEach((el) => el.classList.add('in'));
    return;
  }
  const io = new IntersectionObserver((entries) => {
    entries.forEach((entry) => {
      if (entry.isIntersecting) {
        entry.target.classList.add('in');
        io.unobserve(entry.target);
      }
    });
  }, { threshold: 0.12 });
  els.forEach((el) => io.observe(el));
}

function cssVar(name) {
  return getComputedStyle(document.documentElement).getPropertyValue(name).trim();
}

document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('form.waitlist').forEach(initWaitlist);
  initReveal();
});
