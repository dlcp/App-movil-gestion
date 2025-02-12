import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateProjectScreen extends StatefulWidget {
  final Project? project;
  final int? projectIndex;

  CreateProjectScreen({this.project, this.projectIndex});

  @override
  _CreateProjectScreenState createState() => _CreateProjectScreenState();
}

class _CreateProjectScreenState extends State<CreateProjectScreen> {
  final _nameController = TextEditingController();
  final _budgetController = TextEditingController();
  DateTime? _endDate;
  late DateTime _creationDate;
  bool _isLoading = false; // Indicador de carga

  @override
  void initState() {
    super.initState();
    _creationDate = widget.project?.creationDate ?? DateTime.now();
    _endDate = widget.project?.endDate;
    if (widget.project != null) {
      _nameController.text = widget.project!.name;
      _budgetController.text = widget.project!.budget.toString();
    }
  }

  void _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveProject() async {
    final name = _nameController.text;
    final budget = double.tryParse(_budgetController.text) ?? 0.0;

    if (name.isNotEmpty && budget > 0 && _endDate != null) {
      setState(() {
        _isLoading = true; // Activar el spinner
      });

      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
      final isNewProject = widget.project == null;

      final projectId = isNewProject
          ? FirebaseFirestore.instance.collection('projects').doc().id
          : widget.project!.id;

      final newProject = Project(
        id: projectId,
        name: name,
        budget: budget,
        creationDate: _creationDate,
        endDate: _endDate!,
      );

      if (isNewProject) {
        await projectProvider.addProject(newProject);
        await FirebaseFirestore.instance.collection('projects').doc(projectId).set(newProject.toJson());
      } else {
        await projectProvider.updateProject(widget.projectIndex!, newProject);
        await FirebaseFirestore.instance.collection('projects').doc(projectId).update(newProject.toJson());
      }

      setState(() {
        _isLoading = false; // Desactivar el spinner
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Proyecto ${isNewProject ? 'agregado' : 'actualizado'}: $name")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.projectIndex == null ? "Nuevo Proyecto" : "Editar Proyecto"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Nombre del Proyecto",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.work),
                        ),
                      ),
                      SizedBox(height: 15),
                      TextField(
                        controller: _budgetController,
                        decoration: InputDecoration(
                          labelText: "Presupuesto",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 15),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.calendar_today, color: Colors.deepPurple),
                        title: Text(
                          "Fecha de creación: ${DateFormat('dd/MM/yyyy').format(_creationDate)}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(height: 10),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.date_range, color: Colors.deepPurple),
                        title: Text(
                          "Fecha de finalización: ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Seleccionar'}",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        trailing: Icon(Icons.calendar_month),
                        onTap: () => _selectEndDate(context),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProject,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  widget.projectIndex == null ? "Guardar Proyecto" : "Actualizar Proyecto",
                                  style: TextStyle(fontSize: 16),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}
