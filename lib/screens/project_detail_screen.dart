import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; 
import '../models/project.dart';
import '../models/expense.dart';

class ProjectDetailScreen extends StatefulWidget {
  final Project project;

  const ProjectDetailScreen({super.key, required this.project});

  @override
  _ProjectDetailScreenState createState() => _ProjectDetailScreenState();
}

class _ProjectDetailScreenState extends State<ProjectDetailScreen> {
  late double remaining;

  @override
  void initState() {
    super.initState();
    remaining = widget.project.budget -
        widget.project.expenses.fold(0, (sum, item) => sum + item.amount);
  }

  void _addExpense() {
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Agregar Egreso"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(labelText: "Descripción"),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Cantidad"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              final description = descriptionController.text;
              final amount = double.tryParse(amountController.text) ?? 0.0;

              if (amount > 0 && amount <= remaining) {
                setState(() {
                  widget.project.expenses.add(
                    Expense(description: description, amount: amount),
                  );
                  remaining -= amount;
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Cantidad inválida o saldo insuficiente"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text("Agregar"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.project.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Presupuesto: \$${widget.project.budget.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18)),
                    Text("Gastado: \$${(widget.project.budget - remaining).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 18, color: Colors.red)),
                    Text("Disponible: \$${remaining.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 18,
                          color: remaining < 0 ? Colors.red : Colors.green,
                        )),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            Expanded(
              child: ListView.builder(
                itemCount: widget.project.expenses.length,
                itemBuilder: (context, index) {
                  final expense = widget.project.expenses[index];
                  return ListTile(
                    title: Text(expense.description),
                    subtitle: Text("\$${expense.amount.toStringAsFixed(2)}"),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addExpense,
        child: const Icon(Icons.add),
      ),
      
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(8.0),
        color: Colors.grey[100], 
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Creación: ${DateFormat('dd/MM/yyyy').format(widget.project.creationDate)}",
              style: const TextStyle(fontSize: 12),
            ),
            Text(
              "Finalización: ${DateFormat('dd/MM/yyyy').format(widget.project.endDate)}",
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
