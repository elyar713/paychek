'use strict';

/**
 * Auth HTML marketing Paychek (Firebase compat) — sans boot Flutter.
 * Connexion / inscription restent sur la page courante ; le journal
 * s’ouvre via /?app=1 (menu Mon compte).
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
      loginTitle: 'Log in',
      signupTitle: 'Sign up',
      emailPh: 'Email',
      passwordPh: 'Password',
      fullNamePh: 'Full name',
      loginSubmit: 'Enter',
      signupSubmit: 'Create account',
      or: 'or',
      google: 'Continue with Google',
      apple: 'Continue with Apple',
      switchToSignupLabel: "Don't have an account?",
      switchToSignup: 'Sign up',
      switchToLoginLabel: 'Already have an account?',
      switchToLogin: 'Log in',
      trialNote: 'Your 7-day trial activates automatically',
      forgot: 'Forgot password?',
      resetSent: 'Password reset email sent.',
      closeAria: 'Close',
      busy: 'Please wait…',
      errGeneric: 'Something went wrong. Please try again.',
      errEmail: 'Enter a valid email.',
      errPassword: 'Password must be at least 6 characters.',
      errName: 'Enter your name.',
      errPopup: 'Popup blocked. Allow popups for this site.',
      errCancelled: 'Sign-in cancelled.',
    },
    fr: {
      loginTitle: 'Connexion',
      signupTitle: 'Inscription',
      emailPh: 'E-mail',
      passwordPh: 'Mot de passe',
      fullNamePh: 'Nom complet',
      loginSubmit: 'Entrer',
      signupSubmit: 'Créer mon compte',
      or: 'ou',
      google: 'Continuer avec Google',
      apple: 'Continuer avec Apple',
      switchToSignupLabel: 'Pas encore de compte ?',
      switchToSignup: "S'inscrire",
      switchToLoginLabel: 'Déjà un compte ?',
      switchToLogin: 'Connexion',
      trialNote: 'Votre essai de 7 jours sera activé automatiquement',
      forgot: 'Mot de passe oublié ?',
      resetSent: 'E-mail de réinitialisation envoyé.',
      closeAria: 'Fermer',
      busy: 'Patientez…',
      errGeneric: 'Une erreur est survenue. Réessayez.',
      errEmail: 'Saisissez un e-mail valide.',
      errPassword: 'Le mot de passe doit contenir au moins 6 caractères.',
      errName: 'Saisissez votre nom.',
      errPopup: 'Fenêtre bloquée. Autorisez les popups pour ce site.',
      errCancelled: 'Connexion annulée.',
    },
    de: {
      loginTitle: 'Anmelden',
      signupTitle: 'Registrieren',
      emailPh: 'E-Mail',
      passwordPh: 'Passwort',
      fullNamePh: 'Vollständiger Name',
      loginSubmit: 'Weiter',
      signupSubmit: 'Konto erstellen',
      or: 'oder',
      google: 'Mit Google fortfahren',
      apple: 'Mit Apple fortfahren',
      switchToSignupLabel: 'Noch kein Konto?',
      switchToSignup: 'Registrieren',
      switchToLoginLabel: 'Bereits ein Konto?',
      switchToLogin: 'Anmelden',
      trialNote: 'Ihre 7-Tage-Testphase wird automatisch aktiviert',
      forgot: 'Passwort vergessen?',
      resetSent: 'E-Mail zum Zurücksetzen gesendet.',
      closeAria: 'Schließen',
      busy: 'Bitte warten…',
      errGeneric: 'Etwas ist schiefgelaufen. Bitte erneut versuchen.',
      errEmail: 'Gültige E-Mail eingeben.',
      errPassword: 'Passwort mindestens 6 Zeichen.',
      errName: 'Namen eingeben.',
      errPopup: 'Popup blockiert. Popups für diese Seite erlauben.',
      errCancelled: 'Anmeldung abgebrochen.',
    },
    es: {
      loginTitle: 'Iniciar sesión',
      signupTitle: 'Registrarse',
      emailPh: 'Correo',
      passwordPh: 'Contraseña',
      fullNamePh: 'Nombre completo',
      loginSubmit: 'Entrar',
      signupSubmit: 'Crear cuenta',
      or: 'o',
      google: 'Continuar con Google',
      apple: 'Continuar con Apple',
      switchToSignupLabel: '¿No tienes cuenta?',
      switchToSignup: 'Regístrate',
      switchToLoginLabel: '¿Ya tienes cuenta?',
      switchToLogin: 'Inicia sesión',
      trialNote: 'Tu prueba de 7 días se activa automáticamente',
      forgot: '¿Olvidaste la contraseña?',
      resetSent: 'Correo de restablecimiento enviado.',
      closeAria: 'Cerrar',
      busy: 'Espera…',
      errGeneric: 'Algo salió mal. Inténtalo de nuevo.',
      errEmail: 'Introduce un correo válido.',
      errPassword: 'La contraseña debe tener al menos 6 caracteres.',
      errName: 'Introduce tu nombre.',
      errPopup: 'Ventana bloqueada. Permite ventanas emergentes.',
      errCancelled: 'Inicio de sesión cancelado.',
    },
    pt: {
      loginTitle: 'Entrar',
      signupTitle: 'Criar conta',
      emailPh: 'E-mail',
      passwordPh: 'Palavra-passe',
      fullNamePh: 'Nome completo',
      loginSubmit: 'Entrar',
      signupSubmit: 'Criar conta',
      or: 'ou',
      google: 'Continuar com Google',
      apple: 'Continuar com Apple',
      switchToSignupLabel: 'Ainda não tem conta?',
      switchToSignup: 'Criar conta',
      switchToLoginLabel: 'Já tem conta?',
      switchToLogin: 'Entrar',
      trialNote: 'O seu teste de 7 dias é ativado automaticamente',
      forgot: 'Esqueceu a palavra-passe?',
      resetSent: 'E-mail de redefinição enviado.',
      closeAria: 'Fechar',
      busy: 'Aguarde…',
      errGeneric: 'Algo correu mal. Tente novamente.',
      errEmail: 'Introduza um e-mail válido.',
      errPassword: 'A palavra-passe deve ter pelo menos 6 caracteres.',
      errName: 'Introduza o seu nome.',
      errPopup: 'Popup bloqueado. Autorize popups neste site.',
      errCancelled: 'Sessão cancelada.',
    },
    ko: {
      loginTitle: '로그인',
      signupTitle: '가입하기',
      emailPh: '이메일',
      passwordPh: '비밀번호',
      fullNamePh: '이름',
      loginSubmit: '입장',
      signupSubmit: '계정 만들기',
      or: '또는',
      google: 'Google로 계속',
      apple: 'Apple로 계속',
      switchToSignupLabel: '계정이 없으신가요?',
      switchToSignup: '가입하기',
      switchToLoginLabel: '이미 계정이 있으신가요?',
      switchToLogin: '로그인',
      trialNote: '7일 체험이 자동으로 활성화됩니다',
      forgot: '비밀번호를 잊으셨나요?',
      resetSent: '비밀번호 재설정 이메일을 보냈습니다.',
      closeAria: '닫기',
      busy: '잠시만…',
      errGeneric: '문제가 발생했습니다. 다시 시도하세요.',
      errEmail: '유효한 이메일을 입력하세요.',
      errPassword: '비밀번호는 6자 이상이어야 합니다.',
      errName: '이름을 입력하세요.',
      errPopup: '팝업이 차단되었습니다. 팝업을 허용하세요.',
      errCancelled: '로그인이 취소되었습니다.',
    },
  };

  var mode = 'login';
  var authRef = null;
  var busy = false;
  var escHandler = null;
  var wired = false;

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

  function normalizeMode(m) {
    var x = String(m || 'login').toLowerCase();
    if (x === 'signin' || x === 'connexion' || x === 'login') return 'login';
    return 'signup';
  }

  function isEmbeddedInApp() {
    try {
      return global.parent && global.parent !== global;
    } catch (_e) {
      return true;
    }
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var existing = document.querySelector('script[src="' + src + '"]');
      if (existing) {
        if (existing.getAttribute('data-paychek-loaded') === '1') {
          resolve();
          return;
        }
        existing.addEventListener('load', function () {
          resolve();
        });
        existing.addEventListener('error', reject);
        return;
      }
      var s = document.createElement('script');
      s.src = src;
      s.async = true;
      s.onload = function () {
        s.setAttribute('data-paychek-loaded', '1');
        resolve();
      };
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  function ensureFirebaseSdk() {
    if (global.firebase && global.firebase.auth) {
      return Promise.resolve();
    }
    return loadScript(
      'https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js',
    ).then(function () {
      return loadScript(
        'https://www.gstatic.com/firebasejs/10.14.1/firebase-auth-compat.js',
      );
    });
  }

  function getAuth() {
    if (!global.firebase || !global.firebase.initializeApp) {
      throw new Error('Firebase SDK missing');
    }
    var app;
    try {
      app = global.firebase.app();
    } catch (_e) {
      app = global.firebase.initializeApp(FIREBASE_CONFIG);
    }
    return global.firebase.auth(app);
  }

  function ensureDom() {
    var root = document.getElementById('paychek-site-auth');
    if (root) return root;
    root = document.createElement('div');
    root.id = 'paychek-site-auth';
    root.className = 'paychek-site-auth-root';
    root.setAttribute('hidden', '');
    root.setAttribute('role', 'dialog');
    root.setAttribute('aria-modal', 'true');
    root.innerHTML =
      '<div class="paychek-site-auth-backdrop" data-paychek-auth-dismiss></div>' +
      '<div class="paychek-site-auth-panel">' +
      '<button type="button" class="paychek-site-auth-close" data-paychek-auth-dismiss aria-label="Close">' +
      '<i class="fas fa-times" aria-hidden="true"></i>' +
      '</button>' +
      '<h2 class="paychek-site-auth-title" data-paychek-auth-title>Log in</h2>' +
      '<p class="paychek-site-auth-trial" data-paychek-auth-trial hidden></p>' +
      '<div class="paychek-site-auth-error" data-paychek-auth-error hidden></div>' +
      '<div class="paychek-site-auth-ok" data-paychek-auth-ok hidden></div>' +
      '<form data-paychek-auth-form novalidate>' +
      '<input class="paychek-site-auth-field paychek-site-auth-name" data-paychek-auth-name type="text" autocomplete="name" hidden>' +
      '<input class="paychek-site-auth-field" data-paychek-auth-email type="email" autocomplete="email" required>' +
      '<input class="paychek-site-auth-field" data-paychek-auth-password type="password" autocomplete="current-password" required>' +
      '<button type="submit" class="paychek-site-auth-submit" data-paychek-auth-submit>Enter</button>' +
      '</form>' +
      '<button type="button" class="paychek-site-auth-forgot" data-paychek-auth-forgot>Forgot password?</button>' +
      '<div class="paychek-site-auth-divider" data-paychek-auth-or>or</div>' +
      '<div class="paychek-site-auth-social">' +
      '<button type="button" class="paychek-site-auth-social-btn" data-paychek-auth-google>' +
      '<i class="fab fa-google" aria-hidden="true"></i><span data-paychek-auth-google-label>Google</span>' +
      '</button>' +
      '<button type="button" class="paychek-site-auth-social-btn" data-paychek-auth-apple>' +
      '<i class="fab fa-apple" aria-hidden="true"></i><span data-paychek-auth-apple-label>Apple</span>' +
      '</button>' +
      '</div>' +
      '<p class="paychek-site-auth-switch">' +
      '<span data-paychek-auth-switch-label></span> ' +
      '<button type="button" data-paychek-auth-switch></button>' +
      '</p>' +
      '</div>';
    document.body.appendChild(root);
    return root;
  }

  function setBusy(root, on) {
    busy = !!on;
    var s = t();
    root.querySelectorAll('button, input').forEach(function (el) {
      if (el.hasAttribute('data-paychek-auth-dismiss') || el.hasAttribute('data-paychek-auth-switch')) {
        el.disabled = false;
        return;
      }
      el.disabled = busy;
    });
    var submit = root.querySelector('[data-paychek-auth-submit]');
    if (submit && busy) submit.textContent = s.busy;
    else applyLabels(root);
  }

  function showError(root, msg) {
    var err = root.querySelector('[data-paychek-auth-error]');
    var ok = root.querySelector('[data-paychek-auth-ok]');
    if (ok) {
      ok.hidden = true;
      ok.textContent = '';
    }
    if (!err) return;
    if (!msg) {
      err.hidden = true;
      err.textContent = '';
      return;
    }
    err.hidden = false;
    err.textContent = msg;
  }

  function showOk(root, msg) {
    var err = root.querySelector('[data-paychek-auth-error]');
    var ok = root.querySelector('[data-paychek-auth-ok]');
    if (err) {
      err.hidden = true;
      err.textContent = '';
    }
    if (!ok) return;
    if (!msg) {
      ok.hidden = true;
      ok.textContent = '';
      return;
    }
    ok.hidden = false;
    ok.textContent = msg;
  }

  function mapAuthError(code) {
    var s = t();
    switch (code) {
      case 'auth/popup-blocked':
        return s.errPopup;
      case 'auth/popup-closed-by-user':
      case 'auth/cancelled-popup-request':
        return s.errCancelled;
      case 'auth/invalid-email':
        return s.errEmail;
      case 'auth/weak-password':
        return s.errPassword;
      case 'auth/email-already-in-use':
        return locale() === 'fr'
          ? 'Cet e-mail est déjà utilisé.'
          : 'This email is already in use.';
      case 'auth/user-not-found':
      case 'auth/wrong-password':
      case 'auth/invalid-credential':
        return locale() === 'fr'
          ? 'E-mail ou mot de passe incorrect.'
          : 'Incorrect email or password.';
      case 'auth/too-many-requests':
        return locale() === 'fr'
          ? 'Trop de tentatives. Réessayez plus tard.'
          : 'Too many attempts. Try again later.';
      default:
        return s.errGeneric;
    }
  }

  function applyLabels(root) {
    var s = t();
    var isLogin = mode === 'login';
    var title = root.querySelector('[data-paychek-auth-title]');
    if (title) title.textContent = isLogin ? s.loginTitle : s.signupTitle;
    var trial = root.querySelector('[data-paychek-auth-trial]');
    if (trial) {
      trial.textContent = s.trialNote;
      trial.hidden = isLogin;
    }
    var name = root.querySelector('[data-paychek-auth-name]');
    if (name) {
      name.placeholder = s.fullNamePh;
      name.hidden = isLogin;
      name.required = !isLogin;
      name.autocomplete = 'name';
    }
    var email = root.querySelector('[data-paychek-auth-email]');
    if (email) email.placeholder = s.emailPh;
    var password = root.querySelector('[data-paychek-auth-password]');
    if (password) {
      password.placeholder = s.passwordPh;
      password.autocomplete = isLogin ? 'current-password' : 'new-password';
    }
    var submit = root.querySelector('[data-paychek-auth-submit]');
    if (submit && !busy) {
      submit.textContent = isLogin ? s.loginSubmit : s.signupSubmit;
    }
    var forgot = root.querySelector('[data-paychek-auth-forgot]');
    if (forgot) {
      forgot.textContent = s.forgot;
      forgot.hidden = !isLogin;
    }
    var or = root.querySelector('[data-paychek-auth-or]');
    if (or) or.textContent = s.or;
    var g = root.querySelector('[data-paychek-auth-google-label]');
    if (g) g.textContent = s.google;
    var a = root.querySelector('[data-paychek-auth-apple-label]');
    if (a) a.textContent = s.apple;
    var swLabel = root.querySelector('[data-paychek-auth-switch-label]');
    var swBtn = root.querySelector('[data-paychek-auth-switch]');
    if (swLabel) {
      swLabel.textContent = isLogin ? s.switchToSignupLabel : s.switchToLoginLabel;
    }
    if (swBtn) {
      swBtn.textContent = isLogin ? s.switchToSignup : s.switchToLogin;
    }
    var close = root.querySelector('.paychek-site-auth-close');
    if (close) close.setAttribute('aria-label', s.closeAria);
    root.setAttribute('aria-label', isLogin ? s.loginTitle : s.signupTitle);
  }

  function close() {
    var root = document.getElementById('paychek-site-auth');
    if (!root) return;
    root.setAttribute('hidden', '');
    document.body.classList.remove('paychek-site-auth-open');
    if (escHandler) {
      document.removeEventListener('keydown', escHandler);
      escHandler = null;
    }
    showError(root, '');
    showOk(root, '');
    setBusy(root, false);
  }

  function open(requestedMode) {
    if (isEmbeddedInApp()) {
      try {
        global.parent.postMessage(
          JSON.stringify({
            type: 'paychek-auth',
            mode: normalizeMode(requestedMode),
          }),
          '*',
        );
        return;
      } catch (_e) {}
    }

    mode = normalizeMode(requestedMode);
    var root = ensureDom();
    wireOnce(root);
    applyLabels(root);
    showError(root, '');
    showOk(root, '');
    root.removeAttribute('hidden');
    document.body.classList.add('paychek-site-auth-open');
    if (!escHandler) {
      escHandler = function (e) {
        if (e.key === 'Escape') close();
      };
      document.addEventListener('keydown', escHandler);
    }
    ensureFirebaseSdk()
      .then(function () {
        authRef = getAuth();
      })
      .catch(function () {
        showError(root, t().errGeneric);
      });
    var focusEl = root.querySelector(
      mode === 'signup' ? '[data-paychek-auth-name]' : '[data-paychek-auth-email]',
    );
    if (focusEl) {
      setTimeout(function () {
        focusEl.focus();
      }, 30);
    }
  }

  function afterSuccess(root) {
    setBusy(root, false);
    close();
  }

  function handleEmailSubmit(root, ev) {
    ev.preventDefault();
    if (busy) return;
    var s = t();
    var emailEl = root.querySelector('[data-paychek-auth-email]');
    var passEl = root.querySelector('[data-paychek-auth-password]');
    var nameEl = root.querySelector('[data-paychek-auth-name]');
    var email = (emailEl && emailEl.value ? emailEl.value : '').trim();
    var password = passEl && passEl.value ? passEl.value : '';
    var fullName = (nameEl && nameEl.value ? nameEl.value : '').trim();
    showError(root, '');
    showOk(root, '');
    if (!email || email.indexOf('@') < 1) {
      showError(root, s.errEmail);
      return;
    }
    if (password.length < 6) {
      showError(root, s.errPassword);
      return;
    }
    if (mode === 'signup' && !fullName) {
      showError(root, s.errName);
      return;
    }
    setBusy(root, true);
    ensureFirebaseSdk()
      .then(function () {
        var auth = getAuth();
        authRef = auth;
        if (mode === 'login') {
          return auth.signInWithEmailAndPassword(email, password);
        }
        return auth.createUserWithEmailAndPassword(email, password).then(function (cred) {
          if (cred && cred.user && fullName) {
            return cred.user.updateProfile({ displayName: fullName }).then(function () {
              return cred;
            });
          }
          return cred;
        });
      })
      .then(function () {
        afterSuccess(root);
      })
      .catch(function (err) {
        setBusy(root, false);
        showError(root, mapAuthError(err && err.code));
      });
  }

  function handleSocial(root, providerName) {
    if (busy) return;
    showError(root, '');
    showOk(root, '');
    setBusy(root, true);
    ensureFirebaseSdk()
      .then(function () {
        var auth = getAuth();
        authRef = auth;
        var provider =
          providerName === 'apple'
            ? new global.firebase.auth.OAuthProvider('apple.com')
            : new global.firebase.auth.GoogleAuthProvider();
        if (providerName === 'google') {
          provider.setCustomParameters({ prompt: 'select_account' });
        }
        if (providerName === 'apple') {
          provider.addScope('email');
          provider.addScope('name');
        }
        return auth.signInWithPopup(provider);
      })
      .then(function () {
        afterSuccess(root);
      })
      .catch(function (err) {
        setBusy(root, false);
        showError(root, mapAuthError(err && err.code));
      });
  }

  function handleForgot(root) {
    if (busy) return;
    var s = t();
    var emailEl = root.querySelector('[data-paychek-auth-email]');
    var email = (emailEl && emailEl.value ? emailEl.value : '').trim();
    showError(root, '');
    showOk(root, '');
    if (!email || email.indexOf('@') < 1) {
      showError(root, s.errEmail);
      return;
    }
    setBusy(root, true);
    ensureFirebaseSdk()
      .then(function () {
        return getAuth().sendPasswordResetEmail(email);
      })
      .then(function () {
        setBusy(root, false);
        showOk(root, s.resetSent);
      })
      .catch(function (err) {
        setBusy(root, false);
        showError(root, mapAuthError(err && err.code));
      });
  }

  function wireOnce(root) {
    if (wired) return;
    wired = true;
    root.addEventListener('click', function (e) {
      var target = e.target;
      if (!target) return;
      if (target.closest && target.closest('[data-paychek-auth-dismiss]')) {
        e.preventDefault();
        close();
        return;
      }
      if (target.closest && target.closest('[data-paychek-auth-switch]')) {
        e.preventDefault();
        mode = mode === 'login' ? 'signup' : 'login';
        showError(root, '');
        showOk(root, '');
        applyLabels(root);
        return;
      }
      if (target.closest && target.closest('[data-paychek-auth-google]')) {
        e.preventDefault();
        handleSocial(root, 'google');
        return;
      }
      if (target.closest && target.closest('[data-paychek-auth-apple]')) {
        e.preventDefault();
        handleSocial(root, 'apple');
        return;
      }
      if (target.closest && target.closest('[data-paychek-auth-forgot]')) {
        e.preventDefault();
        handleForgot(root);
      }
    });
    var form = root.querySelector('[data-paychek-auth-form]');
    if (form) {
      form.addEventListener('submit', function (ev) {
        handleEmailSubmit(root, ev);
      });
    }
  }

  function openFromQuery() {
    try {
      var params = new URLSearchParams(global.location.search || '');
      var auth = params.get('auth');
      if (!auth) return;
      open(auth);
      params.delete('auth');
      var next = params.toString();
      var url =
        global.location.pathname +
        (next ? '?' + next : '') +
        (global.location.hash || '');
      if (global.history && global.history.replaceState) {
        global.history.replaceState(null, '', url);
      }
    } catch (_e) {}
  }

  function startJournalOrAuth() {
    if (isEmbeddedInApp()) {
      open('signup');
      return;
    }
    ensureFirebaseSdk()
      .then(function () {
        var auth = getAuth();
        if (auth.currentUser) {
          global.location.href = (global.location.origin || '') + '/?app=1';
          return;
        }
        open('signup');
      })
      .catch(function () {
        open('signup');
      });
  }

  function goToAppAuth(requestedMode) {
    open(requestedMode);
  }

  global.paychekOpenSiteAuth = open;
  global.paychekCloseSiteAuth = close;
  global.paychekGoToAppAuth = goToAppAuth;
  global.paychekNotifyParentAuth = goToAppAuth;
  global.paychekStartJournalOrAuth = startJournalOrAuth;

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', openFromQuery);
  } else {
    openFromQuery();
  }
})(window);
