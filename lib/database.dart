class Database {
  Database({
    required this.box,
  });

  final box;

  List todolist = [];

  void loadlist() {
    todolist = box.get('todolist', defaultValue: []);
  }

  void updatelist() {
    box.put('todolist', todolist);
  }
}
