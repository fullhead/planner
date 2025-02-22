import "../basemodel.dart";

class Contact {

  int id = 0;
  String name = '';
  String phone = '';
  String email = '';
  String birthday = '';

  @override
  String toString() {
    return "{ id=$id, name=$name, phone=$phone, email=$email, birthday=$birthday }";
  }
}

class ContactsModel extends BaseModel {

  late String phoneNumber;

  void setPhoneNumber(String inPhoneNumber) {
    phoneNumber = inPhoneNumber;
    notifyListeners();
  }

  void triggerRebuild() {
    notifyListeners();
  }
}

ContactsModel contactsModel = ContactsModel();
