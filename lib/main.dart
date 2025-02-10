import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'providers/project_provider.dart';
import 'models/project.dart';
import 'screens/project_detail_screen.dart';
import 'screens/create_project_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ProjectProvider()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión de Proyectos',
      theme: ThemeData(
        primarySwatch: MaterialColor(0xFFB39DDB, {
          50: Color(0xFFF3E5F5),
          100: Color(0xFFE1BEE7),
          200: Color(0xFFD1A6D7),
          300: Color(0xFFC085C8),
          400: Color(0xFFB085C1),
          500: Color(0xFFB39DDB),
          600: Color(0xFF9E86C9),
          700: Color(0xFF8D6FB8),
          800: Color(0xFF7B58A7),
          900: Color(0xFF5C3F8D),
        }),
        scaffoldBackgroundColor: Color(0xFFF3E5F5), 
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: TextTheme(
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
          bodySmall: TextStyle(fontSize: 14, color: Colors.grey[600]),
          titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          labelStyle: TextStyle(color: Colors.purple[600]),
        ),
      ),
      home: ProjectListScreen(),
    );
  }
}

class ProjectListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Proyectos'),
        centerTitle: true,
        elevation: 2,
      ),
      body: projectProvider.projects.isEmpty
          ? Center(child: Text('No hay proyectos'))
          : ListView.builder(
              itemCount: projectProvider.projects.length,
              itemBuilder: (context, index) {
                final project = projectProvider.projects[index];
                return MouseRegion(
                  onEnter: (_) {
                  },
                  onExit: (_) {
                  },
                  child: Card(
                    margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 6,
                    color: Colors.white,
                    shadowColor: Colors.purple[100], 
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(project.name, style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text('Presupuesto: \$${project.budget.toString()}'),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProjectDetailScreen(project: project),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.purple[600]),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CreateProjectScreen(
                                    project: project,
                                    projectIndex: index,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              projectProvider.removeProject(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddProjectDialog(context);
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[600],
      ),
    );
  }

  void _showAddProjectDialog(BuildContext context) {
    final projectProvider = Provider.of<ProjectProvider>(context, listen: false);
    final nameController = TextEditingController();
    final budgetController = TextEditingController();
    DateTime creationDate = DateTime.now();
    DateTime? endDate;

    Future<void> _selectEndDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        endDate = picked;
      }
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Nuevo Proyecto'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nombre'),
                  ),
                  TextField(
                    controller: budgetController,
                    decoration: InputDecoration(labelText: 'Presupuesto'),
                    keyboardType: TextInputType.number,
                  ),
                  ListTile(
                    title: Text("Fecha de creación: ${DateFormat('dd/MM/yyyy').format(creationDate)}"),
                  ),
                  ListTile(
                    title: Text(endDate == null ? "Seleccionar fecha de finalización" : "Fecha de finalización: ${DateFormat('dd/MM/yyyy').format(endDate!)}"),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      await _selectEndDate(context);
                      setState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancelar', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty && budgetController.text.isNotEmpty && endDate != null) {
                      final newProject = Project(
                        name: nameController.text,
                        budget: double.parse(budgetController.text),
                        creationDate: creationDate,
                        endDate: endDate!,
                        expenses: [],
                      );
                      projectProvider.addProject(newProject);
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Por favor, completa todos los campos'), backgroundColor: Colors.red),
                      );
                    }
                  },
                  child: Text('Agregar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple[600],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
