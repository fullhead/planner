import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "tasksdbworker.dart";
import "taskslist.dart";
import "tasksentry.dart";
import "tasksmodel.dart" show TasksModel, tasksModel;


class Tasks extends StatelessWidget {

  Tasks({super.key}) {
    tasksModel.loadData("tasks", TasksDBWorker.db);
  }

  /// Метод build() для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<TasksModel>(
        model: tasksModel,
        child: ScopedModelDescendant<TasksModel>(
            builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
              return IndexedStack(
                  index: inModel.stackIndex,
                  children: [
                    TasksList(),
                    if (inModel.entityBeingEdited != null) TasksEntry(),
                    if (inModel.entityBeingEdited == null) Container(),
                  ]
              );
            })
    );
  }
}
