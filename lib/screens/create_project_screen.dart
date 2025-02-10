import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import 'package:intl/intl.dart';

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
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _saveProject() {
    final name = _nameController.text;
    final budget = double.tryParse(_budgetController.text) ?? 0.0;

    if (name.isNotEmpty && budget > 0 && _endDate != null) {
      final projectProvider = Provider.of<ProjectProvider>(context, listen: false);

      final newProject = Project(
        name: name,
        budget: budget,
        creationDate: _creationDate,
        endDate: _endDate!,
      );

      if (widget.projectIndex == null) {
        projectProvider.addProject(newProject);
      } else {
        projectProvider.updateProject(widget.projectIndex!, newProject);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Proyecto ${widget.projectIndex == null ? 'agregado' : 'actualizado'}: $name")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.projectIndex == null ? "Nuevo Proyecto" : "Editar Proyecto")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Nombre del Proyecto"),
            ),
            TextField(
              controller: _budgetController,
              decoration: InputDecoration(labelText: "Presupuesto"),
              keyboardType: TextInputType.number,
            ),
            ListTile(
              title: Text("Fecha de creación: ${DateFormat('dd/MM/yyyy').format(_creationDate)}"),
            ),
            ListTile(
              title: Text("Fecha de finalización: ${_endDate != null ? DateFormat('dd/MM/yyyy').format(_endDate!) : 'Seleccionar'}"),
              trailing: Icon(Icons.calendar_today),
              onTap: () => _selectEndDate(context),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProject,
              child: Text(widget.projectIndex == null ? "Guardar Proyecto" : "Actualizar Proyecto"),
            ),
          ],
        ),
      ),
    );
  }
}
