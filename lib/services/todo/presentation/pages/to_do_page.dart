import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../data/todo_model.dart';
import '../data/todo_repository.dart';
import '../widgets/todo_list_item.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  final ToDoRepository _repository = ToDoRepository();
  final TextEditingController _taskController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _addTask(String task) {
    if (_formKey.currentState!.validate()) {
      _repository.addTask(ToDoModel(title: task));
      _taskController.clear();
      Navigator.pop(context);
    }
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Task',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _taskController,
                decoration: InputDecoration(
                  hintText: 'Enter task name',
                  prefixIcon: const Icon(Iconsax.task),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a task';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _addTask(_taskController.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF634682),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Add Task',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          
          Expanded(
            child: Card(
              
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ValueListenableBuilder(
                  valueListenable: _repository.listenable,
                  builder: (context, box, _) {
                    final tasks = _repository.getTasks();
                    return tasks.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Iconsax.note_remove,
                                    size: 48, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  "No tasks yet",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Tap + to add your first task",
                                  style: GoogleFonts.poppins(
                                    fontSize: 11,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            itemCount: tasks.length,
                            itemBuilder: (context, index) => Column(
                              children: [
                                ToDoListItem(
                                  task: tasks[index],
                                  index: index,
                                  onToggle: () =>
                                      _repository.toggleTaskStatus(index),
                                  onDelete: () =>
                                      _repository.removeTask(index),
                                ),
                                if (index != tasks.length - 1)
                                  const Divider(height: 1),
                              ],
                            ),
                          );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 50,
        child: FloatingActionButton(
          onPressed: _showAddTaskDialog,
          backgroundColor: const Color.fromARGB(255, 111, 78, 146),
          elevation: 4,
          child: const Icon(Iconsax.add, color: Colors.white, size: 20),
        ),
      ),
    );
  }
}