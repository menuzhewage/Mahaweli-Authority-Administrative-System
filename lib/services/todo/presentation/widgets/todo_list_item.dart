import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/todo_model.dart';

class ToDoListItem extends StatelessWidget {
  final ToDoModel task;
  final int index;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const ToDoListItem({
    super.key,
    required this.task,
    required this.index,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(index.toString()),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        child: ListTile(
          leading: Checkbox(
            value: task.isDone,
            onChanged: (value) => onToggle(),
          ),
          title: Row(
            children: [
              Text(
                task.title,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  decoration: task.isDone ? TextDecoration.lineThrough : null,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onDelete,
                child: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
