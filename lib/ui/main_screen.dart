import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../quiz_api.dart';
import '../classes/topic.dart';
import '../stats_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz'), actions: [
        IconButton(
          icon: const Icon(Icons.bar_chart),
          onPressed: () {
            context.push('/statistics');
          },
        ),
      ]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            const Text('Welcome to Quiz App!', style: TextStyle(fontSize: 24)),
            const Text('We have questions of all kinds! Choose a topic to study.',
                style: TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Expanded(child: TopicList())
          ],
        ),
      ),
    );
  }
}

class TopicList extends StatelessWidget {
  TopicList({Key? key}) : super(key: key);

  final Future<List<Topic>> topics = QuizApi().findAllTopics();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Topic>>(
        future: topics,
        builder: (BuildContext context, AsyncSnapshot<List<Topic>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator(); 
          } else if (snapshot.hasError) {
            return Text("Error retrieving topics: ${snapshot.error}");
          } else if (!snapshot.hasData) {
            return const Text("No topics available.");
          } else {
            List<Topic> topics = snapshot.data!;
            List<Widget> children = topics.map((topic) {
              return Card(
                  child: ListTile(
                leading: const Column(
                    // you have to do this to vertically center the icon...
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.article)]),
                title: Text(topic.name),
                subtitle: const Text("Click to study this topic!"),
                onTap: () => context.push('/topics/${topic.id}'),
              ));
            }).toList();
            children = [
              Card(
                  child: ListTile(
                leading: const Column(
                    // you have to do this to vertically center the icon...
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [Icon(Icons.library_books)]),
                title: const Text("All Topics"),
                subtitle: const Text(
                    "Study all topics with a focus on less mastered ones!"),
                onTap: () => context.push('/topics'),
              )),
              Container(padding: const EdgeInsets.only(top: 5, bottom: 5), child: const Row(children: [
                Expanded(child: Divider()),
                SizedBox(width: 6),
                Text("Choose a Topic"),
                SizedBox(width: 6),
                Expanded(child: Divider()),
              ])),
              ...children
            ];
            return ListView(padding: const EdgeInsets.all(8), children: children);
          }
        });
  }
}
