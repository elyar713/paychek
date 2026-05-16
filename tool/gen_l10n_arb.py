# -*- coding: utf-8 -*-
"""GÃ©nÃ¨re lib/l10n/app_*.arb Ã  partir des tables ci-dessous."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "lib" / "localization"

# ClÃ©s communes â€” texte EN, FR, ES, PT, KO, ZH_TW
K = {
    "navDashboard": (
        "Dashboard", "Dashboard", "Panel", "Painel", "ëŒ€ì‹œë³´ë“œ", "å„€è¡¨æ¿",
    ),
    "navTrade": ("Trade", "Trade", "Trading", "Trading", "ê±°ëž˜", "äº¤æ˜“"),
    "navAdd": ("Add", "Ajouter", "AÃ±adir", "Adicionar", "ì¶”ê°€", "æ–°å¢ž"),
    "navCalendar": ("Calendar", "Calendrier", "Calendario", "CalendÃ¡rio", "ìº˜ë¦°ë”", "æ—¥æ›†"),
    "navMore": ("More", "Plus", "MÃ¡s", "Mais", "ë”ë³´ê¸°", "æ›´å¤š"),
    "plusDashboard": (
        "Dashboard", "Dashboard", "Panel", "Painel", "ëŒ€ì‹œë³´ë“œ", "å„€è¡¨æ¿",
    ),
    "plusTrade": ("Trade", "Trade", "Trading", "Trading", "ê±°ëž˜", "äº¤æ˜“"),
    "plusAdd": ("Add", "Ajouter", "AÃ±adir", "Adicionar", "ì¶”ê°€", "æ–°å¢ž"),
    "plusCalendar": ("Calendar", "Calendrier", "Calendario", "CalendÃ¡rio", "ìº˜ë¦°ë”", "æ—¥æ›†"),
    "plusMentalState": (
        "Mental state", "Ã‰tat mental", "Estado mental", "Estado mental", "ë©˜íƒˆ", "å¿ƒç†ç‹€æ…‹",
    ),
    "plusMyStrategy": (
        "My strategy", "Ma stratÃ©gie", "Mi estrategia", "Minha estratÃ©gia", "ë‚´ ì „ëžµ", "æˆ‘çš„ç­–ç•¥",
    ),
    "plusMyAnalysis": (
        "My analysis", "Mon analyse", "Mi anÃ¡lisis", "Minha anÃ¡lise", "ë‚´ ë¶„ì„", "æˆ‘çš„åˆ†æž",
    ),
    "plusPerformance": (
        "Performance", "Performance", "Rendimiento", "Desempenho", "ì„±ê³¼", "ç¸¾æ•ˆ",
    ),
    "plusChecklist": ("Checklist", "Checklist", "Lista", "Checklist", "ì²´í¬ë¦¬ìŠ¤íŠ¸", "æª¢æŸ¥æ¸…å–®"),
    "plusCalculator": (
        "Calculator", "Calculatrice", "Calculadora", "Calculadora", "ê³„ì‚°ê¸°", "è¨ˆç®—æ©Ÿ",
    ),
    "plusSettings": ("Settings", "RÃ©glages", "Ajustes", "ConfiguraÃ§Ãµes", "ì„¤ì •", "è¨­å®š"),
    "settingsTitle": ("Settings", "RÃ©glages", "Ajustes", "ConfiguraÃ§Ãµes", "ì„¤ì •", "è¨­å®š"),
    "languageSection": ("Language", "Langue", "Idioma", "Idioma", "ì–¸ì–´", "èªžè¨€"),
    "tradingSection": ("Trading", "Trading", "Trading", "Trading", "íŠ¸ë ˆì´ë”©", "äº¤æ˜“"),
    "capitalLabel": ("Capital", "Capital", "Capital", "Capital", "ìžë³¸", "è³‡é‡‘"),
    "portfoliosLabel": ("Portfolios", "Portfolios", "Carteras", "Carteiras", "í¬íŠ¸í´ë¦¬ì˜¤", "æŠ•è³‡çµ„åˆ"),
    "deletePortfolioTitle": (
        "Delete â€œ{name}â€?",
        "Supprimer Â« {name} Â» ?",
        "Â¿Eliminar Â« {name} Â»?",
        "Excluir Â« {name} Â»?",
        "Â«{name}Â» ì‚­ì œ?",
        "è¦åˆªé™¤ã€Œ{name}ã€å—Žï¼Ÿ",
    ),
    "cancel": ("Cancel", "Annuler", "Cancelar", "Cancelar", "ì·¨ì†Œ", "å–æ¶ˆ"),
    "delete": ("Delete", "Supprimer", "Eliminar", "Excluir", "ì‚­ì œ", "åˆªé™¤"),
    "capitalTooltip": (
        "Capital and currency (main account)",
        "Capital et devise (compte principal)",
        "Capital y divisa (cuenta principal)",
        "Capital e moeda (conta principal)",
        "ìžë³¸ ë° í†µí™”(ë©”ì¸ ê³„ì •)",
        "è³‡é‡‘èˆ‡å¹£åˆ¥ï¼ˆä¸»å¸³æˆ¶ï¼‰",
    ),
    "editPortfolioTooltip": (
        "Edit name, capital, currency",
        "Modifier nom, capital, devise",
        "Editar nombre, capital, divisa",
        "Editar nome, capital, moeda",
        "ì´ë¦„Â·ìžë³¸Â·í†µí™” íŽ¸ì§‘",
        "ç·¨è¼¯åç¨±ã€è³‡é‡‘ã€å¹£åˆ¥",
    ),
    "deleteTooltip": ("Delete", "Supprimer", "Eliminar", "Excluir", "ì‚­ì œ", "åˆªé™¤"),
    "addPortfolio": (
        "Add portfolio",
        "Ajouter un portefeuille",
        "AÃ±adir cartera",
        "Adicionar carteira",
        "í¬íŠ¸í´ë¦¬ì˜¤ ì¶”ê°€",
        "æ–°å¢žæŠ•è³‡çµ„åˆ",
    ),
    "splashTagline": (
        "For real traders",
        "Pour les vrais traders",
        "Para traders de verdad",
        "Para traders de verdade",
        "ì§„ì§œ íŠ¸ë ˆì´ë”ë¥¼ ìœ„í•´",
        "çµ¦çœŸæ­£çš„äº¤æ˜“è€…",
    ),
    "homePerformance": ("Performance", "Performance", "Rendimiento", "Desempenho", "ì„±ê³¼", "ç¸¾æ•ˆ"),
    "languageDialogTitle": (
        "Choose language",
        "Choisir la langue",
        "Elegir idioma",
        "Escolher idioma",
        "ì–¸ì–´ ì„ íƒ",
        "é¸æ“‡èªžè¨€",
    ),
    "languageDialogSubtitle": (
        "Interface language",
        "Langue de lâ€™interface",
        "Idioma de la interfaz",
        "Idioma da interface",
        "ì¸í„°íŽ˜ì´ìŠ¤ ì–¸ì–´",
        "ä»‹é¢èªžè¨€",
    ),
    "langEnglish": ("English", "English", "English", "English", "English", "English"),
    "langSpanish": ("EspaÃ±ol", "EspaÃ±ol", "EspaÃ±ol", "EspaÃ±ol", "EspaÃ±ol", "EspaÃ±ol"),
    "langFrench": ("FranÃ§ais", "FranÃ§ais", "FrancÃ©s", "FrancÃªs", "í”„ëž‘ìŠ¤ì–´", "æ³•èªž"),
    "langPortuguese": ("PortuguÃªs", "PortuguÃªs", "PortuguÃ©s", "PortuguÃªs", "í¬ë¥´íˆ¬ê°ˆì–´", "è‘¡è„ç‰™èªž"),
    "langKorean": ("í•œêµ­ì–´", "í•œêµ­ì–´", "Coreano", "Coreano", "í•œêµ­ì–´", "éŸ“èªž"),
    "langChineseTraditional": ("ä¸­æ–‡ (ç¹é«”)", "ä¸­æ–‡ (ç¹é«”)", "Chino (tradicional)", "ChinÃªs (tradicional)", "ì¤‘êµ­ì–´(ë²ˆì²´)", "ä¸­æ–‡ï¼ˆç¹é«”ï¼‰"),
    "resultDontWorry": ("Don't worry", "T'inquiÃ¨te", "No te preocupes", "NÃ£o se preocupe", "ê±±ì • ë§ˆ", "åˆ¥æ“”å¿ƒ"),
    "resultHeaderSub": (
        "This isn't your profileâ€”it's just a calculation; nothing is real yet. It all starts now.",
        "Ce n'est pas ton profil , c'est juste un calcul , rien n'est encore rÃ©el. Tout commence maintenant.",
        "No es tu perfil, solo un cÃ¡lculo; aÃºn nada es real. Todo empieza ahora.",
        "NÃ£o Ã© o seu perfil â€” Ã© sÃ³ um cÃ¡lculo; nada Ã© real ainda. Tudo comeÃ§a agora.",
        "í”„ë¡œí•„ì´ ì•„ë‹ˆë¼ ê³„ì‚°ì¼ ë¿, ì•„ì§ í˜„ì‹¤ì€ ì•„ë‹™ë‹ˆë‹¤. ì§€ê¸ˆë¶€í„°ìž…ë‹ˆë‹¤.",
        "é€™ä¸æ˜¯ä½ çš„æª”æ¡ˆï¼Œåªæ˜¯è¨ˆç®—ï¼›å°šéžçœŸå¯¦ã€‚ä¸€åˆ‡å¾žç¾åœ¨é–‹å§‹ã€‚",
    ),
    "resultLabelGlobal": ("Global", "Global", "Global", "Global", "ì „ì²´", "æ•´é«”"),
    "resultLabelProfil": ("Profile", "Profil", "Perfil", "Perfil", "í”„ë¡œí•„", "æª”æ¡ˆ"),
    "resultLabelStrategy": ("Strategy", "StratÃ©gie", "Estrategia", "EstratÃ©gia", "ì „ëžµ", "ç­–ç•¥"),
    "resultLabelPsychology": ("Psychology", "Psychologie", "PsicologÃ­a", "Psicologia", "ì‹¬ë¦¬", "å¿ƒç†"),
    "resultStatBullet1": (
        "{percent}% of traders at this level stagnate or lose due to lack of mathematical rigor.",
        "{percent}% des traders de ce niveau stagnent ou perdent par manque de rigueur mathÃ©matique.",
        "El {percent}% de traders en este nivel estancan o pierden por falta de rigor matemÃ¡tico.",
        "{percent}% dos traders neste nÃ­vel estagnam ou perdem por falta de rigor matemÃ¡tico.",
        "ì´ ìˆ˜ì¤€ íŠ¸ë ˆì´ë”ì˜ {percent}%ëŠ” ìˆ˜í•™ì  ì—„ë°€í•¨ ë¶€ì¡±ìœ¼ë¡œ ì •ì²´ë˜ê±°ë‚˜ ì†ì‹¤ì„ ë´…ë‹ˆë‹¤.",
        "æ­¤å±¤ç´šçš„äº¤æ˜“è€…ä¸­ï¼Œ{percent}% å› ç¼ºä¹æ•¸å­¸ç´€å¾‹è€Œåœæ»¯æˆ–è™§æã€‚",
    ),
    "resultStatBullet2": (
        "{percent}% of traders are in the same situation.",
        "{percent}% des traders sont dans la mÃªme situation.",
        "El {percent}% de traders estÃ¡n en la misma situaciÃ³n.",
        "{percent}% dos traders estÃ£o na mesma situaÃ§Ã£o.",
        "íŠ¸ë ˆì´ë”ì˜ {percent}%ê°€ ê°™ì€ ìƒí™©ìž…ë‹ˆë‹¤.",
        "{percent}% çš„äº¤æ˜“è€…è™•æ–¼ç›¸åŒè™•å¢ƒã€‚",
    ),
    "resultStatBullet3": (
        "A trader with strong psychology trades better than one who knows 100 strategies.",
        "Un trader avec une bonne psychologie trade mieux qu'un trader qui connaÃ®t 100 stratÃ©gies.",
        "Un trader con buena psicologÃ­a opera mejor que uno que conoce 100 estrategias.",
        "Um trader com boa psicologia opera melhor que um que conhece 100 estratÃ©gias.",
        "ì‹¬ë¦¬ê°€ ê°•í•œ íŠ¸ë ˆì´ë”ëŠ” 100ê°€ì§€ ì „ëžµì„ ì•„ëŠ” ì‚¬ëžŒë³´ë‹¤ ìž˜í•©ë‹ˆë‹¤.",
        "å¿ƒç†ç´ è³ªå¥½çš„äº¤æ˜“è€…ï¼Œæ¯”æ‡‚ä¸€ç™¾ç¨®ç­–ç•¥çš„äººäº¤æ˜“å¾—æ›´å¥½ã€‚",
    ),
    "capitalInitialTitle": ("Initial capital", "Capital initial", "Capital inicial", "Capital inicial", "ì´ˆê¸° ìžë³¸", "åˆå§‹è³‡é‡‘"),
    "capitalCurrencyTitle": ("Currency", "Devise", "Divisa", "Moeda", "í†µí™”", "å¹£åˆ¥"),
    "capitalHintAmount": ("e.g. 10 450", "ex. 10 450", "ej. 10 450", "ex. 10 450", "ì˜ˆ: 10 450", "ä¾‹ï¼š10 450"),
    "capitalOther": ("other", "autre", "otra", "outra", "ê¸°íƒ€", "å…¶ä»–"),
    "capitalEllipsis": ("â€¦", "â€¦", "â€¦", "â€¦", "â€¦", "â€¦"),
    "customCurrencyTitle": ("Other currency", "Autre devise", "Otra divisa", "Outra moeda", "ê¸°íƒ€ í†µí™”", "å…¶ä»–å¹£åˆ¥"),
    "currencyNameLabel": ("Currency name", "Nom de la devise", "Nombre de la divisa", "Nome da moeda", "í†µí™” ì´ë¦„", "å¹£åˆ¥åç¨±"),
    "currencyNameHint": ("e.g. CHF, XOF", "ex. CHF, XOF", "ej. CHF, XOF", "ex. CHF, XOF", "ì˜ˆ: CHF, XOF", "ä¾‹ï¼šCHFã€XOF"),
    "symbolLabel": ("Symbol", "Symbole", "SÃ­mbolo", "SÃ­mbolo", "ê¸°í˜¸", "ç¬¦è™Ÿ"),
    "symbolHint": ("e.g. Fr, â‚£", "ex. Fr, â‚£", "ej. Fr, â‚£", "ex. Fr, â‚£", "ì˜ˆ: Fr, â‚£", "ä¾‹ï¼šFrã€â‚£"),
    "validate": ("Confirm", "Valider", "Confirmar", "Confirmar", "í™•ì¸", "ç¢ºèª"),
    "errorNameOrSymbol": (
        "Enter at least a name or a symbol.",
        "Renseignez au moins le nom ou le symbole.",
        "Indica al menos el nombre o el sÃ­mbolo.",
        "Informe pelo menos o nome ou o sÃ­mbolo.",
        "ì´ë¦„ ë˜ëŠ” ê¸°í˜¸ë¥¼ í•˜ë‚˜ ì´ìƒ ìž…ë ¥í•˜ì„¸ìš”.",
        "è«‹è‡³å°‘å¡«å¯«åç¨±æˆ–ç¬¦è™Ÿã€‚",
    ),
    "errorAmount": ("Enter a valid amount (â‰¥ 0).", "Entrez un montant valide (â‰¥ 0).", "Introduce un importe vÃ¡lido (â‰¥ 0).", "Insira um valor vÃ¡lido (â‰¥ 0).", "ìœ íš¨í•œ ê¸ˆì•¡(â‰¥ 0)ì„ ìž…ë ¥í•˜ì„¸ìš”.", "è«‹è¼¸å…¥æœ‰æ•ˆé‡‘é¡ï¼ˆâ‰¥ 0ï¼‰ã€‚"),
    "errorInvalidAmount": (
        "Invalid amount or currency.",
        "Montant ou devise invalide.",
        "Importe o divisa no vÃ¡lidos.",
        "Valor ou moeda invÃ¡lidos.",
        "ê¸ˆì•¡ ë˜ëŠ” í†µí™”ê°€ ìž˜ëª»ë˜ì—ˆìŠµë‹ˆë‹¤.",
        "é‡‘é¡æˆ–å¹£åˆ¥ç„¡æ•ˆã€‚",
    ),
}

# Questionnaire Q1
Q1 = {
    "q1Title": (
        "What kind of trader are you?",
        "Quel type de trader ?",
        "Â¿QuÃ© tipo de trader eres?",
        "Que tipo de trader vocÃª Ã©?",
        "ì–´ë–¤ íŠ¸ë ˆì´ë”ì¸ê°€ìš”?",
        "ä½ æ˜¯å“ªä¸€ç¨®äº¤æ˜“è€…ï¼Ÿ",
    ),
    "q1Slogan": (
        "Choose your approach",
        "Choisissez votre approche",
        "Elige tu enfoque",
        "Escolha sua abordagem",
        "ì ‘ê·¼ ë°©ì‹ì„ ì„ íƒí•˜ì„¸ìš”",
        "é¸æ“‡ä½ çš„æ–¹å¼",
    ),
    "q1o1t": ("Scalping", "Scalping", "Scalping", "Scalping", "ìŠ¤ìº˜í•‘", "ç•¶æ²–çŸ­ç·š"),
    "q1o1s": (
        "Positions from seconds to a few minutes",
        "Positions de quelques secondes Ã  quelques minutes",
        "Posiciones de segundos a pocos minutos",
        "PosiÃ§Ãµes de segundos a poucos minutos",
        "ëª‡ ì´ˆì—ì„œ ëª‡ ë¶„ê¹Œì§€ì˜ í¬ì§€ì…˜",
        "æŒå€‰æ•¸ç§’åˆ°æ•¸åˆ†é˜",
    ),
    "q1o2t": ("Day trading", "Day trading", "Day trading", "Day trading", "ë°ì´ íŠ¸ë ˆì´ë”©", "æ—¥å…§äº¤æ˜“"),
    "q1o2s": (
        "All positions are closed before the session ends",
        "Toutes les positions sont fermÃ©es avant la fin de la sÃ©ance",
        "Todas las posiciones se cierran antes del cierre",
        "Todas as posiÃ§Ãµes fecham antes do fim da sessÃ£o",
        "ì„¸ì…˜ ì¢…ë£Œ ì „ì— ëª¨ë“  í¬ì§€ì…˜ ì²­ì‚°",
        "æ”¶ç›¤å‰å…¨éƒ¨å¹³å€‰",
    ),
    "q1o3t": ("Intraday", "Intraday", "IntradÃ­a", "Intraday", "ì¸íŠ¸ë¼ë°ì´", "ç›¤ä¸­"),
    "q1o3s": (
        "Positions held between 1 and 3 days",
        "Positions maintenues entre 1 et 3 jours",
        "Posiciones de 1 a 3 dÃ­as",
        "PosiÃ§Ãµes de 1 a 3 dias",
        "1~3ì¼ ë³´ìœ  í¬ì§€ì…˜",
        "æŒå€‰ 1 è‡³ 3 æ—¥",
    ),
    "q1o4t": ("Swing", "Swing", "Swing", "Swing", "ìŠ¤ìœ™", "æ³¢æ®µ"),
    "q1o4s": (
        "Positions held over several days or weeks",
        "Positions maintenues sur plusieurs jours ou semaines",
        "Posiciones de varios dÃ­as o semanas",
        "PosiÃ§Ãµes por vÃ¡rios dias ou semanas",
        "ë©°ì¹ ~ëª‡ ì£¼ ë³´ìœ  í¬ì§€ì…˜",
        "æŒå€‰æ•¸æ—¥è‡³æ•¸é€±",
    ),
}

Q2 = {
    "q2Title": (
        "Experience profile",
        "Profil d'ExpÃ©rience",
        "Perfil de experiencia",
        "Perfil de experiÃªncia",
        "ê²½í—˜ í”„ë¡œí•„",
        "ç¶“é©—è¼ªå»“",
    ),
    "q2Slogan": (
        "Where are you on your journey?",
        "OÃ¹ en es-tu dans ton parcours ?",
        "Â¿DÃ³nde estÃ¡s en tu camino?",
        "Onde vocÃª estÃ¡ na sua jornada?",
        "ì—¬ì •ì—ì„œ ì–´ë””ì¯¤ì¸ê°€ìš”?",
        "ä½ åœ¨äº¤æ˜“è·¯ä¸Šçš„å“ªä¸€æ®µï¼Ÿ",
    ),
    "q2o1t": ("I don't have a strategy", "Je n'ai pas de stratÃ©gie", "No tengo estrategia", "NÃ£o tenho estratÃ©gia", "ì „ëžµì´ ì—†ë‹¤", "æˆ‘é‚„æ²’æœ‰ç­–ç•¥"),
    "q2o1s": ("You're not alone", "Tu n'es pas seul", "No estÃ¡s solo", "VocÃª nÃ£o estÃ¡ sÃ³", "í˜¼ìžê°€ ì•„ë‹™ë‹ˆë‹¤", "ä½ ä¸¦ä¸å­¤å–®"),
    "q2o1s2": (
        "For traders who are starting and still searching for their method",
        "Pour les traders qui dÃ©butent et cherchent encore leur mÃ©thode",
        "Para quienes empiezan y aÃºn buscan su mÃ©todo",
        "Para quem estÃ¡ comeÃ§ando e ainda busca seu mÃ©todo",
        "ì´ì œ ì‹œìž‘í•´ ë°©ë²•ì„ ì°¾ëŠ” íŠ¸ë ˆì´ë”ìš©",
        "çµ¦å‰›èµ·æ­¥ã€ä»åœ¨æ‘¸ç´¢æ–¹æ³•çš„äº¤æ˜“è€…",
    ),
    "q2o2t": ("I have my strategy", "J'ai ma stratÃ©gie", "Tengo mi estrategia", "Tenho minha estratÃ©gia", "ë‚´ ì „ëžµì´ ìžˆë‹¤", "æˆ‘æœ‰è‡ªå·±çš„ç­–ç•¥"),
    "q2o2s": ("Light at the end of the tunnel", "La lumiÃ¨re au bout du tunnel", "Luz al final del tÃºnel", "Luz no fim do tÃºnel", "í„°ë„ ëì˜ ë¹›", "éš§é“ç›¡é ­çš„å…‰"),
    "q2o2s2": (
        "For those with the basics who want consistency",
        "Pour ceux qui ont les bases mais cherchent la rÃ©gularitÃ©",
        "Para quienes tienen bases pero buscan constancia",
        "Para quem tem o bÃ¡sico e busca regularidade",
        "ê¸°ì´ˆëŠ” ìžˆì§€ë§Œ ê¾¸ì¤€í•¨ì„ ì›í•˜ëŠ” ë¶„",
        "æœ‰åŸºç¤Žã€æƒ³è¿½æ±‚ç©©å®šçš„äºº",
    ),
    "q2o3t": ("Performant", "Performant", "Rendimiento", "Performance", "ìš°ìˆ˜í•œ ì„±ê³¼", "è¡¨ç¾çªå‡º"),
    "q2o3s": (
        "The hardest part is behind you",
        "Le plus dur est derriÃ¨re toi",
        "Lo peor ya pasÃ³",
        "O pior jÃ¡ passou",
        "ê°€ìž¥ íž˜ë“  ë•ŒëŠ” ì§€ë‚˜ê°”ìŠµë‹ˆë‹¤",
        "æœ€é›£çš„å·²ç¶“éŽåŽ»",
    ),
    "q2o3s2": (
        "For experienced traders who master their stats",
        "Pour les traders expÃ©rimentÃ©s qui maÃ®trisent leur statistique",
        "Para traders experimentados que dominan sus estadÃ­sticas",
        "Para traders experientes que dominam suas estatÃ­sticas",
        "í†µê³„ë¥¼ ê¿°ëš«ëŠ” ìˆ™ë ¨ íŠ¸ë ˆì´ë”ìš©",
        "çµ¦ç†Ÿç·´æŽŒæ¡æ•¸æ“šçš„è³‡æ·±äº¤æ˜“è€…",
    ),
}

Q3 = {
    "q3Title": (
        "What do you want to improve?",
        "Que veux-tu amÃ©liorer ?",
        "Â¿QuÃ© quieres mejorar?",
        "O que vocÃª quer melhorar?",
        "ë¬´ì—‡ì„ ê°œì„ í•˜ê³  ì‹¶ë‚˜ìš”?",
        "ä½ æƒ³æ”¹é€²ä»€éº¼ï¼Ÿ",
    ),
    "q3Slogan": (
        "Pick your top priority",
        "Choisis ton objectif prioritaire",
        "Elige tu prioridad",
        "Escolha sua prioridade",
        "ìµœìš°ì„  ëª©í‘œë¥¼ ê³ ë¥´ì„¸ìš”",
        "é¸æ“‡ä½ çš„é¦–è¦ç›®æ¨™",
    ),
    "q3o1t": ("OFF THE ROLLER COASTER", "SORTIR DES MONTAGNES RUSSES", "SALIR DE LA MONTAÃ‘A RUSA", "SAIR DA MONTANHA-RUSSA", "ë¡¤ëŸ¬ì½”ìŠ¤í„°ì—ì„œ ë‚´ë ¤ì˜¤ê¸°", "åˆ¥å†åé›²éœ„é£›è»Š"),
    "q3o1s": (
        "Stop winning one day to lose it all the next.",
        "ArrÃªter de gagner un jour pour tout perdre le lendemain.",
        "Dejar de ganar un dÃ­a para perderlo todo al siguiente.",
        "Parar de ganhar um dia para perder tudo no outro.",
        "í•˜ë£¨ ë²Œê³  ë‹¤ìŒ ë‚  ìžƒëŠ” íŒ¨í„´ì„ ëŠê¸°",
        "åˆ¥å†ä¸€å¤©è³ºä¸€å¤©è³ ",
    ),
    "q3o1s2": (
        "To stabilize your equity curve and avoid the emotional elevator.",
        "Pour stabiliser sa courbe de capital et Ã©viter l'ascenseur Ã©motionnel.",
        "Para estabilizar tu curva de capital y evitar el ascensor emocional.",
        "Para estabilizar sua curva e evitar o elevador emocional.",
        "ìžë³¸ ê³¡ì„ ì„ ì•ˆì •ì‹œí‚¤ê³  ê°ì •ì˜ ì—˜ë¦¬ë² ì´í„°ë¥¼ í”¼í•˜ê¸°",
        "ç©©å®šè³‡é‡‘æ›²ç·šï¼Œé é›¢æƒ…ç·’å‡é™æ¢¯",
    ),
    "q3o2t": ("BECOME A SNIPER", "DEVENIR UN SNIPER", "SER UN FRANCOTIRADOR", "SER UM ATIRADOR DE ELITE", "ì €ê²©ìˆ˜ê°€ ë˜ê¸°", "æˆç‚ºç‹™æ“Šæ‰‹"),
    "q3o2s": (
        "Improve win rate and entry precision.",
        "AmÃ©liorer mon taux de rÃ©ussite et la prÃ©cision de mes entrÃ©es.",
        "Mejorar la tasa de acierto y la precisiÃ³n de entradas.",
        "Melhorar taxa de acerto e precisÃ£o de entradas.",
        "ìŠ¹ë¥ ê³¼ ì§„ìž… ì •í™•ë„ë¥¼ ë†’ì´ê¸°",
        "æé«˜å‹çŽ‡èˆ‡é€²å ´ç²¾æº–åº¦",
    ),
    "q3o2s2": (
        "For those who want to win more often by choosing better trades.",
        "Pour ceux qui veulent gagner plus souvent en sÃ©lectionnant mieux leurs trades.",
        "Para quienes quieren ganar mÃ¡s eligiendo mejores trades.",
        "Para quem quer ganhar mais escolhendo melhores trades.",
        "ë” ë‚˜ì€ ê±°ëž˜ ì„ íƒìœ¼ë¡œ ìžì£¼ ì´ê¸°ê³  ì‹¶ì€ ë¶„",
        "æƒ³é€éŽæ›´å¥½çš„ç¯©é¸æé«˜å‹çŽ‡çš„äºº",
    ),
    "q3o3t": ("STAY ICE-COLD", "RESTER DE MARBRE", "PERMANECER FRÃO", "PERMANECER DE MÃRMORE", "ëƒ‰ì •í•¨ ìœ ì§€", "ä¿æŒå†·éœå¦‚å†°"),
    "q3o3s": (
        "Master discipline and stop emotional decisions.",
        "MaÃ®triser ma discipline et stopper les dÃ©cisions sous le coup de l'Ã©motion.",
        "Dominar la disciplina y frenar decisiones emocionales.",
        "Dominar disciplina e parar decisÃµes emocionais.",
        "ê·œìœ¨ì„ ì§€í‚¤ê³  ê°ì •ì  ê²°ì •ì„ ë©ˆì¶”ê¸°",
        "æŽŒæ¡ç´€å¾‹ï¼Œåœæ­¢æƒ…ç·’æ±ºç­–",
    ),
    "q3o3s2": (
        "To remove impulsive trading and follow your plan 100%.",
        "Pour Ã©liminer le trading impulsif et respecter son plan Ã  100%.",
        "Para eliminar el trading impulsivo y cumplir el plan al 100%.",
        "Para eliminar trades impulsivos e seguir o plano 100%.",
        "ì¶©ë™ ë§¤ë§¤ë¥¼ ì—†ì• ê³  ê³„íš 100% ì¤€ìˆ˜",
        "æ¶ˆé™¤è¡å‹•äº¤æ˜“ã€ç™¾åˆ†ä¹‹ç™¾éµå®ˆè¨ˆç•«",
    ),
    "q3o4t": ("FIND YOUR SIGNATURE", "TROUVER MA SIGNATURE", "ENCONTRAR TU FIRMA", "ENCONTRAR SUA ASSINATURA", "ë‚˜ë§Œì˜ ì‹œê·¸ë‹ˆì²˜ ì°¾ê¸°", "æ‰¾åˆ°ä½ çš„æ‹›ç‰Œæ‰“æ³•"),
    "q3o4s": (
        "Understand which chart patterns truly work for you.",
        "Comprendre les schÃ©mas graphiques qui fonctionnent rÃ©ellement pour moi.",
        "Entender quÃ© patrones grÃ¡ficos realmente funcionan para ti.",
        "Entender quais padrÃµes funcionam de verdade para vocÃª.",
        "ë‚˜ì—ê²Œ ì§„ì§œ í†µí•˜ëŠ” ì°¨íŠ¸ íŒ¨í„´ ì´í•´í•˜ê¸°",
        "æžæ‡‚å“ªäº›åœ–è¡¨åž‹æ…‹çœŸçš„é©åˆä½ ",
    ),
    "q3o4s2": (
        "To spot your own winning patterns and become a specialist.",
        "Pour identifier ses propres modÃ¨les de rÃ©ussite et devenir un spÃ©cialiste.",
        "Para identificar tus propios patrones ganadores y volverte especialista.",
        "Para achar seus padrÃµes vencedores e virar especialista.",
        "ìžì‹ ë§Œì˜ ìˆ˜ìµ íŒ¨í„´ì„ ì°¾ê³  ì „ë¬¸ê°€ ë˜ê¸°",
        "æ‰¾å‡ºè‡ªå·±çš„ç²åˆ©æ¨¡å¼ï¼Œæˆç‚ºå°ˆå®¶",
    ),
}

Q4 = {
    "q4Title": (
        "What is your biggest challenge?",
        "Quel est ton plus grand dÃ©fi ?",
        "Â¿CuÃ¡l es tu mayor reto?",
        "Qual Ã© o seu maior desafio?",
        "ê°€ìž¥ í° ë‚œê´€ì€ ë¬´ì—‡ì¸ê°€ìš”?",
        "ä½ æœ€å¤§çš„æŒ‘æˆ°æ˜¯ä»€éº¼ï¼Ÿ",
    ),
    "q4Slogan": (
        "Identify what blocks you most",
        "Identifie ce qui te bloque le plus",
        "Identifica lo que mÃ¡s te frena",
        "Identifique o que mais te trava",
        "ê°€ìž¥ ë§‰ëŠ” ê²ƒì„ ì°¾ê¸°",
        "æ‰¾å‡ºæœ€å¡ä½ä½ çš„é»ž",
    ),
    "q4o1t": ("FOMO", "FOMO", "FOMO", "FOMO", "FOMO", "FOMO"),
    "q4o1s": ("Fear of missing out.", "Peur de rater quelque chose.", "Miedo a perderse algo.", "Medo de perder algo.", "ë†“ì¹ ê¹Œ ë‘ë ¤ì›€", "éŒ¯å¤±ææ‡¼"),
    "q4o1s2": (
        "Quick, I'll miss the chance to profit!",
        "Vite, je vais rater l'occasion de gagner !",
        "Â¡RÃ¡pido, voy a perder la oportunidad de ganar!",
        "RÃ¡pido, vou perder a chance de lucrar!",
        "ì„œë‘˜ëŸ¬ì•¼ í•´, ìˆ˜ìµ ê¸°íšŒë¥¼ ë†“ì¹  ê±°ì•¼!",
        "å¿«é»žï¼Œæˆ‘è¦éŒ¯éŽç²åˆ©æ©Ÿæœƒäº†ï¼",
    ),
    "q4o2t": ("TILT", "TILT", "TILT", "TILT", "í‹¸íŠ¸", "å¤±æŽ§"),
    "q4o2s": ("Your heart replaced your brain.", "Ton cÅ“ur a remplacÃ© ton cerveau.", "El corazÃ³n sustituyÃ³ al cerebro.", "O coraÃ§Ã£o substituiu o cÃ©rebro.", "ë‡Œ ëŒ€ì‹  ì‹¬ìž¥ì´ ì›€ì§ìž„", "ç†æ™ºè¢«æƒ…ç·’å–ä»£"),
    "q4o2s2": (
        "No wayâ€”I MUST win my money back!",
        "C'est pas possible, je DOIS rÃ©cupÃ©rer mon argent !",
        "Â¡No puede ser, DEBO recuperar mi dinero!",
        "ImpossÃ­vel, PRECISO recuperar meu dinheiro!",
        "ì•ˆ ë¼, ë°˜ë“œì‹œ ëˆì„ ë˜ì°¾ì•„ì•¼ í•´!",
        "ä¸å¯èƒ½ï¼Œæˆ‘ä¸€å®šè¦æŠŠéŒ¢è³ºå›žä¾†ï¼",
    ),
    "q4o3t": ("TRADING BLIND", "TRADER Ã€ L'AVEUGLETTE", "OPERAR A CIEGAS", "OPERAR Ã€S CEGAS", "ë§¹ëª©ì  ë§¤ë§¤", "ç›²ç›®äº¤æ˜“"),
    "q4o3s": ("No clear strategy or plan.", "Pas de stratÃ©gie claire ni de plan.", "Sin estrategia clara ni plan.", "Sem estratÃ©gia clara nem plano.", "ëª…í™•í•œ ì „ëžµÂ·ê³„íš ì—†ìŒ", "æ²’æœ‰æ¸…æ¥šç­–ç•¥èˆ‡è¨ˆç•«"),
    "q4o4s2": (
        "I don't really know, but it feels goodâ€”let's try.",
        "Je ne sais pas trop, mais je le sens bienâ€¦ on tente le coup.",
        "No sÃ© bien, pero lo siento bienâ€¦ probemos.",
        "NÃ£o sei bem, mas sinto que dÃ¡â€¦ vamos tentar.",
        "ìž˜ ëª¨ë¥´ê² ì§€ë§Œ ê°ì´ ì¢‹ì•„â€¦ í•œë²ˆ í•´ë³´ìž",
        "ä¸å¤ªç¢ºå®šï¼Œä½†æ„Ÿè¦ºå°â€¦è©¦è©¦çœ‹",
    ),
    "q4o4t": ("OVERTRADING", "OVERTRADING", "SOBREOPERAR", "OVERTRADING", "ê³¼ë§¤ë§¤", "éŽåº¦äº¤æ˜“"),
    "q4o4s": ("Constant restlessness.", "L'agitation permanente.", "Inquietud constante.", "AgitaÃ§Ã£o constante.", "ëŠìž„ì—†ëŠ” ì•ˆì ˆë¶€ì ˆ", "åœä¸ä¸‹ä¾†çš„èºå‹•"),
    "q4o4s2": (
        "If I don't click, I feel like I'm not working.",
        "Si je ne clique pas, j'ai l'impression de ne pas travailler.",
        "Si no hago clic, siento que no trabajo.",
        "Se nÃ£o clico, sinto que nÃ£o trabalho.",
        "í´ë¦­í•˜ì§€ ì•Šìœ¼ë©´ ì¼í•˜ëŠ” ëŠë‚Œì´ ì•ˆ ë‚¨",
        "ä¸æŒ‰æ»‘é¼ å°±è¦ºå¾—æ²’åœ¨å·¥ä½œ",
    ),
    "q4o5t": ("OVERCONFIDENCE", "EXCÃˆS DE CONFIANCE", "SOBRECONFIANZA", "EXCESSO DE CONFIANÃ‡A", "ê³¼ì‹ ", "éŽåº¦è‡ªä¿¡"),
    "q4o5s": ("Thinking you're invincible.", "Se croire invincible.", "Creerte invencible.", "Achar-se invencÃ­vel.", "ë¬´ì ì´ë¼ ì°©ê°", "ä»¥ç‚ºè‡ªå·±ç„¡æ•µ"),
    "q4o5s2": (
        "I'm too goodâ€”easy money! I'll double the stake.",
        "Je suis trop fort, c'est de l'argent facile ! Je mise le double.",
        "Â¡Soy demasiado bueno, dinero fÃ¡cil! Duplico la apuesta.",
        "Sou forte demais, dinheiro fÃ¡cil! Dobro a aposta.",
        "ë„ˆë¬´ ìž˜í•´ì„œ ì‰¬ìš´ ëˆ! ë°°íŒ… ë‘ ë°°!",
        "æˆ‘å¤ªå¼·äº†ï¼Œè¼•é¬†è³ºï¼åŠ ç¢¼å…©å€ï¼",
    ),
    "q4o6t": ("PARALYSIS", "LA PARALYSIE", "PARÃLISIS", "PARALISIA", "ë§ˆë¹„", "ç™±ç˜“"),
    "q4o6s": ("Fear of everything.", "Peur de tout.", "Miedo a todo.", "Medo de tudo.", "ëª¨ë“  ê²ƒì´ ë‘ë ¤ì›€", "ä»€éº¼éƒ½æ€•"),
    "q4o6s2": (
        "I'm not sure, I'm afraid to lose again.",
        "Je ne suis pas sÃ»r, j'ai peur de perdre encore.",
        "No estoy seguro, me da miedo volver a perder.",
        "NÃ£o tenho certeza, tenho medo de perder de novo.",
        "ìž˜ ëª¨ë¥´ê² ê³  ë˜ ìžƒì„ê¹Œ ë´ ë‘ë ¤ì›€",
        "ä¸ç¢ºå®šï¼Œæ€•å†è³ ä¸€æ¬¡",
    ),
    "q4o7t": ("NO MONEY MANAGEMENT", "SANS MONEY MANAGEMENT", "SIN GESTIÃ“N DE CAPITAL", "SEM GESTÃƒO DE RISCO", "ë¨¸ë‹ˆê´€ë¦¬ ì—†ìŒ", "æ²’æœ‰è³‡é‡‘ç®¡ç†"),
    "q4o7s": ("Playing Russian roulette.", "Jouer Ã  la roulette russe.", "Ruleta rusa.", "Roleta russa.", "ëŸ¬ì‹œì•ˆ ë£°ë ›", "ä¿„ç¾…æ–¯è¼ªç›¤"),
    "q4o7s2": (
        "I'm putting everything on this tradeâ€”do or die.",
        "Je mets tout sur ce trade, Ã§a passe ou Ã§a casse !",
        "Â¡Pongo todo en este trade, o todo o nada!",
        "Coloco tudo nesse trade, vida ou morte!",
        "ì´ë²ˆ íŠ¸ë ˆì´ë“œì— ì˜¬ì¸, ì„±ê³µ ì•„ë‹ˆë©´ ë!",
        "é€™ç­†å…¨æŠ¼ï¼Œä¸æˆåŠŸä¾¿æˆä»ï¼",
    ),
}

# Fix Q4 option 3 - I had wrong keys - need q4o3s, q4o3s2 for blind trading
Q4_fix = {
    "q4o3t": Q4["q4o3t"],
    "q4o3s": ("No clear strategy or plan.", "Pas de stratÃ©gie claire ni de plan.", "Sin estrategia clara ni plan.", "Sem estratÃ©gia clara nem plano.", "ëª…í™•í•œ ì „ëžµÂ·ê³„íš ì—†ìŒ", "æ²’æœ‰æ¸…æ¥šç­–ç•¥èˆ‡è¨ˆç•«"),
    "q4o3s2": Q4["q4o4s2"],  # wrong - the blind subtitle2
}
# Actually re-read Q4 in script - I mixed q4o4. Let me fix Q4 dict manually in the merge

LOCALES = ["en", "fr", "es", "pt", "ko", "zh_TW"]
IDX = {loc: i for i, loc in enumerate(LOCALES)}


def pick(d, key, loc):
    return d[key][IDX[loc]]


def build_arb(loc: str) -> dict:
    out = {"@@locale": loc}
    parts = [K, Q1, Q2, Q3]
    # Rebuild Q4 correctly
    q4_clean = {
        "q4Title": Q4["q4Title"],
        "q4Slogan": Q4["q4Slogan"],
        "q4o1t": Q4["q4o1t"],
        "q4o1s": Q4["q4o1s"],
        "q4o1s2": Q4["q4o1s2"],
        "q4o2t": Q4["q4o2t"],
        "q4o2s": Q4["q4o2s"],
        "q4o2s2": Q4["q4o2s2"],
        "q4o3t": Q4["q4o3t"],
        "q4o3s": Q4["q4o3s"],
        "q4o3s2": (
            "I don't really know, but it feels goodâ€”let's try.",
            "Je ne sais pas trop, mais je le sens bienâ€¦ on tente le coup.",
            "No sÃ© bien, pero lo siento bienâ€¦ probemos.",
            "NÃ£o sei bem, mas sinto que dÃ¡â€¦ vamos tentar.",
            "ìž˜ ëª¨ë¥´ê² ì§€ë§Œ ê°ì´ ì¢‹ì•„â€¦ í•œë²ˆ í•´ë³´ìž",
            "ä¸å¤ªç¢ºå®šï¼Œä½†æ„Ÿè¦ºå°â€¦è©¦è©¦çœ‹",
        ),
        "q4o4t": Q4["q4o4t"],
        "q4o4s": Q4["q4o4s"],
        "q4o4s2": Q4["q4o4s2"],
        "q4o5t": Q4["q4o5t"],
        "q4o5s": Q4["q4o5s"],
        "q4o5s2": Q4["q4o5s2"],
        "q4o6t": Q4["q4o6t"],
        "q4o6s": Q4["q4o6s"],
        "q4o6s2": Q4["q4o6s2"],
        "q4o7t": Q4["q4o7t"],
        "q4o7s": Q4["q4o7s"],
        "q4o7s2": Q4["q4o7s2"],
    }
    for part in parts:
        for key, tup in part.items():
            out[key] = tup[IDX[loc]]
    for key, tup in q4_clean.items():
        out[key] = tup[IDX[loc]]
    # Placeholder metadata for deletePortfolioTitle
    out["@deletePortfolioTitle"] = {
        "placeholders": {"name": {"type": "String"}}
    }
    for pk in ["resultStatBullet1", "resultStatBullet2"]:
        out[f"@{pk}"] = {"placeholders": {"percent": {"type": "int"}}}
    return out


def main():
    OUT.mkdir(parents=True, exist_ok=True)
    for loc in LOCALES:
        fname = f"app_{loc}.arb" if loc != "zh_TW" else "app_zh_TW.arb"
        path = OUT / fname
        data = build_arb(loc)
        with open(path, "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=2)
        print("Wrote", path)


if __name__ == "__main__":
    main()


