import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:path/path.dart";
import "package:scoped_model/scoped_model.dart";
import "package:image_picker/image_picker.dart";
import "../utils.dart" as utils;
import "contactsdbworker.dart";
import "contactsmodel.dart" show ContactsModel, contactsModel;

class ContactsEntry extends StatelessWidget {

  final TextEditingController _nameEditingController = TextEditingController();
  final TextEditingController _phoneEditingController = TextEditingController();
  final TextEditingController _emailEditingController = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  ContactsEntry({super.key}) {
    _nameEditingController.addListener(() {
      contactsModel.entityBeingEdited.name = _nameEditingController.text;
    });
    _phoneEditingController.addListener(() {
      contactsModel.entityBeingEdited.phone = _phoneEditingController.text;
    });
    _emailEditingController.addListener(() {
      contactsModel.entityBeingEdited.email = _emailEditingController.text;
    });
  }

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    _nameEditingController.text = contactsModel.entityBeingEdited.name;
    _phoneEditingController.text = contactsModel.entityBeingEdited.phone;
    _emailEditingController.text = contactsModel.entityBeingEdited.email;

    File avatarFile = File(join(utils.docsDir!.path, "avatar"));
    if (!avatarFile.existsSync() && contactsModel.entityBeingEdited.id != null) {
      avatarFile = File(join(utils.docsDir!.path, contactsModel.entityBeingEdited.id.toString()));
    }

    return ScopedModel(
      model: contactsModel,
      child: ScopedModelDescendant<ContactsModel>(
        builder: (BuildContext inContext, Widget? inChild, ContactsModel inModel) {
          return Scaffold(
            bottomNavigationBar: Padding(
              padding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              child: Row(
                children: [
                  TextButton(
                    child: Text("Отмена"),
                    onPressed: () {
                      File avatarFile = File(join(utils.docsDir!.path, "avatar"));
                      if (avatarFile.existsSync()) {
                        avatarFile.deleteSync();
                      }
                      FocusScope.of(inContext).requestFocus(FocusNode());
                      inModel.setStackIndex(0);
                    },
                  ),
                  Spacer(),
                  TextButton(
                    child: Text("Сохранить"),
                    onPressed: () {
                      _save(inContext, inModel);
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
                    title: avatarFile.existsSync()
                        ? Image.file(avatarFile)
                        : Text("Нет изображения аватара"),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () => _selectAvatar(inContext),
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.person),
                    title: TextFormField(
                      decoration: InputDecoration(hintText: "Имя"),
                      controller: _nameEditingController,
                      validator: (String? inValue) {
                        if (inValue == null || inValue.isEmpty) {
                          return "Пожалуйста, введите имя";
                        }
                        return null;
                      },
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.phone),
                    title: TextFormField(
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(hintText: "Телефон"),
                      controller: _phoneEditingController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.email),
                    title: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(hintText: "Электронная почта"),
                      controller: _emailEditingController,
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.today),
                    title: Text("День рождения"),
                    subtitle: Text(contactsModel.chosenDate),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      color: Colors.blue,
                      onPressed: () async {
                        String? chosenDate = await utils.selectDate(
                          inContext,
                          contactsModel,
                          contactsModel.entityBeingEdited.birthday,
                        );
                        if (chosenDate != null) {
                          contactsModel.entityBeingEdited.birthday = chosenDate;
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

  Future<void> _selectAvatar(BuildContext inContext) async {
    return showDialog(
      context: inContext,
      builder: (BuildContext inDialogContext) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(5, 0, 5, 5)),
                GestureDetector(
                  child: Text("Сделать фото"),
                  onTap: () async {
                    var cameraImage = await ImagePicker().pickImage(source: ImageSource.camera);
                    if (cameraImage != null) {
                      cameraImage.saveTo(join(utils.docsDir!.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    if (inDialogContext.mounted) {
                      Navigator.of(inDialogContext).pop();
                    }
                  },
                ),
                Padding(padding: EdgeInsets.all(10)),
                GestureDetector(
                  child: Text("Выбрать из галереи"),
                  onTap: () async {
                    var galleryImage = await ImagePicker().pickImage(source: ImageSource.gallery);
                    if (galleryImage != null) {
                      galleryImage.saveTo(join(utils.docsDir!.path, "avatar"));
                      contactsModel.triggerRebuild();
                    }
                    if (inDialogContext.mounted) {
                      Navigator.of(inDialogContext).pop();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _save(BuildContext inContext, ContactsModel inModel) async {
    if (!_formKey.currentState!.validate()) return;

    int id;
    if (inModel.entityBeingEdited.id == null || inModel.entityBeingEdited.id == 0) {
      id = await ContactsDBWorker.db.create(contactsModel.entityBeingEdited);
    } else {
      id = contactsModel.entityBeingEdited.id!;
      await ContactsDBWorker.db.update(contactsModel.entityBeingEdited);
    }

    File avatarFile = File(join(utils.docsDir!.path, "avatar"));
    if (avatarFile.existsSync()) {
      avatarFile.renameSync(join(utils.docsDir!.path, id.toString()));
    }

    contactsModel.loadData("contacts", ContactsDBWorker.db);
    inModel.setStackIndex(0);

    if (inContext.mounted) {
      ScaffoldMessenger.of(inContext).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          content: Text("Контакт сохранён"),
        ),
      );
    }
  }
}
