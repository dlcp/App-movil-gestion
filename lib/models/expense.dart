class Expense {
  String id;
  String description;
  double amount;

  Expense({this.id = '', required this.description, required this.amount});

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'amount': amount,
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? '',
      description: json['description'],
      amount: json['amount'],
    );
  }
}
