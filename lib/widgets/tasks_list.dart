import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/widgets/task_tile.dart';
import 'package:task_manager/models/task_data.dart';

import '../models/task.dart'; // Import necessary dependencies and your custom task model.

class TasksList extends StatelessWidget {
  TasksList({super.key, required this.user}); // Constructor for the TasksList widget.
  User user;
  TaskData taskData = Get.put(TaskData()); // Initialize the TaskData class to manage task-related data.

  void _showDeleteConfirmationDialog(BuildContext context, Task task) {
    // Display a confirmation dialog for task deletion.
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: <Widget>[
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog.
              },
            ),
            TextButton(
              child: const Text("Delete"),
              onPressed: () {
                taskData.deleteTask(task,user.uid); // Delete the task using the TaskData instance.
                Navigator.of(context).pop(); // Close the dialog.
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Task deleted."),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }


  void _showEditTaskDialog(BuildContext context, Task task) {
    TextEditingController taskNameController = TextEditingController(text: task.name!.value);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Edit Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: taskNameController,
                decoration: InputDecoration(labelText: "Task Name"),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Save"),
              onPressed: () {

                taskData.editTaskTitle(task,taskNameController.text, user.uid);// Update the task name.
                task.name!.value = taskNameController.text;
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Task updated."),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() => ListView.builder(
      itemBuilder: (context, index) {
        final task = taskData.tasks[index];
        return TaskTile(
          taskTitle: task.name!.value,
          isChecked: task.isDone,
          checkboxCallback: (checkboxState) {
            taskData.updateTask(task,user.uid); // Update the task's state when the checkbox is tapped.
          },
          longPressCallback: () {
            _showDeleteConfirmationDialog(context, task); // Show the delete confirmation dialog.
          },
          editCallback: () {
            _showEditTaskDialog(context, task); // Show the edit dialog.
          },        );
      },
      itemCount: taskData.taskCount,
    ));
  }
}
