import "dart:io";
import "package:flutter/material.dart";
import "package:path_provider/path_provider.dart";
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import "appointments/appointments.dart";
import "contacts/contacts.dart";
import "notes/notes.dart";
import "tasks/tasks.dart";
import "utils.dart" as utils;


void main() {
  startMeUp() async {
    WidgetsFlutterBinding.ensureInitialized();
    await initializeDateFormatting('ru_RU', null);
    Directory docsDir = await getApplicationDocumentsDirectory();
    utils.docsDir = docsDir;
    runApp(Planner());
  }
  startMeUp();
}


class Planner extends StatelessWidget {
  const Planner({super.key});

  /// Метод для построения виджета.
  @override
  Widget build(BuildContext inContext) {
    return MaterialApp(
      locale: Locale('ru', 'RU'),
      supportedLocales: [Locale('ru', 'RU'),],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("Планировщик"),
            bottom: TabBar(
              tabs: [
                Tab(icon: Icon(Icons.event), text: "Встречи"), // Вкладка для встреч.
                Tab(icon: Icon(Icons.note_outlined), text: "Заметки"), // Вкладка для заметок.
                Tab(icon: Icon(Icons.assignment_turned_in_outlined), text: "Задачи"), // Вкладка для задач.
                Tab(icon: Icon(Icons.perm_contact_calendar_outlined), text: "Контакты") // Вкладка для контактов.
              ],
            ),
          ),
          body: TabBarView(
            children: [Appointments(), Notes(), Tasks(), Contacts()],
          ),
        ),
      ),
    );
  }
}
