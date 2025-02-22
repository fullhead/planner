import "../basemodel.dart";


class Appointment {

  int id = 0;
  String title = '';
  String description = '';
  String apptDate = '';
  String apptTime = '';

  @override
  String toString() {
    return "{ id=$id, title=$title, description=$description, apptDate=$apptDate, apptTime=$apptTime }";
  }
}


class AppointmentsModel extends BaseModel {

  late String apptTime;

  void setApptTime(String inApptTime) {
    apptTime = inApptTime;
    notifyListeners();
  }
}

AppointmentsModel appointmentsModel = AppointmentsModel();
