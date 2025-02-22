import "../basemodel.dart";


class Note {

  int id = 0;
  String title = '';
  String content = '';
  String color = '';

  @override
  String toString() {
    return "{ id=$id, title=$title, content=$content, color=$color }";
  }

}


class NotesModel extends BaseModel {

  late String color;

  void setColor(String inColor) {
    color = inColor;
    notifyListeners();
  }

}

NotesModel notesModel = NotesModel();
