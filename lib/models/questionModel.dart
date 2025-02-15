import 'package:flutter/foundation.dart';

class Question with ChangeNotifier {
  String title;
  String description;
  String type;
  bool isRequired;
  List<String> options;

  Question({
    required this.title,
    required this.description,
    required this.type,
    required this.isRequired,
    required this.options,
  });

  void updateTitle(String newTitle) {
    title = newTitle;
    notifyListeners();
  }

  void updateType(String newType) {
    type = newType;
    notifyListeners();
  }

  void updateIsRequired(bool newIsRequired) {
    isRequired = newIsRequired;
    notifyListeners();
  }

  void updateOptions(List<String> newOptions) {
    options = newOptions;
    notifyListeners();
  }
}

class QuestionProvider with ChangeNotifier {
  List<Question> _questions = [];

  List<Question> get questions => _questions;

  void addQuestion(Question question) {
    _questions.add(question);
    notifyListeners();
  }

  void removeQuestion(int index) {
    _questions.removeAt(index);
    notifyListeners();
  }

  void updateQuestion(int index, Question question) {
    _questions[index] = question;
    notifyListeners();
  }

  void clearQuestions() {
    _questions.clear();
    notifyListeners();
  }

  Map<String, dynamic> collectData(String diseaseName, String diseaseType, String name ,String org) {
    List<Map<String, dynamic>> questionData = _questions.map((question) {
      return {
        "paramName": question.title,
        "paramType": question.type,
        "isRequired": question.isRequired,
        "options": question.options.isEmpty ? [] : question.options
      };
    }).toList();

    return {
      "diseaseName": diseaseName,
      "diseaseType": diseaseType,
      "doctorName" : name,
      "org" : org,
      "paramList": questionData
    };
  }
}
