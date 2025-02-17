import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/project.dart';
import '../models/expense.dart';

class ProjectProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Project> _projects = [];

  List<Project> get projects => _projects;

  ProjectProvider() {
    fetchProjects();
  }

  Future<void> fetchProjects() async {
    try {
      final snapshot = await _firestore.collection('projects').get();
      _projects = await Future.wait(snapshot.docs.map((doc) async {
        Project project = Project.fromJson({...doc.data(), 'id': doc.id});
        project.expenses = await fetchExpenses(doc.id);
        return project;
      }));
      notifyListeners();
    } catch (e) {
      print("Error al obtener proyectos: $e");
    }
  }

  Future<void> addProject(Project project) async {
    try {
      final docRef = await _firestore.collection('projects').add(project.toJson());
      project.id = docRef.id;
      _projects.add(project);
      notifyListeners();
    } catch (e) {
      print("Error al agregar proyecto: $e");
    }
  }

  Future<void> updateProject(int index, Project updatedProject) async {
    try {
      if (updatedProject.id == null || updatedProject.id!.isEmpty) {
        print("Error: El proyecto no tiene un ID válido.");
        return;
      }

      await _firestore.collection('projects').doc(updatedProject.id).update(updatedProject.toJson());

      _projects[index] = updatedProject;
      notifyListeners();
    } catch (e) {
      print("Error al actualizar proyecto: $e");
    }
  }

  Future<void> removeProject(int index) async {
    try {
      if (index < 0 || index >= _projects.length) {
        print("Error: Índice fuera de rango.");
        return;
      }

      String projectId = _projects[index].id ?? "";
      if (projectId.isEmpty) {
        print("Error: El ID del proyecto es inválido.");
        return;
      }

      await deleteAllExpenses(projectId);

      await _firestore.collection('projects').doc(projectId).delete();

      _projects.removeAt(index);
      notifyListeners();
    } catch (e) {
      print("Error al eliminar proyecto: $e");
    }
  }

  Future<void> addExpense(String projectId, Expense expense) async {
    try {
      final docRef = await _firestore.collection('projects').doc(projectId).collection('expenses').add(expense.toJson());
      expense.id = docRef.id;
      notifyListeners();
    } catch (e) {
      print("Error al agregar gasto: $e");
    }
  }

  Future<void> removeExpense(String projectId, String expenseId) async {
    try {
      await _firestore.collection('projects').doc(projectId).collection('expenses').doc(expenseId).delete();
      notifyListeners();
    } catch (e) {
      print("Error al eliminar gasto: $e");
    }
  }

  Future<List<Expense>> fetchExpenses(String projectId) async {
    try {
      final snapshot = await _firestore.collection('projects').doc(projectId).collection('expenses').get();
      return snapshot.docs.map((doc) => Expense.fromJson({...doc.data(), 'id': doc.id})).toList();
    } catch (e) {
      print("Error al obtener gastos: $e");
      return [];
    }
  }

  Future<void> deleteAllExpenses(String projectId) async {
    try {
      final snapshot = await _firestore.collection('projects').doc(projectId).collection('expenses').get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print("Error al eliminar todos los gastos: $e");
    }
  }
}
