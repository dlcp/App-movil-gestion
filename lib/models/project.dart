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
      'creationDate': Timestamp.fromDate(creationDate), 
      'endDate': Timestamp.fromDate(endDate),
      'expenses': expenses.map((e) => e.toJson()).toList(), 
    };
  }

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      budget: (json['budget'] as num).toDouble(),
      creationDate: _parseDate(json['creationDate']),
      endDate: _parseDate(json['endDate']),
      expenses: (json['expenses'] as List<dynamic>?)
              ?.map((e) => Expense.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.parse(date);
    } else {
      throw Exception("Formato de fecha no válido: $date");
    }
  }
}
