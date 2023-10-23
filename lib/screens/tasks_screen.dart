import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/widgets/tasks_list.dart';
import 'package:task_manager/screens/add_task_screen.dart';
import 'package:task_manager/models/task_data.dart';

import '../res/custom_colors.dart';
import '../services/authentication.dart';
import 'login_screen.dart';

/// A widget representing the main tasks screen.
class TasksScreen extends StatefulWidget {
  /// Constructor for TasksScreen widget.
  ///
  /// [key] is an optional parameter used to provide a key to this widget.
  const TasksScreen({Key? key, required User user})
      : _user = user,
        super(key: key);
  final User _user;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  /// An instance of the [TaskData] class for managing task-related data.
  TaskData taskData = Get.put(TaskData());

  late User _user;

  @override
  void initState() {
    _user = widget._user;
    taskData.updateTasksFromFirestore(_user.uid);
    super.initState();
  }

  Route _routeToSignInScreen() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => SignInScreen(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = const Offset(-1.0, 0.0);
        var end = Offset.zero;
        var curve = Curves.ease;

        var tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlueAccent,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.lightBlueAccent,
        child: const Icon(Icons.add),
        onPressed: () {
          // Show a bottom sheet for adding tasks when the floating action button is pressed.
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: AddTaskScreen(
                  user: _user,
                ),
              ),
            ),
          );
        },
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.only(
              top: 60.0,
              left: 30.0,
              right: 30.0,
              bottom: 30.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _user.photoURL != null
                        ? ClipOval(
                            child: Material(
                              color: CustomColors.firebaseGrey.withOpacity(0.3),
                              child: Image.network(
                                _user.photoURL!,
                                fit: BoxFit.fitHeight,
                              ),
                            ),
                          )
                        : ClipOval(
                            child: Material(
                              color: CustomColors.firebaseGrey.withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: CustomColors.firebaseGrey,
                                ),
                              ),
                            ),
                          ),
                    const SizedBox(
                      height: 16.0,
                      width: 16.0,
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hello',
                              style: TextStyle(
                                color: CustomColors.firebaseGrey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            taskData.isSigningOut.value
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  )
                                : ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                        Colors.redAccent,
                                      ),
                                      shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      taskData.isSigningOut.value = true;

                                      await Authentication.signOut(
                                          context: context);

                                      Navigator.of(context).pushReplacement(
                                          _routeToSignInScreen());
                                    },
                                    child: const Padding(
                                        padding: EdgeInsets.only(
                                            top: 3.0, bottom: 3.0),
                                        child: Icon(
                                          Icons.logout,
                                          color: Colors.white,
                                        ))),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _user.displayName!,
                          style: TextStyle(
                            color: CustomColors.firebaseYellow,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: Text(
                            '( ${_user.email!} )',
                            style: TextStyle(
                                color: CustomColors.firebaseGrey,
                                fontSize: 16,
                                overflow: TextOverflow.fade),
                            softWrap: true,
                          ),
                        ),
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ],
                )
                // Display a circle avatar with an icon for the app logo.
                ,
                const SizedBox(
                  height: 10.0,
                ),
                const Text(
                  'Task Manager',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Obx(
                  () => Text(
                    // Display the number of tasks using an Obx widget for automatic updates.
                    '${taskData.taskCount} Tasks',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
              ),
              child: TasksList(user: _user),
            ),
          ),
        ],
      ),
    );
  }
}
