import 'dart:convert';
import 'package:http/http.dart' as http;

import './classes/topic.dart';
import './classes/question.dart';

class QuizApi {
  Future<List<Topic>> findAllTopics() async {
    final response = await http.get(
      Uri.parse('https://dad-quiz-api.deno.dev/topics'),
    );

    List<dynamic> topics = jsonDecode(response.body);
    return List<Topic>.from(topics.map(
      (jsonData) => Topic.fromJson(jsonData),
    ));
  }

  Future<Question> getQuestionByTopicId(int topicId) async {
    final response = await http.get(
      Uri.parse('https://dad-quiz-api.deno.dev/topics/$topicId/questions'),
    );
    Map<String, dynamic> questionData = jsonDecode(response.body);
    return Question.fromJson(questionData);
  }

  Future<bool> postAnswer(int topicId, int questionId, String answer) async {
    final response = await http.post(
      Uri.parse(
          'https://dad-quiz-api.deno.dev/topics/$topicId/questions/$questionId/answers'),
      body: jsonEncode({
        'answer': answer,
      }),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    Map<String, dynamic> answerData = jsonDecode(response.body);
    return answerData['correct'];
  }
}
