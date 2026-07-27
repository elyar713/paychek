// PAYCHEK landing-page.js — auth marketing via modale HTML Firebase (paychek-site-auth.js).
const previewData = {
    'dashboard': {
        title: 'Dashboard',
        lead: "Tradez avec la discipline d'un pro, pas avec vos émotions.",
        descPoints: [
            { icon: 'fa-chart-line', label: 'Capital & Balance :', body: 'Votre santé financière immédiatement visible.' },
            { icon: 'fa-sticky-note', label: 'Votre analyse :', body: "Ne cherchez plus vos notes. Votre analyse est affichée clairement pour valider votre biais en une seconde." },
            { icon: 'fa-clipboard-check', label: 'Checklist :', body: "Cliquez et validez vos règles de stratégie directement sur l'écran principal." },
            { icon: 'fa-gauge', label: 'État Mental :', body: "Une jauge visuelle pour savoir si vous êtes en état de cliquer ou s'il faut s'arrêter." },
            { icon: 'fa-calendar-alt', label: 'Calendrier :', body: 'Votre progression gravée dans le temps.' },
            { icon: 'fa-chess-knight', label: 'Votre Stratégie :', body: 'Toujours sous vos yeux.' }
        ],
        imgs: [
            'images/landing-preview-dashboard.png',
            'images/landing-preview-dashboard-2.png'
        ],
        imgAlts: [
            'Aperçu du terminal PAYCHEK — Dashboard',
            'Aperçu PAYCHEK — état mental, stratégie et calendrier'
        ]
    },
    'checklist': {
        title: 'Checklist',
        lead: 'Votre "Feu Vert" avant chaque trade',
        descPoints: [
            { icon: 'fa-sliders', label: 'Validation 360° :', body: 'Technique, Risque, Psychologie. Vérifiez tous vos paramètres avant de cliquer.' },
            { icon: 'fa-circle-notch', label: 'Progression Visuelle :', body: 'Le cercle se remplit à mesure que vous validez vos étapes. Ne cliquez sur "Buy" ou "Sell" que lorsque le cercle est complet.' },
            { icon: 'fa-link', label: 'Zéro Oubli :', body: 'Vos règles de gestion sont gravées dans votre routine.' },
            { icon: 'fa-file-pdf', label: 'Export PDF :', body: 'Gardez une preuve de votre discipline pour vos bilans.' }
        ],
        img: 'images/landing-preview-checklist.png',
        imgAlt: 'Aperçu du module Checklist PAYCHEK'
    },
    'mental': {
        title: 'Mental State',
        lead: 'Le marché ne pardonne pas la fatigue. Paychek vous donne le feu vert psychologique pour trader avec une discipline de fer',
        descPoints: [
            { icon: 'fa-chart-line', label: 'Indicateur de Performance :', body: 'Un score global basé sur vos habitudes. Sommeil, sport, méditation : sachez instantanément si vous êtes en "Peak Form" pour dominer le marché.' },
            { icon: 'fa-sliders', label: 'Analyse du Moment :', body: 'Évaluez votre Focus, votre Énergie et votre Stress en un glissement de doigt. Si vos jauges sont dans le rouge, le Dashboard vous avertit avant l\'erreur.' },
            { icon: 'fa-face-smile', label: 'Gestion des Émotions :', body: 'Excited ? Frustrated ? Neutral ? Identifiez vos biais émotionnels pour éviter le "Revenge Trading" ou l\'euphorie toxique.' },
            { icon: 'fa-clipboard-check', label: 'Routine de Pro :', body: 'Validez vos rituels avant-session. Un trader préparé est un trader qui encaisse.' }
        ],
        img: 'images/landing-preview-mental.png',
        imgAlt: 'Aperçu du module État mental PAYCHEK'
    },
    'analyse': {
        title: 'Mon analyse',
        lead: 'Gérez vos analyses et stratégies en temps réel : plan de trade, blocs détaillés et rapport de synthèse.',
        descPoints: [
            { icon: 'fa-file-lines', label: 'Feuille de plan :', body: 'Direction, timeframes, tendance, phase de marché et niveau de confiance sur un seul écran.' },
            { icon: 'fa-layer-group', label: 'Blocs détaillés :', body: 'Structure, indicateurs, SMC & liquidité, volume profile et capture graphique.' },
            { icon: 'fa-file-export', label: 'Rapport :', body: 'Vue synthèse avec confiance globale avant d\'enregistrer dans votre historique lié à l\'actif.' }
        ],
        imgs: [
            'images/landing-preview-analyse-1.png',
            'images/landing-preview-analyse-2.png',
            'images/landing-preview-analyse-3.png',
            'images/landing-preview-analyse-4.png'
        ],
        imgAlts: [
            'PAYCHEK — rapport d\'analyse (Weekly Swing)',
            'PAYCHEK — fiches Structure, Indicateurs, SMC, Volume',
            'PAYCHEK — feuille de plan Trading',
            'PAYCHEK — résumé confiance et rapport'
        ]
    },
    'strategie': {
        title: 'My Strategy',
        lead: "La plupart des traders oublient leur plan dans le feu de l'action. Paychek l'affiche en permanence pour garantir votre discipline",
        descPoints: [
            { icon: 'fa-sliders', label: 'Configuration personnalisée :', body: "Définissez vos propres piliers techniques. C'est votre stratégie, pas celle d'un autre." },
            { icon: 'fa-pen-to-square', label: 'Arguments de conviction :', body: 'Notez vos arguments pour chaque trade.' },
            { icon: 'fa-bullseye', label: 'Focus immédiat :', body: "Ne perdez plus de temps à chercher votre plan. Il est affiché sur votre Dashboard pour vous garder aligné avec vos règles à chaque session." },
            { icon: 'fa-chart-line', label: 'Score de confiance :', body: 'Évaluez la qualité de votre setup avant de l\'exécuter pour éviter les trades de « basse qualité ».' }
        ],
        img: 'images/landing-preview-strategie.png',
        imgAlt: 'Aperçu module Stratégie PAYCHEK — playbook, risque, sessions et setups'
    },
    'performance': {
        title: 'Performance',
        lead: 'Ne devinez plus vos erreurs, mesurez-les',
        descPoints: [
            { icon: 'fa-brain', label: 'Analyse du Mindset :', body: 'Visualisez l\'impact réel de vos émotions sur vos profits en comparant vos trades par « Principe » et au « Feeling ».' },
            { icon: 'fa-clock', label: 'Golden Hours :', body: 'Découvrez vos heures les plus rentables pour concentrer vos efforts sur les moments où vous gagnez vraiment.' },
            { icon: 'fa-chart-column', label: 'Statistiques de Session :', body: 'Maîtrisez vos données de performance (Win Rate, RR, Volume) pour ajuster votre stratégie comme un professionnel.' },
            { icon: 'fa-layer-group', label: 'Intensité de Trading :', body: 'Déterminez votre nombre de trades idéal par jour pour éviter l\'overtrading et protéger votre capital.' }
        ],
        imgs: [
            'images/landing-preview-performance-2.png',
            'images/landing-preview-performance-3.png',
            'images/landing-preview-performance-4.png'
        ],
        imgAlts: [
            'PAYCHEK — Performance : volume, lots et actifs les plus tradés',
            'PAYCHEK — Performance : day & volume, performance hours et durée de position',
            'PAYCHEK — Performance : discipline & impact, mindset et stratégie execution'
        ]
    },
    'calendrier': {
        title: 'Calendrier',
        lead: 'Un historique visuel complet pour identifier vos forces et corriger vos erreurs passées.',
        desc: 'Une vue mensuelle de vos gains et pertes. Visualisez vos séries de victoires et apprenez de vos jours rouges.',
        img: 'images/landing-preview-calendrier.png',
        imgAlt: 'PAYCHEK — Calendrier : vue mensuelle, cumul, métriques et récapitulatif'
    },
    'trade': {
        title: 'Trade page',
        lead: 'Ne vous contentez pas de passer des ordres. Archivez votre succès.',
        descPoints: [
            { icon: 'fa-book', label: 'Le Journal de Bord :', body: 'Retrouvez l\'historique complet de vos positions avec un calcul automatique de votre rentabilité nette.' },
            { icon: 'fa-chart-line', label: 'Analyse Technique :', body: 'Documentez vos setups avec vos graphiques et vos arguments techniques pour ne jamais oublier le contexte d\'un trade.' },
            { icon: 'fa-clipboard-check', label: 'Bilan de Discipline :', body: 'Identifiez immédiatement quelles règles de votre stratégie ont été respectées ou ignorées pour chaque position.' },
            { icon: 'fa-pen', label: 'Notes Personnelles :', body: 'Gardez une trace de vos émotions et de vos intuitions pour transformer chaque séance en une leçon de progression.' },
            { icon: 'fa-chart-column', label: 'Statistiques de Trade :', body: 'Maîtrisez vos chiffres clés : Risk/Reward réel, durée d\'exposition et impact des commissions sur votre capital.' }
        ],
        imgs: [
            'images/landing-preview-trade-1.png',
            'images/landing-preview-trade-2.png',
            'images/landing-preview-trade-3.png'
        ],
        imgAlts: [
            'PAYCHEK — Trade : liste, filtres et P&L',
            'PAYCHEK — Trade : fiche détaillée d\'un trade',
            'PAYCHEK — Trade : récapitulatif hebdomadaire et sessions'
        ]
    },
    'pdf': {
        title: 'Export PDF',
        lead: 'Générez des rapports professionnels pour auditer votre progression et prouver votre régularité.',
        descPoints: [
            { icon: 'fa-chess-knight', label: 'Stratégie Personnalisée :', body: 'Exportez vos règles et vos piliers techniques pour conserver une trace officielle de votre plan de trading.' },
            { icon: 'fa-chart-line', label: 'Analyse d\'Actif :', body: 'Archivez vos scénarios et vos captures de graphiques pour chaque actif travaillé durant la session.' },
            { icon: 'fa-file-lines', label: 'Détails du Trade :', body: 'Obtenez une fiche individuelle pour chaque position, incluant vos notes, votre setup et votre score de discipline.' },
            { icon: 'fa-calendar-week', label: 'Revues Périodiques :', body: 'Générez des rapports détaillés de vos trades de la semaine pour une analyse post-session approfondie.' },
            { icon: 'fa-chart-column', label: 'Suivi de Performance :', body: 'Compilez vos résultats journaliers, hebdomadaires et mensuels dans un document clair et structuré.' }
        ],
        imgs: [
            'images/landing-preview-pdf-1.png',
            'images/landing-preview-pdf-2.png',
            'images/landing-preview-pdf-3.png',
            'images/landing-preview-pdf-4.png',
            'images/landing-preview-pdf-5.png'
        ],
        imgAlts: [
            'PAYCHEK — Export PDF : performance journal (résumé + discipline)',
            'PAYCHEK — Export PDF : rapport d\'analyse (exécutif, structure, indicateurs)',
            'PAYCHEK — Export PDF : playbook stratégie (règles, risk management, sessions)',
            'PAYCHEK — Export PDF : trades week (récap et qualité)',
            'PAYCHEK — Export PDF : détails d\'un trade (discipline, stats, review)'
        ]
    },
    'csv': {
        title: 'Import CSV',
        lead: '9 logiciels acceptés : choisissez votre plateforme, importez votre export, Paychek reconnaît le format.',
        descPoints: [
            { icon: 'fa-file-csv', label: 'Formats pris en charge :', body: 'MT4, MT5, TradingView, Tradovate, cTrader, NinjaTrader, Quantower, ATAS, Rithmic.' },
            { icon: 'fa-wand-magic-sparkles', label: 'Import guidé :', body: 'Sélection du logiciel dans la liste, puis fichier adapté à chaque source (CSV, HTML, etc.).' },
            { icon: 'fa-chart-line', label: 'Historique dans le journal :', body: 'Vos positions importées rejoignent le journal pour stats, performance et exports PDF.' }
        ],
        img: 'images/landing-preview-csv.png',
        imgAlt: 'PAYCHEK — Import CSV : choix du logiciel (MT4, MT5, TradingView, Tradovate, cTrader…)'
    },
    'ajouter': {
        title: 'Page Trade',
        lead: 'Saisissez vos trades avec la précision d\'un algorithme et la clarté d\'un professionnel.',
        descPoints: [
            { icon: 'fa-bolt', label: 'Ajouter un Trade :', body: 'Enregistrez vos positions en quelques secondes avec une interface intuitive conçue pour la rapidité d\'exécution.' },
            { icon: 'fa-calculator', label: 'Saisie Intelligente :', body: 'Renseignez vos entrées, sorties et frais pour obtenir un calcul automatique et précis de votre profit net.' },
            { icon: 'fa-clipboard-check', label: 'Validation du Plan :', body: 'Identifiez immédiatement si votre trade respecte vos règles ou s\'il s\'agit d\'une décision impulsive (Feeling).' }
        ],
        imgs: [
            'images/landing-preview-ajouter-1.png',
            'images/landing-preview-ajouter-2.png'
        ],
        imgAlts: [
            'PAYCHEK — Ajouter : saisie du trade (actif, lots, entrée/sortie, date)',
            'PAYCHEK — Ajouter : principe/feeling, stratégie et checklist'
        ]
    }
};

var previewCarouselIndex = 0;
/** Module dont le carrousel multi-images est actif (`dashboard`, `analyse`, ou null). */
var previewCarouselKey = 'dashboard';
var previewCarouselAutoId = null;
var PREVIEW_CAROUSEL_MS = 10000;
/** Moitié du fondu image → image (~3 s au total : sortie 1,5 s + entrée 1,5 s), aligné sur le CSS */
var PREVIEW_IMG_FADE_MS = 1500;

function stopPreviewCarouselAuto() {
    if (previewCarouselAutoId !== null) {
        clearInterval(previewCarouselAutoId);
        previewCarouselAutoId = null;
    }
}

function startPreviewCarouselAuto() {
    stopPreviewCarouselAuto();
    if (!previewCarouselKey) return;
    var d = previewData[previewCarouselKey];
    if (!d || !d.imgs || d.imgs.length < 2) return;
    var tab = document.getElementById('tab-' + previewCarouselKey);
    if (!tab || !tab.classList.contains('active')) return;
    previewCarouselAutoId = setInterval(function () {
        previewCarouselStep(1, true);
    }, PREVIEW_CAROUSEL_MS);
}

/** true quand la page est affichée dans l’iframe Flutter (paychek.pro/). */
function paychekIsEmbeddedInApp() {
    try {
        return window.parent !== window;
    } catch (e) {
        return false;
    }
}

var _paychekAuthOverlayEsc = null;

/** Overlay auth legacy (désactivé) — l’auth marketing est HTML via paychek-site-auth.js. */
function paychekEnsureAuthOverlay() {
    return document.getElementById('paychek-auth-overlay');
}

function paychekCloseAuthOverlay() {
    if (typeof window.paychekCloseSiteAuth === 'function') {
        window.paychekCloseSiteAuth();
    }
    var overlay = document.getElementById('paychek-auth-overlay');
    if (!overlay) return;
    overlay.classList.remove('is-open');
    document.body.classList.remove('paychek-auth-overlay-open');
    document.body.style.overflow = '';
    var iframe = overlay.querySelector('.paychek-auth-overlay-frame');
    if (iframe) iframe.src = 'about:blank';
}

function paychekOpenAuthOverlay(mode) {
    if (typeof window.paychekOpenSiteAuth === 'function') {
        window.paychekOpenSiteAuth(mode);
        return;
    }
    // Fallback sans site-auth : reste sur landing (ne pas booter Flutter).
    console.warn('[paychek] paychek-site-auth.js manquant');
}

function paychekOnAuthOverlayMessage(event) {
    var data = event.data;
    if (typeof data === 'string') {
        try {
            data = JSON.parse(data);
        } catch (e) {
            return;
        }
    }
    if (!data || typeof data !== 'object') return;
    if (data.type === 'paychek-auth-overlay-close') {
        paychekCloseAuthOverlay();
    }
}

/** Hors iframe Flutter : modale HTML ; en iframe : postMessage vers l’app. */
function paychekGoToAppAuth(mode) {
    if (paychekIsEmbeddedInApp()) {
        paychekPostToFlutterHost(JSON.stringify({ type: 'paychek-auth', mode: mode }));
        return;
    }
    paychekOpenAuthOverlay(mode);
}

function paychekPostToFlutterHost(payload) {
    var targets = [];
    try {
        if (window.parent && window.parent !== window) targets.push(window.parent);
        if (window.top && window.top !== window && targets.indexOf(window.top) < 0) {
            targets.push(window.top);
        }
        for (var i = 0; i < targets.length; i++) {
            try {
                targets[i].postMessage(payload, '*');
            } catch (e) {
                console.warn('[paychek] postMessage', e);
            }
        }
    } catch (e) {
        console.warn('[paychek] paychekPostToFlutterHost', e);
    }
}

var _landingHeightTimer = null;
var _landingHeightLastSent = 0;

function paychekMeasureLandingHeight() {
    var doc = document.documentElement;
    var scrollTop = window.pageYOffset || (doc ? doc.scrollTop : 0) || 0;

    // Ancré sur le footer : scrollHeight ment quand l’iframe est plus haute que le contenu.
    var footer = document.querySelector('footer');
    if (footer) {
        return Math.ceil(footer.getBoundingClientRect().bottom + scrollTop) + 8;
    }

    var body = document.body;
    if (!body) return 0;
    return Math.ceil(body.getBoundingClientRect().bottom + scrollTop) + 8;
}

function paychekReportLandingHeight() {
    if (!paychekIsEmbeddedInApp()) return;
    var height = paychekMeasureLandingHeight();
    if (!height || height < 400) return;
    if (Math.abs(height - _landingHeightLastSent) < 12) return;
    _landingHeightLastSent = height;
    paychekPostToFlutterHost(JSON.stringify({
        type: 'paychek-landing-height',
        height: height
    }));
}

function paychekScheduleLandingHeightReport() {
    if (!paychekIsEmbeddedInApp()) return;
    if (_landingHeightTimer) clearTimeout(_landingHeightTimer);
    _landingHeightTimer = setTimeout(paychekReportLandingHeight, 80);
}

function paychekNotifyParentScroll(deltaY, deltaX) {
    if (!paychekIsEmbeddedInApp()) return;
    paychekPostToFlutterHost(JSON.stringify({
        type: 'paychek-landing-wheel',
        deltaY: deltaY,
        deltaX: deltaX || 0
    }));
}

function paychekInitEmbeddedHostBridge() {
    if (!paychekIsEmbeddedInApp()) return;
    try {
        document.documentElement.classList.add('paychek-in-app-shell');
        document.body.classList.add('paychek-in-app-shell');
    } catch (e) {}

    if (typeof ResizeObserver !== 'undefined') {
        try {
            var ro = new ResizeObserver(function () {
                paychekScheduleLandingHeightReport();
            });
            ro.observe(document.body);
            ro.observe(document.documentElement);
            var footer = document.querySelector('footer');
            if (footer) ro.observe(footer);
        } catch (e) {}
    }

    window.addEventListener('resize', paychekScheduleLandingHeightReport);
    window.addEventListener('load', paychekScheduleLandingHeightReport);

    var burstTicks = 0;
    var burstId = setInterval(function () {
        paychekReportLandingHeight();
        burstTicks++;
        if (burstTicks >= 24) clearInterval(burstId);
    }, 250);

    window.addEventListener('wheel', function (e) {
        try {
            e.preventDefault();
            paychekNotifyParentScroll(e.deltaY, e.deltaX);
        } catch (err) {}
    }, { passive: false, capture: true });

    var lastTouchY = 0;
    document.addEventListener('touchstart', function (e) {
        if (e.touches.length !== 1) return;
        lastTouchY = e.touches[0].clientY;
    }, { passive: true, capture: true });

    document.addEventListener('touchmove', function (e) {
        if (e.touches.length !== 1) return;
        var y = e.touches[0].clientY;
        var deltaY = lastTouchY - y;
        lastTouchY = y;
        if (Math.abs(deltaY) < 0.5) return;
        try {
            paychekNotifyParentScroll(deltaY, 0);
            e.preventDefault();
        } catch (err) {}
    }, { passive: false, capture: true });

    paychekScheduleLandingHeightReport();
}

function previewCarouselApplyIndex() {
    if (!previewCarouselKey) return;
    var d = previewData[previewCarouselKey];
    if (!d || !d.imgs || !d.imgs.length) return;
    var n = d.imgs.length;
    var i = ((previewCarouselIndex % n) + n) % n;
    var imgEl = document.getElementById('preview-img');
    imgEl.src = d.imgs[i];
    imgEl.alt = (d.imgAlts && d.imgAlts[i]) ? d.imgAlts[i] : 'PAYCHEK';
    if (d.imgs[i].indexOf('analyse-4') >= 0) {
        imgEl.classList.add('preview-img-slim');
    } else {
        imgEl.classList.remove('preview-img-slim');
    }
}

function paychekNotifyParentAuth(mode) {
    paychekGoToAppAuth(mode);
}

/** Codes alignés sur l’app Flutter ([ReglageLanguagePrefs.availableCodes]). */
var LANDING_LANG_META = {
    en: { flag: 'us', trigger: 'EN' },
    fr: { flag: 'fr', trigger: 'FR' },
    de: { flag: 'de', trigger: 'DE' },
    es: { flag: 'es', trigger: 'ES' },
    pt: { flag: 'pt', trigger: 'PT' },
    ko: { flag: 'kr', trigger: 'KO' }
};

function applyLandingLocaleUI(code) {
    var normalized = typeof landingNormalizeLocale === 'function'
        ? landingNormalizeLocale(code)
        : code;
    var meta = LANDING_LANG_META[normalized];
    if (!meta) return normalized;
    var img = document.getElementById('lang-trigger-flag');
    var span = document.getElementById('lang-trigger-code');
    if (img) {
        img.src = 'https://flagcdn.com/w40/' + meta.flag + '.png';
        img.alt = meta.trigger;
    }
    if (span) span.textContent = meta.trigger;
    document.querySelectorAll('[data-landing-lang]').forEach(function (el) {
        var c = el.getAttribute('data-landing-lang');
        if (c === normalized) {
            el.classList.remove('text-gray-400');
            el.classList.add('text-white');
        } else {
            el.classList.add('text-gray-400');
            el.classList.remove('text-white');
        }
    });
    return normalized;
}

function paychekNotifyParentLocale(code) {
    paychekPostToFlutterHost(JSON.stringify({ type: 'paychek-locale', code: code }));
}

function paychekCloseLangMenu() {
    var wrap = document.getElementById('lang-picker-wrap');
    var menu = document.getElementById('lang-dropdown-menu');
    var btn = document.getElementById('lang-trigger-btn');
    if (wrap) wrap.classList.remove('is-open');
    if (menu) menu.classList.remove('is-open');
    if (btn) btn.setAttribute('aria-expanded', 'false');
}

function paychekToggleLangMenu(ev) {
    if (ev) {
        ev.preventDefault();
        ev.stopPropagation();
    }
    var wrap = document.getElementById('lang-picker-wrap');
    var menu = document.getElementById('lang-dropdown-menu');
    var btn = document.getElementById('lang-trigger-btn');
    if (!wrap || !menu) return;
    var open = !wrap.classList.contains('is-open');
    if (open) {
        wrap.classList.add('is-open');
        menu.classList.add('is-open');
        if (btn) btn.setAttribute('aria-expanded', 'true');
    } else {
        paychekCloseLangMenu();
    }
}

function initLandingLangPicker() {
    var wrap = document.getElementById('lang-picker-wrap');
    if (!wrap) return;
    document.addEventListener('pointerdown', function (ev) {
        if (wrap.contains(ev.target)) return;
        paychekCloseLangMenu();
    });
    document.addEventListener('keydown', function (ev) {
        if (ev.key === 'Escape') paychekCloseLangMenu();
    });
}

function landingSelectLang(code, ev) {
    if (ev) {
        ev.preventDefault();
        ev.stopPropagation();
    }
    var normalized = typeof landingSaveLocale === 'function'
        ? landingSaveLocale(code)
        : applyLandingLocaleUI(code);
    applyLandingLocaleUI(normalized);
    if (typeof applyLandingTranslations === 'function') {
        applyLandingTranslations(normalized);
    }
    if (typeof paychekRefreshAccountNavLabels === 'function') {
        paychekRefreshAccountNavLabels();
    }
    paychekNotifyParentLocale(normalized);
    paychekCloseLangMenu();
    paychekScheduleLandingHeightReport();
}

window.addEventListener('message', function (event) {
    try {
        if (typeof event.data !== 'string') return;
        var data = JSON.parse(event.data);
        if (!data || data.type !== 'paychek-locale-sync' || !data.code) return;
        var normalized = typeof landingSaveLocale === 'function'
            ? landingSaveLocale(data.code)
            : applyLandingLocaleUI(data.code);
        applyLandingLocaleUI(normalized);
        if (typeof applyLandingTranslations === 'function') {
            applyLandingTranslations(normalized);
        }
        paychekScheduleLandingHeightReport();
    } catch (e) {}
});

function initPreviewTabsDragScroll() {
    var el = document.getElementById('preview-tabs-scroll');
    if (!el) return;
    var down = false;
    var startPageX = 0;
    var startScrollLeft = 0;
    var dragged = false;
    var threshold = 6;

    function onMove(e) {
        if (!down) return;
        var dx = e.pageX - startPageX;
        if (Math.abs(dx) > threshold) {
            dragged = true;
            el.classList.add('is-grabbing');
        }
        el.scrollLeft = startScrollLeft - dx;
    }

    function onUp() {
        if (!down) return;
        down = false;
        el.classList.remove('is-grabbing');
        if (dragged) {
            el.addEventListener('click', function killGhostClick(ev) {
                ev.preventDefault();
                ev.stopPropagation();
                ev.stopImmediatePropagation();
            }, { capture: true, once: true });
        }
        dragged = false;
    }

    el.addEventListener('mousedown', function (e) {
        if (e.button !== 0) return;
        down = true;
        dragged = false;
        startPageX = e.pageX;
        startScrollLeft = el.scrollLeft;
    });

    window.addEventListener('mousemove', onMove);
    window.addEventListener('mouseup', onUp);
    window.addEventListener('blur', onUp);
}

window.addEventListener('message', paychekOnAuthOverlayMessage);

window.addEventListener('DOMContentLoaded', function () {
    paychekInitEmbeddedHostBridge();
    var initialLocale = typeof landingDetectInitialLocale === 'function'
        ? landingDetectInitialLocale()
        : 'en';
    if (typeof landingSaveLocale === 'function') {
        landingSaveLocale(initialLocale);
    }
    applyLandingLocaleUI(initialLocale);
    if (typeof applyLandingTranslations === 'function') {
        applyLandingTranslations(initialLocale);
    }
    paychekPostToFlutterHost(JSON.stringify({ type: 'paychek-ready', code: initialLocale }));
    paychekNotifyParentLocale(initialLocale);
    previewCarouselIndex = 0;
    var dashTab = document.getElementById('tab-dashboard');
    if (dashTab && dashTab.classList.contains('active')) {
        previewCarouselApplyIndex();
        setPreviewCarouselControlsVisible(true);
        startPreviewCarouselAuto();
        setPreviewDesc(previewData['dashboard']);
    } else {
        setPreviewCarouselControlsVisible(false);
    }
    initPreviewTabsDragScroll();
    initLandingLangPicker();
    paychekScheduleLandingHeightReport();
});

function setPreviewCarouselControlsVisible(show) {
    var ctrl = document.getElementById('preview-carousel-controls');
    if (!ctrl) return;
    if (show) {
        ctrl.classList.remove('hidden');
    } else {
        ctrl.classList.add('hidden');
    }
}

function previewCarouselStep(delta, fromAuto) {
    if (!previewCarouselKey) return;
    var tab = document.getElementById('tab-' + previewCarouselKey);
    if (!tab || !tab.classList.contains('active')) return;
    var d = previewData[previewCarouselKey];
    if (!d || !d.imgs || d.imgs.length < 2) return;
    previewCarouselIndex = (previewCarouselIndex + delta + d.imgs.length) % d.imgs.length;
    var imgEl = document.getElementById('preview-img');
    imgEl.style.opacity = '0';
    setTimeout(function () {
        previewCarouselApplyIndex();
        imgEl.style.opacity = '1';
        if (!fromAuto) startPreviewCarouselAuto();
    }, PREVIEW_IMG_FADE_MS);
}

function setPreviewDesc(d) {
    var el = document.getElementById('preview-desc');
    if (!el) return;
    el.innerHTML = '';
    el.className = 'text-sm sm:text-base leading-relaxed';
    if (d.descPoints && d.descPoints.length) {
        var ul = document.createElement('ul');
        ul.className = 'm-0 list-none space-y-4 p-0';
        for (var i = 0; i < d.descPoints.length; i++) {
            var item = d.descPoints[i];
            var li = document.createElement('li');
            li.className = 'flex gap-3 items-start';
            if (typeof item === 'string') {
                var dot = document.createElement('span');
                dot.className = 'text-blue-500 shrink-0 select-none';
                dot.setAttribute('aria-hidden', 'true');
                dot.textContent = '•';
                var span = document.createElement('span');
                span.className = 'text-gray-400';
                span.textContent = item;
                li.appendChild(dot);
                li.appendChild(span);
            } else {
                var iconWrap = document.createElement('span');
                iconWrap.className = 'text-blue-500 shrink-0 w-7 text-center text-[15px] sm:text-base leading-none mt-0.5';
                iconWrap.setAttribute('aria-hidden', 'true');
                var ic = document.createElement('i');
                ic.className = 'fas ' + item.icon;
                iconWrap.appendChild(ic);
                var textCol = document.createElement('div');
                textCol.className = 'min-w-0 flex-1 leading-relaxed';
                var lab = document.createElement('span');
                lab.className = 'text-gray-300 font-semibold';
                lab.textContent = item.label;
                var sp = document.createElement('span');
                sp.className = 'text-gray-500';
                sp.textContent = '\u00a0' + item.body;
                textCol.appendChild(lab);
                textCol.appendChild(sp);
                li.appendChild(iconWrap);
                li.appendChild(textCol);
            }
            ul.appendChild(li);
        }
        el.appendChild(ul);
    } else {
        var p = document.createElement('p');
        p.className = 'm-0 text-gray-400';
        p.textContent = d.desc || '';
        el.appendChild(p);
    }
}

function switchPreview(key) {
    stopPreviewCarouselAuto();
    document.querySelectorAll('.explorer-tab').forEach(tab => tab.classList.remove('active'));
    const activeTab = document.getElementById('tab-' + key);
    if (activeTab) {
        activeTab.classList.add('active');
        var strip = document.getElementById('preview-tabs-scroll');
        if (strip) {
            try {
                var pad = 16;
                var tL = activeTab.offsetLeft;
                var tR = tL + activeTab.offsetWidth;
                var vL = strip.scrollLeft;
                var vR = vL + strip.clientWidth;
                if (tL < vL + pad) {
                    strip.scrollTo({ left: Math.max(0, tL - pad), behavior: 'smooth' });
                } else if (tR > vR - pad) {
                    strip.scrollTo({ left: tR - strip.clientWidth + pad, behavior: 'smooth' });
                }
            } catch (e) {}
        }
    }

    const imgContainer = document.getElementById('preview-container-img');
    const textContainer = document.getElementById('preview-container-text');
    
    imgContainer.style.opacity = '0';
    textContainer.style.opacity = '0';
    
    setTimeout(() => {
        var primary = document.getElementById('preview-img');
        var d = previewData[key];
        var useCarousel = (key === 'dashboard' || key === 'analyse' || key === 'performance' || key === 'trade' || key === 'ajouter' || key === 'pdf') && d.imgs && d.imgs.length > 1;
        if (useCarousel) {
            previewCarouselKey = key;
            previewCarouselIndex = 0;
            previewCarouselApplyIndex();
            setPreviewCarouselControlsVisible(true);
            startPreviewCarouselAuto();
        } else {
            previewCarouselKey = null;
            if (d.imgs && d.imgs.length === 1) {
                primary.src = d.imgs[0];
                primary.alt = (d.imgAlts && d.imgAlts[0]) ? d.imgAlts[0] : 'PAYCHEK';
                primary.classList.remove('preview-img-slim');
                setPreviewCarouselControlsVisible(false);
            } else {
                primary.src = d.img;
                primary.alt = d.imgAlt ? d.imgAlt : 'PAYCHEK';
                primary.classList.remove('preview-img-slim');
                setPreviewCarouselControlsVisible(false);
            }
        }
        document.getElementById('preview-title').innerText = d.title;
        var leadEl = document.getElementById('preview-lead');
        if (leadEl) {
            if (d.lead) {
                leadEl.textContent = d.lead;
                leadEl.classList.remove('hidden');
            } else {
                leadEl.textContent = '';
                leadEl.classList.add('hidden');
            }
        }
        setPreviewDesc(d);
        
        imgContainer.style.opacity = '1';
        textContainer.style.opacity = '1';
        paychekScheduleLandingHeightReport();
    }, 300);
}

function toggleModal(id) {
    const modal = document.getElementById(id);
    if (!modal) return;
    const willOpen = modal.classList.contains('hidden');
    modal.classList.toggle('hidden');
    document.body.style.overflow = willOpen ? 'hidden' : 'auto';
}

function openPreviewLightbox(ev) {
    if (ev && ev.stopPropagation) ev.stopPropagation();
    var srcEl = document.getElementById('preview-img');
    var lb = document.getElementById('preview-lightbox');
    var lbImg = document.getElementById('preview-lightbox-img');
    if (!srcEl || !lb || !lbImg) return;
    lbImg.src = srcEl.currentSrc || srcEl.src;
    lbImg.alt = srcEl.alt || 'PAYCHEK';
    lbImg.removeAttribute('width');
    lbImg.removeAttribute('height');
    lbImg.style.width = '';
    lbImg.style.height = '';
    lb.classList.remove('hidden');
    document.body.style.overflow = 'hidden';
}

function closePreviewLightbox() {
    var lb = document.getElementById('preview-lightbox');
    if (!lb || lb.classList.contains('hidden')) return;
    lb.classList.add('hidden');
    document.body.style.overflow = 'auto';
}

function previewImgKeydown(ev) {
    if (!ev) return;
    if (ev.key === 'Enter' || ev.key === ' ') {
        ev.preventDefault();
        openPreviewLightbox(ev);
    }
}

document.addEventListener('keydown', function (ev) {
    if (ev.key !== 'Escape') return;
    var lb = document.getElementById('preview-lightbox');
    if (lb && !lb.classList.contains('hidden')) {
        ev.preventDefault();
        closePreviewLightbox();
    }
});

function toggleFaq(element) {
    const isActive = element.classList.contains('active');
    
    // Fermer tous les autres
    document.querySelectorAll('.faq-item').forEach(item => {
        item.classList.remove('active');
    });

    // Basculer l'actuel
    if (!isActive) {
        element.classList.add('active');
    }
    paychekScheduleLandingHeightReport();
}
