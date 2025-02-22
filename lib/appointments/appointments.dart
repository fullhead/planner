import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'appointmentsdbworker.dart';
import 'appointmentslist.dart';
import 'appointmentsmodel.dart' show AppointmentsModel, appointmentsModel;
import 'appointmentsentry.dart';

class Appointments extends StatelessWidget {

  Appointments({super.key}) {
    appointmentsModel.loadData("appointments", AppointmentsDBWorker.db);
  }

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<AppointmentsModel>(
      model: appointmentsModel,
      child: ScopedModelDescendant<AppointmentsModel>(
        builder: (BuildContext inContext, Widget? inChild, AppointmentsModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              AppointmentsList(),
              if (inModel.entityBeingEdited != null) AppointmentsEntry(),
              if (inModel.entityBeingEdited == null) Container(),
            ],
          );
        },
      ),
    );
  }
}
