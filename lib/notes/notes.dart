import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "notesdbworker.dart";
import "noteslist.dart";
import "notesmodel.dart" show NotesModel, notesModel;
import "notesentry.dart";


class Notes extends StatelessWidget {

  Notes({super.key}) {
    notesModel.loadData("notes", NotesDBWorker.db);
  }

  /// Метод build() для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<NotesModel>(
        model: notesModel,
        child: ScopedModelDescendant<NotesModel>(
            builder: (BuildContext inContext, Widget? inChild, NotesModel inModel) {
              return IndexedStack(
                  index: inModel.stackIndex,
                  children: [
                    NotesList(),
                    if (inModel.entityBeingEdited != null) NotesEntry(),
                    if (inModel.entityBeingEdited == null) Container(),
                  ]
              );
            })
    );
  }
}
