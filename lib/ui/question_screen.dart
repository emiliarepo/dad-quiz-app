import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../quiz_api.dart';
import '../classes/question.dart';
import '../stats_provider.dart';

final selectionProvider =
    StateProvider<List<String>>((ref) => []); // what did the person answer?
final correctProvider =
    StateProvider<bool>((ref) => false); // did the person answer correctly?
final questionProvider = StateProvider<Question?>(
    (ref) => null); // this is to save the question value after answering it

void nextQuestion(WidgetRef ref) {
  ref.watch(selectionProvider.notifier).update((state) => state = <String>[]);
  ref.watch(correctProvider.notifier).update((state) => state = false);
  ref.watch(questionProvider.notifier).update((state) => state = null);
}

class QuestionScreen extends ConsumerWidget {
  final int? topicId;
  const QuestionScreen({Key? key, required this.topicId}) : super(key: key);
  const QuestionScreen.generic({Key? key})
      : topicId = null,
        super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Quiz Question'),
          leading: BackButton(onPressed: () {
            context.pop();
            nextQuestion(ref); // reset question on back button press
          }),
          actions: [
            IconButton(
              icon: const Icon(Icons.bar_chart),
              onPressed: () {
                context.push('/statistics');
              },
            ),
          ]),
      body: Center(
        child: FutureBuilder<int>(
          future: getLowestKey(ref.watch(statsProvider)),
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text("Error: ${snapshot.error}");
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Expanded(
                    child: QuestionWidget(
                      topicId: topicId ?? snapshot.data!,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

class QuestionWidget extends ConsumerWidget {
  final int topicId;
  const QuestionWidget({Key? key, required this.topicId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Question? currentQuestion = ref.watch(questionProvider);
    final Future<Question> question = currentQuestion == null
        ? QuizApi().getQuestionByTopicId(topicId)
        : Future.value(currentQuestion);

    Color? determineColor(String option) {
      List<String> selections = ref.watch(selectionProvider);
      bool correct = ref.watch(correctProvider);
      if (selections.contains(option) &&
          correct &&
          selections.indexOf(option) == selections.length - 1) {
        return Colors.green;
      } else if (selections.contains(option)) {
        return Colors.red;
      } else {
        return null;
      }
    }

    void postAnswer(Question question, String option) {
      QuizApi().postAnswer(topicId, question.id, option).then((correct) {
        ref
            .watch(selectionProvider.notifier)
            .update((state) => [...state, option]);
        ref.watch(correctProvider.notifier).update((state) => state = correct);
        ref
            .watch(questionProvider.notifier)
            .update((state) => state = question);
        if (correct) {
          ref.read(statsProvider.notifier).addPoint(topicId);
        }
      });
    }

    return FutureBuilder<Question>(
        future: question,
        builder: (BuildContext context, AsyncSnapshot<Question> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return Text("Error retrieving question: ${snapshot.error}");
          } else if (!snapshot.hasData) {
            return const Text("No question available.");
          } else {
            Question question = snapshot.data!;

            List<Widget> children = question.options.map((option) {
              return Card(
                  surfaceTintColor: determineColor(option),
                  child: ListTile(
                    leading: const Column(
                        // you have to do this to vertically center the icon...
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [Icon(Icons.quiz)]),
                    title: Text(option),
                    subtitle: const Text("Tap to select!"),
                    onTap: !ref.watch(correctProvider)
                        ? () => postAnswer(question, option)
                        : null, // prevent answering if already has answered
                  ));
            }).toList();

            children = [
              Center(
                  child: Text(question.question,
                      style: const TextStyle(fontSize: 24))),
              Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: const Row(children: [
                    Expanded(child: Divider()),
                    SizedBox(width: 6),
                    Text("Choose an Answer"),
                    SizedBox(width: 6),
                    Expanded(child: Divider()),
                  ])),
              ...children
            ];

            if (question.imageUrl != null) {
              children.insert(
                  0,
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(question.imageUrl!, height: 300)));
              children.insert(1, const SizedBox(height: 12));
            }

            if (ref.watch(correctProvider)) {
              // question has been answered
              children.add(Container(
                  padding: const EdgeInsets.only(top: 5, bottom: 5),
                  child: const Divider()));
              if (ref.watch(correctProvider)) {
                children.add(const Center(
                    child: Text("Correct!",
                        style: TextStyle(fontSize: 24, color: Colors.green))));
              } else {
                children.add(const Center(
                    child: Text("Incorrect!",
                        style: TextStyle(fontSize: 24, color: Colors.red))));
              }

              children.add(Card(
                  child: ListTile(
                      leading: const Column(
                          // you have to do this to vertically center the icon...
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [Icon(Icons.input)]),
                      title: const Text("Next Question"),
                      subtitle: const Text("Tap to proceed!"),
                      onTap: () => nextQuestion(ref))));
            }

            return ListView(
                padding: const EdgeInsets.all(8), children: children);
          }
        });
  }
}
