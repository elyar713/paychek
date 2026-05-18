'use strict';

const fs = require('fs');
const path = require('path');

const dir = __dirname;
const jp = (o) => JSON.stringify(o, null, 2);
const read = (n) => JSON.parse(fs.readFileSync(path.join(dir, n), 'utf8'));
const w = (name, obj) => fs.writeFileSync(path.join(dir, name), jp(obj), 'utf8');

const en = read('landing-preview-modules-en.clean.json');

function patchDe(d) {
  d.dashboard.lead = 'Mit institutioneller Disziplin handeln nicht mit emotionalen Ausschlägen.';
  d.dashboard.descPoints[0].label = 'Kapital und Bilanz:';
  d.dashboard.descPoints[0].body = 'Liquiditätslage sofort transparent.';
  d.dashboard.descPoints[1].label = 'Ihre Spielnotiz:';
  d.dashboard.descPoints[1].body = 'Kein Suchen mehr im Chaos die Bias-Prüfung sitzt dort wo Risiko entschieden wird.';
  d.dashboard.descPoints[2].label = 'Checkliste:';
  d.dashboard.descPoints[2].body = 'Mit einem Tap bestätigen Sie jede Spielbuch-Regel direkt vom Kommandoland aus.';
  d.dashboard.descPoints[3].label = 'Mindset-Anzeige:';
  d.dashboard.descPoints[3].body = 'Zeiger zeigt ob Sie handeln dürfen oder die Session pausieren sollten.';
  d.dashboard.descPoints[4].label = 'Kalender:';
  d.dashboard.descPoints[4].body = 'Equity-Verlauf monatweise festgehalten.';
  d.dashboard.descPoints[5].label = 'Ihre Strategie:';
  d.dashboard.descPoints[5].body = 'Der Plan bleibt jederzeit sichtbar.';
  d.dashboard.imgAlts = ['PAYCHEK Dashboard Vorschau', 'PAYCHEK Dashboard Mindset Strategie Kalender'];
  d.checklist.lead = 'Ihr strukturelles Ampelsystem vor jeder Risikoannahme.';
  d.checklist.descPoints[0].label = '360-Grad-Validierung:';
  d.checklist.descPoints[0].body = 'Technik Risiko Kopf drei Achsen vor der Order.';
  d.checklist.descPoints[1].label = 'Visuelle Vollständigkeit:';
  d.checklist.descPoints[1].body = 'Der Ring füllt sich wenn alle Gates geschlossen sind nur dann ausführen.';
  d.checklist.descPoints[2].label = 'Keine Aussetzer:';
  d.checklist.descPoints[2].body = 'Money-Management in der Routine verankert.';
  d.checklist.descPoints[3].label = 'PDF-Belege:';
  d.checklist.descPoints[3].body = 'Nachweisbare Disziplin für Coach oder Investor exportieren.';
  d.checklist.imgAlt = 'PAYCHEK Checkliste Screenshot';
  d.mental.title = 'Mindset';
  d.mental.lead =
    'Der Markt straft Burnout PAYCHEK liefert die psychologische Freigabe mit stahlhart codierter Routine.';
  d.mental.descPoints[0].label = 'Performance Kompass:';
  d.mental.descPoints[0].body =
    'Readiness Score aus Schlaf Bewegung Fokusroutinen wenn Sie wirklich scharf sind.';
  d.mental.descPoints[1].label = 'Moment Snapshot:';
  d.mental.descPoints[1].body = 'Swipe für Fokus Energie Stress rote Warnung bevor Behavior bricht.';
  d.mental.descPoints[2].label = 'Emotions Telemetrie:';
  d.mental.descPoints[2].body = 'Euphorie Frust Neutralität labeln Revenge Tilts austrocknen.';
  d.mental.descPoints[3].label = 'Warmup Ritual:';
  d.mental.descPoints[3].body =
    'Professionelle Routinen vor Session werden bei fester Disziplin zu messbarer Routine.';
  d.mental.imgAlt = 'PAYCHEK Mindset Modul';
  d.analyse.title = 'Analysebereich';
  d.analyse.lead = 'Live-Dossiers mit Tradeplan Detailblöcken und Executive Wrap.';
  d.analyse.descPoints[0].label = 'Plan Arbeitsblatt:';
  d.analyse.descPoints[0].body = 'Richtung Timeframes Trend Regime Vertrauen auf einem Panel.';
  d.analyse.descPoints[1].label = 'Deep Dives:';
  d.analyse.descPoints[1].body = 'Struktur Indikatoren Smart Money Liquidität Volumprofile Screenshots.';
  d.analyse.descPoints[2].label = 'Executive Wrap:';
  d.analyse.descPoints[2].body = 'Schließen Sie mit Konfidenzwert gekoppelt an Instrument Historie.';
  d.analyse.imgAlts = [
    'PAYCHEK Wochenszenario Karte',
    'PAYCHEK Struktur Indikator SMC Blätter',
    'PAYCHEK Plan Arbeitsblatt Trading',
    'PAYCHEK Rollup Confidence Export Stack',
  ];
  d.strategie.lead = 'Viele verlieren den Plan unter Feuer PAYCHEK pinned ihn sichtbar damit Drift verliert.';
  d.strategie.descPoints[0].label = 'Eigene Säulen:';
  d.strategie.descPoints[0].body =
    'Rahmen exakt nach Ihrer Methodik keine Social Copypaste Playbooks.';
  d.strategie.descPoints[1].label = 'Konviktionsbuch:';
  d.strategie.descPoints[1].body = 'Jede Idee bekommt Textthese im Journal.';
  d.strategie.descPoints[2].label = 'Sofortige Ausrichtung:';
  d.strategie.descPoints[2].body = 'Dashboard blendet kontinuierlich Regeln keine Tab Navigation Panik.';
  d.strategie.descPoints[3].label = 'Setup Bewertung:';
  d.strategie.descPoints[3].body = 'Ideenscore vor Ausführung filtert mittelmäßige Setups upstream.';
  d.strategie.imgAlt = 'PAYCHEK Strategie Playbook Risiko Sessions';
  d.performance.lead = 'Hören Sie auf zu raten wo Blut floss quantifizieren Sie jede Reibungsstelle.';
  d.performance.descPoints[0].label = 'Mind Analytik:';
  d.performance.descPoints[0].body =
    'Prinzip Trades gegen Bauch Trades emotionaler Drag auf Expectancy zeigen.';
  d.performance.descPoints[1].label = 'Golden Hour Radar:';
  d.performance.descPoints[1].body = 'Stunden höchsten Ertragszug Fokus kondensieren.';
  d.performance.descPoints[2].label = 'Session Telemetrie:';
  d.performance.descPoints[2].body = 'Trefferquote Payoff Ratio Volum wie ein VolDesk Modelle tweakt.';
  d.performance.descPoints[3].label = 'Handelsintensität Guardrail:';
  d.performance.descPoints[3].body = 'Trades pro Tag Cap gegen Overtrade schützt Kapitalfluss.';
  d.performance.imgAlts = [
    'PAYCHEK Performance Volum Lots Symbole',
    'PAYCHEK Performance Zeitraster Payoff Zeitspanne',
    'PAYCHEK Performance Mind Strategie interplay',
  ];
  d.calendrier.title = 'Kalender';
  d.calendrier.lead = 'Chromatische Historie Stärken sichtbar Fehler chirurgisch kürzen.';
  d.calendrier.desc =
    'Monatsüberblick PnL Gewinnserie erkennen rote Sessions entmystifizieren ohne Mythos.';
  d.calendrier.imgAlt = 'PAYCHEK Kalender Monthly Net Metriken';
  d.trade.title = 'Trade Buch';
  d.trade.lead = 'Mehr als Klicks dokumentieren Institutional Grade Stories archivieren.';
  d.trade.descPoints[0].label = 'Chronologie:';
  d.trade.descPoints[0].body = 'Jede Position automatisch Net Profit Erwartung gerechnet.';
  d.trade.descPoints[1].label = 'Technisches Dossier:';
  d.trade.descPoints[1].body = 'Charts Thesis parallel damit später kein Context Rebuild.';
  d.trade.descPoints[2].label = 'Disziplin Forensik:';
  d.trade.descPoints[2].body = 'Sofort sehen welche Regeln live welche Impulse Übernahme.';
  d.trade.descPoints[3].label = 'Reflection Journal:';
  d.trade.descPoints[3].body =
    'Emotion Intuition Capture damit hindsight Playbook Evolution treibt.';
  d.trade.descPoints[4].label = 'Mikrometeriken:';
  d.trade.descPoints[4].body = 'True RR Exposure Zeit Gebührendrain ohne Ausreden KPI.';
  d.trade.imgAlts = [
    'PAYCHEK Trades Liste Filter PnL',
    'PAYCHEK Trade Detail Drill',
    'PAYCHEK Wochensession Recap',
  ];
  d.pdf.lead = 'Audit Pakete fuer Investoren oder Ihr späteres Ich mit Prozessbeweisen.';
  d.pdf.descPoints[0].label = 'Strategie Portfolio:';
  d.pdf.descPoints[0].body = 'Regeln Tech Säulen als signiertes Artefakt.';
  d.pdf.descPoints[1].label = 'Instrument Reviews:';
  d.pdf.descPoints[1].body = 'Szenarios Snapshots Sessions gebündelt archivieren.';
  d.pdf.descPoints[2].label = 'Trade Folioblätter:';
  d.pdf.descPoints[2].body = 'Jede Füllung mit Journal Tags Behavior Score Export.';
  d.pdf.descPoints[3].label = 'Rhythmus Audits:';
  d.pdf.descPoints[3].body = 'Woche PDF powering strukturierten Posttrade.';
  d.pdf.descPoints[4].label = 'Performance Dossiers:';
  d.pdf.descPoints[4].body = 'Daily Weekly Monthly Compounds Briefing-ready.';
  d.pdf.title = 'PDF Export';
  d.pdf.imgAlts = [
    'PAYCHEK PDF Journal Synopsis',
    'PAYCHEK PDF analytic brief',
    'PAYCHEK PDF playbook Risiko Sessions',
    'PAYCHEK PDF week rollup',
    'PAYCHEK PDF ticket dossier',
  ];
  d.csv.lead = 'Neun Venues Drop Export PAYCHEK matcht Schema selbstständig.';
  d.csv.descPoints[0].label = 'Interop Abdeckung:';
  d.csv.descPoints[0].body =
    'MT4 MT5 TradingView Tradovate cTrader NinjaTrader Quantower ATAS Rithmic.';
  d.csv.descPoints[1].label = 'Guided ingest:';
  d.csv.descPoints[1].body = 'Vendor Flows ohne manuelle Remap Theater.';
  d.csv.descPoints[2].label = 'Unified Blotter:';
  d.csv.descPoints[2].body = 'Imports erben analytic PDF pipeline automatisch.';
  d.csv.imgAlt = 'PAYCHEK CSV Wizard Venue Grid';
  d.ajouter.title = 'Trade hinzufügen';
  d.ajouter.lead = 'Erfassen mit Algorithmus-Präzision und diskretionärer Klarheit kombiniert.';
  d.ajouter.descPoints[0].label = 'Schnell Blotter:';
  d.ajouter.descPoints[0].body = 'Ultra low friction UI journaling habit bleibt.';
  d.ajouter.descPoints[1].label = 'Smart Netting:';
  d.ajouter.descPoints[1].body =
    'Entry Exit Fees automatisch Expectancy keine Spreadsheet Panik.';
  d.ajouter.descPoints[2].label = 'Behavior Gate:';
  d.ajouter.descPoints[2].body = 'Sofort markieren Regel adherence vs Impuls Slide.';
  d.ajouter.imgAlts = [
    'PAYCHEK Add Trade ticker sizing',
    'PAYCHEK Add Trade playbook checklist',
  ];
  return d;
}

function patchEs(x) {
  x.dashboard.lead = 'Opere con la disciplina institucional, no con emociones ruidosas.';
  x.dashboard.descPoints[0].label = 'Capital y balance:';
  x.dashboard.descPoints[0].body = 'La salud de liquidez siempre visible arriba al centro.';
  x.dashboard.descPoints[1].label = 'Tu nota táctica:';
  x.dashboard.descPoints[1].body =
    'Sin perseguir post-its sesgo vivo donde apruebas riesgo.';
  x.dashboard.descPoints[2].label = 'Lista de chequeo:';
  x.dashboard.descPoints[2].body = 'Un toque para certificar cada regla del playbook.';
  x.dashboard.descPoints[3].label = 'Estado mental:';
  x.dashboard.descPoints[3].body = 'La aguja confirma si opera pausado o debe frenar la sesión.';
  x.dashboard.descPoints[4].label = 'Calendario:';
  x.dashboard.descPoints[4].body = 'Curva mensual grabada contra el tiempo.';
  x.dashboard.descPoints[5].label = 'Tu estrategia:';
  x.dashboard.descPoints[5].body = 'El plan no desaparece de la vista.';
  x.dashboard.imgAlts = ['captura PAYCHEK dashboard', 'PAYCHEK dashboard collage mental estrategia calendario'];
  x.checklist.lead = 'Luz procedural verde antes de calibrar tamaño.';
  x.checklist.descPoints[0].label = 'Validación 360:';
  x.checklist.descPoints[0].body = 'Técnica riesgo psique triple cheque antes de tamaño.';
  x.checklist.descPoints[1].label = 'Arco visual:';
  x.checklist.descPoints[1].body =
    'Anillo crece hasta sellar alas solo operar halo completo.';
  x.checklist.descPoints[2].label = 'Cero amnesias:';
  x.checklist.descPoints[2].body = 'Gestión monetaria grabada en ritual sin olvidos.';
  x.checklist.descPoints[3].label = 'PDF de auditoría:';
  x.checklist.descPoints[3].body =
    'Sellos tiempo disciplina para coach inversionista instantáneo export.';
  x.checklist.imgAlt = 'módulo lista PAYCHEK screenshot';
  x.mental.title = 'Mentalidad';
  x.mental.lead =
    'El mercado castiga burnout PAYCHEK es torre biometrica que aclara tierra antes de tamaño.';
  x.mental.descPoints[0].label = 'Brújula:';
  x.mental.descPoints[0].body = 'Puntaje hábitos sueño entreno mindfulness peak real.';
  x.mental.descPoints[1].label = 'Snapshot momentum:';
  x.mental.descPoints[1].body =
    'Swipe foco energía stress gauges rojos alerta antes crash conductual.';
  x.mental.descPoints[2].label = 'Telemetría emocional:';
  x.mental.descPoints[2].body = 'Marcar euforia frustración neutro para matar revenge loop.';
  x.mental.descPoints[3].label = 'Ritual warmup:';
  x.mental.descPoints[3].body = 'Atletas preparados convierten calentura en payouts.';
  x.mental.imgAlt = 'PAYCHEK módulo mental estado';
  x.analyse.title = 'Espacio analítico';
  x.analyse.lead = 'Dossier vivo plan bloques ejecutivos mismo canvas.';
  x.analyse.descPoints[0].label = 'Hoja plan:';
  x.analyse.descPoints[0].body =
    'Dirección marcos tendencia régimen convicción un solo panel.';
  x.analyse.descPoints[1].label = 'Inmersión técnica:';
  x.analyse.descPoints[1].body = 'Indicadores estructuras smart money volumen snapshots.';
  x.analyse.descPoints[2].label = 'Resumen ejecutivo:';
  x.analyse.descPoints[2].body = 'Sellado con índice confianza historia activo enlazado.';
  x.analyse.imgAlts = [
    'tarjeta análisis semanal PAYCHEK',
    'fichas estructura indicadores SMC PAYCHEK',
    'hoja trading plan PAYCHEK',
    'confidence rollup PAYCHEK',
  ];
  x.strategie.lead =
    'En batalla el playbook se pierde PAYCHEK lo fija visible y el drift pierde la guerra.';
  x.strategie.descPoints[0].label = 'Pilares únicos:';
  x.strategie.descPoints[0].body = 'Framework bespoke suyo no viral template.';
  x.strategie.descPoints[1].label = 'Ledger convicciones:';
  x.strategie.descPoints[1].body = 'Historia por idea accionable.';
  x.strategie.descPoints[2].label = 'Alineamiento inmediato:';
  x.strategie.descPoints[2].body = 'Sin tab hunt dashboard porta reglas session loop.';
  x.strategie.descPoints[3].label = 'Score setup:';
  x.strategie.descPoints[3].body = 'Califique idea antes ejecución filtra scalps pobres upstream.';
  x.strategie.imgAlt = 'estrategia PAYCHEK playbook riesgo sesiones';
  x.performance.lead = 'Deje de adivinar fugas métricas reales muestran heridas.';
  x.performance.descPoints[0].label = 'Mapa mente:';
  x.performance.descPoints[0].body =
    'Trades principio vs feeling muestran arrastre emoción en la expectativa.';
  x.performance.descPoints[1].label = 'Radar horario áureo:';
  x.performance.descPoints[1].body = 'Ventanas pago enfocadas solo cuando payoff denso.';
  x.performance.descPoints[2].label = 'Telemetría sesión:';
  x.performance.descPoints[2].body = 'Hit rate payoff volumen tweaking data desk vibes.';
  x.performance.descPoints[3].label = 'Guardarraíl intensidad:';
  x.performance.descPoints[3].body = 'Tope trades día evitar overtrade capital choke.';
  x.performance.imgAlts = [
    'rendimiento PAYCHEK volumen símbolos',
    'rendimiento tiempo payoff duración PAYCHEK',
    'disciplina impacto mindset PAYCHEK',
  ];
  x.calendrier.title = 'Calendario';
  x.calendrier.lead = 'Histórico croma fortalezas destacan errores recortados quirúrgicamente.';
  x.calendrier.desc = 'Vista mensual PnL rachas verdes dias rojos datos sin folklore.';
  x.calendrier.imgAlt = 'calendario PAYCHEK métricas net recap';
  x.trade.title = 'Libro de trades';
  x.trade.lead = 'Más allá del click archivo historias grado institucional.';
  x.trade.descPoints[0].label = 'Ledger ordenado:';
  x.trade.descPoints[0].body = 'Cada ticket auto net esperanza líquido.';
  x.trade.descPoints[1].label = 'Folder técnico:';
  x.trade.descPoints[1].body =
    'Gráficas tesis lado a lado revisitas rápidas sin contexto perdido.';
  x.trade.descPoints[2].label = 'Forense disciplina:';
  x.trade.descPoints[2].body = 'Reglas respetadas impulsos flag instantáneo.';
  x.trade.descPoints[3].label = 'Diario reflexión:';
  x.trade.descPoints[3].body = 'Emoción intuición capturada hindsight upgrade playbook.';
  x.trade.descPoints[4].label = 'Métricas micro:';
  x.trade.descPoints[4].body =
    'Payoff verdadero tiempo exposición bleed fees KPI frío.';
  x.trade.imgAlts = [
    'lista trades PAYCHEK filtro',
    'detalle trade PAYCHEK',
    'recap semanal PAYCHEK sesiones',
  ];
  x.pdf.title = 'Exportar PDF';
  x.csv.title = 'Importar CSV';
  x.pdf.lead = 'Paquetes audit para inversionistas yo futuro con prueba proceso.';
  x.pdf.descPoints[0].label = 'Folio estrategia:';
  x.pdf.descPoints[0].body = 'Doctrina pilares archivo firmado.';
  x.pdf.descPoints[1].label = 'Revisiones instrumento:';
  x.pdf.descPoints[1].body = 'Escenarios capturas archivo sprint.';
  x.pdf.descPoints[2].label = 'Fichas ticket:';
  x.pdf.descPoints[2].body = 'Notas playbook score disciplina cada fill.';
  x.pdf.descPoints[3].label = 'Auditorías rítmicas:';
  x.pdf.descPoints[3].body = 'Informes semanales post-trade profundo.';
  x.pdf.descPoints[4].label = 'Dossiers performance:';
  x.pdf.descPoints[4].body = 'Daily weekly mensual briefing PDF limpio.';
  x.pdf.imgAlts = [
    'PDF PAYCHEK resumen checklist',
    'PDF analisis ejecutivo PAYCHEK',
    'PDF playbook PAYCHEK',
    'PDF semanal trades PAYCHEK',
    'PDF detalle ticket PAYCHEK',
  ];
  x.csv.lead = 'Nueve plataformas soltar export formato auto reconocimiento.';
  x.csv.descPoints[0].label = 'Cobertura interop:';
  x.csv.descPoints[0].body =
    'MT4 MT5 TradingView Tradovate cTrader NinjaTrader Quantower ATAS Rithmic.';
  x.csv.descPoints[1].label = 'Asistente ingest:';
  x.csv.descPoints[1].body = 'Flujos proveedor CSV HTML sin remap manual.';
  x.csv.descPoints[2].label = 'Blotter unificado:';
  x.csv.descPoints[2].body = 'Imports heredan analytic PDF automatismo.';
  x.csv.imgAlt = 'wizard CSV PAYCHEK selectores venue';
  x.ajouter.title = 'Añadir trade';
  x.ajouter.lead = 'Captura precisión algorítmica con claridad discresional.';
  x.ajouter.descPoints[0].label = 'Blotter rapido:';
  x.ajouter.descPoints[0].body = 'UI fricción mínimo hábito journal intacto.';
  x.ajouter.descPoints[1].label = 'Neteo inteligente:';
  x.ajouter.descPoints[1].body =
    'Entradas salidas fees esperanza autocalculado sin spreadsheets.';
  x.ajouter.descPoints[2].label = 'Filtro conducta:';
  x.ajouter.descPoints[2].body = 'Marca reglas versus impulsos segundo cero.';
  x.ajouter.imgAlts = ['add trade PAYCHEK sizing', 'add trade playbook checklist PAYCHEK'];
  return x;
}

function patchPt(p) {
  p.dashboard.lead =
    'Opere com a disciplina de um escritório profissional, não com ruído emocional.';
  p.dashboard.descPoints[0].label = 'Capital e saldo:';
  p.dashboard.descPoints[0].body = 'Saúde de liquidez sempre visível.';
  p.dashboard.descPoints[1].label = 'Nota estratégica:';
  p.dashboard.descPoints[1].body =
    'Acaba caça aos post-its bias fica onde o risco é aprovado.';
  p.dashboard.descPoints[2].label = 'Checklist:';
  p.dashboard.descPoints[2].body =
    'Um toque certifica todas as regras no painel comando.';
  p.dashboard.descPoints[3].label = 'Estado mental:';
  p.dashboard.descPoints[3].body = 'Ponteiros diz operar pausado ou encerre sessão.';
  p.dashboard.descPoints[4].label = 'Calendário:';
  p.dashboard.descPoints[4].body = 'Curva mensal registra progresso.';
  p.dashboard.descPoints[5].label = 'Sua estratégia:';
  p.dashboard.descPoints[5].body = 'O plano não some do radar.';
  p.dashboard.imgAlts = ['preview dashboard PAYCHEK', 'dashboard PAYCHEK mental estrategia calendário'];
  p.checklist.lead = 'Sinal procedural verde antes dimensionar risco.';
  p.checklist.descPoints[0].label = 'Validação 360:';
  p.checklist.descPoints[0].body =
    'Técnico risco psique triplo cheque antes clicar.';
  p.checklist.descPoints[1].label = 'Arco visual:';
  p.checklist.descPoints[1].body = 'Anel fecha quando portões cerram só halo completo executa.';
  p.checklist.descPoints[2].label = 'Zero esquecimentos:';
  p.checklist.descPoints[2].body = 'Gestão scripted na rotina corporativa.';
  p.checklist.descPoints[3].label = 'PDF de auditoria:';
  p.checklist.descPoints[3].body =
    'Selos tempo disciplina export coach investidor rápido.';
  p.checklist.imgAlt = 'módulo checklist PAYCHEK screenshot';
  p.mental.title = 'Mental';
  p.mental.lead =
    'Mercado penaliza burnout PAYCHEK é radar biométrico concede autorização só com solo firme.';
  p.mental.descPoints[0].label = 'Bússola performance:';
  p.mental.descPoints[0].body =
    'Score hábitos sono treino mindfulness pico real.';
  p.mental.descPoints[1].label = 'Snapshot momento:';
  p.mental.descPoints[1].body =
    'Swipe foco energia stress gauges vermelhos alerta antes explode.';
  p.mental.descPoints[2].label = 'Telemetria emocional:';
  p.mental.descPoints[2].body = 'Marcar euforia frustra neutro revenge loop não sobrevive.';
  p.mental.descPoints[3].label = 'Ritual warmup:';
  p.mental.descPoints[3].body = 'Traders preparados monetizam preparação repetível.';
  p.mental.imgAlt = 'módulo mental PAYCHEK';
  p.analyse.title = 'Espaço análise';
  p.analyse.lead =
    'Dossiê vivo com plano técnico mais wrap executivo no mesmo vidro.';
  p.analyse.descPoints[0].label = 'Folha plano:';
  p.analyse.descPoints[0].body =
    'Direção timeframes regime convicção num painel único.';
  p.analyse.descPoints[1].label = 'Imersões profundas:';
  p.analyse.descPoints[1].body =
    'Estrutura indicadores smart money liquidity volume snaps.';
  p.analyse.descPoints[2].label = 'Executive wrap:';
  p.analyse.descPoints[2].body =
    'Fecha com índice confiança ligado histórico do símbolo.';
  p.analyse.imgAlts = [
    'card analise PAYCHEK semanal',
    'fichas estrutura indicadores SMC',
    'plan sheet PAYCHEK',
    'rollup confiança PAYCHEK',
  ];
  p.strategie.lead =
    'Em guerra playbook some PAYCHEK mantém visible disciplina ganha corrida.';
  p.strategie.descPoints[0].label = 'Pilares custom:';
  p.strategie.descPoints[0].body = 'Framework espelho playbook nada viral terceiros.';
  p.strategie.descPoints[1].label = 'Registro convicção:';
  p.strategie.descPoints[1].body = 'Tese texto cada ideia acionável.';
  p.strategie.descPoints[2].label = 'Alinhamento imediato:';
  p.strategie.descPoints[2].body = 'Dashboard segura regras sem tab frenzy.';
  p.strategie.descPoints[3].label = 'Score setup:';
  p.strategie.descPoints[3].body = 'Nota antes executar scalp ruim barrado upstream.';
  p.strategie.imgAlt = 'estrategia PAYCHEK playbook risco sessões';
  p.performance.lead =
    'Pare fugas intuitivas medição objetiva onde capital sangra.';
  p.performance.descPoints[0].label = 'Mapa mental:';
  p.performance.descPoints[0].body =
    'Trades princípio contra feeling revelam arrasto emocional.';
  p.performance.descPoints[1].label = 'Radar horários ouro:';
  p.performance.descPoints[1].body = 'Só quando payoff mais denso você foca energia lá.';
  p.performance.descPoints[2].label = 'Telemetria sessão:';
  p.performance.descPoints[2].body = 'Winrate payoff volume tweaking vibe mesa proprietária.';
  p.performance.descPoints[3].label = 'Guard intensidade:';
  p.performance.descPoints[3].body = 'Teto trades dia evitar overtrade defesa capital.';
  p.performance.imgAlts = [
    'performance volume símbolo PAYCHEK',
    'performance tempo payoff PAYCHEK',
    'impacto disciplina mindset PAYCHEK',
  ];
  p.calendrier.title = 'Calendário';
  p.calendrier.lead =
    'Histórico cromático força aparecer erros cortados com precisão.';
  p.calendrier.desc = 'PnL mensal rachas vermelhas estudadas factual sem folclore.';
  p.calendrier.imgAlt = 'calendário PAYCHEK métricas recap';
  p.trade.title = 'Livro trades';
  p.trade.lead =
    'Além do click arquiva história nível sala institucional.';
  p.trade.descPoints[0].label = 'Cronologia:';
  p.trade.descPoints[0].body = 'Cada bilhete net expectancy autopilot.';
  p.trade.descPoints[1].label = 'Folder técnico:';
  p.trade.descPoints[1].body =
    'Gráficos tese lado a lado revisitas sem reaprender contexto.';
  p.trade.descPoints[2].label = 'Forense disciplina:';
  p.trade.descPoints[2].body =
    'Instantâneo regra obedecida vs impulso destaque vivo.';
  p.trade.descPoints[3].label = 'Journal reflexivo:';
  p.trade.descPoints[3].body =
    'Captura emoção intuição hindsight evolui playbook.';
  p.trade.descPoints[4].label = 'Micrometrics:';
  p.trade.descPoints[4].body =
    'RR real tempo exposicao bleed taxas KPI duro.';
  p.trade.imgAlts = [
    'trades filtros PAYCHEK',
    'trade detalhe PAYCHEK',
    'recap semanal sessões PAYCHEK',
  ];
  p.pdf.title = 'Exportar PDF';
  p.csv.title = 'Importar CSV';
  p.pdf.lead =
    'Pacotes auditoria investidor futuro você com provas repetível processo.';
  p.pdf.descPoints[0].label = 'Portfólio estratégia:';
  p.pdf.descPoints[0].body =
    'Regras pilares arquivo assinado.';
  p.pdf.descPoints[1].label = 'Reviews instrumentos:';
  p.pdf.descPoints[1].body = 'Cenarios prints sprint arquivo.';
  p.pdf.descPoints[2].label = 'Fichas ticket:';
  p.pdf.descPoints[2].body =
    'Notas playbook comportamento cada fill.';
  p.pdf.descPoints[3].label = 'Auditorias ritmo:';
  p.pdf.descPoints[3].body = 'Semana relatórios pós-trade estruturado.';
  p.pdf.descPoints[4].label = 'Dossiers perf:';
  p.pdf.descPoints[4].body = 'Daily weekly mensal PDF briefing-ready.';
  p.pdf.imgAlts = [
    'PDF resumo PAYCHEK',
    'PDF briefing analítico PAYCHEK',
    'PDF playbook PAYCHEK',
    'PDF semanal trades PAYCHEK',
    'PDF dossier ticket PAYCHEK',
  ];
  p.csv.lead =
    'Nove venues largar exports schema PAYCHEK autodetecta.';
  p.csv.descPoints[0].label = 'Cobertura interop:';
  p.csv.descPoints[0].body =
    'MT4 MT5 TradingView Tradovate cTrader NinjaTrader Quantower ATAS Rithmic.';
  p.csv.descPoints[1].label = 'Assistent ingest:';
  p.csv.descPoints[1].body = 'Flows vendor CSV HTML sem remap manual.';
  p.csv.descPoints[2].label = 'Blotter unificado:';
  p.csv.descPoints[2].body = 'Import herda analytics PDF automatismo.';
  p.csv.imgAlt = 'wizard CSV PAYCHEK grade venues';
  p.ajouter.title = 'Adicionar trade';
  p.ajouter.lead = 'Precisão algoritmo mais clara discrição profissional.';
  p.ajouter.descPoints[0].label = 'Blotter veloz:';
  p.ajouter.descPoints[0].body = 'Baixa frição journaling consistente.';
  p.ajouter.descPoints[1].label = 'Net inteligente:';
  p.ajouter.descPoints[1].body =
    'Entradas saídas taxas netting automático expectancy.';
  p.ajouter.descPoints[2].label = 'Filtro comportamento:';
  p.ajouter.descPoints[2].body =
    'Flag instantâneo regra obedece contra impulsão.';
  p.ajouter.imgAlts = [
    'add trade PAYCHEK tamanhos',
    'playbook checklist add trade PAYCHEK',
  ];
  return p;
}

function patchKo(k) {
  k.dashboard.lead = '감정보다 검증 가능한 디스플린으로 운용하세요.';
  k.dashboard.descPoints[0].label = '자금과 잔고:';
  k.dashboard.descPoints[0].body = '유동성 건전성을 즉시 시각화합니다.';
  k.dashboard.descPoints[1].label = '분석 노트:';
  k.dashboard.descPoints[1].body =
    '스티커 헌팅 종료 검증 순간 근처에 노트 노출합니다.';
  k.dashboard.descPoints[2].label = '체크리스트:';
  k.dashboard.descPoints[2].body =
    '한 번 탭하면 모든 플레이북 룰이 중앙 명령에서 확정됩니다.';
  k.dashboard.descPoints[3].label = '멘탈 상태:';
  k.dashboard.descPoints[3].body =
    '지금 체결해도 되는지 혹은 멈추어야 하는지 바로 확인합니다.';
  k.dashboard.descPoints[4].label = '캘린더:';
  k.dashboard.descPoints[4].body = '월별 에쿼티 흔적을 차곡 차곡 적재합니다.';
  k.dashboard.descPoints[5].label = '전략:';
  k.dashboard.descPoints[5].body = '플랜은 시선에서 놓치지 않습니다.';
  k.dashboard.imgAlts = ['PAYCHEK 대시보드 미리보기', '대시보드 멘탈 전략 콜라주'];
  k.checklist.lead = '포지션 사이즈 결정 전 절차적인 출발 신호등.';
  k.checklist.descPoints[0].label = '360도 검증:';
  k.checklist.descPoints[0].body = '기술 리스크 심리 각도 주문 전 이중 검증합니다.';
  k.checklist.descPoints[1].label = '시각적 완충링:';
  k.checklist.descPoints[1].body =
    '모든 게이트가 닫힐 때만 헤일로 채워집니다 헤일로 완성 전까지 체결 보류입니다.';
  k.checklist.descPoints[2].label = '망각 방지:';
  k.checklist.descPoints[2].body =
    '자금 관리 규칙은 루틴 속에 새겨져 있습니다.';
  k.checklist.descPoints[3].label = 'PDF 감사:';
  k.checklist.descPoints[3].body =
    '코치 또는 투자자 보고 순간 디스플린 증거를 내보냅니다.';
  k.checklist.imgAlt = 'PAYCHEK 체크리스트 스크린샷';
  k.mental.title = '마인드셋';
  k.mental.lead =
    '피로는 시장이 부과 페널티 PAYCHEK는 생체 탑처럼 심리 이륙 승인을 관리합니다.';
  k.mental.descPoints[0].label = '퍼포먼스 나침반:';
  k.mental.descPoints[0].body =
    '수면 운동 명상 패턴 준비도 스코어로 피크 체류 여부 즉결합니다.';
  k.mental.descPoints[1].label = '순간 스냅샷:';
  k.mental.descPoints[1].body =
    '집중 에너지 스트레스 스와이프 한 번 레드 게이지면 선제 경보.';
  k.mental.descPoints[2].label = '감정 텔레메트리:';
  k.mental.descPoints[2].body =
    '흥분 좌절 중립 태깅 리벤지 루프 말립니다.';
  k.mental.descPoints[3].label = '프리 세션 루틴:';
  k.mental.descPoints[3].body =
    '준비가 탄탄한 트레이더만 루틴을 수익 루프로 전환합니다.';
  k.mental.imgAlt = 'PAYCHEK 마인드 모듈';
  k.analyse.title = '분석 스튜디오';
  k.analyse.lead =
    '계획 기술 심층 블록 브리핑 레이어를 한 유리면에 두었습니다.';
  k.analyse.descPoints[0].label = '플랜 시트:';
  k.analyse.descPoints[0].body =
    '방향 타임프레임 추세 레짐 신뢰 맵 한 패널에 모읍니다.';
  k.analyse.descPoints[1].label = '심층 카드 묶음:';
  k.analyse.descPoints[1].body =
    '구조 SMC 유동성 볼륨 프로필 차트 스냅을 묶었습니다.';
  k.analyse.descPoints[2].label = '요약 브리핑:';
  k.analyse.descPoints[2].body =
    '자산 히스토리와 신뢰 점수로 기록 완충합니다.';
  k.analyse.imgAlts = [
    '주간 분석 카드 PAYCHEK',
    '구조 SMC 카드 더미 PAYCHEK',
    '트레이딩 플랜 페이지 PAYCHEK',
    '신뢰 롤업 PAYCHEK',
  ];
  k.strategie.title = '전략';
  k.strategie.lead =
    '세션 중 플레이북 증발을 막기 위해 PAYCHEK가 상시 피닝 디스플린 승리.';
  k.strategie.descPoints[0].label = '커스텀 기둥:';
  k.strategie.descPoints[0].body =
    '외부 베낀 템플릿 대신 우리 방법론 피드를 만듭니다.';
  k.strategie.descPoints[1].label = '컨빅션 로그:';
  k.strategie.descPoints[1].body =
    '모든 거래 아이디어 근거를 텍스트로 남겨 증언합니다.';
  k.strategie.descPoints[2].label = '즉석 정렬:';
  k.strategie.descPoints[2].body =
    '탭 헌팅 없이 규칙 대시보드에 상주합니다.';
  k.strategie.descPoints[3].label = '셋업 점수:';
  k.strategie.descPoints[3].body =
    '실행 전 품질 필터로 저급 셋업을 업스트림에서 제거.';
  k.strategie.imgAlt = '전략 모듈 리스크 세션 플레이북 PAYCHEK';
  k.performance.lead = '누수 위치 추측을 멈추고 KPI가 출혈을 지목합니다.';
  k.performance.descPoints[0].label = '마인드맵 분석:';
  k.performance.descPoints[0].body =
    '규칙 대 직관 트레이드 스택 비교 실제 감정 드래그량 가시화.';
  k.performance.descPoints[1].label = '골든 아워 레이더:';
  k.performance.descPoints[1].body =
    '기대값 밀도가 높은 창구만 선택적 집중.';
  k.performance.descPoints[2].label = '세션 텔레메트리:';
  k.performance.descPoints[2].body =
    '승률 페이오프 트레이딩량으로 데스크 모델 튜닝 복제 가능.';
  k.performance.descPoints[3].label = '세션 강도 가드:';
  k.performance.descPoints[3].body =
    '일일 거래 건 한도 과매매로 자본 교란 차단합니다.';
  k.performance.imgAlts = [
    '퍼포먼스 거래량 심볼 히트맵 PAYCHEK',
    '퍼포먼스 시간대 페이오프 체류 PAYCHEK',
    '디스플린 실행 상호 PAYCHEK',
  ];
  k.calendrier.title = '캘린더';
  k.performance.title = '퍼포먼스';
  k.calendrier.lead = '색 히스토리로 강점 부각 과거 미스 크랙 축소.';
  k.calendrier.desc =
    '월별 PnL 연승과 적신호 날 패턴 학습 데이터만 남김 무신 신화 배제.';
  k.calendrier.imgAlt = '캘린더 누적 메트릭 모자이크 PAYCHEK';
  k.trade.title = '트레이드 북';
  k.trade.lead = '클릭을 넘어 기관형 스토리 아카이빙.';
  k.trade.descPoints[0].label = '연대기 원장:';
  k.trade.descPoints[0].body =
    '티켓마다 순익 기대값 자동 연산 패널 포함.';
  k.trade.descPoints[1].label = '테크 두시어:';
  k.trade.descPoints[1].body =
    '차트 논증 병렬로 추후 회고 시 컨텍스트 재건 불필요.';
  k.trade.descPoints[2].label = '디스플린 포렌식:';
  k.trade.descPoints[2].body =
    '규칙 존중 대 충동 침식 즉시 라벨.';
  k.trade.descPoints[3].label = '리플렉션 저널:';
  k.trade.descPoints[3].body =
    '감정 통찰 적재 hindsight가 플레이북 반복 학습 재료입니다.';
  k.trade.descPoints[4].label = '마이크로 KPI:';
  k.trade.descPoints[4].body =
    '실제 페이오프 비율 체류시간 커미션 누수 핵심 수치 고정.';
  k.trade.imgAlts = [
    '거래 목록 필터 PAYCHEK',
    '티켓 드릴 다운 PAYCHEK',
    '주간 세션 리캡 PAYCHEK',
  ];
  k.pdf.title = 'PDF 내보내기';
  k.csv.title = 'CSV 가져오기';
  k.pdf.lead =
    '투자 담당 또는 미래의 나에게 반복 프로세스를 증명하는 PDF 패키지.';
  k.pdf.descPoints[0].label = '전략 포트폴리오:';
  k.pdf.descPoints[0].body =
    '규정 테크 기둥을 서명 수준 패키지로 보관합니다.';
  k.pdf.descPoints[1].label = '종목 리뷰실:';
  k.pdf.descPoints[1].body =
    '시나리오와 캡처 세션 종료 순간별 아카이브.';
  k.pdf.descPoints[2].label = '티켓 시트:';
  k.pdf.descPoints[2].body =
    '체결마다 저널 규칙 태깅 디스플린 스코어 기록합니다.';
  k.pdf.descPoints[3].label = '주기 감사:';
  k.pdf.descPoints[3].body =
    '주간 디브리프 자동 패키지로 구조 회고 제공.';
  k.pdf.descPoints[4].label = '퍼포먼스 두시어:';
  k.pdf.descPoints[4].body =
    '일중 주중 월간 결합 레포트 레디 PDF 패키지.';
  k.pdf.imgAlts = [
    'PDF 일간 요약 디스플린 PAYCHEK',
    'PDF 브리핑 패키지 PAYCHEK',
    'PDF 플레이북 RM 세션 PAYCHEK',
    'PDF 주간 rollup PAYCHEK',
    'PDF 티켓 디테일 패킷 PAYCHEK',
  ];
  k.csv.lead =
    '9개 플랫폼 브라우즈 내보내기를 끌어다 놓으면 PAYCHEK가 스키마 인식합니다.';
  k.csv.descPoints[0].label = '통합 호환 목록:';
  k.csv.descPoints[0].body =
    'MT4 MT5 TradingView Tradovate cTrader NinjaTrader Quantower ATAS Rithmic.';
  k.csv.descPoints[1].label = '가이드 수집:';
  k.csv.descPoints[1].body =
    '벤더 별 플로우 CSV HTML 무리한 리맵 필요 없음.';
  k.csv.descPoints[2].label = '단일 블로터 라인:';
  k.csv.descPoints[2].body =
    '가져오기 결과는 분석 PDF 파이프라인 그대로 승계.';
  k.csv.imgAlt = 'CSV 위자드 벤처 그리드 PAYCHEK';
  k.ajouter.title = '트레이드 추가';
  k.ajouter.lead =
    '알고리즘 수준 정밀도와 전문 디스크립션 명료함을 동시에.';
  k.ajouter.descPoints[0].label = '저지연 블로터:';
  k.ajouter.descPoints[0].body =
    '마찰 저항 최소 입력 습관을 보호합니다.';
  k.ajouter.descPoints[1].label = '스마트 넷팅:';
  k.ajouter.descPoints[1].body =
    '진출 청산 수수료 자연스럽게 순 기대값 연산합니다.';
  k.ajouter.descPoints[2].label = '컨덕트 필터:';
  k.ajouter.descPoints[2].body =
    '규칙 준수 대 충동 체결을 즉석 마킹합니다.';
  k.ajouter.imgAlts = [
    '트레이드 추가 사이즈 태깅 PAYCHEK',
    '체크리스트 포함 트레이드 추가 PAYCHEK',
  ];
  return k;
}

function cloneEnglish() {
  return JSON.parse(JSON.stringify(en));
}

w('landing-preview-modules-de.clean.json', patchDe(cloneEnglish()));
w('landing-preview-modules-es.clean.json', patchEs(cloneEnglish()));
w('landing-preview-modules-pt.clean.json', patchPt(cloneEnglish()));
w('landing-preview-modules-ko.clean.json', patchKo(cloneEnglish()));

console.log('Wrote landing-preview-modules-{de,es,pt,ko}.clean.json');
