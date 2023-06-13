import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../quiz_api.dart';
import '../classes/topic.dart';
import '../stats_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scores = ref.watch(statsProvider);
    final sum = scores.values.fold(0, (prev, curr) => prev + curr);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Quiz Statistics'),
          leading: BackButton(onPressed: () {
            context.pop();
          })),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          const Text('Your Statistics', style: TextStyle(fontSize: 24)),
          Text('Total correct answers: $sum',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Expanded(child: TopicList(scores: scores)),
        ],
      )),
    );
  }
}

class TopicList extends StatelessWidget {
  final Map<int, int> scores;
  TopicList({Key? key, required this.scores}) : super(key: key);

  final Future<List<Topic>> topics = QuizApi().findAllTopics();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topic>>(
        future: topics,
        builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text("Loading topics.");
          } else if (snapshot.hasError) {
            return Text("Error retrieving topics: ${snapshot.error}");
          } else if (!snapshot.hasData) {
            return const Text("No topics available.");
          } else {
            List<Topic> topics = snapshot.data!;
            topics.sort((a, b) => scores[a.id]! > scores[b.id]! ? -1 : 1);
            List<Widget> children = topics.map((topic) {
              return Card(
                  child: ListTile(
                leading: const Column(
                    // you have to do this to vertically center the icon...
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.article)]),
                title: Text(topic.name),
                subtitle: Text("Correct answers: ${scores[topic.id]!}"),
              ));
            }).toList();
            children = [...children];
            return ListView(
                padding: const EdgeInsets.all(8), children: children);
          }
        });
  }
}
