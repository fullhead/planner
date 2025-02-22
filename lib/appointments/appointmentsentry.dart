import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointmentsdbworker.dart';
import 'appointmentsmodel.dart' show AppointmentsModel, appointmentsModel;
import "../utils.dart" as utils;

class AppointmentsEntry extends StatelessWidget {
  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _descriptionEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  AppointmentsEntry({super.key}) {
    _titleEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _descriptionEditingController.addListener(() {
      appointmentsModel.entityBeingEdited.description = _descriptionEditingController.text;
    });
  }

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    _titleEditingController.text = appointmentsModel.entityBeingEdited.title ?? '';
    _descriptionEditingController.text = appointmentsModel.entityBeingEdited.description ?? '';

    return ScopedModel(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    child: Text("Отмена"),
                    onPressed: () {
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  TextButton(
                    child: Text("Сохранить"),
                    onPressed: () {
                      _save(inContext, appointmentsModel);
                    },
                  ),
                ],
              ),
            ),
            body: Form(
              key: _formKey,
              child: ListView(
                children: [
                  ListTile(
                    leading: Icon(Icons.subject),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Заголовок"),
                      controller: _titleEditingController,
                      validator: (String? inValue) {
                        if (inValue == null || inValue.isEmpty) {
                          return "Пожалуйста, введите заголовок!";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.description),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      decoration: InputDecoration(hintText: "Описание"),
                      controller: _descriptionEditingController,
                      validator: (String? inValue) {
                        if (inValue == null || inValue.isEmpty) {
                          return "Пожалуйста, введите описание!";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("Дата встречи"),
                    subtitle: Text(appointmentsModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(
                            inContext,
                            appointmentsModel,
                            appointmentsModel.entityBeingEdited.apptDate
                        );
                        if (chosenDate != null && chosenDate.isNotEmpty) {
                          appointmentsModel.entityBeingEdited.apptDate = chosenDate;
                        }
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.alarm),
                    title: Text("Время встречи"),
                    subtitle: Text(appointmentsModel.apptTime),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: inContext,
                          initialTime: TimeOfDay.now(),
                        );
                        if (pickedTime != null) {
                          String formattedTime = pickedTime.format(inContext);
                          appointmentsModel.setApptTime(formattedTime);
                          appointmentsModel.entityBeingEdited.apptTime = formattedTime;
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

  void _save(BuildContext inContext, AppointmentsModel inModel) async {
    if (!_formKey.currentState!.validate()) return;

    if (inModel.entityBeingEdited.id == 0) {
      await AppointmentsDBWorker.db.create(appointmentsModel.entityBeingEdited);
    } else {
      await AppointmentsDBWorker.db.update(appointmentsModel.entityBeingEdited);
    }

    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
    inModel.setStackIndex(0);

    if (inContext.mounted) {
      ScaffoldMessenger.of(inContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text("Встреча сохранена"),
        ),
      );
    }
  }
}
