'use strict';

window.PAYCHEK_SAFEGUARD_I18N = {
  en: {
    meta: {
      title: 'Paychek Safeguard | Discipline for NinjaTrader',
      description:
        'Paychek Safeguard — NinjaTrader 8 discipline addon. Enable blocks orders outside your rules; monitor when disabled. Session, zones, lots, limits, cooldown, exit/SL. 7-day trial.'
    },
    nav: { journal: 'Journal', safeguard: 'Safeguard', login: 'Log in', signup: 'Sign up' },
    hero: {
      chip: 'NinjaTrader 8 discipline addon',
      titleHtml:
        '<span class="sg-hero-brand">PAYCHEK</span><span class="sg-hero-product">SAFEGUARD</span>',
      subtitleHtml:
        'Your rules stay on — <strong>Enabled</strong> blocks orders outside the plan; disabled still monitors.',
      ctaPrimary: 'Start free trial',
      ctaDownload: 'Download',
      ctaAuth: 'Sign up',
      platform: 'Windows · 7-day trial · 1 PC',
      addon: 'Add-on for NinjaTrader 8'
    },
    visual: {
      capital: 'Capital',
      hours: 'Usage hours',
      enabled: 'Enabled',
      statusLabel: 'Discipline status',
      statusMain: 'You can trade',
      allowed: 'Allowed',
      r1: 'Session · inside window',
      r2: 'Trade zone · in zone',
      r3: 'Max trades / day · 2 left',
      r4: 'Cooldown · off',
      on: 'On'
    },
    problem: {
      title: 'The plan holds — until the click',
      subtitle:
        'Revenge trades, oversized size, trading outside the session: one impulsive order can undo a week of discipline.',
      p1: { title: 'Outside the session', desc: 'You said you stop at 16:00. Emotion keeps the chart open.' },
      p2: { title: 'Outside the zone', desc: 'The setup is gone. The finger still hits Buy.' },
      p3: {
        title: 'Past the limit',
        desc: 'Max trades or daily loss already hit — yet another order goes through.'
      }
    },
    how: {
      title: 'How it works',
      subtitle:
        'Define rules once. Connect NinjaTrader. Choose Enabled when you want orders blocked — or stay in monitoring.',
      enable: {
        tag: 'Enabled',
        title: 'Orders can be blocked',
        desc: 'When Enabled and connected, Safeguard can block entries that break your rules — before they hit the market.'
      },
      monitor: {
        tag: 'Disabled / not connected',
        title: 'Monitoring only',
        desc: 'Rules and status still update. You see why a trade would be blocked or accepted — without enforcement.'
      },
      s1: {
        title: 'Set your rules',
        desc: 'Session, zones, lots, daily limits, cooldown, exit/SL — in the Safeguard app.'
      },
      s2: {
        title: 'Install the addon',
        desc: 'Close NinjaTrader → 2-Install-Addon.bat → F5. To remove: 4-Uninstall-Addon.bat → F5.'
      },
      s3: {
        title: 'Enable when ready',
        desc: 'Flip to Enabled for live protection. Status panel shows allowed vs blocked reasons.'
      }
    },
    rules: {
      title: 'Plan rules',
      subtitle: 'Eight discipline controls — the same ones in the Safeguard app.',
      session: {
        title: 'Session',
        desc: 'Allow trading only inside your defined time window and timezone.'
      },
      zone: {
        title: 'Trade zone',
        desc: 'Entries outside your allowed price zones can be blocked.'
      },
      lot: {
        title: 'Max lot',
        desc: 'Cap size per entry so impulse cannot oversize the position.'
      },
      trades: {
        title: 'Max trades / day',
        desc: 'When the daily count is done, further entries stop.'
      },
      cooldown: {
        title: 'Cooldown',
        desc: 'Enforce a pause between trades so emotion cannot reopen risk.'
      },
      exit: {
        title: 'Exit / SL discipline',
        desc: 'Protect stop-loss behaviour — limit unsafe SL modifications.'
      },
      lossTrade: {
        title: 'Max loss / trade',
        desc: 'Cap risk per trade; can close if floating loss exceeds the limit.'
      },
      lossDay: {
        title: 'Max daily loss',
        desc: 'Hard stop for the day when cumulative loss hits your ceiling.'
      }
    },
    extras: {
      capital: {
        title: 'Capital',
        desc: 'Set account capital used as context for risk limits.'
      },
      hours: {
        title: 'Usage hours',
        desc: 'Define when you intend to trade — aligned with your session rules.'
      },
      status: {
        title: 'Status & reasons',
        desc: 'Live status panel: Allowed / Blocked / Monitoring — with rule-by-rule reasons.'
      }
    },
    pricing: {
      title: 'Try it. Then go Pro.',
      subtitle: 'Start with a free trial on one PC. Upgrade when you want full-year protection.',
      trial: {
        name: 'Trial',
        priceHtml: '7 days <small>free</small>',
        desc: 'Full Safeguard trial for NinjaTrader 8 — one PC per Paychek account.',
        f1: 'All plan rules',
        f2: 'Enable + monitoring',
        f3: 'Activate on licence.html',
        cta: 'Activate trial'
      },
      pro: {
        name: 'Pro',
        priceHtml: '~$69 <small>/ year</small>',
        desc: 'Annual Pro licence after the trial. Checkout opens when payment is configured on your account.',
        f1: '1-year Pro key',
        f2: 'Same discipline stack',
        f3: 'Managed from your licence page',
        cta: 'Upgrade to Pro',
        ctaLicence: 'Open licence'
      }
    },
    cta: {
      title: 'Same brand. Different job.',
      body: 'Paychek Journal helps you analyze. Paychek Safeguard helps you obey the plan while you trade in NinjaTrader.',
      primary: 'Try / Activate',
      download: 'Download',
      journal: 'Discover Journal'
    },
    footer: {
      copyright: '© 2026 PAYCHEK — ALL RIGHTS RESERVED.',
      blog: 'Blog',
      contact: 'Contact',
      licence: 'Licence'
    }
  },

  fr: {
    meta: {
      title: 'Paychek Safeguard | Discipline pour NinjaTrader',
      description:
        'Paychek Safeguard — addon de discipline NinjaTrader 8. Enabled bloque les ordres hors règles ; monitoring si désactivé. Session, zones, lots, limites, cooldown, exit/SL. Essai 7 jours.'
    },
    nav: { journal: 'Journal', safeguard: 'Safeguard', login: 'Connexion', signup: "S'inscrire" },
    hero: {
      chip: 'Addon de discipline NinjaTrader 8',
      titleHtml:
        '<span class="sg-hero-brand">PAYCHEK</span><span class="sg-hero-product">SAFEGUARD</span>',
      subtitleHtml:
        'Vos règles restent actives — <strong>Enabled</strong> bloque les ordres hors plan ; désactivé, le monitoring continue.',
      ctaPrimary: "Démarrer l'essai",
      ctaDownload: 'Télécharger',
      ctaAuth: "S'inscrire",
      platform: 'Windows · essai 7 jours · 1 PC',
      addon: 'Add-on pour NinjaTrader 8'
    },
    visual: {
      capital: 'Capital',
      hours: "Heures d'usage",
      enabled: 'Enabled',
      statusLabel: 'Statut discipline',
      statusMain: 'Vous pouvez trader',
      allowed: 'Autorisé',
      r1: 'Session · dans la fenêtre',
      r2: 'Zone de trade · dans la zone',
      r3: 'Trades max / jour · 2 restants',
      r4: 'Temps de pause · off',
      on: 'Activé'
    },
    problem: {
      title: 'Le plan tient — jusqu’au clic',
      subtitle:
        'Revenge trades, taille trop grosse, hors session : un ordre impulsif peut effacer une semaine de discipline.',
      p1: {
        title: 'Hors session',
        desc: 'Vous aviez dit stop à 16h. L’émotion garde le graphique ouvert.'
      },
      p2: {
        title: 'Hors zone',
        desc: 'Le setup n’est plus là. Le doigt appuie quand même sur Buy.'
      },
      p3: {
        title: 'Au-delà de la limite',
        desc: 'Max trades ou perte du jour déjà atteints — un nouvel ordre passe encore.'
      }
    },
    how: {
      title: 'Comment ça marche',
      subtitle:
        'Définissez les règles. Connectez NinjaTrader. Passez en Enabled pour bloquer — ou restez en monitoring.',
      enable: {
        tag: 'Enabled',
        title: 'Les ordres peuvent être bloqués',
        desc: 'Quand Enabled et connecté, Safeguard peut bloquer les entrées hors règles — avant le marché.'
      },
      monitor: {
        tag: 'Désactivé / non connecté',
        title: 'Monitoring seul',
        desc: 'Les règles et le statut se mettent à jour. Vous voyez pourquoi un trade serait bloqué ou accepté.'
      },
      s1: {
        title: 'Définissez vos règles',
        desc: 'Session, zones, lots, limites du jour, cooldown, exit/SL — dans l’app Safeguard.'
      },
      s2: {
        title: 'Installez l’addon',
        desc: 'Fermer NinjaTrader → 2-Install-Addon.bat → F5. Pour retirer : 4-Uninstall-Addon.bat → F5.'
      },
      s3: {
        title: 'Activez quand prêt',
        desc: 'Passez en Enabled pour la protection live. Le panneau de statut montre les raisons.'
      }
    },
    rules: {
      title: 'Règles du plan',
      subtitle: 'Huit contrôles de discipline — les mêmes que dans l’app Safeguard.',
      session: {
        title: 'Session',
        desc: 'Autorisez le trading uniquement dans votre fenêtre horaire et fuseau.'
      },
      zone: {
        title: 'Zone de trade',
        desc: 'Les entrées hors zones de prix autorisées peuvent être bloquées.'
      },
      lot: {
        title: 'Lot max',
        desc: 'Plafonnez la taille par entrée pour éviter le surdimensionnement.'
      },
      trades: {
        title: 'Trades max / jour',
        desc: 'Quand le compteur du jour est atteint, les entrées s’arrêtent.'
      },
      cooldown: {
        title: 'Temps de pause',
        desc: 'Imposez une pause entre les trades pour que l’émotion ne rouvre pas le risque.'
      },
      exit: {
        title: 'Discipline Exit / SL',
        desc: 'Protégez le comportement du stop-loss — limitez les modifications dangereuses.'
      },
      lossTrade: {
        title: 'Perte max / trade',
        desc: 'Plafond de risque par trade ; peut clôturer si la perte flottante dépasse la limite.'
      },
      lossDay: {
        title: 'Perte max journalière',
        desc: 'Stop dur du jour quand la perte cumulée atteint votre plafond.'
      }
    },
    extras: {
      capital: {
        title: 'Capital',
        desc: 'Définissez le capital utilisé comme contexte pour les limites de risque.'
      },
      hours: {
        title: "Heures d'usage",
        desc: 'Indiquez quand vous comptez trader — aligné avec vos règles de session.'
      },
      status: {
        title: 'Statut & raisons',
        desc: 'Panneau live : Autorisé / Bloqué / Monitoring — avec raisons règle par règle.'
      }
    },
    pricing: {
      title: 'Essayez. Puis passez Pro.',
      subtitle: 'Commencez avec un essai gratuit sur un PC. Passez Pro pour une année complète.',
      trial: {
        name: 'Essai',
        priceHtml: '7 jours <small>gratuit</small>',
        desc: 'Essai Safeguard complet pour NinjaTrader 8 — un PC par compte Paychek.',
        f1: 'Toutes les règles',
        f2: 'Enabled + monitoring',
        f3: 'Activation sur licence.html',
        cta: "Activer l'essai"
      },
      pro: {
        name: 'Pro',
        priceHtml: '~69 $ <small>/ an</small>',
        desc: 'Licence Pro annuelle après l’essai. Le paiement s’ouvre quand l’URL est configurée.',
        f1: 'Clé Pro 1 an',
        f2: 'Même stack de discipline',
        f3: 'Géré depuis votre page licence',
        cta: 'Passer Pro',
        ctaLicence: 'Ouvrir la licence'
      }
    },
    cta: {
      title: 'Même marque. Autre mission.',
      body: 'Paychek Journal vous aide à analyser. Paychek Safeguard vous aide à respecter le plan dans NinjaTrader.',
      primary: 'Essayer / Activer',
      download: 'Télécharger',
      journal: 'Découvrir le Journal'
    },
    footer: {
      copyright: '© 2026 PAYCHEK — TOUS DROITS RÉSERVÉS.',
      blog: 'Blog',
      contact: 'Contact',
      licence: 'Licence'
    }
  },

  de: {
    meta: {
      title: 'Paychek Safeguard | Disziplin für NinjaTrader',
      description:
        'Paychek Safeguard — NinjaTrader-8-Disziplin-Addon. Enabled blockiert Orders außerhalb der Regeln; Monitoring wenn deaktiviert. 7-Tage-Test.'
    },
    nav: { journal: 'Journal', safeguard: 'Safeguard', login: 'Anmelden', signup: 'Registrieren' },
    hero: {
      chip: 'NinjaTrader-8-Disziplin-Addon',
      titleHtml:
        '<span class="sg-hero-brand">PAYCHEK</span><span class="sg-hero-product">SAFEGUARD</span>',
      subtitleHtml:
        'Ihre Regeln bleiben aktiv — <strong>Enabled</strong> blockiert Orders außerhalb des Plans; deaktiviert weiter Monitoring.',
      ctaPrimary: 'Gratis-Test starten',
      ctaDownload: 'Herunterladen',
      ctaAuth: 'Registrieren',
      platform: 'Windows · 7-Tage-Test · 1 PC',
      addon: 'Add-on für NinjaTrader 8'
    },
    visual: {
      capital: 'Kapital',
      hours: 'Nutzungszeiten',
      enabled: 'Enabled',
      statusLabel: 'Disziplin-Status',
      statusMain: 'Sie können traden',
      allowed: 'Erlaubt',
      r1: 'Session · im Fenster',
      r2: 'Trade-Zone · in Zone',
      r3: 'Max. Trades / Tag · 2 übrig',
      r4: 'Abkühlzeit · aus',
      on: 'An'
    },
    problem: {
      title: 'Der Plan hält — bis zum Klick',
      subtitle:
        'Revenge-Trades, zu große Size, außerhalb der Session: ein Impuls-Order kann eine Woche Disziplin zunichte machen.',
      p1: {
        title: 'Außerhalb der Session',
        desc: 'Sie wollten um 16:00 stoppen. Emotion hält den Chart offen.'
      },
      p2: {
        title: 'Außerhalb der Zone',
        desc: 'Das Setup ist weg. Der Finger drückt trotzdem Buy.'
      },
      p3: {
        title: 'Über dem Limit',
        desc: 'Max-Trades oder Tagesverlust schon erreicht — trotzdem eine weitere Order.'
      }
    },
    how: {
      title: 'So funktioniert’s',
      subtitle:
        'Regeln einmal setzen. NinjaTrader verbinden. Enabled zum Blockieren — oder Monitoring behalten.',
      enable: {
        tag: 'Enabled',
        title: 'Orders können blockiert werden',
        desc: 'Bei Enabled und Verbindung kann Safeguard Entries außerhalb der Regeln blockieren — vor dem Markt.'
      },
      monitor: {
        tag: 'Deaktiviert / nicht verbunden',
        title: 'Nur Monitoring',
        desc: 'Regeln und Status aktualisieren sich. Sie sehen, warum ein Trade blockiert oder akzeptiert würde.'
      },
      s1: {
        title: 'Regeln setzen',
        desc: 'Session, Zonen, Lots, Tageslimits, Cooldown, Exit/SL — in der Safeguard-App.'
      },
      s2: {
        title: 'Addon installieren',
        desc: 'NinjaTrader schließen → 2-Install-Addon.bat → F5. Entfernen: 4-Uninstall-Addon.bat → F5.'
      },
      s3: {
        title: 'Aktivieren wenn bereit',
        desc: 'Auf Enabled für Live-Schutz. Status zeigt Allowed vs Blocked Gründe.'
      }
    },
    rules: {
      title: 'Planregeln',
      subtitle: 'Acht Disziplin-Kontrollen — dieselben wie in der Safeguard-App.',
      session: {
        title: 'Session',
        desc: 'Trading nur im definierten Zeitfenster und Zeitzone erlauben.'
      },
      zone: {
        title: 'Trade-Zone',
        desc: 'Entries außerhalb erlaubter Preiszonen können blockiert werden.'
      },
      lot: {
        title: 'Max. Lot',
        desc: 'Größe pro Entry deckeln, damit Impuls nicht oversized.'
      },
      trades: {
        title: 'Max. Trades / Tag',
        desc: 'Wenn das Tageskontingent voll ist, stoppen weitere Entries.'
      },
      cooldown: {
        title: 'Abkühlzeit',
        desc: 'Pause zwischen Trades erzwingen, damit Emotion Risiko nicht neu öffnet.'
      },
      exit: {
        title: 'Exit- / SL-Disziplin',
        desc: 'Stop-Loss-Verhalten schützen — unsichere SL-Änderungen begrenzen.'
      },
      lossTrade: {
        title: 'Max. Verlust / Trade',
        desc: 'Risiko pro Trade deckeln; kann schließen wenn Floating-Loss die Grenze überschreitet.'
      },
      lossDay: {
        title: 'Max. Tagesverlust',
        desc: 'Harter Tagesstopp wenn kumulativer Verlust die Decke erreicht.'
      }
    },
    extras: {
      capital: {
        title: 'Kapital',
        desc: 'Kontokapital als Kontext für Risikolimits setzen.'
      },
      hours: {
        title: 'Nutzungszeiten',
        desc: 'Festlegen, wann Sie traden wollen — abgestimmt auf Session-Regeln.'
      },
      status: {
        title: 'Status & Gründe',
        desc: 'Live-Panel: Allowed / Blocked / Monitoring — mit Gründen je Regel.'
      }
    },
    pricing: {
      title: 'Testen. Dann Pro.',
      subtitle: 'Kostenloser Test auf einem PC. Upgrade für ein volles Jahr Schutz.',
      trial: {
        name: 'Test',
        priceHtml: '7 Tage <small>gratis</small>',
        desc: 'Vollständiger Safeguard-Test für NinjaTrader 8 — ein PC pro Paychek-Konto.',
        f1: 'Alle Planregeln',
        f2: 'Enabled + Monitoring',
        f3: 'Aktivierung auf licence.html',
        cta: 'Test aktivieren'
      },
      pro: {
        name: 'Pro',
        priceHtml: '~69 $ <small>/ Jahr</small>',
        desc: 'Jährliche Pro-Lizenz nach dem Test. Checkout wenn Zahlung konfiguriert ist.',
        f1: '1-Jahres-Pro-Key',
        f2: 'Gleicher Disziplin-Stack',
        f3: 'Verwaltet auf der Lizenzseite',
        cta: 'Upgrade auf Pro',
        ctaLicence: 'Lizenz öffnen'
      }
    },
    cta: {
      title: 'Gleiche Marke. Andere Aufgabe.',
      body: 'Paychek Journal hilft beim Analysieren. Paychek Safeguard hilft, den Plan in NinjaTrader einzuhalten.',
      primary: 'Testen / Aktivieren',
      download: 'Herunterladen',
      journal: 'Journal entdecken'
    },
    footer: {
      copyright: '© 2026 PAYCHEK — ALLE RECHTE VORBEHALTEN.',
      blog: 'Blog',
      contact: 'Kontakt',
      licence: 'Lizenz'
    }
  },

  es: {
    meta: {
      title: 'Paychek Safeguard | Disciplina para NinjaTrader',
      description:
        'Paychek Safeguard — addon de disciplina NinjaTrader 8. Enabled bloquea órdenes fuera de reglas; monitoreo si está desactivado. Prueba 7 días.'
    },
    nav: { journal: 'Diario', safeguard: 'Safeguard', login: 'Iniciar sesión', signup: 'Registrarse' },
    hero: {
      chip: 'Addon de disciplina NinjaTrader 8',
      titleHtml:
        '<span class="sg-hero-brand">PAYCHEK</span><span class="sg-hero-product">SAFEGUARD</span>',
      subtitleHtml:
        'Tus reglas siguen activas — <strong>Enabled</strong> bloquea órdenes fuera del plan; desactivado, sigue el monitoreo.',
      ctaPrimary: 'Empezar prueba',
      ctaDownload: 'Descargar',
      ctaAuth: 'Registrarse',
      platform: 'Windows · prueba 7 días · 1 PC',
      addon: 'Add-on para NinjaTrader 8'
    },
    visual: {
      capital: 'Capital',
      hours: 'Horas de uso',
      enabled: 'Enabled',
      statusLabel: 'Estado de disciplina',
      statusMain: 'Puedes operar',
      allowed: 'Permitido',
      r1: 'Sesión · dentro de la ventana',
      r2: 'Zona de trade · en zona',
      r3: 'Trades máx. / día · 2 restantes',
      r4: 'Enfriamiento · off',
      on: 'Activo'
    },
    problem: {
      title: 'El plan aguanta — hasta el clic',
      subtitle:
        'Revenge trades, tamaño excesivo, fuera de sesión: una orden impulsiva puede borrar una semana de disciplina.',
      p1: {
        title: 'Fuera de sesión',
        desc: 'Dijiste stop a las 16:00. La emoción mantiene el gráfico abierto.'
      },
      p2: {
        title: 'Fuera de zona',
        desc: 'El setup ya no está. El dedo sigue pulsando Buy.'
      },
      p3: {
        title: 'Más allá del límite',
        desc: 'Max trades o pérdida diaria ya alcanzada — y otra orden entra.'
      }
    },
    how: {
      title: 'Cómo funciona',
      subtitle:
        'Define reglas. Conecta NinjaTrader. Pasa a Enabled para bloquear — o quédate en monitoreo.',
      enable: {
        tag: 'Enabled',
        title: 'Las órdenes pueden bloquearse',
        desc: 'Con Enabled y conexión, Safeguard puede bloquear entradas fuera de reglas — antes del mercado.'
      },
      monitor: {
        tag: 'Desactivado / no conectado',
        title: 'Solo monitoreo',
        desc: 'Las reglas y el estado se actualizan. Ves por qué un trade sería bloqueado o aceptado.'
      },
      s1: {
        title: 'Define tus reglas',
        desc: 'Session, zonas, lots, límites diarios, cooldown, exit/SL — en la app Safeguard.'
      },
      s2: {
        title: 'Instala el addon',
        desc: 'Cerrar NinjaTrader → 2-Install-Addon.bat → F5. Quitar: 4-Uninstall-Addon.bat → F5.'
      },
      s3: {
        title: 'Activa cuando estés listo',
        desc: 'Pasa a Enabled para protección en vivo. El panel muestra razones Allowed / Blocked.'
      }
    },
    rules: {
      title: 'Reglas del plan',
      subtitle: 'Ocho controles de disciplina — los mismos de la app Safeguard.',
      session: {
        title: 'Sesión',
        desc: 'Permite operar solo dentro de tu ventana horaria y zona horaria.'
      },
      zone: {
        title: 'Zona de trade',
        desc: 'Las entradas fuera de las zonas de precio permitidas pueden bloquearse.'
      },
      lot: {
        title: 'Lote máx.',
        desc: 'Limita el tamaño por entrada para que el impulso no sobredimensione.'
      },
      trades: {
        title: 'Trades máx. / día',
        desc: 'Cuando se agota el contador del día, se detienen más entradas.'
      },
      cooldown: {
        title: 'Enfriamiento',
        desc: 'Impone una pausa entre trades para que la emoción no reabra el riesgo.'
      },
      exit: {
        title: 'Disciplina Exit / SL',
        desc: 'Protege el stop-loss — limita modificaciones peligrosas del SL.'
      },
      lossTrade: {
        title: 'Pérdida máx. / trade',
        desc: 'Tope de riesgo por trade; puede cerrar si la pérdida flotante supera el límite.'
      },
      lossDay: {
        title: 'Pérdida máx. diaria',
        desc: 'Parada dura del día cuando la pérdida acumulada llega al techo.'
      }
    },
    extras: {
      capital: {
        title: 'Capital',
        desc: 'Define el capital usado como contexto para los límites de riesgo.'
      },
      hours: {
        title: 'Horas de uso',
        desc: 'Indica cuándo piensas operar — alineado con tus reglas de sesión.'
      },
      status: {
        title: 'Estado y motivos',
        desc: 'Panel en vivo: Permitido / Bloqueado / Monitoreo — con motivos por regla.'
      }
    },
    pricing: {
      title: 'Pruébalo. Luego Pro.',
      subtitle: 'Empieza con una prueba gratis en un PC. Pasa a Pro para un año completo.',
      trial: {
        name: 'Prueba',
        priceHtml: '7 días <small>gratis</small>',
        desc: 'Prueba completa de Safeguard para NinjaTrader 8 — un PC por cuenta Paychek.',
        f1: 'Todas las reglas',
        f2: 'Enabled + monitoreo',
        f3: 'Activación en licence.html',
        cta: 'Activar prueba'
      },
      pro: {
        name: 'Pro',
        priceHtml: '~69 $ <small>/ año</small>',
        desc: 'Licencia Pro anual tras la prueba. El pago se abre si la URL está configurada.',
        f1: 'Clave Pro 1 año',
        f2: 'Misma pila de disciplina',
        f3: 'Gestionado en tu página de licencia',
        cta: 'Pasar a Pro',
        ctaLicence: 'Abrir licencia'
      }
    },
    cta: {
      title: 'Misma marca. Otro trabajo.',
      body: 'Paychek Journal te ayuda a analizar. Paychek Safeguard te ayuda a respetar el plan en NinjaTrader.',
      primary: 'Probar / Activar',
      download: 'Descargar',
      journal: 'Descubrir el Diario'
    },
    footer: {
      copyright: '© 2026 PAYCHEK — TODOS LOS DERECHOS RESERVADOS.',
      blog: 'Blog',
      contact: 'Contacto',
      licence: 'Licencia'
    }
  },

  pt: {
    meta: {
      title: 'Paychek Safeguard | Disciplina para NinjaTrader',
      description:
        'Paychek Safeguard — addon de disciplina NinjaTrader 8. Enabled bloqueia ordens fora das regras; monitorização se desativado. Teste 7 dias.'
    },
    nav: { journal: 'Diário', safeguard: 'Safeguard', login: 'Entrar', signup: 'Criar conta' },
    hero: {
      chip: 'Addon de disciplina NinjaTrader 8',
      titleHtml:
        '<span class="sg-hero-brand">PAYCHEK</span><span class="sg-hero-product">SAFEGUARD</span>',
      subtitleHtml:
        'As suas regras mantêm-se — <strong>Enabled</strong> bloqueia ordens fora do plano; desativado, a monitorização continua.',
      ctaPrimary: 'Iniciar teste',
      ctaDownload: 'Descarregar',
      ctaAuth: 'Criar conta',
      platform: 'Windows · teste 7 dias · 1 PC',
      addon: 'Add-on para NinjaTrader 8'
    },
    visual: {
      capital: 'Capital',
      hours: 'Horas de uso',
      enabled: 'Enabled',
      statusLabel: 'Estado de disciplina',
      statusMain: 'Pode operar',
      allowed: 'Permitido',
      r1: 'Sessão · dentro da janela',
      r2: 'Zona de trade · na zona',
      r3: 'Trades máx. / dia · 2 restantes',
      r4: 'Pausa · off',
      on: 'Ativo'
    },
    problem: {
      title: 'O plano aguenta — até ao clique',
      subtitle:
        'Revenge trades, tamanho excessivo, fora da sessão: uma ordem impulsiva pode apagar uma semana de disciplina.',
      p1: {
        title: 'Fora da sessão',
        desc: 'Disse que parava às 16:00. A emoção mantém o gráfico aberto.'
      },
      p2: {
        title: 'Fora da zona',
        desc: 'O setup já não está. O dedo continua a carregar Buy.'
      },
      p3: {
        title: 'Além do limite',
        desc: 'Max trades ou perda diária já atingidos — e outra ordem passa.'
      }
    },
    how: {
      title: 'Como funciona',
      subtitle:
        'Defina regras. Ligue o NinjaTrader. Passe a Enabled para bloquear — ou fique em monitorização.',
      enable: {
        tag: 'Enabled',
        title: 'As ordens podem ser bloqueadas',
        desc: 'Com Enabled e ligado, o Safeguard pode bloquear entradas fora das regras — antes do mercado.'
      },
      monitor: {
        tag: 'Desativado / não ligado',
        title: 'Só monitorização',
        desc: 'As regras e o estado atualizam-se. Vê por que um trade seria bloqueado ou aceite.'
      },
      s1: {
        title: 'Defina as regras',
        desc: 'Session, zonas, lots, limites diários, cooldown, exit/SL — na app Safeguard.'
      },
      s2: {
        title: 'Instale o addon',
        desc: 'Fechar NinjaTrader → 2-Install-Addon.bat → F5. Remover: 4-Uninstall-Addon.bat → F5.'
      },
      s3: {
        title: 'Ative quando estiver pronto',
        desc: 'Passe a Enabled para proteção em direto. O painel mostra razões Allowed / Blocked.'
      }
    },
    rules: {
      title: 'Regras do plano',
      subtitle: 'Oito controlos de disciplina — os mesmos da app Safeguard.',
      session: {
        title: 'Sessão',
        desc: 'Permita operar só dentro da sua janela horária e fuso.'
      },
      zone: {
        title: 'Zona de trade',
        desc: 'Entradas fora das zonas de preço permitidas podem ser bloqueadas.'
      },
      lot: {
        title: 'Lote máx.',
        desc: 'Limite o tamanho por entrada para o impulso não sobredimensionar.'
      },
      trades: {
        title: 'Trades máx. / dia',
        desc: 'Quando o contador do dia acaba, as entradas param.'
      },
      cooldown: {
        title: 'Pausa (cooldown)',
        desc: 'Imponha uma pausa entre trades para a emoção não reabrir o risco.'
      },
      exit: {
        title: 'Disciplina Exit / SL',
        desc: 'Proteja o stop-loss — limite alterações perigosas do SL.'
      },
      lossTrade: {
        title: 'Perda máx. / trade',
        desc: 'Teto de risco por trade; pode fechar se a perda flutuante exceder o limite.'
      },
      lossDay: {
        title: 'Perda máx. diária',
        desc: 'Paragem dura do dia quando a perda acumulada atinge o teto.'
      }
    },
    extras: {
      capital: {
        title: 'Capital',
        desc: 'Defina o capital usado como contexto para os limites de risco.'
      },
      hours: {
        title: 'Horas de uso',
        desc: 'Indique quando pretende operar — alinhado com as regras de sessão.'
      },
      status: {
        title: 'Estado e motivos',
        desc: 'Painel em direto: Permitido / Bloqueado / Monitorização — com motivos por regra.'
      }
    },
    pricing: {
      title: 'Experimente. Depois Pro.',
      subtitle: 'Comece com um teste grátis num PC. Passe a Pro para um ano completo.',
      trial: {
        name: 'Teste',
        priceHtml: '7 dias <small>grátis</small>',
        desc: 'Teste completo do Safeguard para NinjaTrader 8 — um PC por conta Paychek.',
        f1: 'Todas as regras',
        f2: 'Enabled + monitorização',
        f3: 'Ativação em licence.html',
        cta: 'Ativar teste'
      },
      pro: {
        name: 'Pro',
        priceHtml: '~69 $ <small>/ ano</small>',
        desc: 'Licença Pro anual após o teste. O pagamento abre se o URL estiver configurado.',
        f1: 'Chave Pro 1 ano',
        f2: 'Mesma stack de disciplina',
        f3: 'Gerido na página de licença',
        cta: 'Passar a Pro',
        ctaLicence: 'Abrir licença'
      }
    },
    cta: {
      title: 'Mesma marca. Outro trabalho.',
      body: 'Paychek Journal ajuda a analisar. Paychek Safeguard ajuda a cumprir o plano no NinjaTrader.',
      primary: 'Experimentar / Ativar',
      download: 'Descarregar',
      journal: 'Descobrir o Diário'
    },
    footer: {
      copyright: '© 2026 PAYCHEK — TODOS OS DIREITOS RESERVADOS.',
      blog: 'Blog',
      contact: 'Contacto',
      licence: 'Licença'
    }
  },

  ko: {
    meta: {
      title: 'Paychek Safeguard | NinjaTrader를 위한 규율',
      description:
        'Paychek Safeguard — NinjaTrader 8 규율 애드온. Enabled면 규칙 밖 주문을 차단하고, 비활성 시에도 모니터링. 7일 체험.'
    },
    nav: { journal: '저널', safeguard: 'Safeguard', login: '로그인', signup: '가입하기' },
    hero: {
      chip: 'NinjaTrader 8 규율 애드온',
      titleHtml:
        '<span class="sg-hero-brand">PAYCHEK</span><span class="sg-hero-product">SAFEGUARD</span>',
      subtitleHtml:
        '규칙은 유지됩니다 — <strong>Enabled</strong>는 계획 밖 주문을 차단하고, 꺼져 있어도 모니터링합니다.',
      ctaPrimary: '무료 체험 시작',
      ctaDownload: '다운로드',
      ctaAuth: '가입하기',
      platform: 'Windows · 7일 체험 · PC 1대',
      addon: 'NinjaTrader 8 애드온'
    },
    visual: {
      capital: '자본',
      hours: '사용 시간',
      enabled: 'Enabled',
      statusLabel: '규율 상태',
      statusMain: '거래 가능',
      allowed: '허용',
      r1: '세션 · 시간 내',
      r2: '트레이드 존 · 존 안',
      r3: '일일 최대 거래 · 2회 남음',
      r4: '쿨다운 · 끔',
      on: '켜짐'
    },
    problem: {
      title: '계획은 유지됩니다 — 클릭 전까지',
      subtitle:
        '복수 매매, 과다 사이즈, 세션 밖 거래: 한 번의 충동 주문이 일주일의 규율을 무너뜨릴 수 있습니다.',
      p1: {
        title: '세션 밖',
        desc: '16:00에 끝내겠다고 했지만, 감정은 차트를 열어 둡니다.'
      },
      p2: {
        title: '존 밖',
        desc: '셋업은 사라졌습니다. 그래도 Buy를 누릅니다.'
      },
      p3: {
        title: '한도 초과',
        desc: '일일 거래 수나 손실 한도에 이미 도달했는데도 또 주문이 나갑니다.'
      }
    },
    how: {
      title: '작동 방식',
      subtitle:
        '규칙을 한 번 정하고 NinjaTrader를 연결하세요. 차단하려면 Enabled, 아니면 모니터링만.',
      enable: {
        tag: 'Enabled',
        title: '주문을 차단할 수 있음',
        desc: 'Enabled이고 연결되면, Safeguard는 규칙 밖 진입을 시장 전에 차단할 수 있습니다.'
      },
      monitor: {
        tag: '비활성 / 미연결',
        title: '모니터링만',
        desc: '규칙과 상태는 계속 갱신됩니다. 차단·수락 사유를 강제 없이 확인할 수 있습니다.'
      },
      s1: {
        title: '규칙 설정',
        desc: 'Session, 존, 랏, 일일 한도, 쿨다운, Exit/SL — Safeguard 앱에서.'
      },
      s2: {
        title: '애드온 설치',
        desc: 'NinjaTrader 종료 → 2-Install-Addon.bat → F5. 제거: 4-Uninstall-Addon.bat → F5.'
      },
      s3: {
        title: '준비되면 Enable',
        desc: '실시간 보호를 위해 Enabled로 전환. 상태 패널에 허용/차단 사유가 표시됩니다.'
      }
    },
    rules: {
      title: '플랜 규칙',
      subtitle: '여덟 가지 규율 컨트롤 — Safeguard 앱과 동일합니다.',
      session: {
        title: '세션',
        desc: '정의한 시간대와 타임존 안에서만 거래를 허용합니다.'
      },
      zone: {
        title: '트레이드 존',
        desc: '허용 가격 존 밖의 진입은 차단될 수 있습니다.'
      },
      lot: {
        title: '최대 랏',
        desc: '진입당 사이즈를 제한해 충동적인 과다 포지션을 막습니다.'
      },
      trades: {
        title: '일일 최대 거래',
        desc: '일일 횟수가 끝나면 추가 진입이 멈춥니다.'
      },
      cooldown: {
        title: '쿨다운',
        desc: '거래 사이 쿨다운을 강제해 감정이 위험을 다시 열지 못하게 합니다.'
      },
      exit: {
        title: 'Exit / SL 규율',
        desc: '스탑로스 동작을 보호하고 위험한 SL 수정을 제한합니다.'
      },
      lossTrade: {
        title: '거래당 최대 손실',
        desc: '거래당 리스크를 제한하고, 평가손실이 한도를 넘으면 청산할 수 있습니다.'
      },
      lossDay: {
        title: '일일 최대 손실',
        desc: '누적 손실이 한도에 도달하면 그날 거래를 강하게 멈춥니다.'
      }
    },
    extras: {
      capital: {
        title: '자본',
        desc: '리스크 한도의 기준으로 사용할 계좌 자본을 설정합니다.'
      },
      hours: {
        title: '사용 시간',
        desc: '거래하려는 시간을 정의합니다 — 세션 규칙과 맞춥니다.'
      },
      status: {
        title: '상태 & 사유',
        desc: '실시간 패널: 허용 / 차단 / 모니터링 — 규칙별 사유 표시.'
      }
    },
    pricing: {
      title: '체험 후 Pro',
      subtitle: 'PC 1대에서 무료 체험을 시작하세요. 연간 보호를 원하면 Pro로 업그레이드하세요.',
      trial: {
        name: '체험',
        priceHtml: '7일 <small>무료</small>',
        desc: 'NinjaTrader 8용 Safeguard 전체 체험 — Paychek 계정당 PC 1대.',
        f1: '모든 플랜 규칙',
        f2: 'Enabled + 모니터링',
        f3: 'licence.html에서 활성화',
        cta: '체험 활성화'
      },
      pro: {
        name: 'Pro',
        priceHtml: '~$69 <small>/ 년</small>',
        desc: '체험 후 연간 Pro 라이선스. 결제 URL이 설정되면 체크아웃이 열립니다.',
        f1: '1년 Pro 키',
        f2: '동일한 규율 스택',
        f3: '라이선스 페이지에서 관리',
        cta: 'Pro로 업그레이드',
        ctaLicence: '라이선스 열기'
      }
    },
    cta: {
      title: '같은 브랜드. 다른 역할.',
      body: 'Paychek Journal은 분석을 돕습니다. Paychek Safeguard는 NinjaTrader에서 계획을 지키게 돕습니다.',
      primary: '체험 / 활성화',
      download: '다운로드',
      journal: '저널 알아보기'
    },
    footer: {
      copyright: '© 2026 PAYCHEK — 모든 권리 보유.',
      blog: '블로그',
      contact: '문의',
      licence: '라이선스'
    }
  }
};
