import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "contactsdbworker.dart";
import "contactslist.dart";
import "contactsentry.dart";
import "contactsmodel.dart" show ContactsModel, contactsModel;

class Contacts extends StatelessWidget {
  Contacts({super.key}) {
    contactsModel.loadData("contacts", ContactsDBWorker.db);
  }

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder:
            (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          return IndexedStack(
            index: inModel.stackIndex,
            children: [
              ContactsList(),
              if (inModel.entityBeingEdited != null) ContactsEntry(),
              if (inModel.entityBeingEdited == null) Container(),
            ],
          );
        },
      ),
    );
  }
}
