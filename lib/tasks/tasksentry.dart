import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import "../utils.dart" as utils;
import "tasksdbworker.dart";
import "tasksmodel.dart" show TasksModel, tasksModel;

class TasksEntry extends StatelessWidget {
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TasksEntry({super.key}) {
    _descriptionEditingController.addListener(() {
      tasksModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    _descriptionEditingController.text = tasksModel.entityBeingEdited.description;

    return ScopedModel(
      model: tasksModel,
      child: ScopedModelDescendant<TasksModel>(
        builder: (BuildContext inContext, Widget? inChild, TasksModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                    child: Text("Отмена"),
                  ),
                  Spacer(),
                  TextButton(
                    onPressed: () => _save(inContext, tasksModel),
                    child: Text("Сохранить"),
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Описание"),
                      controller: _descriptionEditingController,
                      validator: (String? inValue) {
                        if (inValue == null || inValue.isEmpty) {
                          return "Пожалуйста, введите описание";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Дата выполнения"),
                    subtitle: Text(tasksModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(
                          inContext,
                          tasksModel,
                          tasksModel.entityBeingEdited.dueDate,
                        );
                        if (chosenDate != null && chosenDate.isNotEmpty) {
                          tasksModel.entityBeingEdited.dueDate = chosenDate;
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _save(BuildContext inContext, TasksModel inModel) async {
    if (!_formKey.currentState!.validate()) return;

    if (inModel.entityBeingEdited.id == 0) {
      await TasksDBWorker.db.create(tasksModel.entityBeingEdited);
    } else {
      await TasksDBWorker.db.update(tasksModel.entityBeingEdited);
    }

    tasksModel.loadData("tasks", TasksDBWorker.db);
    inModel.setStackIndex(0);

    if (inContext.mounted) {
      ScaffoldMessenger.of(inContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text("Задача сохранена"),
        ),
      );
    }
  }
}
