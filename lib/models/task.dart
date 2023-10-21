import 'package:get/get.dart';

/// A class representing a task with a name and done status.
class Task extends GetxController {
  /// The name of the task.
  RxString? name;

  /// The status of the task (whether it is done or not).
  RxBool isDone = false.obs;

  /// Constructor to create a Task.
  ///
  /// [name] is the name of the task.
  /// [isDone] is the initial status of the task.
  Task({this.name, required this.isDone});

  /// Toggles the status of the task.
  ///
  /// If the task is currently done, it will be marked as not done, and vice versa.
  void toggleDone() {
    isDone.value = !isDone.value;
    refresh();
  }
}
