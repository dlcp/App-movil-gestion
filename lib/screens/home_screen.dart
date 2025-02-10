import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/project_provider.dart';
import '../models/project.dart';
import 'project_detail_screen.dart';
import 'create_project_screen.dart'; 

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<ProjectProvider>(context, listen: false).fetchProjects());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proyectos")),
      body: Consumer<ProjectProvider>(
        builder: (context, projectProvider, child) {
          return FutureBuilder(
            future: projectProvider.fetchProjects(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (projectProvider.projects.isEmpty) {
                return Center(child: Text("No hay proyectos aún. Agrega uno."));
              }

              return ListView.builder(
                itemCount: projectProvider.projects.length,
                itemBuilder: (context, index) {
                  final project = projectProvider.projects[index];

                  return Card(
                    child: ListTile(
                      title: Text(project.name),
                      subtitle: Text('Presupuesto: \$${project.budget}'),
                      onTap: () {
                        // 📌 Navegar a la pantalla de detalles del proyecto seleccionado
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ProjectDetailScreen(project: project),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.blue),
                            onPressed: () {
                              _editProjectDialog(context, index, project);
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              Provider.of<ProjectProvider>(context,
                                      listen: false)
                                  .removeProject(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateProjectScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editProjectDialog(BuildContext context, int index, Project project) {
    final _nameController = TextEditingController(text: project.name);
    final _budgetController =
        TextEditingController(text: project.budget.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar Proyecto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre'),
              ),
              TextField(
                controller: _budgetController,
                decoration: InputDecoration(labelText: 'Presupuesto'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                final updatedProject = Project(
                  id: project.id,
                  name: _nameController.text,
                  budget: double.tryParse(_budgetController.text) ?? 0.0,
                  creationDate: project.creationDate,
                  endDate: project.endDate,
                  expenses: project.expenses,
                );

                Provider.of<ProjectProvider>(context, listen: false)
                    .updateProject(index, updatedProject);

                Navigator.pop(context);
              },
              child: Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}
