import 'checklist_models.dart';

import 'checklist_prompts.dart';

import 'checklist_sections_storage.dart';

import 'checklist_firestore_sync.dart';

import 'checklist_realtime_notifier.dart';

import '../shared/paychek_demo_graduation_prefs.dart';



Set<String> _checklistStockDemoItemIds() => {

      for (final s in defaultNouveauTradeSections())

        for (final i in s.items)

          i.id,

    };



Set<String> _checklistStockDemoSectionIds() =>

    defaultNouveauTradeSections().map((s) => s.id).toSet();



/// Sections d’origine (ids + lignes démo inchangés).

bool checklistSectionsAreStockDefaults(List<ChecklistSectionData> sections) {

  final stock = checklistEnsureProtectedSections(defaultNouveauTradeSections());

  final cur = checklistEnsureProtectedSections(sections);

  if (stock.length != cur.length) return false;

  for (var i = 0; i < stock.length; i++) {

    if (stock[i].id != cur[i].id) return false;

    if (stock[i].items.length != cur[i].items.length) return false;

    for (var j = 0; j < stock[i].items.length; j++) {

      if (stock[i].items[j].id != cur[i].items[j].id) return false;

    }

  }

  return true;

}



/// Après la 1ère utilisation : NEWS conservée, lignes/sections démo retirées.

List<ChecklistSectionData> checklistSectionsWithoutDemoContent(

  List<ChecklistSectionData> sections,

) {

  final stockItemIds = _checklistStockDemoItemIds();

  final stockSectionIds = _checklistStockDemoSectionIds();

  const newsId = ChecklistPrompts.sectionIdNews;



  final out = <ChecklistSectionData>[];

  for (final section in sections) {

    final isStockSection = stockSectionIds.contains(section.id);

    if (!isStockSection) {

      out.add(section);

      continue;

    }

    final keptItems = section.items

        .where((i) => !stockItemIds.contains(i.id))

        .toList(growable: false);

    if (section.id == newsId) {

      out.add(section.copyWith(items: keptItems));

    } else if (keptItems.isNotEmpty) {

      out.add(section.copyWith(items: keptItems));

    }

  }

  if (!out.any((s) => s.id == newsId)) {

    out.insert(

      0,

      ChecklistSectionData(

        id: newsId,

        title: ChecklistPrompts.sectionTitleNews,

        enabled: true,

        items: const [],

      ),

    );

  }

  return checklistEnsureProtectedSections(out);

}



List<ChecklistSectionData> checklistStarterAfterDemoGraduation() =>

    checklistSectionsWithoutDemoContent(defaultNouveauTradeSections());



/// 1ère interaction checklist (cocher, ajouter une ligne, etc.) — pas au 1er trade.

Future<void> checklistPersistGraduationIfNeeded(

  List<ChecklistSectionData> sections,

) async {

  if (await PaychekDemoGraduationPrefs.isChecklistGraduated()) return;

  final stripped = checklistSectionsWithoutDemoContent(sections);

  await PaychekDemoGraduationPrefs.markChecklistGraduated();

  await ChecklistSectionsStorage.save(stripped);

  await ChecklistFirestoreSync.pushIfSignedIn();

  ChecklistRealtimeNotifier.bump();

}



/// Si déjà diplômé : ne jamais réafficher les lignes démo.

Future<List<ChecklistSectionData>?> checklistSectionsAfterGraduationFilter(

  List<ChecklistSectionData>? loaded,

) async {

  if (!await PaychekDemoGraduationPrefs.isChecklistGraduated()) return loaded;

  if (loaded == null || loaded.isEmpty) {

    return checklistStarterAfterDemoGraduation();

  }

  return checklistSectionsWithoutDemoContent(loaded);

}


