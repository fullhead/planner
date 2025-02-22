import "dart:io";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "package:flutter_slidable/flutter_slidable.dart";
import "package:intl/intl.dart";
import "package:path/path.dart";
import "../utils.dart" as utils;
import "contactsdbworker.dart";
import "contactsmodel.dart" show Contact, ContactsModel, contactsModel;

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return ScopedModel<ContactsModel>(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.add, color: Colors.black),
              onPressed: () async {
                File avatarFile = File(join(utils.docsDir!.path, "avatar"));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                contactsModel.entityBeingEdited = Contact();
                contactsModel.setChosenDate(''); // Здесь устанавливаем пустую строку, а не null
                contactsModel.setStackIndex(1);
              },
            ),
            body: ListView.builder(
              itemCount: contactsModel.entityList.length,
              itemBuilder: (BuildContext inBuildContext, int inIndex) {
                Contact contact = contactsModel.entityList[inIndex];
                File avatarFile = File(join(utils.docsDir!.path, contact.id.toString()));
                bool avatarFileExists = avatarFile.existsSync();

                return Padding(
                  padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                  child: Column(
                    children: [
                      Slidable(
                        key: ValueKey(contact.id),
                        endActionPane: ActionPane(
                          motion: DrawerMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (context) => _deleteContact(inContext, contact),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Удалить',
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ],
                        ),
                        child: Card(
                          margin: EdgeInsets.zero,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigoAccent,
                              foregroundColor: Colors.white,
                              backgroundImage: avatarFileExists ? FileImage(avatarFile) : null,
                              child: avatarFileExists ? null : Text(contact.name.substring(0, 1).toUpperCase()),
                            ),
                            title: Text(contact.name),
                            subtitle: (contact.phone.isEmpty)
                                ? Text("Телефон не указан")
                                : Text(contact.phone),
                            onTap: () async {
                              File avatarFile = File(join(utils.docsDir!.path, "avatar"));
                              if (avatarFile.existsSync()) {
                                avatarFile.deleteSync();
                              }
                              contactsModel.entityBeingEdited = await ContactsDBWorker.db.get(contact.id);

                              // Исправлена ошибка: использование пустой строки для несуществующей даты
                              if (contactsModel.entityBeingEdited.birthday == "") {
                                contactsModel.setChosenDate(''); // Пустая строка, если день рождения не указан
                              } else {
                                try {
                                  List dateParts = contactsModel.entityBeingEdited.birthday.split(",");
                                  DateTime birthday = DateTime(
                                    int.parse(dateParts[0]),
                                    int.parse(dateParts[1]),
                                    int.parse(dateParts[2]),
                                  );
                                  contactsModel.setChosenDate(DateFormat.yMMMMd("ru_RU").format(birthday.toLocal()));
                                } catch (e) {
                                  if (kDebugMode) {
                                    print("Ошибка при разборе даты: $e");
                                  }
                                }
                              }

                              contactsModel.setStackIndex(1);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future _deleteContact(BuildContext inContext, Contact inContact) async {
    return showDialog(
      context: inContext,
      barrierDismissible: false,
      builder: (BuildContext inAlertContext) {
        return AlertDialog(
          title: const Text("Удалить контакт"),
          content: Text("Вы уверены, что хотите удалить '${inContact.name}'?"),
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
                File avatarFile = File(join(utils.docsDir!.path, inContact.id.toString()));
                if (avatarFile.existsSync()) {
                  avatarFile.deleteSync();
                }
                await ContactsDBWorker.db.delete(inContact.id);

                // Проверяем, что контекст ещё монтирован перед выполнением действий
                if (inAlertContext.mounted) {
                  Navigator.of(inAlertContext).pop();
                }
                if (inAlertContext.mounted) {
                  ScaffoldMessenger.of(inAlertContext).showSnackBar(
                    const SnackBar(
                      backgroundColor: Colors.red,
                      duration: Duration(seconds: 2),
                      content: Text("Контакт удалён"),
                    ),
                  );
                }
                contactsModel.loadData("contacts", ContactsDBWorker.db);
              },
            ),
          ],
        );
      },
    );
  }
}
