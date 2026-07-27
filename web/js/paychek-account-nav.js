'use strict';

/**
 * Auth unique Paychek sur les pages marketing :
 * - déconnecté : Connexion / Inscription
 * - connecté : Mon compte → Journal / Licence / Facturation / Déconnexion
 */
(function (global) {
  var FIREBASE_CONFIG = {
    apiKey: 'AIzaSyB_hs_XTxovKaTPz4SQ8cYGSlGmjue3JqY',
    authDomain: 'paychek-trading.firebaseapp.com',
    projectId: 'paychek-trading',
    storageBucket: 'paychek-trading.firebasestorage.app',
    messagingSenderId: '738203717325',
    appId: '1:738203717325:web:28a7a4da987d1caa36e384',
  };

  var STRINGS = {
    en: {
      account: 'My account',
      journal: 'Open trading journal',
      license: 'License',
      billing: 'Billing',
      logout: 'Log out',
      login: 'Log in',
      signup: 'Sign up',
    },
    fr: {
      account: 'Mon compte',
      journal: 'Accéder journal de trading',
      license: 'Licence',
      billing: 'Facturation',
      logout: 'Déconnexion',
      login: 'Connexion',
      signup: "S'inscrire",
    },
    de: {
      account: 'Mein Konto',
      journal: 'Trading-Journal öffnen',
      license: 'Lizenz',
      billing: 'Abrechnung',
      logout: 'Abmelden',
      login: 'Anmelden',
      signup: 'Registrieren',
    },
    es: {
      account: 'Mi cuenta',
      journal: 'Abrir diario de trading',
      license: 'Licencia',
      billing: 'Facturación',
      logout: 'Cerrar sesión',
      login: 'Iniciar sesión',
      signup: 'Registrarse',
    },
    pt: {
      account: 'Minha conta',
      journal: 'Abrir diário de trading',
      license: 'Licença',
      billing: 'Faturação',
      logout: 'Terminar sessão',
      login: 'Entrar',
      signup: 'Criar conta',
    },
    ko: {
      account: '내 계정',
      journal: '트레이딩 저널 열기',
      license: '라이선스',
      billing: '결제',
      logout: '로그아웃',
      login: '로그인',
      signup: '가입하기',
    },
  };

  function locale() {
    try {
      var stored = localStorage.getItem('paychek_landing_lang');
      if (stored) return String(stored).slice(0, 2).toLowerCase();
    } catch (_e) {}
    return (navigator.language || 'en').slice(0, 2).toLowerCase();
  }

  function t() {
    return STRINGS[locale()] || STRINGS.en;
  }

  function originBase() {
    return global.location.origin || '';
  }

  function ensureMenuDom() {
    var host = document.getElementById('paychek-account-nav');
    if (!host) return null;
    if (host.querySelector('[data-paychek-account-root]')) return host;

    host.innerHTML =
      '<div data-paychek-account-root class="paychek-account-root">' +
      '<div data-paychek-auth-guest class="paychek-account-guest">' +
      '<button type="button" class="paychek-account-login" data-paychek-auth-open="login" data-paychek-i18n="login">Log in</button>' +
      '<button type="button" class="paychek-nav-signup paychek-account-signup" data-paychek-auth-open="signup" data-paychek-i18n="signup">Sign up</button>' +
      '</div>' +
      '<div data-paychek-auth-user class="paychek-account-user" hidden>' +
      '<button type="button" class="paychek-account-trigger" data-paychek-account-trigger aria-haspopup="true" aria-expanded="false">' +
      '<span data-paychek-account-label>My account</span>' +
      '<i class="fas fa-chevron-down text-[8px] opacity-50" aria-hidden="true"></i>' +
      '</button>' +
      '<div class="paychek-account-menu" data-paychek-account-menu hidden role="menu">' +
      '<a href="/?app=1" target="_top" role="menuitem" data-paychek-action="journal">Open trading journal</a>' +
      '<a href="/licence.html" target="_top" role="menuitem" data-paychek-action="license">License</a>' +
      '<a href="/facturation.html" target="_top" role="menuitem" data-paychek-action="billing">Billing</a>' +
      '<button type="button" role="menuitem" data-paychek-action="logout">Log out</button>' +
      '</div></div></div>';
    return host;
  }

  function applyLabels(host) {
    var s = t();
    var label = host.querySelector('[data-paychek-account-label]');
    if (label) label.textContent = s.account;
    var map = {
      journal: s.journal,
      license: s.license,
      billing: s.billing,
      logout: s.logout,
    };
    Object.keys(map).forEach(function (key) {
      var el = host.querySelector('[data-paychek-action="' + key + '"]');
      if (el) el.textContent = map[key];
    });
    var loginBtn = host.querySelector('[data-paychek-auth-open="login"]');
    var signupBtn = host.querySelector('[data-paychek-auth-open="signup"]');
    if (loginBtn) loginBtn.textContent = s.login;
    if (signupBtn) signupBtn.textContent = s.signup;
  }

  function openSiteAuth(mode) {
    if (typeof global.paychekOpenSiteAuth === 'function') {
      global.paychekOpenSiteAuth(mode);
      return;
    }
    if (typeof global.paychekNotifyParentAuth === 'function') {
      global.paychekNotifyParentAuth(mode);
    }
  }

  function setLoggedIn(host, loggedIn, displayName) {
    var guest = host.querySelector('[data-paychek-auth-guest]');
    var user = host.querySelector('[data-paychek-auth-user]');
    if (guest) {
      if (loggedIn) guest.setAttribute('hidden', '');
      else guest.removeAttribute('hidden');
    }
    if (user) {
      if (loggedIn) user.removeAttribute('hidden');
      else user.setAttribute('hidden', '');
    }
    var label = host.querySelector('[data-paychek-account-label]');
    var s = t();
    if (label) {
      label.textContent = loggedIn
        ? (displayName || s.account)
        : s.account;
    }
  }

  function closeMenu(host) {
    var menu = host.querySelector('[data-paychek-account-menu]');
    var btn = host.querySelector('[data-paychek-account-trigger]');
    if (menu) menu.hidden = true;
    if (btn) btn.setAttribute('aria-expanded', 'false');
  }

  function toggleMenu(host) {
    var menu = host.querySelector('[data-paychek-account-menu]');
    var btn = host.querySelector('[data-paychek-account-trigger]');
    if (!menu || !btn) return;
    var open = menu.hidden;
    menu.hidden = !open;
    btn.setAttribute('aria-expanded', open ? 'true' : 'false');
  }

  function wireUi(host, auth) {
    applyLabels(host);
    var trigger = host.querySelector('[data-paychek-account-trigger]');
    if (trigger) {
      trigger.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        toggleMenu(host);
      });
    }
    document.addEventListener('click', function () {
      closeMenu(host);
    });
    host.querySelectorAll('[data-paychek-auth-open]').forEach(function (btn) {
      btn.addEventListener('click', function (e) {
        e.preventDefault();
        e.stopPropagation();
        openSiteAuth(btn.getAttribute('data-paychek-auth-open') || 'login');
      });
    });
    var logoutBtn = host.querySelector('[data-paychek-action="logout"]');
    if (logoutBtn) {
      logoutBtn.addEventListener('click', function (e) {
        e.preventDefault();
        closeMenu(host);
        auth.signOut().catch(function () {});
      });
    }
  }

  function bootWithCompat() {
    if (!global.firebase || !global.firebase.initializeApp) {
      console.warn('[paychek] Firebase SDK missing for account nav');
      return;
    }
    var app;
    try {
      app = global.firebase.app();
    } catch (_e) {
      app = global.firebase.initializeApp(FIREBASE_CONFIG);
    }
    var auth = global.firebase.auth(app);
    var host = ensureMenuDom();
    if (!host) return;
    wireUi(host, auth);
    auth.onAuthStateChanged(function (user) {
      var name = '';
      if (user) {
        name = (user.displayName || user.email || '').trim();
        if (name.indexOf('@') > 0) name = name.split('@')[0];
        if (name.length > 18) name = name.slice(0, 16) + '…';
      }
      setLoggedIn(host, !!user, name);
      applyLabels(host);
      if (!user) closeMenu(host);
    });
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.async = true;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  function init() {
    if (!document.getElementById('paychek-account-nav')) return;
    var chain = Promise.resolve();
    if (!global.firebase) {
      chain = loadScript('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js').then(
        function () {
          return loadScript(
            'https://www.gstatic.com/firebasejs/10.14.1/firebase-auth-compat.js',
          );
        },
      );
    }
    chain.then(bootWithCompat).catch(function (err) {
      console.warn('[paychek] account nav init failed', err);
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }

  global.paychekRefreshAccountNavLabels = function () {
    var host = document.getElementById('paychek-account-nav');
    if (host) applyLabels(host);
  };
})(window);
