import "dart:io";
import "package:flutter/material.dart";
import "package:intl/intl.dart";
import "basemodel.dart";


Directory? docsDir;

Future<String?> selectDate(BuildContext inContext, BaseModel inModel, String? inDateString) async {

  DateTime initialDate = DateTime.now();
  if (inDateString != null && inDateString.isNotEmpty) {
    try {
      List<String> dateParts = inDateString.split(",");
      if (dateParts.length == 3) {

        int year = int.parse(dateParts[0]);
        int month = int.parse(dateParts[1]);
        int day = int.parse(dateParts[2]);

        initialDate = DateTime(year, month, day);
      }
    } catch (e) {
      initialDate = DateTime.now();
    }
  }

  DateTime? picked = await showDatePicker(
    context: inContext,
    initialDate: initialDate,
    firstDate: DateTime(1900),
    lastDate: DateTime(2100),
    locale: const Locale('ru', 'RU'),
  );

  if (picked != null) {

    inModel.setChosenDate(DateFormat.yMMMMd("ru_RU").format(picked.toLocal()));
    return "${picked.year},${picked.month},${picked.day}";
  }

  return null;
}


