// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:quiz/ui/main_screen.dart';
import 'package:quiz/ui/question_screen.dart';
import 'package:quiz/ui/statistics_screen.dart';
import 'package:quiz/stats_provider.dart';

void main() {
  setUpAll(() {
    nock.init();
    nock.defaultBase = 'https://dad-quiz-api.deno.dev';
  });

  setUp(() {
    nock.cleanAll();
  });

  testWidgets(
      'Opening the application and seeing the list of topics. Verifying that the topics from the API are shown.',
      (WidgetTester tester) async {
    final interceptor = nock.get("/topics")
      ..reply(
          200,
          jsonEncode([
            {
              "id": 1,
              "name": "Topic name",
              "question_path": "/topics/1/questions"
            }
          ]));

    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));
    expect(interceptor.isDone, true);
    expect(find.text('Welcome to Quiz App!'), findsOneWidget);

    await tester.pumpAndSettle(); // wait for topics to load
    expect(find.byIcon(Icons.article), findsOneWidget);
    expect(find.text('Topic name'), findsOneWidget);
  });

  testWidgets(
      'Selecting a topic without images and seeing a question for that topic. Verifying that the question text and the answer options from the API are shown.',
      (WidgetTester tester) async {
    final questionInterceptor = nock.get("/topics/1/questions")
      ..reply(
          200,
          jsonEncode({
            "id": 1,
            "question": "Question text",
            "options": ["Option 1", "Option 2", "Option 3"],
            "answer_post_path": "/topics/1/questions/1/answers"
          }));
    final topicsInterceptor = nock.get("/topics")
      ..reply(
          200,
          jsonEncode([
            {
              "id": 1,
              "name": "Topic name",
              "question_path": "/topics/1/questions"
            }
          ]));

    SharedPreferences.setMockInitialValues({
      'score': ["1:17", "2:3"]
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: QuestionScreen(topicId: 1))));
    await tester.pumpAndSettle();
    expect(questionInterceptor.isDone, true);
    expect(topicsInterceptor.isDone, true);
    expect(find.text("Quiz Question"), findsOneWidget);
    await tester.pumpAndSettle(); // wait for question to load
    expect(find.text("Question text"), findsOneWidget);
    expect(find.text("Option 3"), findsOneWidget);
  });

  testWidgets(
      'Selecting an answer option. Verifying that the feedback (correctness or incorrectness) matches the data received from the API.',
      (WidgetTester tester) async {
    final questionInterceptor = nock.get("/topics/1/questions")
      ..reply(
          200,
          jsonEncode({
            "id": 1,
            "question": "Question text",
            "options": ["Option 1", "Option 2", "Option 3"],
            "answer_post_path": "/topics/1/questions/1/answers"
          }));
    final topicsInterceptor = nock.get("/topics")
      ..reply(
          200,
          jsonEncode([
            {
              "id": 1,
              "name": "Topic name",
              "question_path": "/topics/1/questions"
            }
          ]));

    final wrongInterceptor =
        nock.post("/topics/1/questions/1/answers", {"answer": "Option 1"})
          ..reply(
              200,
              jsonEncode({
                "correct": false,
              }));

    final correctInterceptor =
        nock.post("/topics/1/questions/1/answers", {"answer": "Option 2"})
          ..reply(
              200,
              jsonEncode({
                "correct": true,
              }));

    SharedPreferences.setMockInitialValues({
      'score': ["1:17", "2:3"]
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: QuestionScreen(topicId: 1))));

    await tester.pumpAndSettle();
    expect(questionInterceptor.isDone, true);
    expect(topicsInterceptor.isDone, true);

    expect(find.text("Quiz Question"), findsOneWidget);

    await tester.pumpAndSettle(); // wait for question to load
    await tester.tap(find.text("Option 1"));
    await tester.pumpAndSettle(); // wait for feedback to load
    expect(wrongInterceptor.isDone, true);
    expect(find.text("Correct!"), findsNothing);
    await tester.tap(find.text("Option 2"));
    await tester.pumpAndSettle();
    expect(correctInterceptor.isDone, true);
    expect(find.text("Correct!"), findsOneWidget);
  });

  testWidgets(
      'Opening the statistics page and seeing the total correct answer count. Verifying that the correct answer count matches data stored in SharedPreferences.',
      (WidgetTester tester) async {
    final topicsInterceptor = nock.get("/topics")
      ..reply(
          200,
          jsonEncode([
            {
              "id": 1,
              "name": "Topic name",
              "question_path": "/topics/1/questions"
            },
            {
              "id": 2,
              "name": "Another topic name",
              "question_path": "/topics/2/questions"
            }
          ]));

    SharedPreferences.setMockInitialValues({
      'score': ["1:17", "2:3"]
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: StatisticsScreen())));

    await tester.pumpAndSettle();
    expect(topicsInterceptor.isDone, true);
    expect(find.text("Quiz Statistics"), findsOneWidget);

    await tester.pumpAndSettle(); // wait for statistics to load
    expect(find.text("Total correct answers: 20"), findsOneWidget);
  });

  testWidgets(
      'Opening the statistics page and seeing topic-specific statistics for a topic. Verifying that the topic-specific correct answer counts match data stored in SharedPreferences.',
      (WidgetTester tester) async {
    final topicsInterceptor = nock.get("/topics")
      ..reply(
          200,
          jsonEncode([
            {
              "id": 1,
              "name": "Topic name",
              "question_path": "/topics/1/questions"
            },
            {
              "id": 2,
              "name": "Another topic name",
              "question_path": "/topics/2/questions"
            }
          ]))
      ..persist();

    SharedPreferences.setMockInitialValues({
      'score': ["1:17", "2:3"]
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: StatisticsScreen())));

    await tester.pumpAndSettle();
    expect(topicsInterceptor.isDone, true);
    expect(find.text("Quiz Statistics"), findsOneWidget);

    await tester.pumpAndSettle(); // wait for statistics to load
    expect(find.text("Correct answers: 17"), findsOneWidget);
    expect(find.text("Correct answers: 3"), findsOneWidget);
  });

  testWidgets(
      'Choosing the generic practice option and being shown a question from a topic with the fewest correct answers. Verifying that the choice of the topic is done based on data in SharedPreferences and that the question matches the data from the API.',
      (WidgetTester tester) async {
    final questionInterceptor = nock.get("/topics/2/questions")
      ..reply(
          200,
          jsonEncode({
            "id": 1,
            "question": "Question text",
            "options": ["Option 1", "Option 2", "Option 3"],
            "answer_post_path": "/topics/1/questions/1/answers"
          }));

    final topicsInterceptor = nock.get("/topics")
      ..reply(
          200,
          jsonEncode([
            {
              "id": 1,
              "name": "Topic name",
              "question_path": "/topics/1/questions"
            },
            {
              "id": 2,
              "name": "Another topic name",
              "question_path": "/topics/2/questions"
            }
          ]));

    SharedPreferences.setMockInitialValues({
      'score': ["1:17", "2:3"]
    });
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
        child: const MaterialApp(home: QuestionScreen.generic())));
    await tester.pumpAndSettle();
    expect(questionInterceptor.isDone, true);
    expect(topicsInterceptor.isDone, true);
    expect(find.text("Quiz Question"), findsOneWidget);
    await tester.pumpAndSettle(); // wait for question to load
    expect(find.text("Question text"), findsOneWidget);
    expect(find.text("Option 3"), findsOneWidget);
  });
}
