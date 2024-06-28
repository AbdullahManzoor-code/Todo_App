import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive/hive.dart';
import 'package:myapp/database.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Get the directory to store the Hive database
  final path = await getApplicationDocumentsDirectory();

  // Initialise Hive with the directory path
  Hive.init(path.path);

  // Open a Hive box (database)
  await Hive.openBox('Box');

  // Run the Flutter app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.white,
        colorScheme:
            ColorScheme.fromSeed(seedColor: Colors.deepPurple.shade100),
        useMaterial3: true,
      ),
      home: const Todotask(),
    );
  }
}

class Todotask extends StatefulWidget {
  const Todotask({super.key});

  @override
  State<Todotask> createState() => _TodotaskState();
}

// Controller for the text input field
TextEditingController textcontor = TextEditingController();

// Database instance
Database db = Database(box: Hive.box('Box'));

class _TodotaskState extends State<Todotask> {
  // Method to handle checkbox change
  void oncheck(int index) {
    setState(() {
      db.todolist[index][1] = !db.todolist[index][1];
      db.updatelist();
    });
  }

  @override
  void initState() {
    super.initState();
    db.loadlist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const Drawer(),
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.deepPurple.shade500,
        title: const Center(
          child: Text("TODO APP"),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView.builder(
          itemCount: db.todolist.length,
          itemBuilder: (BuildContext context, int index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Slidable(
                endActionPane: ActionPane(
                  motion: const StretchMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        setState(() {
                          db.todolist.removeAt(index);
                          db.updatelist();
                        });
                      },
                      icon: Icons.delete,
                    )
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.deepPurple.shade100,
                      borderRadius: BorderRadius.circular(20)),
                  child: ListTile(
                    leading: Checkbox(
                        value: db.todolist[index][1],
                        onChanged: (value) {
                          oncheck(index);
                        }),
                    title: Text(
                      db.todolist[index][0],
                      style: TextStyle(
                          decoration: db.todolist[index][1]
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) => AlertDialog(
                    title: Column(
                      children: [
                        const Text("ADD TASK"),
                        TextFormField(
                          controller: textcontor,
                        )
                      ],
                    ),
                    actions: [
                      TextButton(
                          onPressed: () {
                            setState(() {
                              if (textcontor.text != "") {
                                db.todolist.add([textcontor.text, false]);
                              }
                            });
                            textcontor.text = "";
                            Navigator.of(context).pop();
                            db.updatelist();
                          },
                          child: const Text("SAVE")),
                      TextButton(
                          onPressed: () {
                            textcontor.clear();
                            Navigator.of(context).pop();
                          },
                          child: const Text("CANCEL"))
                    ],
                  ));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
