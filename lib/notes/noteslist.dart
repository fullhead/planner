import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "notesdbworker.dart";
import "notesmodel.dart" show Note, NotesModel, notesModel;


class NotesList extends StatelessWidget {
  const NotesList({super.key});

  /// Метод build() для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext inContext, Widget? inChild, NotesModel inModel) {
              return Scaffold(
                  floatingActionButton: FloatingActionButton(
                      child: Icon(Icons.add, color: Colors.black),
                      onPressed: () async {
                        notesModel.entityBeingEdited = Note();
                        notesModel.setColor('');
                        notesModel.setStackIndex(1);

                      }),
                  body: ListView.builder(
                      itemCount: notesModel.entityList.length,
                      itemBuilder: (BuildContext inBuildContext, int inIndex) {
                        Note note = notesModel.entityList[inIndex];
                        Color color = Colors.white;
                        switch (note.color) {
                          case "red": color = Colors.red[100]!; break; // Мягкий пастельный красный.
                          case "green": color = Colors.green[100]!; break; // Мягкий пастельный зеленый.
                          case "blue": color = Colors.lightBlue[100]!; break; // Мягкий светло-голубой.
                          case "yellow": color = Colors.yellow[100]!; break; // Мягкий пастельный желтый.
                          case "grey": color = Colors.grey[200]!; break; // Светло-серый.
                          case "purple": color = Colors.purple[100]!; break; // Мягкий пастельный фиолетовый.
                        }
                        return Container(
                          padding: EdgeInsets.fromLTRB(5, 5, 5, 5),
                          child: Slidable(
                            key: ValueKey(note.id),
                            endActionPane: ActionPane(
                              motion: DrawerMotion(),
                              extentRatio: 0.25,
                              children: [
                                SlidableAction(
                                  onPressed: (context) => _deleteNote(context, note),
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
                              color: color,
                              child: ListTile(
                                title: Text(
                                  note.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 5.0),
                                  child: Text(
                                    note.content,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  notesModel.entityBeingEdited = await NotesDBWorker.db.get(note.id);
                                  notesModel.setColor(notesModel.entityBeingEdited.color);
                                  notesModel.setStackIndex(1);
                                },
                              ),
                            ),
                          ),
                        );
                      })
              );
            })
    );
  }

  Future _deleteNote(BuildContext inContext, Note inNote) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: Text("Удалить заметку"),
          content: Text("Вы уверены, что хотите удалить '${inNote.title}'?"),
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
                await NotesDBWorker.db.delete(inNote.id);
                if (inAlertContext.mounted) {
                  Navigator.of(inAlertContext).pop();
                }
                if (inAlertContext.mounted) {
                  ScaffoldMessenger.of(inAlertContext).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Заметка удалена"),
                    ),
                  );
                }
                notesModel.loadData("notes", NotesDBWorker.db);
              },
            ),
          ],
        );
      },
    );
  }
}
