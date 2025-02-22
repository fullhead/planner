import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'notesdbworker.dart';
import 'notesmodel.dart' show NotesModel, notesModel;


class NotesEntry extends StatelessWidget {

  final TextEditingController _titleEditingController = TextEditingController();
  final TextEditingController _contentEditingController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  NotesEntry({super.key}) {

    _titleEditingController.addListener(() {
      notesModel.entityBeingEdited.title = _titleEditingController.text;
    });
    _contentEditingController.addListener(() {
      notesModel.entityBeingEdited.content = _contentEditingController.text;
    });
  }

  /// Метод build для построения виджета.
  @override
  Widget build(BuildContext inContext) {

    _titleEditingController.text = notesModel.entityBeingEdited.title ?? '';
    _contentEditingController.text = notesModel.entityBeingEdited.content ?? '';

    return ScopedModel(
      model: notesModel,
      child: ScopedModelDescendant<NotesModel>(
        builder: (BuildContext inContext, Widget? inChild, NotesModel inModel) {
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
                      _save(inContext, notesModel);
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
                    leading: Icon(Icons.title),
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
                    leading: Icon(Icons.content_paste),
                    title: TextFormField(
                      keyboardType: TextInputType.multiline,
                      maxLines: 8,
                      decoration: InputDecoration(hintText: "Содержание"),
                      controller: _contentEditingController,
                      validator: (String? inValue) {
                        if (inValue == null || inValue.isEmpty) {
                          return "Пожалуйста, введите содержание!";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.color_lens),
                    title: Row(
                      children: _buildColorOptions(inContext),
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

  List<Widget> _buildColorOptions(BuildContext inContext) {
    const List<String> colors = ['red', 'green', 'blue', 'yellow', 'grey', 'purple'];
    return colors.map((color) {
      return GestureDetector(
        child: Container(
          decoration: ShapeDecoration(
            shape: Border.all(color: _colorFromString(color), width: 18) +
                Border.all(
                  width: 6,
                  color: notesModel.color == color ? _colorFromString(color) : Theme.of(inContext).canvasColor,
                ),
          ),
        ),
        onTap: () {
          notesModel.entityBeingEdited.color = color;
          notesModel.setColor(color);
        },
      );
    }).toList();
  }

  Color _colorFromString(String color) {
    switch (color) {
      case 'red':
        return Colors.red[100]!;
      case 'green':
        return Colors.green[100]!;
      case 'blue':
        return Colors.lightBlue[100]!;
      case 'yellow':
        return Colors.yellow[100]!;
      case 'grey':
        return Colors.grey[200]!;
      case 'purple':
        return Colors.purple[100]!;
      default:
        return Colors.white;
    }
  }

  void _save(BuildContext inContext, NotesModel inModel) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (inModel.entityBeingEdited.id == 0) {
      await NotesDBWorker.db.create(notesModel.entityBeingEdited);
    } else {
      await NotesDBWorker.db.update(notesModel.entityBeingEdited);
    }

    notesModel.loadData("notes", NotesDBWorker.db);
    inModel.setStackIndex(0);

    if (inContext.mounted) {
      ScaffoldMessenger.of(inContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text("Заметка сохранена"),
        ),
      );
    }
  }
}
