import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import './quiz_api.dart';

class StatsNotifier extends StateNotifier<Map<int, int>> {
  final SharedPreferences prefs;
  StatsNotifier(this.prefs) : super({});

  _initialize() {
    QuizApi().findAllTopics().then((topics) {
      if (!prefs.containsKey('score')) {
        prefs.setStringList('score', <String>[]);
      }

      final stringList = prefs.getStringList('score');
      var scores = Map.fromEntries(stringList!.map((entry) => MapEntry(
          int.parse(entry.split(':')[0]), int.parse(entry.split(':')[1]))));
      for (var t in topics) {
        scores.putIfAbsent(t.id, () => 0);
      }
      state = scores;
    });
  }

  addPoint(int id) {
    state = Map.from(state)..update(id, (value) => value + 1);
    prefs.setStringList('score',
        state.entries.map((entry) => '${entry.key}:${entry.value}').toList());
  }
}

final statsProvider =
    StateNotifierProvider<StatsNotifier, Map<int, int>>((ref) {
  final sn = StatsNotifier(ref.watch(sharedPreferencesProvider));
  sn._initialize();
  return sn;
});

final sharedPreferencesProvider =
    Provider<SharedPreferences>((ref) => throw UnimplementedError());

Future<int> getLowestKey(Map<int, int> values) async {
  final minValue =
      values.values.reduce((curr, next) => curr < next ? curr : next);
  final minKeys = values.entries
      .where((entry) => entry.value == minValue)
      .map((entry) => entry.key)
      .toList();
  if (minKeys.isEmpty) {
    return 1;
  }
  return minKeys[Random().nextInt(minKeys.length)];
}
