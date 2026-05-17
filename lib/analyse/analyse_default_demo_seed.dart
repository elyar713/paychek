import 'package:flutter/widgets.dart';

import 'analyse_controller.dart';
import 'analyse_models.dart';
import 'analyse_report_snapshot.dart';

/// Actif attendu pour la fiche démo GOLD (voir [applyAnalyseDefaultGoldBreakoutDemo]).
bool isAnalyseDefaultGoldDemoAsset(AnalyseReportSnapshot s) {
  final u = s.actif.trim().toUpperCase();
  return u.contains('GOLD') && (u.contains('XAU') || u.contains('XAU/USD'));
}

/// Rapport par défaut (dashboard, plan d’analyse…) : GOLD / XAU si présent, sinon le premier.
AnalyseReportSnapshot? pickStoredAnalyseReportDefaultPreferGold(
  List<AnalyseReportSnapshot> stored,
) {
  if (stored.isEmpty) return null;
  for (final s in stored) {
    if (isAnalyseDefaultGoldDemoAsset(s)) return s;
  }
  return stored.first;
}

/// Aperçu dashboard (aligné sur la 1ʳᵉ fiche démo GOLD).
AnalyseReportSnapshot buildAnalyseDashboardPreviewSnapshot({Locale? locale}) {
  final c = AnalyseController();
  final loc = locale ?? WidgetsBinding.instance.platformDispatcher.locale;
  applyAnalyseDefaultGoldBreakoutDemo(c, locale: loc);
  final snap = AnalyseReportSnapshot.fromController(c, locale: loc);
  c.dispose();
  return snap;
}

/// Démo GOLD / XAU/USD — en premier dans la pile par défaut (SMC & volume désactivés).
void applyAnalyseDefaultGoldBreakoutDemo(
  AnalyseController c, {
  required Locale locale,
}) {
  final code = locale.languageCode;
  final fr = code == 'fr';
  final es = code == 'es';
  c.analyseActif = 'GOLD (XAU/USD)';
  if (fr) {
    c.nomAnalyse = 'Breakout Canal Baissier H4';
    c.notesTimeframe =
        'Après une correction saine, le Gold montre des signes de reprise haussière sur le graphique journalier. Le momentum repart à l\'achat après avoir testé une moyenne mobile clé.';
    c.structureDernierPoint = 'Cassure de Ligne de Tendance';
    c.notesStructure =
        'Le prix vient de casser par le haut un canal baissier H4. Le support à 2150.00 a servi de base de rebond. L\'objectif est la résistance psychologique à 2200.00.';
  } else if (es) {
    c.nomAnalyse = 'Ruptura de Canal Bajista H4';
    c.notesTimeframe =
        'Tras una corrección saludable, Gold muestra señales de continuación alcista en el gráfico diario. El momentum vuelve a compradores tras testear una media móvil clave.';
    c.structureDernierPoint = 'Ruptura de línea de tendencia';
    c.notesStructure =
        'El precio acaba de romper por encima de un canal bajista en H4. El soporte en 2150.00 actuó como base de rebote. El objetivo es la resistencia psicológica en 2200.00.';
  } else if (code == 'pt') {
    c.nomAnalyse = 'Rompimento de canal de baixa H4';
    c.notesTimeframe =
        'Após um pullback saudável, o ouro mostra sinais de continuação de alta no gráfico diário. O momentum volta para os compradores após testar uma média móvel importante.';
    c.structureDernierPoint = 'Rompimento de linha de tendência';
    c.notesStructure =
        'O preço acabou de romper para cima um canal de baixa em H4. O suporte em 2150.00 serviu de base de repique. O alvo é a resistência psicológica em 2200.00.';
  } else if (code == 'de') {
    c.nomAnalyse = 'H4-Breakout aus bäischem Kanal';
    c.notesTimeframe =
        'Nach einer gesunden Korrektur zeigt Gold auf dem Tageschart Anzeichen einer fortgesetzten Aufwärtsbewegung. Das Momentum dreht zurück zu Käufern nach dem Test einer wichtigen gleitenden Durchschnittslinie.';
    c.structureDernierPoint = 'Trendlinien-Bruch';
    c.notesStructure =
        'Der Kurs hat gerade nach oben aus einem bäischen H4-Kanal ausgebrochen. Die Unterstützung bei 2150.00 diente als Sprungbrett. Ziel ist der psychologische Widerstand bei 2200.00.';
  } else {
    c.nomAnalyse = 'Bearish Channel H4 Breakout';
    c.notesTimeframe =
        'After a healthy pullback, Gold is showing signs of bullish continuation on the daily chart. Momentum is turning back to buyers after testing a key moving average.';
    c.structureDernierPoint = 'Trendline Break';
    c.notesStructure =
        'Price has just broken above a bearish H4 channel. Support at 2150.00 acted as a bounce base. The target is the psychological resistance at 2200.00.';
  }
  c.bias = AnalyseDirectionBias.achat;
  c.htfPick = const ContextePick.enumOf(AnalyseTimeframe.daily);
  c.localTrendPick = const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
  c.phasePick = const ContextePick.enumOf(AnalysePhase.impulsion);
  c.confidenceFeuille = 75;

  c.structureTf = AnalyseStructureChartTf.h4.label;
  c.structureSupportMaj = '2150.00';
  c.structureResistanceMaj = '2200.00';
  c.structureSupportTested = true;
  c.structureResistanceTested = false;

  c.smcEnabled = false;
  c.volumeProfileEnabled = false;
}

/// Démo EUR/USD — en second dans la pile par défaut (feuille + structure + SMC + volume).
void applyAnalyseDefaultEuroUsdWeeklySwingDemo(
  AnalyseController c, {
  required Locale locale,
}) {
  final code = locale.languageCode;
  final fr = code == 'fr';
  final es = code == 'es';
  c.analyseActif = 'EUR/USD';
  if (fr) {
    c.nomAnalyse = 'Plan Swing Hebdomadaire';
    c.notesTimeframe =
        'Le prix est en pleine impulsion haussière après avoir rebondi sur la zone de demande H4. Je cherche un point d\'entrée après une correction (retracement).';
    c.structureDernierPoint = 'BOS (Break of Structure)';
    c.notesStructure =
        'Structure H4 clairement haussière. Le support à 1.08200 a tenu deux fois. Viser la résistance à 1.09500 qui est le prochain objectif liquide.';
    c.smcZone = 'Bullish OB (Demande)';
    c.smcFvg = 'Gap à 1.08450';
    c.smcLiquidityPools = 'Buy Side Liquidity (BSL) au-dessus de 1.09500';
    c.notesSmc =
        "Plan d'entrée idéal dans la zone OTE (0.618 Fib) qui coïncide avec un FVG non comblé et un Order Block H4. Les stops des vendeurs (BSL) au-dessus du précédent sommet sont la cible principale.";
    c.notesVolumeProfile =
        'Le POC est situé juste en dessous de notre zone d\'entrée préférée. Si le prix descend au POC, cela confirme qu\'il y a des acheteurs forts. La zone de valeur est bien définie entre 1.08150 et 1.08700.';
  } else if (es) {
    c.nomAnalyse = 'Plan Swing Semanal';
    c.notesTimeframe =
        'El precio está en un impulso alcista claro tras rebotar en la zona de demanda H4. Busco una entrada después de una corrección (pullback).';
    c.structureDernierPoint = 'BOS (Break of Structure)';
    c.notesStructure =
        'La estructura H4 es claramente alcista. El soporte en 1.08200 se mantuvo dos veces. Objetivo en la resistencia 1.09500 como próxima zona de liquidez.';
    c.smcZone = 'Bullish OB (Demanda)';
    c.smcFvg = 'Gap en 1.08450';
    c.smcLiquidityPools = 'Buy Side Liquidity (BSL) por encima de 1.09500';
    c.notesSmc =
        'Plan de entrada ideal en la zona OTE (0.618 Fib), alineada con un FVG sin rellenar y un Order Block H4. Los stops de vendedores (BSL) sobre el último máximo son el objetivo principal.';
    c.notesVolumeProfile =
        'El POC está justo por debajo de nuestra zona de entrada preferida. Si el precio cae al POC, confirma compradores fuertes. El área de valor está definida entre 1.08150 y 1.08700.';
  } else if (code == 'pt') {
    c.nomAnalyse = 'Plano swing semanal';
    c.notesTimeframe =
        'O preço está em um impulso de alta claro após rebater na zona de demanda H4. Busco una entrada após uma correção (pullback).';
    c.structureDernierPoint = 'BOS (Break of Structure)';
    c.notesStructure =
        'A estrutura H4 é claramente altista. O suporte em 1.08200 segurou duas vezes. Alvo na resistência 1.09500 como próxima zona de liquidez.';
    c.smcZone = 'Bullish OB (Demanda)';
    c.smcFvg = 'Gap em 1.08450';
    c.smcLiquidityPools = 'Buy Side Liquidity (BSL) acima de 1.09500';
    c.notesSmc =
        'Plano de entrada ideal na zona OTE (0,618 Fib), alinhado a um FVG não preenchido e um Order Block H4. Os stops dos vendedores (BSL) acima do último topo são o alvo principal.';
    c.notesVolumeProfile =
        'O POC fica logo abaixo da nossa zona de entrada preferida. Se o preço cair ao POC, confirma compradores fortes. A área de valor está definida entre 1.08150 e 1.08700.';
  } else if (code == 'de') {
    c.nomAnalyse = 'Wöchentlicher Swing-Plan';
    c.notesTimeframe =
        'Der Kurs zeigt nach dem Abprall in der H4-Nachfragezone einen klaren bullischen Impuls. Ich suche einen Einstieg nach einer Korrektur (Pullback).';
    c.structureDernierPoint = 'BOS (Break of Structure)';
    c.notesStructure =
        'Die H4-Struktur ist klar bullisch. Die Unterstützung bei 1.08200 hielt zweimal. Ziel ist der Widerstand bei 1.09500 als nächstes Liquiditätsziel.';
    c.smcZone = 'Bullish OB (Demand)';
    c.smcFvg = 'Lücke bei 1.08450';
    c.smcLiquidityPools = 'Buy Side Liquidity (BSL) über 1.09500';
    c.notesSmc =
        'Idealer Einstiegsplan in der OTE-Zone (0,618 Fib), passend zu einem ungefüllten FVG und einem H4-Orderblock. Verkäufer-Stops (BSL) über dem vorherigen Hoch sind das Hauptziel.';
    c.notesVolumeProfile =
        'Der POC liegt knapp unter unserer bevorzugten Einstiegszone. Fällt der Kurs zum POC, bestätigt das starke Käufer. Der Value-Bereich liegt zwischen 1.08150 und 1.08700.';
  } else {
    c.nomAnalyse = 'Weekly Swing Plan';
    c.notesTimeframe =
        'Price is in a clear bullish impulse after bouncing from the H4 demand zone. I am looking for an entry after a correction (pullback).';
    c.structureDernierPoint = 'BOS (Break of Structure)';
    c.notesStructure =
        'H4 structure is clearly bullish. Support at 1.08200 held twice. Target the resistance at 1.09500 as the next liquidity objective.';
    c.smcZone = 'Bullish OB (Demand)';
    c.smcFvg = 'Gap at 1.08450';
    c.smcLiquidityPools = 'Buy Side Liquidity (BSL) above 1.09500';
    c.notesSmc =
        'Ideal entry plan in the OTE zone (0.618 Fib) that aligns with an unfilled FVG and an H4 Order Block. Sellers\' stops (BSL) beyond the prior swing high are the main target.';
    c.notesVolumeProfile =
        'The POC sits just below our preferred entry zone. If price dips to the POC, it confirms strong buyers. The value area is well defined between 1.08150 and 1.08700.';
  }
  c.bias = AnalyseDirectionBias.surveiller;
  c.htfPick = const ContextePick.enumOf(AnalyseTimeframe.daily);
  c.localTrendPick = const ContextePick.enumOf(AnalyseLocalTrend.haussiere);
  c.phasePick = const ContextePick.enumOf(AnalysePhase.impulsion);
  c.confidenceFeuille = 65;

  c.structureTf = AnalyseStructureChartTf.h4.label;
  c.structureSupportMaj = '1.08200';
  c.structureResistanceMaj = '1.09500';
  c.structureSupportTested = true;
  c.structureResistanceTested = false;

  c.smcTf = AnalyseStructureChartTf.h4.label;
  c.smcFibLevel = '0.618';
  c.smcFibPrice = '1.08550';
  c.confidenceSmc = 65;

  c.volumeProfileTf = AnalyseStructureChartTf.h4.label;
  c.volumeProfileZoneActive = true;
  c.volumeProfileZoneFrom = '1.08150';
  c.volumeProfileZoneTo = '1.08700';
  c.volumeProfilePoc = '1.08350';
  c.volumeProfileVah = '1.08700';
  c.volumeProfileVal = '1.08150';

  c.smcEnabled = true;
  c.volumeProfileEnabled = true;
}
