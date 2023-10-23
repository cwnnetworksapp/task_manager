import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/models/task_data.dart';

/// A screen for adding a new task.
class AddTaskScreen extends StatefulWidget {
  /// Constructor for the AddTaskScreen widget.
  AddTaskScreen({super.key, required this.user});

  final User user;
  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
 // The currently logged-in user.
  TaskData taskData =
      Get.put(TaskData());
 // Initialize TaskData for task management.
  @override
  Widget build(BuildContext context) {
    String? newTaskTitle; // The title of the new task to be added.

    return Container(
      color: const Color(0xff757575),
      child: Container(
        padding: const EdgeInsets.all(20.0),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.0),
            topRight: Radius.circular(20.0),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Add Task',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.lightBlueAccent,
              ),
            ),
            TextField(

              autofocus: true,
              textAlign: TextAlign.center,
              onChanged: (newText) {
                newTaskTitle = newText; // Capture the new task title.

              },
            ),

            ElevatedButton(
              child: const Text(
                'Add',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: () {
                if (newTaskTitle != null && newTaskTitle!.trim().isNotEmpty) {
                  // Add the new task to the task list using TaskData.
                  taskData.addTask(RxString(newTaskTitle!), widget.user.uid);
                  Navigator.pop(context); // Close the AddTaskScreen.
                } else {
                  // Show a popup or snackbar to inform the user that the input is empty or only contains spaces.
                  // You can use Get.snackbar for this purpose.
                  Get.snackbar(
                    "Empty Task Title",
                    "Please enter a non-empty task title.",
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),

          ],
        ),
      ),
    );
  }
}
