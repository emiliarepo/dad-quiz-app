class Topic {
  final int id;
  final String name;
  final String questionPath;

  Topic.fromJson(Map<String, dynamic> jsonData)
      : id = jsonData['id'],
        name = jsonData['name'],
        questionPath = jsonData['question_path'];
}


