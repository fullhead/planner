import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import 'package:intl/intl.dart';
import "appointmentsdbworker.dart";
import "appointmentsmodel.dart" show Appointment, AppointmentsModel, appointmentsModel;

class AppointmentsList extends StatelessWidget {
  const AppointmentsList({super.key});

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () async {
                appointmentsModel.entityBeingEdited = Appointment();
                appointmentsModel.setApptTime('');
                appointmentsModel.setChosenDate('');
                appointmentsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: appointmentsModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Appointment appointment = appointmentsModel.entityList[inIndex];
                return Container(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Slidable(
                    key: ValueKey(appointment.id),
                    endActionPane: ActionPane(
                      motion: const DrawerMotion(),
                      extentRatio: 0.25,
                      children: [
                        SlidableAction(
                          onPressed: (context) => _deleteAppointment(context, appointment),
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          label: 'Удалить',
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ],
                    ),
                    child: Card(
                      margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        title: Text(
                          appointment.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 5.0),
                              child: Text(
                                appointment.description,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                            // Отображаем дату и время в одной строке
                            if (appointment.apptDate.isNotEmpty || appointment.apptTime.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 10.0),
                                child: Row(
                                  children: [
                                    Text(
                                      _formatDate(appointment.apptDate),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    if (appointment.apptTime.isNotEmpty)
                                      Text(
                                        " в ${appointment.apptTime}",
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        onTap: () async {
                          appointmentsModel.entityBeingEdited = await AppointmentsDBWorker.db.get(appointment.id);
                          appointmentsModel.setApptTime(appointmentsModel.entityBeingEdited.apptTime);
                          String sDate = _formatDate(appointmentsModel.entityBeingEdited.apptDate);
                          appointmentsModel.setChosenDate(sDate);
                          appointmentsModel.setStackIndex(1);
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

  Future _deleteAppointment(BuildContext inContext, Appointment inAppointment) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text("Удалить встречу"),
          content: Text("Вы уверены, что хотите удалить '${inAppointment.title}'?"),
          actions: [
            TextButton(
              child: const Text("Отмена"),
              onPressed: () {
                Navigator.of(inAlertContext).pop();
              },
            ),
            TextButton(
              child: const Text("Удалить"),
              onPressed: () async {
                await AppointmentsDBWorker.db.delete(inAppointment.id);
                if (inAlertContext.mounted) {
                  Navigator.of(inAlertContext).pop();
                }
                if (inAlertContext.mounted) {
                  ScaffoldMessenger.of(inAlertContext).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Встреча удалена"),
                    ),
                  );
                }
                appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
              },
            ),
          ],
        );
      },
    );
  }

  // Метод для форматирования даты.
  String _formatDate(String date) {
    List<String> dateParts = date.split(",");
    if (dateParts.length == 3) {
      DateTime dt = DateTime(
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
      );
      return DateFormat.yMMMMd("ru_RU").format(dt.toLocal());
    }
    return "";
  }
}
