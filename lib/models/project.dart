import 'package:cloud_firestore/cloud_firestore.dart';

import 'expense.dart';

class Project {
  String id;
  String name;
  double budget;
  DateTime creationDate;
  DateTime endDate;
  List<Expense> expenses;

  Project({
    this.id = '',
    required this.name,
    required this.budget,
    required this.creationDate,
    required this.endDate,
    this.expenses = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'budget': budget,
      'creationDate': creationDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'],
      budget: json['budget'],
      creationDate: (json['creationDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
    );
  }
}
