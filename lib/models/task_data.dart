import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:task_manager/models/task.dart';
import 'dart:collection';

/// A class for managing a list of tasks and their state.
class TaskData extends GetxController {

  ///Checking weather application is sign out or not

  RxBool isSigningOut = false.obs;



  /// The list of tasks, wrapped with the GetX `RxList` for reactivity.
  RxList<Task> _tasks = <Task>[].obs;

  // Function to fetch tasks from Firestore and update the local list
  Future<void> updateTasksFromFirestore(String uid) async {
    _tasks.clear(); // Clear the existing local tasks list.

    // Query Firestore to fetch tasks for the given UID.
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Tasks')
        .doc(uid)
        .collection('userTasks')
        .get();

    // Loop through the documents and add them to the local list.
    for (QueryDocumentSnapshot document in querySnapshot.docs) {
      final Map<String, dynamic> data = document.data() as Map<String, dynamic>;
      final Task task = Task(
        name: RxString(data['name']),
        isDone: RxBool(data['isDone']),
      );
      _tasks.add(task);
    }

    refresh(); // Refresh the GetX controller to reflect changes in the UI.
  }

  /// Get an unmodifiable view of the tasks.
  UnmodifiableListView<Task> get tasks {
    return UnmodifiableListView(_tasks);
  }

  /// Get the count of tasks in the list.
  int get taskCount {
    return _tasks.length;
  }

  /// Add a new task with the given title to the list and save it to Firestore.
  ///
  /// [newTaskTitle] is the title of the new task to be added.
  /// [uid] is the user's unique identifier.
  void addTask(RxString newTaskTitle, String uid) async {
    final task = Task(name: newTaskTitle, isDone: RxBool(false));
    _tasks.add(task);

    // Save the task to Firebase Firestore.
    await FirebaseFirestore.instance.collection('Tasks').doc(uid).collection('userTasks').add({
      'name': newTaskTitle.value,
      'isDone': false,
    });

    refresh();
  }

  /// Update the state of a task by toggling its done status in Firestore.
  ///
  /// [task] is the task to be updated.
  /// [uid] is the user's unique identifier.
  void updateTask(Task task, String uid) async {
    // Toggle the task's 'isDone' status.
    task.isDone.value = !task.isDone.value;

    // Find and update the task in Firebase Firestore based on some identifier (e.g., task name).
    QuerySnapshot tasks = await FirebaseFirestore.instance.collection('Tasks').doc(uid).collection('userTasks')
        .where('name', isEqualTo: task.name!.value)
        .get();

    if (tasks.docs.isNotEmpty) {
      // Assuming that there is only one matching task, update it.
      await FirebaseFirestore.instance.collection('Tasks').doc(uid).collection('userTasks')
          .doc(tasks.docs.first.id)
          .update({
        'isDone': task.isDone.value,
      });
    }

    refresh();
  }

  /// Delete a task from the list and Firestore.
  ///
  /// [task] is the task to be deleted.
  /// [uid] is the user's unique identifier.
  Future<void> deleteTask(Task task, String uid) async {
    // Remove the task from the local list.
    _tasks.remove(task);

    // Delete the task from Firebase Firestore based on some identifier (e.g., task name).
    QuerySnapshot tasks = await FirebaseFirestore.instance.collection('Tasks').doc(uid).collection('userTasks')
        .where('name', isEqualTo: task.name!.value)
        .get();

    if (tasks.docs.isNotEmpty) {
      // Assuming that there is only one matching task, delete it.
      await FirebaseFirestore.instance.collection('Tasks').doc(uid).collection('userTasks')
          .doc(tasks.docs.first.id)
          .delete();
    }

    refresh();
  }
}
