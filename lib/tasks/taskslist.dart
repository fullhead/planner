import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'tasksdbworker.dart';
import 'tasksmodel.dart' show Task, TasksModel, tasksModel;

class TasksList extends StatelessWidget {
  const TasksList({super.key});

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<TasksModel>(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.black),
              onPressed: () {
                tasksModel.entityBeingEdited = Task();
                tasksModel.setChosenDate('');
                tasksModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: tasksModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Task task = tasksModel.entityList[inIndex];
                String sDueDate = '';
                if (task.dueDate.isNotEmpty) {
                  List dateParts = task.dueDate.split(",");
                  DateTime dueDate = DateTime(
                    int.parse(dateParts[0]),
                    int.parse(dateParts[1]),
                    int.parse(dateParts[2]),
                  );
                  sDueDate = DateFormat.yMMMMd("ru_RU").format(dueDate.toLocal());
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Slidable(
                    key: ValueKey(task.id),
                    endActionPane: ActionPane(
                      motion: DrawerMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) => _deleteTask(context, task),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Удалить',
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                    child: Card(
                      margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Checkbox(
                          value: task.completed == "true",
                          onChanged: (inValue) async {
                            task.completed = inValue.toString();
                            await TasksDBWorker.db.update(task);
                            tasksModel.loadData("tasks", TasksDBWorker.db);
                          },
                        ),
                        title: Text(
                          task.description,
                          style: task.completed == "true"
                              ? TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)
                              : TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        subtitle: task.dueDate.isEmpty
                            ? null
                            : Text(
                          sDueDate,
                          style: task.completed == "true"
                              ? TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough)
                              : TextStyle(color: Colors.black54, fontSize: 16),
                        ),
                        onTap: () async {
                          if (task.completed == "true") return;
                          tasksModel.entityBeingEdited = await TasksDBWorker.db.get(task.id);
                          tasksModel.setChosenDate(sDueDate);
                          tasksModel.setStackIndex(1);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future _deleteTask(BuildContext inContext, Task inTask) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Удалить задачу"),
          content: Text("Вы уверены, что хотите удалить '${inTask.description}'?"),
          actions: [
            TextButton(
              child: Text("Отмена"),
              onPressed: () {
                Navigator.of(inAlertContext).pop();
              },
            ),
            TextButton(
              child: Text("Удалить"),
              onPressed: () async {
                await TasksDBWorker.db.delete(inTask.id);
                if (inAlertContext.mounted) Navigator.of(inAlertContext).pop();
                if (inAlertContext.mounted) {
                  ScaffoldMessenger.of(inAlertContext).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Задача удалена"),
                    ),
                  );
                }
                tasksModel.loadData("tasks", TasksDBWorker.db);
              },
            ),
          ],
        );
      },
    );
  }
}
