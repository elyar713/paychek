import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mon_app_finder/checklist/checklist_item_schedule.dart';
import 'package:mon_app_finder/checklist/checklist_models.dart';
import 'package:mon_app_finder/checklist/checklist_news_trade_classifier.dart';
import 'package:mon_app_finder/checklist/checklist_prompts.dart';

ChecklistSectionData _newsSection({
  bool enabled = true,
  List<ChecklistItemData> items = const [],
}) =>
    ChecklistSectionData(
      id: ChecklistPrompts.sectionIdNews,
      title: ChecklistPrompts.sectionTitleNews,
      enabled: enabled,
      items: items,
    );

void main() {
  group('classifyTradeNewsTiming', () {
    test('avant la prochaine annonce du jour', () {
      final sections = [
        _newsSection(
          items: [
            ChecklistItemData(
              id: ChecklistPrompts.itemIdNews3,
              label: 'CPI',
              schedule: ChecklistItemSchedule(
                mode: ChecklistScheduleMode.specificDate,
                specificDate: DateTime(2026, 5, 20),
                warningTime: const TimeOfDay(hour: 14, minute: 30),
              ),
            ),
          ],
        ),
      ];
      final flags = classifyTradeNewsTiming(
        entreeAt: DateTime(2026, 5, 20, 10, 0),
        sections: sections,
      );
      expect(flags.avantNews, isTrue);
      expect(flags.apresNews, isFalse);
    });

    test('apres la derniere annonce du jour', () {
      final sections = [
        _newsSection(
          items: [
            ChecklistItemData(
              id: ChecklistPrompts.itemIdNews3,
              label: 'CPI',
              schedule: ChecklistItemSchedule(
                mode: ChecklistScheduleMode.specificDate,
                specificDate: DateTime(2026, 5, 20),
                warningTime: const TimeOfDay(hour: 14, minute: 30),
              ),
            ),
          ],
        ),
      ];
      final flags = classifyTradeNewsTiming(
        entreeAt: DateTime(2026, 5, 20, 16, 0),
        sections: sections,
      );
      expect(flags.avantNews, isFalse);
      expect(flags.apresNews, isTrue);
    });

    test('entre deux annonces : avant la suivante', () {
      final sections = [
        _newsSection(
          items: [
            ChecklistItemData(
              id: ChecklistPrompts.itemIdNews3,
              label: 'CPI',
              schedule: ChecklistItemSchedule(
                mode: ChecklistScheduleMode.specificDate,
                specificDate: DateTime(2026, 5, 20),
                warningTime: const TimeOfDay(hour: 14, minute: 30),
              ),
            ),
            ChecklistItemData(
              id: ChecklistPrompts.itemIdNews4,
              label: 'NFP',
              schedule: ChecklistItemSchedule(
                mode: ChecklistScheduleMode.specificDate,
                specificDate: DateTime(2026, 5, 20),
                warningTime: const TimeOfDay(hour: 15, minute: 30),
              ),
            ),
          ],
        ),
      ];
      final flags = classifyTradeNewsTiming(
        entreeAt: DateTime(2026, 5, 20, 15, 0),
        sections: sections,
      );
      expect(flags.avantNews, isTrue);
      expect(flags.apresNews, isFalse);
    });

    test('section off : pas de calcul même avec horaire ce jour', () {
      final flags = classifyTradeNewsTiming(
        entreeAt: DateTime(2026, 5, 20, 16, 0),
        sections: [
          _newsSection(
            enabled: false,
            items: [
              ChecklistItemData(
                id: ChecklistPrompts.itemIdNews3,
                label: 'CPI',
                schedule: ChecklistItemSchedule(
                  mode: ChecklistScheduleMode.specificDate,
                  specificDate: DateTime(2026, 5, 20),
                  warningTime: const TimeOfDay(hour: 14, minute: 30),
                ),
              ),
            ],
          ),
        ],
      );
      expect(flags, TradeNewsTimingFlags.none);
    });

    test('resolveTradeNewsTimingFlags garde le fallback si section off', () {
      const manual = TradeNewsTimingFlags(avantNews: true, apresNews: false);
      final flags = resolveTradeNewsTimingFlags(
        entreeAt: DateTime(2026, 5, 20, 16, 0),
        sections: [_newsSection(enabled: false)],
        manualFallback: manual,
      );
      expect(flags, manual);
    });

    test('aucun tag si section on mais sans date ce jour', () {
      expect(
        classifyTradeNewsTiming(
          entreeAt: DateTime(2026, 5, 21, 12, 0),
          sections: [
            _newsSection(
              items: [
                const ChecklistItemData(
                  id: ChecklistPrompts.itemIdNews1,
                  label: 'Calendrier',
                ),
              ],
            ),
          ],
        ),
        TradeNewsTimingFlags.none,
      );
    });
  });
}
