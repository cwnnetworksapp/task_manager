import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskTile extends StatelessWidget {
  final RxBool? isChecked;
  final String? taskTitle;
  var checkboxCallback;
  var longPressCallback;
  var editCallback;

  TaskTile({
    Key? key,
    this.isChecked,
    this.taskTitle,
    this.checkboxCallback,

    this.longPressCallback,
    this.editCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Obx(() => Text(
        taskTitle!,
        style: TextStyle(
          decoration: isChecked!.value ? TextDecoration.lineThrough : null,
        ),
      )),

      trailing: SizedBox(
        width: 100,
        height: 100,
        child: Row(
          children: [

            Expanded(child: IconButton(onPressed: editCallback, icon: const Icon(Icons.edit))),
            Obx(
              ()=> Expanded(
                child: Checkbox(
                  activeColor: Colors.lightBlueAccent,
                  value: isChecked!.value,
                  onChanged: checkboxCallback,
                ),
              ),
            ),
            Expanded(child: IconButton(onPressed: longPressCallback, icon: const Icon(Icons.delete,color: Colors.red,))),

          ],
        ),
      ),
    );
  }
}
