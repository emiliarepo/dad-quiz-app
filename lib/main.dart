import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import './ui/main_screen.dart';
import './ui/question_screen.dart';
import './ui/statistics_screen.dart';
import './stats_provider.dart';

void main() async {
  final router = GoRouter(routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/topics/:id', builder: (context, state) => QuestionScreen(topicId: int.parse(state.params['id']!))),
    GoRoute(path: '/topics', builder: (context, state) => const QuestionScreen.generic()),
    GoRoute(path: '/statistics', builder: (context, state) => const StatisticsScreen())
  ]);

  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(ProviderScope(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)], child: MaterialApp.router(routerConfig: router, theme: ThemeData(useMaterial3: true))));
}


