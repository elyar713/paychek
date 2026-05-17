// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get actionAdd => '추가';

  @override
  String get addPortfolio => '포트폴리오 추가';

  @override
  String get ajouterTradeCapitalRequiredHint => '계산을 위해 자본(설문)을 설정하세요.';

  @override
  String get ajouterTradeCapitalGainEnterExitToShowPnl => '손익을 보려면 청산가를 입력하세요.';

  @override
  String get ajouterTradeCapitalGainOpenPositionNote =>
      '미청산 포지션: 청산 시 추정 손익이 표시됩니다.';

  @override
  String get ajouterTradeCommissionFeesLabel => '수수료(커미션)';

  @override
  String get ajouterTradeFillSuggestedLot => '로트 채우기';

  @override
  String get ajouterTradeSizingEstimationFootnote =>
      '* 추정은 저장된 자본을 사용합니다. 계약/CFD 수치는 대략적입니다.';

  @override
  String get ajouterTradeScreenshotHelp => '차트 또는 셋업 스크린샷 추가(선택).';

  @override
  String get ajouterTradeCsvChooseSoftware => 'Choisir un logiciel';

  @override
  String get ajouterTradePageTitle => '거래 추가';

  @override
  String get ajouterTradeErrorQtyPositive => '0보다 큰 포지션 크기를 입력하세요.';

  @override
  String get ajouterTradeErrorEntryPrice => '유효한 진입가(0보다 큼)를 입력하세요.';

  @override
  String get ajouterTradeErrorExitOrFlags =>
      '유효한 청산가를 입력하거나, 청산가를 모를 때 본전/미청산을 선택하세요.';

  @override
  String get ajouterTradePsychTagBlind => '맹목';

  @override
  String get ajouterTradeCapitalGainHeading => '자본 & 손익';

  @override
  String get ajouterTradeMindsetPrompt => '이 거래를 이런 상태로 했습니다:';

  @override
  String get ajouterTradeDisciplineSettingsTooltip => '설정: 감정 및 활성 섹션.';

  @override
  String get ajouterTradeSaveAndNext => '저장 후 다음';

  @override
  String ajouterTradeLiteMonthlyLimitReached(int max) {
    return 'Lite: 한 달(달력 기준)에 최대 $max건까지 기록할 수 있습니다. 무제한은 Pro로 업그레이드하세요.';
  }

  @override
  String ajouterTradeLiteMonthlyLimitImportSkipped(int skipped, int max) {
    return '$skipped건이 가져오지 않았습니다. Lite는 한 달에 최대 $max건까지 허용됩니다.';
  }

  @override
  String get ajouterTradeSectionEtatMoment => '현재 상태';

  @override
  String get ajouterTradeImagePickerClose => '닫기';

  @override
  String get ajouterTradeImagePickerTitle => '이미지 출처';

  @override
  String get ajouterTradeGallery => '갤러리';

  @override
  String get ajouterTradeCamera => '카메라';

  @override
  String get ajouterTradeFeedbackAlmost100 => '거의 100%입니다. 항목을 계속 지키세요.';

  @override
  String get ajouterTradeFeedbackTickEach => '해당하는 항목을 모두 체크하세요(복수 선택).';

  @override
  String get ajouterTradeChoicesSaved => '저장된 선택:';

  @override
  String ajouterTradeNonRespectedSemantic(Object label) {
    return '미준수: $label';
  }

  @override
  String ajouterTradeDisciplineRespectBase(int pct) {
    return '준수 $pct%';
  }

  @override
  String ajouterTradeDisciplineRespectNonList(Object items, Object more) {
    return ' · 미준수: $items$more';
  }

  @override
  String get ajouterTradeFieldActif => '종목';

  @override
  String get ajouterTradeFieldEntree => '진입';

  @override
  String get ajouterTradeFieldSortie => '청산';

  @override
  String get ajouterTradeCheckboxBreakeven => '본전';

  @override
  String get ajouterTradeCheckboxPositionOpen => '미청산 포지션';

  @override
  String get ajouterTradeCheckboxAvantNews => '뉴스 전';

  @override
  String get ajouterTradeCheckboxApresNews => '뉴스 후';

  @override
  String get ajouterTradeDirectionBuyLong => '매수 · 롱';

  @override
  String get ajouterTradeDirectionSellShort => '매도 · 숏';

  @override
  String get ajouterTradeEntryExitDateHint =>
      '팁: 진입·청산 날짜와 시간을 설정하세요. 성과 페이지에서 보유 시간과 손익을 연결합니다.';

  @override
  String get ajouterTradeQtyLots => '크기(로트)';

  @override
  String get ajouterTradeQtyContracts => '크기(계약)';

  @override
  String get ajouterTradeQtyUnits => '크기(단위)';

  @override
  String get ajouterTradeQtyShares => '크기(주)';

  @override
  String get ajouterTradeShortcutsLots => '로트 단축';

  @override
  String get ajouterTradeShortcutsContracts => '계약 단축';

  @override
  String get ajouterTradeShortcutsQty => '크기 단축';

  @override
  String get ajouterTradeShortcutsCommonSizes => '단축(일반 크기)';

  @override
  String get ajouterTradeLotHintMini => '예: 0.1 = 일반적인 미니 로트.';

  @override
  String get ajouterTradeLotFieldHintForex => '예: 0.1';

  @override
  String get ajouterTradeLotFieldHintContracts => '예: 2';

  @override
  String get ajouterTradeLotFieldHintUnits => '예: 1';

  @override
  String get ajouterTradeLotFieldHintShares => '예: 10';

  @override
  String get ajouterTradeDisciplineSettingsTitle => '규율 설정';

  @override
  String get ajouterTradeDisciplineSettingsSubtitle => '이 거래에서 활성화할 섹션을 선택하세요.';

  @override
  String get ajouterTradeDisciplineFeelingModeTitle => '감정 모드';

  @override
  String get ajouterTradeDisciplineFeelingAllowSubtitle =>
      '아래 섹션을 채울 수 있게 합니다.';

  @override
  String get ajouterTradeDisciplineSectionsHeading => '섹션';

  @override
  String get ajouterTradeDisciplineStrategieTitle => '전략';

  @override
  String get ajouterTradeDisciplineStrategieSubtitle => '셋업, 피드백';

  @override
  String get ajouterTradeDisciplinePlanTitle => '분석 계획';

  @override
  String get ajouterTradeDisciplinePlanSubtitle => '리포트, 피드백';

  @override
  String get ajouterTradeDisciplineChecklistTitle => '체크리스트';

  @override
  String get ajouterTradeDisciplineChecklistSubtitle => '지킬 포인트';

  @override
  String get ajouterTradeDisciplineEtatTitle => '현재 상태';

  @override
  String get ajouterTradeDisciplineEtatSubtitle => '순간과 감정';

  @override
  String get ajouterTradeDisciplineSliderStrategieRespected => '전략 준수';

  @override
  String get ajouterTradePositionSettingsTitle => '포지션 설정';

  @override
  String get ajouterTradeStrategieFeedbackBravo => '잘했어요! 전략을 완전히 지켰습니다.';

  @override
  String get ajouterTradeStrategieFeedbackWhichMissed =>
      '전략 중 어떤 부분을 지키지 못했나요?';

  @override
  String get ajouterTradeStrategieGoldRules => '황금 규칙';

  @override
  String ajouterTradeStrategieRuleN(int n) {
    return '규칙 $n';
  }

  @override
  String ajouterTradeStrategieSetupTimeframesRow(Object value) {
    return '시간봉: $value';
  }

  @override
  String ajouterTradeStrategieSetupIndicatorsRow(Object value) {
    return '지표: $value';
  }

  @override
  String ajouterTradeStrategieSetupPatternRow(Object value) {
    return '패턴: $value';
  }

  @override
  String ajouterTradeStrategieSetupSignalRow(Object value) {
    return '시그널: $value';
  }

  @override
  String get ajouterTradeStrategieRiskManagement => '리스크 관리';

  @override
  String get ajouterTradeStrategieHoursSessions => '시간 & 세션';

  @override
  String get ajouterTradeStrategieSetupModels => '셋업 & 모델';

  @override
  String ajouterTradeStrategieSetupModelsWithTitle(Object title) {
    return '셋업 & 모델 — $title';
  }

  @override
  String get ajouterTradeStrategiePickStrategyHint =>
      '위 목록에서 전략을 선택하면 셋업 상세(진입, 손절, 목표, 포지션 관리 등)가 표시됩니다.';

  @override
  String get ajouterTradeStrategieRowPattern => '패턴';

  @override
  String get ajouterTradeStrategieRowSignal => '시그널';

  @override
  String get ajouterTradeStrategieClosedLabel100 => '좋아요, 전략 준수';

  @override
  String get ajouterTradeStrategieClosedLabel95 => '거의 모두 준수';

  @override
  String get ajouterTradeStrategieClosedLabelLow => '복습할 포인트';

  @override
  String get ajouterTradePlanPickReportAbove => '위 필드에서 리포트를 선택하세요.';

  @override
  String get ajouterTradePlanFeedbackAlmost100 =>
      '거의 100%입니다. 분석 계획의 모든 항목을 계속 지키세요.';

  @override
  String get ajouterTradePlanFeedbackBravo => '잘했어요! 분석 계획을 모두 지켰습니다.';

  @override
  String get ajouterTradePlanFeedbackWhichMissed => '분석 계획 중 어떤 부분을 지키지 못했나요?';

  @override
  String get ajouterTradePlanClosedLabel100 => '좋아요, 계획 준수';

  @override
  String get ajouterTradePlanClosedLabelLow => '피드백';

  @override
  String get ajouterTradeChecklistFeedbackAlmost100 =>
      '거의 100%입니다. 항목을 계속 지키세요.';

  @override
  String get ajouterTradeChecklistFeedbackBravo => '잘했어요! 체크리스트를 모두 지켰습니다.';

  @override
  String get ajouterTradeChecklistFeedbackWhichMissed =>
      '체크리스트 중 어떤 부분을 지키지 못했나요?';

  @override
  String get ajouterTradeChecklistClosedLabel100 => '좋아요, 체크리스트 준수';

  @override
  String get ajouterTradeChecklistClosedLabelLow => '체크리스트';

  @override
  String get ajouterTradeEtatFeelingPrompt => '어떤 감정이 떠올랐나요?';

  @override
  String get ajouterTradeEtatFeedbackAlmost100 => '거의 100%입니다. 항목을 계속 지키세요.';

  @override
  String get ajouterTradeEtatClosedLabel100 => '네, 힘들죠. 잘했어요!';

  @override
  String get ajouterTradeEtatClosedLabelLow => '현재 상태';

  @override
  String get ajouterTradeEtatHeaderMoment => '나의 상태';

  @override
  String get ajouterTradeEtatHeaderEmotions => '감정';

  @override
  String get ajouterTradeScreenshotLoadError => '이미지를 표시할 수 없습니다';

  @override
  String get ajouterTradeScreenshotChangeImage => '이미지 변경';

  @override
  String get ajouterTradeScreenshotTapToAdd => '탭하여 이미지 추가';

  @override
  String get ajouterTradeScreenshotRemove => '제거';

  @override
  String get ajouterTradePlanRowBias => '편향';

  @override
  String get ajouterTradePlanRowTimeframeHtf => '상위 시간봉';

  @override
  String get ajouterTradePlanRowPhase => '페이즈';

  @override
  String get ajouterTradePlanRowNotes => '메모';

  @override
  String get ajouterTradePlanRowLastPoint => '마지막 스윙 포인트';

  @override
  String ajouterTradePlanRowExtraSupport(int n) {
    return '추가 지지 $n';
  }

  @override
  String ajouterTradePlanRowExtraResistance(int n) {
    return '추가 저항 $n';
  }

  @override
  String get ajouterTradePlanRowOutils => '도구';

  @override
  String get ajouterTradePlanRowLiquidity => '유동성';

  @override
  String get ajouterTradePlanRowFibPrice => '피보나치 가격';

  @override
  String get ajouterTradePlanSectionVolume => '거래량';

  @override
  String get analyseAddField => '+ 필드 추가';

  @override
  String get analyseAddPhaseTitle => '페이즈 추가';

  @override
  String get analyseAddResist => '+ 저항 추가';

  @override
  String get analyseAddShort => '+ 추가';

  @override
  String get analyseAddSupport => '+ 지지 추가';

  @override
  String get analyseAddTimeframeTitle => '시간봉 추가';

  @override
  String get analyseAddTimeframeCustomEntry => '기타 (직접 입력)';

  @override
  String get analyseAddTimeframeSectionRestore => '다시 표시';

  @override
  String get analyseAddTimeframeSectionIntraday => '인트라데이';

  @override
  String get analyseAddTimeframeSectionSwing => '스윙·포지션';

  @override
  String get analyseAddTrendTitle => '추세 추가';

  @override
  String get analyseReportScreenshotSectionTitle => '스크린샷';

  @override
  String get analyseReportScreenshotAddCapture => '스크린샷 추가';

  @override
  String get analyseReportScreenshotChooseImage => '이미지 선택';

  @override
  String get analyseReportScreenshotSubtitleWeb => '이미지 파일';

  @override
  String get analyseReportScreenshotSubtitleFilePicker => '갤러리 또는 탐색기';

  @override
  String get analyseReportScreenshotCamera => '카메라';

  @override
  String get analyseReportScreenshotHintWithCamera => '파일, 갤러리 또는 카메라';

  @override
  String get analyseReportScreenshotHintNoCamera => '이 기기에서 이미지 선택';

  @override
  String get analyseReportScreenshotErrorPlugin =>
      '이 대상에서는 이미지 선택을 사용할 수 없습니다. «이미지 선택»을 사용하거나 앱을 다시 빌드하세요.';

  @override
  String get analyseReportScreenshotErrorGeneric => '스크린샷을 추가할 수 없습니다.';

  @override
  String get analyseCardIndicators => '지표';

  @override
  String get analyseCardSmcLiquidity => 'SMC & 유동성';

  @override
  String get analyseCardVolumeProfile => '거래량 프로파일';

  @override
  String get analysePageHeroTitle => '내 분석';

  @override
  String get analysePageHeroSubtitle => '분석과 전략을 실시간으로 관리하세요.';

  @override
  String get analyseSidebarConfidenceSummary => '요약';

  @override
  String get analyseSidebarConfidenceLabel => '전체 신뢰도';

  @override
  String get analyseSidebarReportHint => '보고서는 연결된 자산과 함께 기록에 저장됩니다.';

  @override
  String get analyseSidebarPreviewStyle => '스타일 미리보기';

  @override
  String get analyseConfidenceHigh => '높음';

  @override
  String get analyseConfidenceLevelTitle => '신뢰 수준';

  @override
  String get analyseConfidenceLow => '낮음';

  @override
  String analyseCopyLabel(String label) {
    return '$label 복사';
  }

  @override
  String analyseCopyNumber(int n) {
    return '$n 복사';
  }

  @override
  String get analyseCurrentMarketPhase => '현재 시장 페이즈';

  @override
  String get analyseCurrentTrend => '현재 추세';

  @override
  String get analyseDeleteTemplateTitle => '이 템플릿을 삭제할까요?';

  @override
  String get analyseDirectionLabel => '방향';

  @override
  String get analyseDraftLabelHint => '라벨…';

  @override
  String get analyseExtraBroken => '이탈';

  @override
  String get analyseExtraHeld => '유지';

  @override
  String get analyseExtraPriceHint => '가격';

  @override
  String get analyseFeuillePlanTitle => '트레이딩 플랜 시트';

  @override
  String get analyseFibLevel => '피보나치 레벨';

  @override
  String get analyseFibShort => '피보나치';

  @override
  String get analyseFreeFields => '자유 필드';

  @override
  String get analyseFvg => '공정가치 갭(FVG)';

  @override
  String get analyseHintActifExamples => '예: 나스닥, EUR/USD…';

  @override
  String get analyseHintDetailsDots => '상세…';

  @override
  String get analyseHintHtfChipExample => '예: 주간';

  @override
  String get analyseHintImbalance => '불균형…';

  @override
  String get analyseHintNotesDots => '메모…';

  @override
  String get analyseHintPriceDots => '가격…';

  @override
  String get analyseHintStops => '스탑은 어디? (예: 매수측)';

  @override
  String get analyseHintTextDots => '텍스트…';

  @override
  String get analyseHintTfExamples => '예: MN, 3D…';

  @override
  String get analyseHintZoneHtf => 'HTF 구간…';

  @override
  String get analyseHtfTimeframe => '분석 시간봉(HTF)';

  @override
  String get analyseImpactFeuille => '시트 영향';

  @override
  String get analyseImpactIndicators => '지표 영향';

  @override
  String analyseImpactLine(int percent) {
    return '영향: $percent%';
  }

  @override
  String get analyseImpactModalBlurb =>
      '네 영향 합계는 100%입니다. 슬라이더를 움직이면 나머지가 비례 조정됩니다.';

  @override
  String get analyseImpactModalTitle => '영향 조정';

  @override
  String get analyseImpactShort => '영향';

  @override
  String get analyseImpactSmc => 'SMC 영향';

  @override
  String get analyseLastPointHint => '마지막 포인트…';

  @override
  String get analyseLiquidityPools => '유동성 풀';

  @override
  String get analyseMovementDetailsHint => '움직임 상세…';

  @override
  String get analyseNameFieldHint => '분석 이름…';

  @override
  String get analyseNameFieldLabel => '분석 이름';

  @override
  String get analyseNoTemplatesSaved => '저장된 템플릿 없음';

  @override
  String get analyseNote => '메모';

  @override
  String get analyseNotesIndicators => '메모(지표)';

  @override
  String get analyseNotesSmcExample => '예: FVG 전 유동성 스윕…';

  @override
  String get analyseNotesSmcLiq => '메모(SMC & 유동성)';

  @override
  String get analyseNotesVolumeProfile => '메모(거래량 프로파일)';

  @override
  String get analyseOrderBlock => '오더 블록(OB)';

  @override
  String get analysePhase => '페이즈';

  @override
  String get analyseReportCellFvg => 'FVG';

  @override
  String get analyseReportCellLiqPools => '유동성 풀';

  @override
  String get analyseReportCellOrderBlock => '오더 블록';

  @override
  String get analyseResistLower => '저항';

  @override
  String get analyseResistShort => '저항';

  @override
  String get analyseSetup => '셋업';

  @override
  String get analyseSideBuy => '매수';

  @override
  String get analyseSideSell => '매도';

  @override
  String get analyseSideWatch => '관망';

  @override
  String get analyseSmcAdds => 'SMC 추가';

  @override
  String get analyseStructTagResist => 'R';

  @override
  String get analyseStructTagSupport => 'S';

  @override
  String get analyseStructure => '구조';

  @override
  String get analyseStructureSectionTitle => '구조';

  @override
  String get analyseSupport => '지지';

  @override
  String get analyseSupportLower => '지지';

  @override
  String analyseTemplateApplied(String name) {
    return '템플릿 «$name» 적용됨';
  }

  @override
  String get analyseTemplateNameHint => '새 이름…';

  @override
  String get analyseTemplateRenameDialogTitle => '템플릿 이름 바꾸기';

  @override
  String get analyseTemplateSaveDialogTitle => '템플릿 이름';

  @override
  String get analyseTemplateStyleHint => '예: 스윙, 스캘핑…';

  @override
  String get analyseTestedTwice => '2회 테스트';

  @override
  String get analyseTimeframeLabelShort => '시간봉';

  @override
  String get analyseTooltipPickTemplate => '저장된 템플릿 선택';

  @override
  String get analyseTooltipSaveTemplatePills => '이름으로 저장(습관)';

  @override
  String get analyseTrend => '추세';

  @override
  String get analyseTrendLabel => '추세';

  @override
  String get analyseVolumePoc => 'POC';

  @override
  String get analyseVolumeProfile => '거래량 프로파일';

  @override
  String get analyseVolumeProfileDefaultLabel => '거래량 프로파일';

  @override
  String get analyseVolumeVah => 'VAH';

  @override
  String get analyseVolumeVal => 'VAL';

  @override
  String get analyseVolumeZoneFrom => '부터';

  @override
  String get analyseVolumeZoneLabel => '구간';

  @override
  String get analyseVolumeZoneTo => '까지';

  @override
  String get appBrandName => 'PAYCHEK';

  @override
  String get buttonCalculate => '계산';

  @override
  String get calAmountLabel => '금액';

  @override
  String get calMonthlyObjectiveTitle => '월간 목표';

  @override
  String get calPageTitle => '캘린더';

  @override
  String get calObjectiveLabel => '목표';

  @override
  String get calCumulativePerformanceTitle => '누적 성과';

  @override
  String get calBestDay => '최고의 날';

  @override
  String get calTradingDays => '매매 일수';

  @override
  String get calAverageShort => '평균';

  @override
  String get calPnlShort => '손익';

  @override
  String get calCapitalChangePct => '자본 %';

  @override
  String get calAveragePerDay => '일평균';

  @override
  String get calObjectiveShort => '목표';

  @override
  String calChartError(String message) {
    return '오류: $message';
  }

  @override
  String calDayTradesCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count건',
      one: '1건',
      zero: '거래 없음',
    );
    return '$_temp0';
  }

  @override
  String get monthJanuary => '1월';

  @override
  String get monthFebruary => '2월';

  @override
  String get monthMarch => '3월';

  @override
  String get monthApril => '4월';

  @override
  String get monthMay => '5월';

  @override
  String get monthJune => '6월';

  @override
  String get monthJuly => '7월';

  @override
  String get monthAugust => '8월';

  @override
  String get monthSeptember => '9월';

  @override
  String get monthOctober => '10월';

  @override
  String get monthNovember => '11월';

  @override
  String get monthDecember => '12월';

  @override
  String get monthAbbrJanuary => '1월';

  @override
  String get monthAbbrFebruary => '2월';

  @override
  String get monthAbbrMarch => '3월';

  @override
  String get monthAbbrApril => '4월';

  @override
  String get monthAbbrMay => '5월';

  @override
  String get monthAbbrJune => '6월';

  @override
  String get monthAbbrJuly => '7월';

  @override
  String get monthAbbrAugust => '8월';

  @override
  String get monthAbbrSeptember => '9월';

  @override
  String get monthAbbrOctober => '10월';

  @override
  String get monthAbbrNovember => '11월';

  @override
  String get monthAbbrDecember => '12월';

  @override
  String get calcBestBalance => '최고 잔고';

  @override
  String get calcEndBalance => '기말 잔고';

  @override
  String get calcEquityCurveTitle => '트레이드 수익률 곡선';

  @override
  String get calcLabelEntry => '진입가';

  @override
  String get calcLabelRiskShort => '리스크';

  @override
  String get calcLabelSl => '손절';

  @override
  String get calcLabelStartBalance => '기초 잔고';

  @override
  String get calcLabelTp => '익절';

  @override
  String get calcLabelTradesShort => '거래';

  @override
  String get calcLabelWinRateShort => '승률';

  @override
  String get calcLoss => '손실';

  @override
  String get calcMaxDrawdown => '최대 낙폭';

  @override
  String get calcProfitFactor => '손익비';

  @override
  String get calcRatioSectionTitle => '비율';

  @override
  String get calcResult => '결과';

  @override
  String get calcResultOfCalculation => '계산 결과';

  @override
  String get calcRowGain => '수익:';

  @override
  String get calcRowSl => 'SL:';

  @override
  String get calcRowVsCapital => '자본 대비';

  @override
  String get calcSettingsTitle => '설정';

  @override
  String get calcTotalGainLabel => '총 수익';

  @override
  String get calcTradeReturnTableTitle => '트레이드 수익률 결과';

  @override
  String get calcWin => '승';

  @override
  String get calcWinsLosses => '승 / 패';

  @override
  String get calcWorstBalance => '최저 잔고';

  @override
  String get calculateRatio => '비율 계산';

  @override
  String get cancel => '취소';

  @override
  String get capitalAmountLabel => '자본 금액';

  @override
  String get capitalCurrencyTitle => '통화';

  @override
  String get capitalEllipsis => '…';

  @override
  String get capitalHintAmount => '예: 10 450';

  @override
  String get capitalInitialTitle => '초기 자본';

  @override
  String get capitalLabel => '자본';

  @override
  String get capitalOther => '기타';

  @override
  String get capitalTooltip => '자본 및 통화(메인 계정)';

  @override
  String get checklistAddSection => '섹션 추가';

  @override
  String get checklistDefaultNewSection => '새 섹션';

  @override
  String get checklistDeleteSectionBody => '이 섹션에 대해 되돌릴 수 없습니다.';

  @override
  String get checklistDeleteSectionTitle => '섹션을 삭제할까요?';

  @override
  String get checklistEditSectionHint => '제목';

  @override
  String get checklistIntroBody => '포지션에 들어가기 전에 트레이딩 플랜의 모든 기준을 확인하세요.';

  @override
  String get checklistItemAnalyse1 => '배경 추세(HTF)가 나의 아이디어와 맞습니다.';

  @override
  String get checklistItemAnalyse2 => '가격이 핵심 구간(지지/저항, 오더 블록)에 있습니다.';

  @override
  String get checklistItemAnalyse3 => '명확한 진입 확인(패턴, 다이버전스)이 있습니다.';

  @override
  String get checklistItemHint => '기준 입력';

  @override
  String get checklistItemPsy1 => '중립적 마음으로 매매합니다(복수 매매 없음).';

  @override
  String get checklistItemPsy2 => '진입 전 잠재 손실을 수용합니다.';

  @override
  String get checklistItemPsy3 => '연패 후에도 계획을 지킵니다.';

  @override
  String get checklistItemRisque1 => '손절은 기술적으로 설정했습니다(임의 아님).';

  @override
  String get checklistItemRisque2 => '리스크는 자본의 1%를 넘지 않습니다.';

  @override
  String get checklistItemRisque3 => '손익비는 최소 1:2입니다.';

  @override
  String get checklistMenuEdit => '편집';

  @override
  String get checklistPageTitle => '체크리스트';

  @override
  String get checklistProgressCl => 'CL';

  @override
  String get checklistSectionAnalyse => '기술적 분석';

  @override
  String get checklistSectionPsy => '심리';

  @override
  String get checklistSectionRisque => '리스크 관리';

  @override
  String get clearAll => '모두 지우기';

  @override
  String get confirm => '확인';

  @override
  String get currencyNameHint => '예: CHF, XOF';

  @override
  String get currencyNameLabel => '통화 이름';

  @override
  String get customCurrencyTitle => '기타 통화';

  @override
  String get dashboardAiAnalyze => '분석';

  @override
  String get dashboardAiCoachBody =>
      '«분석»을 눌러 주간 통계(승률, 시간, 요인)를 AI가 검토하고 맞춤 심리 조언을 받으세요.';

  @override
  String get dashboardAiCoachTitle => 'PAYCHEK AI 코치';

  @override
  String get dashboardAnalyseShortcutTitle => '내 분석';

  @override
  String get dashboardBestTradeLabel => '최고 거래';

  @override
  String get dashboardCapitalBalanceHeader => '자본 / 잔고';

  @override
  String get dashboardCapitalEvolutionTitle => '자본 변화';

  @override
  String get dashboardChecklistHeading => '체크리스트';

  @override
  String get dashboardChecklistSeeRest => '더보기 >';

  @override
  String get dashboardChecklistAllDoneBravo => '좋은 거래 되세요.';

  @override
  String get dashboardMyStateSection => '내 상태';

  @override
  String get dashboardOpenStrategyTooltip => '내 전략 열기';

  @override
  String dashboardPerfHourWinRate(int percent) {
    return '$percent% 승률';
  }

  @override
  String get dashboardPerfHoursRow1 => '09:00 - 11:30 (시작)';

  @override
  String get dashboardPerfHoursRow2 => '14:30 - 16:30 (미국장)';

  @override
  String get dashboardPerfHoursRow3 => '19:00+ (저녁)';

  @override
  String get dashboardPerfHoursTitle => '성과 시간대';

  @override
  String get dashboardRingState => '상태';

  @override
  String get dashboardRingWin => '승';

  @override
  String get dashboardSuccessFactorSample => '세션 전 운동';

  @override
  String get dashboardSuccessFactorsSubtitle => '습관이 승률에 미치는 영향을 추적하세요.';

  @override
  String get dashboardSuccessFactorsTitle => '성공 요인';

  @override
  String get dashboardTfAll => '전체';

  @override
  String get dashboardTfDay => '1일';

  @override
  String get dashboardTfMonth => '1개월';

  @override
  String get dashboardTfWeek => '1주';

  @override
  String dashboardTradeCount(int count) {
    return '$count건';
  }

  @override
  String get dashboardTradeOne => '1건';

  @override
  String dashboardEvolutionTradesThisPeriod(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '이 기간 거래 $count건',
      one: '이 기간 거래 1건',
      zero: '이 기간 거래 0건',
    );
    return '$_temp0';
  }

  @override
  String get dashboardEvolutionSparklineHoverOrigin => '누적 시작';

  @override
  String get dashboardEvolutionSparklineHoverNoTrade => '이 구간에 거래 없음';

  @override
  String dashboardEvolutionSparklineHoverMore(int count) {
    return '+$count건 더';
  }

  @override
  String get dashboardEvolutionSparklineTapHint => '탭하여 열기';

  @override
  String get dashboardWeekResultPrefix => '결과: ';

  @override
  String get dashboardWeekThisWeek => '이번 주';

  @override
  String get dashboardWeekdayShortFri => '금';

  @override
  String get dashboardWeekdayShortMon => '월';

  @override
  String get dashboardWeekdayShortSat => '토';

  @override
  String get dashboardWeekdayShortSun => '일';

  @override
  String get dashboardWeekdayShortThu => '목';

  @override
  String get dashboardWeekdayShortTue => '화';

  @override
  String get dashboardWeekdayShortWed => '수';

  @override
  String get dashboardWorstLossLabel => '최대 손실';

  @override
  String get delete => '삭제';

  @override
  String deletePortfolioTitle(String name) {
    return '«$name»을(를) 삭제할까요?';
  }

  @override
  String get deleteTooltip => '삭제';

  @override
  String get editPortfolioTooltip => '이름, 자본, 통화 편집';

  @override
  String get errorAmount => '유효한 금액(≥ 0)을 입력하세요.';

  @override
  String get errorInvalidAmount => '금액 또는 통화가 잘못되었습니다.';

  @override
  String get errorNameOrSymbol => '이름 또는 기호를 입력하세요.';

  @override
  String get exportPdfFailed => 'PDF를 내보낼 수 없습니다.';

  @override
  String exportPdfFailedWithError(String error) {
    return 'PDF 내보내기 실패: $error';
  }

  @override
  String get exportPdfUnavailable => 'PDF 내보내기가 취소되었거나 사용할 수 없습니다.';

  @override
  String get homePerformance => '성과';

  @override
  String get webHomeHeroSubtitle => '환영합니다. 주간 성과입니다.';

  @override
  String webHomeHeroWelcome(Object fullName) {
    return '$fullName님, 환영합니다';
  }

  @override
  String get webHomeLiveTerminal => '라이브 터미널';

  @override
  String get webHomeWelcomeBack => '다시 오신 것을 환영합니다,';

  @override
  String get webHomeUpgradeUnlockSubtitle => '실시간 기관 데이터 잠금 해제';

  @override
  String get webRailMenuHeading => '메뉴';

  @override
  String get labelActif => '종목';

  @override
  String get labelGain => '손익';

  @override
  String get labelLot => '로트';

  @override
  String get labelMarket => '시장';

  @override
  String get labelPrice => '가격';

  @override
  String get labelRiskPct => '리스크 %';

  @override
  String get labelSuggestedSize => '추천 크기';

  @override
  String get langChineseTraditional => '中文 (繁體)';

  @override
  String get langEnglish => 'English';

  @override
  String get langFrench => 'Français';

  @override
  String get langGerman => 'Deutsch';

  @override
  String get langItalian => 'Italiano';

  @override
  String get langKorean => '한국어';

  @override
  String get langPortuguese => 'Português';

  @override
  String get langSpanish => 'Español';

  @override
  String get languageDialogSubtitle => '인터페이스 언어';

  @override
  String get languageDialogTitle => '언어 선택';

  @override
  String get languageSection => '언어';

  @override
  String get onboardingLanguageContinue => '계속';

  @override
  String get mentalBad => '나쁨';

  @override
  String get mentalConfidence => '자신감';

  @override
  String get mentalEmotionFieldLabel => '감정 이름(예: 차분, 두려움)';

  @override
  String get mentalEmotional => '감정적';

  @override
  String get mentalEnergy => '에너지';

  @override
  String get mentalExcited => '흥분';

  @override
  String get mentalFocus => '집중';

  @override
  String get mentalFrustrated => '좌절';

  @override
  String get mentalHappy => '기쁨';

  @override
  String get mentalHintEmotion => '예: 차분, 두려움';

  @override
  String get mentalHintMetric => '예: 인내, 스트레스';

  @override
  String get mentalHintRoutine => '예: 운동, 독서';

  @override
  String get mentalMarketStudy => '시장 공부';

  @override
  String get mentalMeditation => '명상(10분)';

  @override
  String get mentalMetricFieldLabel => '지표 이름(예: 인내, 스트레스)';

  @override
  String get mentalNegative => '부정(-)';

  @override
  String get mentalNeutral => '중립';

  @override
  String get mentalNewEmotion => '새 감정';

  @override
  String get mentalNewMetric => '새 지표';

  @override
  String get mentalNewRoutine => '새 루틴';

  @override
  String get mentalPeakForm => '최상 컨디션';

  @override
  String get mentalPositive => '긍정(+)';

  @override
  String get mentalRestTitle => '휴식';

  @override
  String get mentalRiskAppetite => '두려움';

  @override
  String get mentalRoutineFieldLabel => '루틴 이름(예: 운동, 독서)';

  @override
  String get mentalGlobalScoreCalendarTitle => '일별 전체 점수';

  @override
  String get mentalCalendarDayStartDialogTitle => 'Début';

  @override
  String get mentalCalendarDayWindowStartLabel => 'Début';

  @override
  String get mentalCalendarDayWindowEndLabel => 'Fin';

  @override
  String get mentalCalendarDayWindowSettingsTooltip => 'Plage 24 h';

  @override
  String get mentalCalendarDayWindowDialogTitle => 'Plage horaire du score';

  @override
  String get mentalCalendarDayEndDialogTitle => 'Fin de la plage';

  @override
  String get mentalSleepEnough => '충분한 수면';

  @override
  String mentalSleepImpact(int percent) {
    return '영향: $percent%';
  }

  @override
  String get mentalSport => '운동 / 조깅';

  @override
  String get mentalTired => '피곤';

  @override
  String get mentalWeightGlobalImpact => '전체 영향';

  @override
  String get mentalWeightModalBlurb =>
      '이 기준의 중요도를 조정하세요. 배수를 쓰거나 원하는 비율을 직접 설정하세요.';

  @override
  String get mentalWeightModalTitle => '영향 조정';

  @override
  String get mentalWeightNatureLabel => '영향 성격';

  @override
  String get mentalWeightPolarityHelpNegative => '이 기준 값이 높으면 전체 점수가 감소합니다.';

  @override
  String get mentalWeightPolarityHelpPositive => '이 기준 값이 높으면 전체 점수가 증가합니다.';

  @override
  String get mentalPageTitle => '멘탈 상태';

  @override
  String get mentalPageIntro => '멘탈 상태를 평가하세요. 프로필에 맞게 각 기준의 영향(가중치)을 조정하세요.';

  @override
  String get mentalGaugeStateLabel => '상태';

  @override
  String mentalGaugeBasedOnIndicators(int count) {
    return '$count개 지표 기준';
  }

  @override
  String get mentalGaugeStatusStable => '균형 양호';

  @override
  String get mentalGaugeStatusFragile => '주의 필요';

  @override
  String get mentalSectionRoutinesHeading => '내 루틴';

  @override
  String get mentalSectionMomentHeading => '현재 상태';

  @override
  String get mentalSectionEmotionHeading => '감정들';

  @override
  String modelSavedSnackbar(String name) {
    return '템플릿 «$name» 저장됨';
  }

  @override
  String get navAdd => '추가';

  @override
  String get navCalendar => '캘린더';

  @override
  String get navDashboard => '대시보드';

  @override
  String get navMore => '더보기';

  @override
  String get navTrade => '거래';

  @override
  String get ok => '확인';

  @override
  String get perf0Sub => '스트레스와 피로가 승률에 미치는 영향';

  @override
  String get perf0Title => '심리: 감정 & 수면';

  @override
  String get perf1Sub => '수익성 분석(월~일)';

  @override
  String get perf1Title => '요일';

  @override
  String get perf2Sub => '가장 수익이 좋은 시간 찾기';

  @override
  String get perf2Title => '세션 시간';

  @override
  String get perf3Sub => '이 차트 패턴의 성공률';

  @override
  String get perf3Title => '패턴: 이중 천장/바닥';

  @override
  String get perf4Sub => '주요 반전 분석';

  @override
  String get perf4Title => '패턴: 헤드앤숄더';

  @override
  String get perf5Sub => '과매수/과매도 신호 검증';

  @override
  String get perf5Title => '지표: RSI 다이버전스';

  @override
  String get perf6Sub => '이동평균 교차 효과';

  @override
  String get perf6Title => '지표: MACD 교차';

  @override
  String get perf7Sub => '0.618 및 0.5 레벨에서의 반등';

  @override
  String get perf7Title => '지표: 피보나치 되돌림';

  @override
  String get perf8Sub => '오더 블록과 유동성 분석';

  @override
  String get perf8Title => '전략: 스마트 머니 컨셉(SMC)';

  @override
  String get perf9Sub => '금융 리스크가 승률에 미치는 영향';

  @override
  String get perf9Title => '거래량 & 로트 크기';

  @override
  String get perfAddWidgetButton => '위젯 추가';

  @override
  String get perfChartBar => '막대 차트';

  @override
  String get perfChartHBar => '가로 막대';

  @override
  String get perfChartHintBar => '비교에 적합(예: 요일)';

  @override
  String get perfChartHintHBar => '목록 형식, 단순';

  @override
  String get perfChartHintLine => '시간에 따른 추세';

  @override
  String get perfChartHintPie => '전체 비율용';

  @override
  String get perfChartLine => '선 차트';

  @override
  String get perfChartPie => '원 / 게이지';

  @override
  String get perfCustomizeIntro => '성과 페이지를 맞춤 설정하세요.';

  @override
  String get perfDataFootnoteDuration => '데이터: 보유 시간별 분석(CSV).';

  @override
  String get perfDataFootnoteVolume => '거래량 대리: |손익| 구간(CSV).';

  @override
  String get perfEmptyChart => '거래를 가져오거나 불러와 차트를 표시하세요(CSV).';

  @override
  String get perfLineChartCaption => '선: 누적 수익(시간순, CSV).';

  @override
  String get perfNewWidgetTitle => '새 위젯';

  @override
  String get perfNoResults => '옵션을 찾을 수 없습니다.';

  @override
  String get perfPieChartCaption => '조각 = 카테고리별 거래량; 원에서 % = 비중.';

  @override
  String get perfRemoveWidgetTooltip => '위젯 제거';

  @override
  String get perfSearchHint => '검색(예: 패턴, 심리…)';

  @override
  String get perfStep1Title => '1. 무엇을 분석할까요?';

  @override
  String get perfStep2Title => '2. 차트 유형';

  @override
  String get plusAdd => '추가';

  @override
  String get plusCalculator => '계산기';

  @override
  String get plusCalendar => '캘린더';

  @override
  String get plusChecklist => '체크리스트';

  @override
  String get plusDashboard => '대시보드';

  @override
  String get plusMentalState => '멘탈 상태';

  @override
  String get plusMyAnalysis => '내 분석';

  @override
  String get plusMyStrategy => '내 전략';

  @override
  String get plusPerformance => '성과';

  @override
  String get plusSettings => '설정';

  @override
  String get plusTrade => '거래';

  @override
  String get paychekAccessDeniedTitle => 'Access restricted';

  @override
  String get paychekAccessDeniedWeb =>
      'Web access for this account has been disabled. Contact support if needed.';

  @override
  String get paychekAccessDeniedMobile =>
      'Mobile app access for this account has been disabled. Contact support if needed.';

  @override
  String get portfolioNameMissing => '포트폴리오 이름을 입력하세요(예: 브로커).';

  @override
  String get portfoliosLabel => '포트폴리오';

  @override
  String get q1Slogan => '접근 방식을 선택하세요';

  @override
  String get q1Title => '어떤 트레이더인가요?';

  @override
  String get q1o1s => '수 초~몇 분 포지션';

  @override
  String get q1o1t => '스캘핑';

  @override
  String get q1o2s => '세션 종료 전 모두 청산';

  @override
  String get q1o2t => '데이 트레이딩';

  @override
  String get q1o3s => '1~3일 보유';

  @override
  String get q1o3t => '인트라데이';

  @override
  String get q1o4s => '수일~수주 보유';

  @override
  String get q1o4t => '스윙';

  @override
  String get q2Slogan => '여정에서 어디에 있나요?';

  @override
  String get q2Title => '경험 프로필';

  @override
  String get q2o1s => '혼자가 아닙니다';

  @override
  String get q2o1s2 => '시작했고 아직 방법을 찾는 트레이더';

  @override
  String get q2o1t => '전략이 없습니다';

  @override
  String get q2o2s => '터널 끝의 빛';

  @override
  String get q2o2s2 => '기초는 있고 일관성을 원하는 분';

  @override
  String get q2o2t => '전략이 있습니다';

  @override
  String get q2o3s => '가장 어려운 부분은 지났습니다';

  @override
  String get q2o3s2 => '통계를 다루는 숙련 트레이더';

  @override
  String get q2o3t => '고성과';

  @override
  String get q3Slogan => '최우선 과제를 고르세요';

  @override
  String get q3Title => '무엇을 개선하고 싶나요?';

  @override
  String get q3o1s => '오늘 크게 이겼다가 내일 다 잃는 것을 멈추기.';

  @override
  String get q3o1s2 => '자산 곡선을 안정시키고 감정 롤러코스터를 피하기.';

  @override
  String get q3o1t => '롤러코스터에서 내려오기';

  @override
  String get q3o2s => '승률과 진입 정확도 향상.';

  @override
  String get q3o2s2 => '더 나은 거래를 고르고 자주 이기고 싶은 분.';

  @override
  String get q3o2t => '스나이퍼가 되기';

  @override
  String get q3o3s => '규율을 익히고 감정적 결정을 멈추기.';

  @override
  String get q3o3s2 => '충동 매매를 없애고 계획을 100% 지키기.';

  @override
  String get q3o3t => '냉정 유지';

  @override
  String get q3o4s => '나에게 실제로 통하는 차트 패턴을 이해하기.';

  @override
  String get q3o4s2 => '나만의 수익 패턴을 찾고 전문가로 성장하기.';

  @override
  String get q3o4t => '나만의 시그니처 찾기';

  @override
  String get q4Slogan => '가장 막는 것을 찾으세요';

  @override
  String get q4Title => '가장 큰 어려움은 무엇인가요?';

  @override
  String get q4o1s => '놓칠까 두려움.';

  @override
  String get q4o1s2 => '빨리! 수익 기회를 놓칠 거야!';

  @override
  String get q4o1t => 'FOMO';

  @override
  String get q4o2s => '이성 대신 느낌이 앞섰습니다.';

  @override
  String get q4o2s2 => '안 돼—돈을 반드시 되찾아야 해!';

  @override
  String get q4o2t => '틸트';

  @override
  String get q4o3s => '명확한 전략이나 계획이 없습니다.';

  @override
  String get q4o3s2 => '잘 모르겠지만 기분은 좋아—한번 해보자.';

  @override
  String get q4o3t => '맹목적 매매';

  @override
  String get q4o4s => '끊임없는 불안.';

  @override
  String get q4o4s2 => '클릭하지 않으면 일을 안 하는 것 같아요.';

  @override
  String get q4o4t => '과매매';

  @override
  String get q4o5s => '무적이라고 생각합니다.';

  @override
  String get q4o5s2 => '너무 잘해—쉬운 돈! 배팅을 두 배로!';

  @override
  String get q4o5t => '과신';

  @override
  String get q4o6s => '모든 것이 두렵습니다.';

  @override
  String get q4o6s2 => '잘 모르겠고 또 잃을까 봐 무섭습니다.';

  @override
  String get q4o6t => '마비';

  @override
  String get q4o7s => '러시안 룰렛을 합니다.';

  @override
  String get q4o7s2 => '이 거래에 모든 것을 걸었어—성공 아니면 실패.';

  @override
  String get q4o7t => '자금 관리 없음';

  @override
  String get reglagePortfolioSheetSubtitle => '계좌 자본 및 통화';

  @override
  String get reglagePortfolioSheetTitle => '자본 & 포트폴리오';

  @override
  String get resultDontWorry => '걱정 마세요';

  @override
  String get resultHeaderSub =>
      '이것은 프로필이 아니라 계산일 뿐입니다. 아직 실제가 아니에요. 지금부터 시작입니다.';

  @override
  String get resultLabelGlobal => '전체';

  @override
  String get resultLabelProfil => '프로필';

  @override
  String get resultLabelPsychology => '심리';

  @override
  String get resultLabelStrategy => '전략';

  @override
  String resultStatBullet1(int percent) {
    return '이 단계의 트레이더 중 $percent%는 수학적 엄밀함 부족으로 정체되거나 손실을 봅니다.';
  }

  @override
  String resultStatBullet2(int percent) {
    return '트레이더의 $percent%가 같은 상황입니다.';
  }

  @override
  String get resultStatBullet3 => '심리가 강한 트레이더는 100가지 전략을 아는 사람보다 낫게 매매합니다.';

  @override
  String get save => '저장';

  @override
  String get screenshot => '스크린샷';

  @override
  String get accountPageTitle => '계정';

  @override
  String get mobileReconnectAfterLogoutTitle => '로그아웃되었습니다';

  @override
  String get mobileReconnectAfterLogoutBody =>
      '클라우드 프로필과 구독 상태를 복원하려면 다시 로그인하세요. 계정 없이 이 기기에서 앱을 계속 사용할 수도 있습니다.';

  @override
  String get mobileReconnectContinueWithoutAccount => '로그인 없이 계속';

  @override
  String get profileViewDetailsSection => '프로필 정보';

  @override
  String get profileAccountStatusTitle => '계정 상태';

  @override
  String get profileAccountStatusPro => 'Pro';

  @override
  String get profileAccountStatusLite => 'Lite';

  @override
  String get profileTrialBadge => '체험';

  @override
  String profileTrialDaysLeft(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '무료 체험 $count일 남음',
      one: '무료 체험 1일 남음',
    );
    return '$_temp0';
  }

  @override
  String profileTrialEndsOn(String date) {
    return '체험 종료일: $date';
  }

  @override
  String profileTrialEndedOn(String date) {
    return '체험이 $date에 종료됨';
  }

  @override
  String profileProPeriodEndsOn(String date) {
    return '갱신일: $date';
  }

  @override
  String get profileSubscribeButton => 'Pro로 업그레이드 (연 \$49.90 구독)';

  @override
  String get profileManageSubscriptionButton => '구독 관리';

  @override
  String get profileUpgradeLabel => '업그레이드';

  @override
  String get profileEditSavedSnack => '프로필이 저장되었습니다';

  @override
  String get profileEditIncompleteFieldsSnack => '이름, 성, 이메일을 모두 입력하세요';

  @override
  String get profileEditInvalidEmailSnack => '올바른 이메일 주소를 입력하세요';

  @override
  String get accountAuthSectionTitle => '로그인';

  @override
  String get accountContinueWith => '다음으로 계속:';

  @override
  String get accountTabLogin => '로그인';

  @override
  String get accountTabSignup => '회원가입';

  @override
  String get accountFieldEmail => '이메일';

  @override
  String get accountFieldPassword => '비밀번호';

  @override
  String get accountFieldConfirmPassword => '비밀번호 확인';

  @override
  String get accountFieldBirthDate => '생년월일';

  @override
  String get accountFieldFirstName => '이름';

  @override
  String get accountFieldLastName => '성';

  @override
  String get accountLoginButton => '로그인';

  @override
  String get accountSignupButton => '계정 만들기';

  @override
  String get authTerminalTagline => '마음을 다스리고, 트레이드를 다스리다';

  @override
  String get authTerminalCtaLogin => '터미널 시작';

  @override
  String get authTerminalCtaSignup => '아이덴티티 만들기';

  @override
  String get authTerminalEncryptedPrefix => '암호화 노드:';

  @override
  String get authTerminalEncryptedStatus => '활성';

  @override
  String get authTerminalHintEmail => 'name@terminal.com';

  @override
  String get authTerminalHintPassword => '••••••••';

  @override
  String get accountLoginSnackEmailMissing => '로그인: 이메일을 입력하세요';

  @override
  String get accountLoginSnackEmailReady => '로그인: 이메일 입력됨';

  @override
  String get accountSignupSnackEmailMissing => '회원가입: 이메일을 입력하세요';

  @override
  String get accountSignupSnackFirstNameMissing => '회원가입: 이름을 입력하세요';

  @override
  String get accountSignupSnackLastNameMissing => '회원가입: 성을 입력하세요';

  @override
  String get accountSignupSnackBirthDateMissing => '회원가입: 생년월일을 선택하세요';

  @override
  String get accountSignupSnackReady => '회원가입: 양식 준비 완료';

  @override
  String get accountSignupSnackPasswordMissing => '회원가입: 비밀번호를 입력하세요';

  @override
  String get accountSignupSnackPasswordMismatch => '회원가입: 비밀번호가 일치하지 않습니다';

  @override
  String get accountSignupSnackPasswordTooShort => '비밀번호는 최소 6자 이상이어야 합니다';

  @override
  String get accountLoginSnackPasswordMissing => '로그인: 비밀번호를 입력하세요';

  @override
  String get accountForgotPasswordLink => '비밀번호를 잊으셨나요?';

  @override
  String get accountForgotPasswordSnackEmailMissing =>
      '위에 이메일을 입력하면 재설정 링크를 보내 드립니다.';

  @override
  String get accountForgotPasswordSnackSent =>
      '해당 이메일로 가입된 계정이 있으면 새 비밀번호를 설정할 링크를 보냅니다.';

  @override
  String get accountForgotPasswordSnackTooManyRequests =>
      '요청이 너무 많습니다. 잠시 후 다시 시도하세요.';

  @override
  String get accountPasswordResetDialogTitle => '비밀번호 재설정';

  @override
  String get accountPasswordResetDialogSubtitle =>
      'Paychek 계정 이메일을 입력하세요. 새 비밀번호를 설정할 링크를 보냅니다.';

  @override
  String get accountPasswordResetCta => '링크 보내기';

  @override
  String get accountPasswordResetBackToLogin => '로그인으로 돌아가기';

  @override
  String get accountPasswordResetSnackEmailMissing => '이메일을 입력하세요.';

  @override
  String get accountPasswordResetSentDialogTitle => '메일함을 확인하세요';

  @override
  String get accountPasswordResetSentDialogMessage =>
      '해당 주소로 가입된 계정이 있으면 새 비밀번호를 설정할 링크가 포함된 이메일을 보냅니다. 스팸함도 확인해 주세요.';

  @override
  String get accountPasswordResetSentDialogCta => '확인';

  @override
  String get accountAuthSignupSuccess => '계정이 생성되었습니다';

  @override
  String get accountAuthLoginSuccess => '로그인되었습니다';

  @override
  String get accountAuthErrorWeakPassword => '비밀번호가 너무 약합니다';

  @override
  String get accountAuthErrorEmailInUse => '이미 사용 중인 이메일입니다';

  @override
  String get accountAuthErrorInvalidEmail => '유효하지 않은 이메일입니다';

  @override
  String get accountAuthErrorWrongCredentials => '이메일 또는 비밀번호가 올바르지 않습니다';

  @override
  String get accountAuthErrorNetwork => '네트워크 오류입니다. 다시 시도하세요.';

  @override
  String get accountAuthErrorGeneric => '문제가 발생했습니다';

  @override
  String get accountAuthErrorRestartOrReload =>
      '인증 연결이 끊어졌습니다. 앱을 완전히 종료한 뒤 다시 실행하세요(웹에서는 핫 리로드를 피하세요).';

  @override
  String get accountAuthErrorDifferentSignInMethod =>
      '이 이메일은 다른 로그인 방식으로 이미 사용 중입니다.';

  @override
  String accountAuthErrorWithFirebaseCode(String code) {
    return '문제가 발생했습니다 ($code).';
  }

  @override
  String get accountAuthErrorUnknownFirebaseAuth =>
      '로그인에 실패했습니다(알 수 없는 오류). 연결을 확인하고 다시 시도하거나 Chrome에서 Paychek을 여세요. Firebase 콘솔 → Authentication에서 이메일/비밀번호와 사용 중인 제공업체를 사용 설정하세요.';

  @override
  String accountAuthErrorSignInServerMessage(String message) {
    return '$message';
  }

  @override
  String get accountAuthWindowsSignInNotice =>
      'Windows 데스크톱 앱에서는 Firebase 로그인이 자주 불안정할 수 있습니다(Flutter/Firebase의 알려진 제한). Paychek 모바일 앱을 사용하거나 브라우저에서 로그인하세요.';

  @override
  String get accountAuthWindowsOpenWebsite => '브라우저에서 paychek.pro 열기';

  @override
  String get accountSocialAppleAndroidUseGoogle =>
      '이 빌드에서는 Android에서 Apple 로그인이 설정되어 있지 않습니다. Google 또는 이메일을 사용하거나 웹에서 로그인하세요.';

  @override
  String get accountSocialAppleUnavailableDesktop =>
      'Windows/Linux 데스크톱 앱에서는 Apple 로그인을 사용할 수 없습니다. 웹(Chrome), iPhone, iPad 또는 Mac을 사용하세요.';

  @override
  String get accountSocialGoogleUnavailableDesktop =>
      'Windows/Linux에서는 Google 로그인을 사용할 수 없습니다. Chrome, Android 또는 iOS를 사용하세요.';

  @override
  String get accountSocialFacebookUnavailableDesktop =>
      'Windows/Linux 데스크톱 앱에서는 Facebook 로그인을 사용할 수 없습니다. 웹(Chrome), Android, iOS 또는 macOS를 사용하세요.';

  @override
  String get accountSocialGoogleWebClientMissing =>
      '모바일/태블릿에서 Google: lib/reglage/social_auth_config.dart에 웹 OAuth 클라이언트 ID를 설정하세요. Android는 Firebase(프로젝트 설정 → Android 앱)에 앱 SHA-1 지문을 등록하세요.';

  @override
  String get paywallTitle => '무료 체험이 끝났습니다';

  @override
  String get paywallHeadlineBefore => '무료 체험이 ';

  @override
  String get paywallHeadlineAccent => '종료되었습니다';

  @override
  String get paywallUpgradeSubtitle => 'Pro로 업그레이드해 트레이딩 잠재력을 모두 열고 우위를 유지하세요.';

  @override
  String paywallEndedOn(String date) {
    return '체험 종료일: $date.';
  }

  @override
  String get paywallCompareCurrentPlan => '현재 플랜';

  @override
  String get paywallCompareRecommended => '추천';

  @override
  String get paywallPlanLiteName => 'Lite';

  @override
  String get paywallPlanProName => 'Pro';

  @override
  String get paywallLiteFeature1 => '월 30회 트레이드';

  @override
  String get paywallLiteFeature2 => '수동 입력만';

  @override
  String get paywallLiteFeature3 => '기본 캘린더';

  @override
  String get paywallProFeature1 => '무제한';

  @override
  String get paywallProFeature2 => 'CSV 가져오기 및 수동 입력';

  @override
  String get paywallProFeature3 => 'Pro 캘린더';

  @override
  String get paywallProFeature4 => '체크리스트';

  @override
  String get paywallProFeature5 => '분석 생성기';

  @override
  String get paywallProFeature6 => '전략 페이지';

  @override
  String get paywallProFeature7 => '성과 통계';

  @override
  String get paywallProFeature8 => '멘탈 상태';

  @override
  String get paywallProFeature9 => 'PDF보내기';

  @override
  String get paywallPriceAnnualHighlight => '연 US\$49.90';

  @override
  String get paywallPriceApproxPerMonth => '월 약 US\$4.15';

  @override
  String paywallTrialEndedBody(String date) {
    return '신규 가입 7일 무료 체험이 $date에 종료되었습니다. Pro가 없으면 Lite 요금제입니다.';
  }

  @override
  String get paywallLiteLimitedHint =>
      'Lite에서는 트레이드 추가와 캘린더만 사용할 수 있습니다. 나머지는 Pro 구독이 필요합니다.';

  @override
  String get paywallProPriceAnnual => 'Pro: 연 US\$49.90';

  @override
  String get paywallContinueFreemium => 'Lite로 계속 (제한적 이용)';

  @override
  String get paywallSubscribeButton => '지금 구독';

  @override
  String get paywallRestoreButton => '이미 구독 중입니다';

  @override
  String get paywallStoreNotConfigured =>
      'Stripe 결제 링크가 없습니다. Admin → Config → Payment Link(https://…) 설정, 결제 활성화 후 로그인 상태에서 다시 시도하세요.';

  @override
  String get paywallRestoreNothingFound => '계속 차단됨: 활성 구독이 감지되지 않았습니다.';

  @override
  String get paywallLegalFooter => 'Stripe 보안 결제 • 언제든 해지 • 서비스 약관';

  @override
  String get paywallGoldPremiumPill => '프리미엄 액세스';

  @override
  String get paywallGoldMarketingHeadline => 'PRO로 업그레이드';

  @override
  String get paywallGoldTagline => '수익 내는 트레이더를 위한 도구.';

  @override
  String get paywallGoldYourPlanLabel => '현재';

  @override
  String get paywallGoldLiteColumnCaption => '스탠다드';

  @override
  String get paywallGoldProColumnCaption => '무제한';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsSupportSection => '지원';

  @override
  String get settingsSupportCardTitle => '지원 및 피드백';

  @override
  String get settingsSupportCardSubtitle => '이메일로 문의하고 앱 내 가이드를 확인하세요.';

  @override
  String get supportFeedbackTitleLead => '지원 & ';

  @override
  String get supportFeedbackTitleAccent => '피드백';

  @override
  String get supportFeedbackSubtitle => '질문이나 아이디어가 있나요? 기다리고 있어요.';

  @override
  String get supportFeedbackBack => '뒤로';

  @override
  String get supportActionEmailLabel => '이메일';

  @override
  String get supportActionEmailHint => '24시간 내 답변';

  @override
  String get supportActionDocsLabel => '문서';

  @override
  String get supportActionDocsHint => '이용 가이드';

  @override
  String get supportActionTwitterLabel => 'X';

  @override
  String get supportActionTwitterHint => '커뮤니티';

  @override
  String get supportFormNewMessage => '새 메시지';

  @override
  String get supportFormKindLabel => '문의 유형';

  @override
  String get supportFormKindAccount => '계정';

  @override
  String get supportFormKindBilling => '결제 · 청구';

  @override
  String get supportFormKindFeature => '기능';

  @override
  String get supportFormKindOther => '기타';

  @override
  String get supportFormEmailLabel => '이메일';

  @override
  String get supportFormEmailHint => 'name@example.com';

  @override
  String get supportFormDescriptionLabel => '설명';

  @override
  String get supportFormDescriptionHint => '내용을 입력하세요…';

  @override
  String get supportFormSubmit => '지금 보내기';

  @override
  String get supportFormSubmitSuccess => '감사합니다. 메시지가 성공적으로 전송되었습니다.';

  @override
  String get supportFormSubmitSuccessPartial =>
      '감사합니다. 메시지는 전송되었지만 첨부 파일은 업로드되지 않았습니다.';

  @override
  String get supportFormSubmitDone => '메일 앱이 열리지 않으면 다시 시도하거나 직접 메일을 보내 주세요.';

  @override
  String get supportFormErrorEmail => '이메일을 입력하세요.';

  @override
  String get supportFormErrorDescription => '설명을 입력하세요.';

  @override
  String get supportFormMailSubjectPrefix => 'Paychek 지원';

  @override
  String get supportFormMailBodyIntro => 'Paychek 앱에서 보낸 메시지:';

  @override
  String get supportFormAttachmentLabel => '첨부(선택)';

  @override
  String get supportFormAttachmentPick => '사진 또는 PDF';

  @override
  String get supportFormAttachmentHint => 'PDF 또는 이미지, 최대 10MB';

  @override
  String get supportFormAttachmentRemove => '파일 제거';

  @override
  String get supportFormAttachmentSignInHint => '첨부하려면 로그인하거나, 이메일만 보낼 수 있습니다.';

  @override
  String get supportFormAttachmentTooLarge => '10MB를 초과했습니다.';

  @override
  String get supportFormAttachmentInvalidExtension =>
      'PDF, JPG, PNG, WebP만 가능합니다.';

  @override
  String get supportFormAttachmentReadFailed => '파일을 읽을 수 없습니다.';

  @override
  String get supportFormSubmitFirestoreDone =>
      '감사합니다. 메시지가 저장되었습니다. 관리 콘솔에서 확인됩니다.';

  @override
  String get supportFormSubmitSending => '전송 중…';

  @override
  String get supportFormSubmitError => '전송 실패. 연결을 확인하세요.';

  @override
  String get supportFormSubmitSavedPartialAttachment =>
      '메시지는 저장되었지만 첨부가 업로드되지 않았습니다(네트워크 또는 Storage). Firebase를 확인하세요.';

  @override
  String get supportQuickHelpTitle => '빠른 도움말';

  @override
  String get supportFaqWhereDataQ => '내 데이터는 어디에 있나요?';

  @override
  String get supportFaqWhereDataA =>
      '이 기기에 저장됩니다(설정, 일지, 포트폴리오). 로그아웃 또는 데이터 삭제 시 사라질 수 있으며, 보관에는 PDF 내보내기를 이용하세요.';

  @override
  String get supportFaqFeatureQ => '새 기능이 필요하신가요?';

  @override
  String get supportFaqFeatureA => '위 양식에서 «기능 제안»을 선택해 보내 주세요. 모든 메시지를 확인합니다.';

  @override
  String get supportStatusLabel => '기술 상태';

  @override
  String get supportStatusOperational => '서비스 정상';

  @override
  String get helpCenterTitle => '고객센터';

  @override
  String get helpCenterSubtitle => '앱 사용에 대한 간단한 답변과 설명을 확인하세요.';

  @override
  String get helpCenterSearchHint => '검색…';

  @override
  String get helpCenterVersionMobile => '모바일 버전';

  @override
  String get helpCenterVersionWeb => '웹 버전';

  @override
  String get helpCenterEmptyResults => '결과가 없습니다.';

  @override
  String get helpCenterArticleAddTradeTitle => '거래 추가';

  @override
  String get helpCenterArticleAddTradeBody =>
      '추가 탭에서 필드를 입력하세요(종목, 진입, 손절, 목표 등). 저장하면 됩니다. 필요하면 스크린샷을 첨부할 수 있습니다.';

  @override
  String get helpCenterArticleEditTradeTitle => '트레이드 — 일지 화면';

  @override
  String get helpCenterArticleEditTradeBody =>
      'Guide : Maîtriser votre Journal de Trading (Page Trade)\nLa page Trade est le centre d\'archivage intelligent de Paychek. Elle ne se contente pas de lister vos opérations ; elle les organise pour vous offrir une vision claire de votre progression, du trade individuel à la performance mensuelle.\n\n[img:assets/help_center/trade_page_header_filters.png]\n\n1. Tableau de Bord de Période (Header)\nEn haut de votre journal, vous disposez d\'un résumé instantané de la période sélectionnée :\n\nProfit Net : Votre résultat financier net en dollars et son impact en pourcentage sur votre capital (ex: +1070,00\$ / +53,50%).\n\nLe Win Rate Ring : L\'anneau central affiche votre pourcentage de réussite global. C\'est l\'indicateur visuel immédiat de la santé de votre trading.\n\nCompteur de Trades : Le détail précis du nombre de positions Gagnantes (G), Perdantes (P) et à l\'équilibre (Br).\n\n2. Navigation et Filtres Temporels\nPersonnalisez votre vue selon votre besoin d\'analyse grâce aux sélecteurs rapides :\n\nSélecteur 1D / 1S / 1M / ALL : Basculez instantanément entre une vue journalière, hebdomadaire, mensuelle ou l\'historique complet.\n\nFiltres de statut : Isolez vos trades Gagnants, Perdants ou Breakeven d\'un seul clic pour étudier des comportements spécifiques.\n\nActifs les plus tradés : Visualisez rapidement vos statistiques sur vos instruments préférés (ex: XAUUSD, EURUSD).\n\n[img:assets/help_center/trade_page_period_pdf_report.png]\n\n3. Structure en Accordéons et Rapports PDF\nL\'interface utilise un système de \"replier/déplier\" pour une lecture fluide et des options d\'exportation à tous les niveaux :\n\nRapports de Période (Jour/Semaine/Mois) : Chaque bloc de date (ex: \"14 Mars\") affiche un résumé de la performance du jour.\n\nEn cliquant sur l\'icône PDF à côté de la date, vous téléchargez un rapport complet de cette période spécifique. Idéal pour vos bilans de fin de semaine ou de mois.\n\nRapports de Trade Individuel : Cliquez sur un trade pour le déplier et voir ses détails (Heures, Session, Entry/Exit).\n\nChaque trade possède son propre bouton PDF. Ce document génère une fiche technique pro avec votre graphique et vos scores de discipline.\n\n[img:assets/help_center/trade_page_rings_week_view.png]\n\n4. Analyse visuelle par Ring\nChaque ligne (journée ou trade) est accompagnée d\'un Ring (anneau) :\n\nPour une journée, le ring représente le Win Rate global du jour.\n\nCela vous permet d\'identifier en une seconde vos journées \"rouges\" ou \"vertes\" sans avoir à lire chaque ligne de trade.\n\n[img:assets/help_center/trade_page_options_menu.png]\n\n5. Options de Gestion et Correction (Les 3 points)\nParce qu\'une erreur de saisie peut arriver, Paychek vous donne un contrôle total sur vos archives. À côté de l\'icône PDF de chaque fiche trade, vous trouverez un menu \"Options\" (représenté par 3 points verticaux) :\n\nModifier le Trade : Vous permet de réouvrir le formulaire de saisie pour corriger un prix, changer l\'heure, ajouter un screenshot oublié ou ajuster vos scores de discipline.\n\nSupprimer le Trade : Efface définitivement l\'enregistrement de votre journal.\n\nAttention : La suppression d\'un trade mettra à jour instantanément vos statistiques globales, votre Win Rate et votre capital dans les pages Trade et Performance.';

  @override
  String get helpCenterArticleChecklistTitle => '체크리스트';

  @override
  String get helpCenterArticleChecklistBody =>
      '📋 Checklist\n\n[img:assets/help_center/checklist_routine_discipline.png]\n\n1. Understanding the progress ring\nThe colored circle at the top of your screen is your readiness indicator.\n\n- Real-time progress: each ticked box moves the percentage forward.\n- Your checklist ring is not only on Routine — it stays in sync on your main Dashboard.\n- The gold standard: we recommend never opening a position unless your ring is at 100%. A trade taken with an incomplete checklist is often an emotional trade.\n\n2. Customize your routine\nEvery trader is unique. Paychek lets you build your own verification system.\n\n- Add a section: tap “+ Add a section” at the bottom to create a category (e.g. morning routine, economic news, post-session).\n- Manage items (⋯ menu):\n  - Add a task: open the three-dot menu next to a section title to insert a new checkpoint.\n  - Delete / edit: if a rule no longer fits your strategy, remove it to keep the UI clean.\n\n3. Default sections\nTo help you get started, we include three pillars:\n\n- Technical Analysis: validate your confluences (trend, S/R, indicators).\n- Risk Management: confirm your stop-loss is set and your risk per trade is respected.\n- Psychology: a quick check that you are not in revenge mode or euphoria.';

  @override
  String get helpCenterArticleCalendarTitle => '캘린더';

  @override
  String get helpCenterArticleCalendarBody =>
      '📅 Guide: Calendar & performance analysis\n\nThe Paychek Calendar is your main steering tool. It turns raw data into a visual map of your success and discipline.\n\n[img:assets/help_center/calendar_overview.png]\n\n1. Month overview\nColor coding: Green cells show net profit, red cells a loss, and gray cells days with no activity.\n\nQuick summary: Above the calendar, see your win rate, trade count, and total monthly P&L at a glance.\n\nMonthly objective: Watch the progress bar to see how far you are from your financial goal. Tap the settings icon to change your target.\n\n[img:assets/help_center/calendar_monthly_objective.png]\n\n2. Expandable menu (deep analysis)\nTap any month header to open detailed analysis.\n\n[img:assets/help_center/calendar_deep_analysis.png]\n\nDiscipline rings: View your average discipline scores for the month (plan followed, checklist completed, mental state).\n\nSession breakdown: See performance by timezone — Asia, Europe, and US. Great for spotting which part of the day pays best for you.\n\nInteractive sparkline (performance curve):\n- Hover the line to pinpoint a trade (on mobile, drag along the curve with your finger).\n- Tap a point on the curve to open that trade’s full record instantly.\n\n3. Session statistics (sidebar)\nTo the right of your calendar, your consistency stats:\n\nCumulative performance: How your capital evolves day by day.\n\nBest day: Your largest daily gain of the month.\n\nAverage day: What you gain or lose on average per day.\n\n[img:assets/help_center/calendar_trades_month_report.png]\n\n4. PDF export 📄\nAt the top right of the Calendar page, the PDF icon generates a professional report in one tap.\n\nWhat’s inside: The report includes the visual calendar, the performance curve, and a recap of your discipline averages.';

  @override
  String get helpCenterArticleMentalStateTitle => '멘탈 상태';

  @override
  String get helpCenterArticleMentalStateBody =>
      'Guide: Mental state — tailor your psychology\n\nRoughly 80% of trading success is psychology. The Mental state page lets you measure how you feel and see how emotions affect your results.\n\n[img:assets/help_center/mental_state_dashboard.png]\n\n1. Global score (The Ring)\nThe central ring shows your “Solid Balance”. It updates from all your indicators (emotions, rest, routines). The higher the score, the more you are in a mindset suited to trading.\n\n2. Personalized impact (gear ⚙️)\nEvery trader is different. Paychek lets you define your own rules:\n\n[img:assets/help_center/mental_state_adjust_impact.png]\n\n- Impact nature: open a criterion’s gear to set Positive (+) or Negative (−). Example: if excitement is dangerous for you, set it to Negative.\n\n- Global impact (%): the slider sets how much that criterion weighs on your global score. Crank it up for what matters most; lower it for secondary criteria.\n\n3. Sections & emotions\n\n[img:assets/help_center/mental_state_section_controls.png]\n\n- Edit / delete: pencil to rename an emotion or indicator; trash to remove it.\n\n- Section toggle (ON / OFF 100%): turn off an entire section (e.g. My Routines). When off, it no longer counts toward your daily global score.\n\n- Add (+): create your own indicators to match your routine.\n\n4. Score calendar & time window\nThe mini-calendar shows your mental score for past days.\n\n- Session settings (⚙️): set a start time and an end time.\n\n- Day mode: track from morning to evening (full-day style window).\n\n- Session mode: focus on trading hours only (e.g. 3:30 PM – 10:00 PM).';

  @override
  String get helpCenterArticleExportPdfTitle => 'PDF 내보내기';

  @override
  String get helpCenterArticleExportPdfBody =>
      '트레이드 또는 퍼포먼스에서 PDF 내보내기를 사용하세요. 실패하면 권한을 확인한 뒤 다시 시도하세요.';

  @override
  String get helpCenterArticleResetDataTitle => '로컬 데이터 삭제';

  @override
  String get helpCenterArticleResetDataBody =>
      '설정 > 데이터에서 이 기기에 저장된 데이터를 지울 수 있습니다. 되돌릴 수 없으며, 이후 앱을 다시 시작하는 것이 좋습니다.';

  @override
  String get helpCenterArticleMyStrategyTitle => '내 전략 — 플레이북';

  @override
  String get helpCenterArticleMyAnalysisTitle => '내 분석 — 트레이딩 플랜';

  @override
  String get helpCenterArticleMyAnalysisBody =>
      '🔬 My Analysis: Build Your Trading Plans\n\nThe My Analysis page lets you build a full roadmap before you enter the market. By quantifying each technical element, Paychek calculates a global confidence score to validate your setup.\n\n[img:assets/help_center/analyse_trend_sheet.png]\n\n1. Trend card (context)\nDefine the frame for your opportunity:\n\nAsset & name: Use (+) to name your analysis and the instrument (e.g. EUR/USD — Weekly Swing Plan).\n\nDirection & phase: Choose your bias (Buy, Sell, or Watch) and the current market phase (Accumulation, Impulse, Distribution).\n\nConfidence slider: Set how certain you feel for this section. Open the gear (⚙️) to adjust this card’s impact (weight %) on the final report confidence.\n\n[img:assets/help_center/analyse_card_controls.png]\n\nCustomization: Use the pencil to edit available timeframes or phases, and Duplicate to compare several analyses on different timeframes in the same section.\n\n2. Technical sections (Structure, SMC, Indicators, Volume)\nEveryone trades differently. Turn cards on or off with the ON/OFF switch:\n\n[img:assets/help_center/analyse_technical_cards.png]\n\nStructure: Log support and resistance. Tick if a level was tested more than twice to strengthen relevance.\n\nSMC & Liquidity: Record Order Blocks, Fair Value Gaps (FVG), and Fibonacci levels.\n\nIndicators & Volume profile: Detail RSI/MACD signals or Point of Control (POC) zones.\n\nScreenshot: Attach a chart capture to illustrate your plan visually.\n\n3. Generating the report\nWhen your analysis is ready, tap Report.\n\n[img:assets/help_center/analyse_summary_report.png]\n\nGlobal confidence ring: The final ring is computed from your sliders and their impact weights.\n\nDynamic color coding: The validated report at the bottom uses a color that matches your direction: green (Buy), red (Sell), or yellow (Watch).\n\n[img:assets/help_center/analyse_report_embedded.png]\n\n4. Managing reports\nHistory: Reports are saved and tied to your instruments.\n\nActions: You can edit (pencil), delete (trash), or export a professional PDF of your analysis to archive or share.\n\n[img:assets/help_center/analyse_report_pdf.png]';

  @override
  String get helpCenterArticlePerformanceTitle => '퍼포먼스 — 트레이딩 스캐너';

  @override
  String get settingsLogoutButton => '로그아웃';

  @override
  String get settingsLogoutSnack => '로그아웃되었습니다.';

  @override
  String get settingsLogoutSnackPartial =>
      '기기에서 프로필이 지워졌습니다. 계속 보이면 네트워크를 확인하거나 앱을 다시 시작하세요.';

  @override
  String get splashTagline => '마음을 다스리고, 트레이드를 다스리다';

  @override
  String get statsAvgGain => '평균 수익';

  @override
  String get statsPsychSub => '계획 준수';

  @override
  String get statsPsychology => '심리';

  @override
  String get statsRR => '손익비';

  @override
  String get statsSectionTitle => '통계';

  @override
  String get statsStrategy => '전략';

  @override
  String get statsStrategySub => '검증된 기준';

  @override
  String get strategieAlertSignal => '알림 시그널';

  @override
  String get strategieDescription => '설명';

  @override
  String get strategieDescriptionHint => '예: 낮은 변동성';

  @override
  String get strategieEditSessionTitle => '세션 편집';

  @override
  String get strategieHintEntry => '매수/매도를 어디서 클릭하나요?';

  @override
  String get strategieHintIndicatorTag => '예: RSI';

  @override
  String get strategieHintInvalidation => '시나리오가 틀린 곳은?';

  @override
  String get strategieHintManagement => '포지션을 어떻게 보호하나요?';

  @override
  String get strategieHintPattern => '예: 이중 바닥';

  @override
  String get strategieHintSignal => '트리거…';

  @override
  String get strategieHintTarget => '최종 목표 또는 유동성 구간';

  @override
  String get strategieHintTimeframeTag => '예: M15';

  @override
  String get strategieIndicators => '지표';

  @override
  String get strategieModelName => '모델 이름';

  @override
  String get strategieNewSessionTitle => '새 세션';

  @override
  String get strategiePatternFigure => '패턴 / 도형';

  @override
  String get strategieRuleEntryPrecise => '정확한 진입';

  @override
  String get strategieRuleInvalidation => '무효화(손절)';

  @override
  String get strategieRuleManagement => '관리(본전 / 분할청산)';

  @override
  String get strategieRuleTarget => '목표(익절)';

  @override
  String get strategieSessionName => '세션 이름';

  @override
  String get strategieSetupColor => '색';

  @override
  String get strategieSetupEditTitle => '셋업 편집';

  @override
  String get strategieSetupNewTitle => '새 셋업';

  @override
  String get strategieTimeEndOptionalLabel => '종료(선택)';

  @override
  String get strategieTimeStartLabel => '시작';

  @override
  String get strategieTimeframes => '시간봉';

  @override
  String get strategieZoneNoTrade => '매매 안 함';

  @override
  String get strategieZoneTrade => '매매';

  @override
  String get strategieZoneType => '구간 유형';

  @override
  String get strategiePagePlaybookIntro =>
      '트레이딩 플랜(플레이북). 규율과 집중을 위해 세션 전에 이 규칙을 다시 읽으세요.';

  @override
  String get analyseReportTitle => '리포트';

  @override
  String get strategieGestionCaptionMaximum => '최대';

  @override
  String get strategieGestionCaptionMinimum => '최소';

  @override
  String get strategieSectionSetupsAndModels => '셋업 & 템플릿';

  @override
  String get strategieSectionTradeCalendar => '트레이드 캘린더';

  @override
  String get strategieCalendarNeedSetupForUsage =>
      '위에서 셋업을 추가하면 사용한 날을 기록할 수 있습니다.';

  @override
  String strategieCalendarUsageForSetup(String name) {
    return '사용 기록 — $name';
  }

  @override
  String get strategieCalendarUsageTooltip =>
      '이 셋업으로 이 날짜를 표시하거나 해제합니다(트레이드 추가와 동일한 이름).';

  @override
  String get strategieCalendarDotsExplain =>
      '해당 일에 사용한 전략마다 점이 표시됩니다(트레이드 추가, 진입일 기준).';

  @override
  String get strategieSetupNavPrevious => '이전';

  @override
  String get strategieSetupNavNext => '다음 셋업 >';

  @override
  String get strategieSheetSetupsTitle => '셋업 & 템플릿';

  @override
  String get strategieMenuDisableFactors => '비활성화';

  @override
  String get strategieManageTemplates => '템플릿 관리';

  @override
  String get strategieDuplicateSetup => '셋업 복제';

  @override
  String get strategieMesReglesDraftHint => '새 규칙…';

  @override
  String get strategieSetupRemoveFromDashboard => '대시보드에서 제거';

  @override
  String get strategieSetupShowOnDashboard => '대시보드에 표시';

  @override
  String get strategiePdfPlaybookBlurbShort =>
      '트레이딩 플랜(플레이북). 세션 전에 이 규칙을 다시 읽으세요.';

  @override
  String get strategiePdfFooterNote =>
      '황금 규칙: 참고 문구(저장 안 됨). 리스크, 세션, 셋업: 저장된 데이터.';

  @override
  String get strategiePdfTableSession => '세션';

  @override
  String get strategiePdfTableDescription => '설명';

  @override
  String get strategiePdfTableSchedule => '일정';

  @override
  String get strategiePdfTechnicalContext => '기술적 맥락';

  @override
  String get strategiePdfAlertSignal => '알림 시그널';

  @override
  String get strategiePdfFileNamePrefix => 'my_strategy';

  @override
  String strategiePdfExportError(String error) {
    return 'PDF를 만들 수 없습니다: $error';
  }

  @override
  String get symbolHint => '예: Fr, ₣';

  @override
  String get symbolLabel => '심볼';

  @override
  String get tradeColEndingBalance => '기말 잔고';

  @override
  String get tradeColPnl => '손익';

  @override
  String get tradeColResult => '결과';

  @override
  String get tradeColStartingBalance => '기초 잔고';

  @override
  String get tradeColTotalGain => '총 수익';

  @override
  String get tradeColTotalGainPct => '총 수익 %';

  @override
  String get tradeColTrade => '거래 #';

  @override
  String get tradeDeleteConfirmBody => '이 작업은 되돌릴 수 없습니다.';

  @override
  String get tradeDeleteConfirmTitle => '이 거래를 삭제할까요?';

  @override
  String get tradeReturn => '거래 수익률';

  @override
  String get tradeActionsTooltip => '작업';

  @override
  String get tradeAverageShort => '평균';

  @override
  String tradeDayTradeNumber(int n) {
    return '오늘의 거래 #$n';
  }

  @override
  String tradeDurationHoursMinutes(int hours, String minutes) {
    return '$hours시간 $minutes분';
  }

  @override
  String tradeDurationMinutes(int minutes) {
    return '$minutes분';
  }

  @override
  String get tradeEditMenu => '편집';

  @override
  String get tradeExportPdfTooltip => 'PDF 내보내기';

  @override
  String get tradeFilterAll => '전체';

  @override
  String get tradeFilterBreakeven => '본전';

  @override
  String get tradeFilterLoser => '손실';

  @override
  String get tradeFilterOpenPosition => '미청산';

  @override
  String get tradeFilterWinner => '수익';

  @override
  String tradeSummaryBreakdownShort(int w, int l, int b) {
    return '승:$w  패:$l  본:$b';
  }

  @override
  String tradeSummaryBreakdownWithOpen(int w, int l, int b, int o) {
    return '승:$w  패:$l  본:$b  미:$o';
  }

  @override
  String get tradeGainShort => '순손익';

  @override
  String get tradeLabelChecklist => '체크리스트';

  @override
  String get tradeLabelDuration => '기간';

  @override
  String get tradeLabelEntry => '진입';

  @override
  String get tradeLabelEtat => '상태';

  @override
  String get tradeLabelExit => '청산';

  @override
  String get tradeLabelHours => '시간';

  @override
  String get tradeLabelPlan => '계획';

  @override
  String get tradeLabelSession => '세션';

  @override
  String get tradeLabelStrategie => '전략';

  @override
  String get tradeLabelNews => '뉴스';

  @override
  String get tradeMindsetFeeling => '느낌';

  @override
  String get tradeMindsetPrinciple => '원칙';

  @override
  String get tradeMonthTitle => '월';

  @override
  String get tradeMostTradedHeading => '가장 많이 거래한 종목';

  @override
  String get tradeNotRespected => '미준수';

  @override
  String tradeOpenPositionLine(String when) {
    return '미청산 • 진입 $when';
  }

  @override
  String get tradePdfAnalysePostTrade => '사후 검토';

  @override
  String get tradePdfBarresSemaine => '주간 막대';

  @override
  String get tradePdfCloture => '청산됨';

  @override
  String get tradePdfPositionOpen => '미청산';

  @override
  String tradePdfDatePrefix(String when) {
    return '날짜: $when';
  }

  @override
  String tradePdfDetailsTitle(String pair) {
    return '거래 상세 ($pair)';
  }

  @override
  String get tradePdfEtatPsychologique => '심리 상태';

  @override
  String get tradePdfTags => '태그';

  @override
  String get tradeTagsSection => 'TAG';

  @override
  String get tradePdfExportDayTitle => '거래(일)';

  @override
  String get tradePdfExportMonthTitle => '거래(월)';

  @override
  String get tradePdfExportWeekTitle => '거래(주)';

  @override
  String get tradePdfGainNet => '순손익';

  @override
  String get tradePdfImpactCapital => '자본 영향';

  @override
  String get tradePdfMoyenne => '평균';

  @override
  String get tradePdfNonRespecte => '미준수';

  @override
  String get tradePdfPeriode => '기간';

  @override
  String get tradePdfQualiteMoyennes => '품질(평균)';

  @override
  String tradePdfScreenshotTitle(String pair) {
    return '스크린샷 — $pair';
  }

  @override
  String get tradePdfSessions => '세션';

  @override
  String get tradePdfSparklineMois => '월 스파크라인';

  @override
  String get tradePdfTrades => '거래';

  @override
  String get tradePdfWinRate => '승률';

  @override
  String tradePctOfCapital(String percent) {
    return '자본의 $percent%';
  }

  @override
  String get tradeScreenshotLoadError => '이미지를 불러올 수 없습니다';

  @override
  String get tradeScreenshotUnavailableWeb => '스크린샷 사용 불가(웹)';

  @override
  String get tradeSectionChecklist => '체크리스트';

  @override
  String get tradeSectionEtat => '상태';

  @override
  String get tradeSectionPlan => '계획';

  @override
  String get tradeSectionStrategie => '전략';

  @override
  String tradeStrategieNonRespectUnmapped(String id) {
    return '전략 상세 ($id)';
  }

  @override
  String get tradeSessionAsia => '아시아';

  @override
  String get tradeSessionEurope => '유럽';

  @override
  String get tradeSessionLate => '시간외';

  @override
  String get tradeSessionUs => '미국';

  @override
  String get tradeSideBreakevenShort => '본전';

  @override
  String get tradeSideBuyLong => '매수';

  @override
  String get tradeSideBuyShort => '매수';

  @override
  String get tradeSideSellLong => '매도';

  @override
  String get tradeSideSellShort => '매도';

  @override
  String get tradeSummaryProfitNet => '순손익';

  @override
  String get tradeSummaryTrades => '거래';

  @override
  String get tradeSummaryWinRate => '승률';

  @override
  String get tradeTotalUpper => '합계';

  @override
  String get tradeTradesListHeading => '거래';

  @override
  String get tradeTradesMonthHeading => '거래(월)';

  @override
  String get tradeTradesWeekHeading => '거래(주)';

  @override
  String get tradeWeekTitle => '주';

  @override
  String get tradeWinDayRingSubtitle => '승(일)';

  @override
  String get tradeWinrateLabel => '승률';

  @override
  String get settingsTradingWeek5 => '5일 (월–금)';

  @override
  String get settingsTradingWeek7 => '7일 (월–일)';

  @override
  String get settingsTradingWeekSubtitle =>
      '전통 시장은 5일(월–금), 전체 달력 주는 7일(예: 암호화폐)로 표시합니다.';

  @override
  String get settingsTradingWeekTitle => '표시 주';

  @override
  String get settingsDashboardCardSubtitle => '홈 맞춤: 섹션 및 순서';

  @override
  String get settingsDashLayoutTitle => '홈 섹션';

  @override
  String get settingsDashLayoutReorderHint =>
      '손잡이를 드래그해 순서를 바꾸세요. 섹션을 끄면 홈에서 숨깁니다.';

  @override
  String get settingsDashOpenHomeButton => '홈 보기';

  @override
  String get settingsDashSectionCapital => '자본 및 승률';

  @override
  String get settingsDashSectionChecklist => '체크리스트';

  @override
  String get settingsDashSectionAnalyse => '분석';

  @override
  String get settingsDashSectionEtat => '멘탈';

  @override
  String get settingsDashSectionStrategie => '전략';

  @override
  String get settingsDashSectionWeekly => '주간 성과';

  @override
  String get settingsDashSectionEvolution => '자본 변화';

  @override
  String get tradingSection => '트레이딩';

  @override
  String get settingsCgvSection => '이용 약관';

  @override
  String get settingsCgvPageTitle => '일반 판매 조건';

  @override
  String get settingsCgvRowTitle => '일반 판매 조건';

  @override
  String get settingsCgvRowSubtitle => '앱에서 전체 약관 읽기';

  @override
  String get settingsCgvDocHeading => '판매 일반 조건(CGV) - PAYCHEK';

  @override
  String get settingsCgv1Title => '1. 목적';

  @override
  String get settingsCgv1Body =>
      '본 CGV는 트레이딩 일지 및 리스크 관리 도구인 Paychek 애플리케이션의 \"프리미엄\" 이용 구독을 규율합니다. 이용권은 매년 자동 갱신되는 연 구독으로 제공되며, 해지 시까지 갱신됩니다.';

  @override
  String get settingsCgv2Title => '2. 제공 서비스';

  @override
  String get settingsCgv2Body =>
      '프리미엄 이용권은 앱의 모든 기능(고급 통계, 자동 리스크 계산, 데이터 내보내기)을 해제합니다. 이용권은 가입 시 생성된 사용자 계정에 연결됩니다.';

  @override
  String get settingsCgv3Title => '3. 요금 및 결제';

  @override
  String get settingsCgv3Body =>
      '직접 구독: 가격은 연 49.90달러(USD)이며, 해지 시까지 자동 갱신됩니다.\n\n파트너 제공: 사용자가 당사 파트너(프롭 펌 또는 브로커) 중 한 곳의 추천 조건을 충족하면 무료로 제공될 수 있습니다.\n\nPaychek는 신규 고객에 대해 언제든지 가격을 변경할 권리를 보유합니다.';

  @override
  String get settingsCgv4Title => '4. 청약 철회 및 환불';

  @override
  String get settingsCgv4Body =>
      '디지털 콘텐츠 관련 법령에 따라:\n\n서비스의 디지털적 특성 및 결제 직후 즉시 콘텐츠에 접근할 수 있음으로, 사용자는 서비스가 즉시 시작됨에 동의하며 14일 청약 철회권을 명시적으로 포기합니다.\n\n프리미엄 이용이 활성화된 후에는 앱을 사용할 수 없을 정도의 중대한 기술적 결함이 있는 경우를 제외하고 환불되지 않습니다.';

  @override
  String get settingsCgv5Title => '5. \"파트너 제공\" 특별 조항';

  @override
  String get settingsCgv5Body =>
      '파트너를 통한 이용은 해당 파트너의 소속(제휴) 승인에 따라 제공됩니다.\n\n파트너가 소속을 거부하는 경우(입금 또는 거래 규칙 미준수 등), Paychek는 프리미엄 이용을 철회하거나 표준 요금 결제를 요구할 권리를 보유합니다.';

  @override
  String get settingsCgv6Title => '6. 리스크 고지 (트레이딩)';

  @override
  String get settingsCgv6Body =>
      'Paychek는 금융 자문가가 아닙니다. 본 애플리케이션은 관리 및 분석을 위한 기술 도구입니다.\n\n트레이딩은 자본 손실 위험이 매우 높습니다. 사용자는 자신의 거래 결정에 대해 전적인 책임을 집니다.\n\nPaychek는 금융 시장에서 사용자에게 발생한 금전적 손실에 대해 책임지지 않습니다.';

  @override
  String get settingsCgv7Title => '7. 서비스 가용성';

  @override
  String get settingsCgv7Body =>
      'Paychek는 24시간 접속 유지를 위해 노력합니다. 다만 유지보수 또는 제3자 서버(Firebase, Google Cloud) 장애로 인한 중단에 대해서는 책임지지 않습니다.';

  @override
  String get settingsCgv8Title => '8. 데이터 보호';

  @override
  String get settingsCgv8Body =>
      '사용자의 트레이딩 데이터는 엄격하게 기밀이며 재판매되지 않습니다. 기술 제공업체를 통해 안전하게 저장됩니다.';

  @override
  String get settingsPrivacyRowTitle => '개인정보 처리방침';

  @override
  String get settingsPrivacyRowSubtitle => '개인정보, 쿠키 및 권리';

  @override
  String get settingsPrivacyPageTitle => '개인정보 처리방침';

  @override
  String get settingsPrivacyDocHeading => '개인정보 처리방침 — PAYCHEK';

  @override
  String get settingsDataResetSection => '데이터';

  @override
  String get settingsDataResetTitle => '로컬 데이터 모두 삭제';

  @override
  String get settingsDataResetDescription =>
      '한동안 Paychek를 사용한 뒤 처음부터 다시 시작하려면(앱 재설치와 비슷하게) 이 기기에 저장된 데이터를 모두 지울 수 있습니다: 트레이드, 분석, 저널, 대시보드 레이아웃, 로컬 프로필, 기기의 체험 기준일 등.\n\n언어 설정과 ‘표시 주(週)’ 설정은 유지됩니다.\n\n임시 메모리(체크리스트 등)를 비우려면 앱을 완전히 종료한 뒤 다시 여세요.';

  @override
  String get settingsDataResetButton => '이 기기에서 모두 삭제';

  @override
  String get settingsDataResetDialogTitle => '로컬 데이터를 모두 삭제할까요?';

  @override
  String get settingsDataResetDialogBody =>
      '되돌릴 수 없습니다. 이 기기의 로컬 Paychek 데이터가 삭제됩니다. Firebase 로그인 세션은 유지될 수 있으며, 로컬 복사본만 제거됩니다.\n\n캐시가 남아 있으면 앱을 다시 시작하세요.';

  @override
  String get settingsDataResetDialogCancel => '취소';

  @override
  String get settingsDataResetDialogConfirm => '모두 삭제';

  @override
  String get settingsDataResetSuccess => '로컬 데이터가 삭제되었습니다. 필요하면 앱을 다시 시작하세요.';

  @override
  String get validate => '확인';

  @override
  String get winrate => '승률';
}
