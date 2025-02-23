
# Планировщик

**Планировщик** — это многофункциональное мобильное приложение, разработанное на платформе Flutter. Приложение позволяет:
- Планировать и управлять встречами;
- Вести записи в виде заметок;
- Организовывать задачи и отслеживать их выполнение;
- Хранить и редактировать контакты.

Приложение использует локальную базу данных (sqflite) для сохранения данных и поддерживает русскую локализацию.

---

## Содержание

- [Особенности](#особенности)
- [Структура проекта](#структура-проекта)
- [Установка и запуск](#установка-и-запуск)
- [Использование](#использование)
- [Зависимости](#зависимости)
- [Лицензия](#лицензия)
- [Полезные ссылки](#полезные-ссылки)
- [Контакты разработчика](#контакты-разработчика)

---

## Особенности

| Функциональность         | Описание                                                                                                                                                                 |
|--------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| **Встречи**              | Создание, редактирование и удаление встреч. Выбор даты и времени для встречи с форматированием согласно локали.                                                            |
| **Заметки**              | Создание и редактирование заметок с возможностью выбора цвета для выделения.                                                                                              |
| **Задачи**               | Управление задачами с возможностью отметить выполнение (через Checkbox) и задать дату выполнения.                                                                         |
| **Контакты**             | Добавление, редактирование и удаление контактов. Возможность выбора и сохранения аватаров, а также указания дня рождения.                                                    |
| **Локализация**          | Приложение полностью локализовано на русский язык (ru_RU).                                                                                                               |
| **База данных**          | Использование библиотеки **sqflite** для CRUD-операций с локальной базой данных, что обеспечивает быструю работу и сохранение данных на устройстве пользователя.      |
| **Интерфейс**            | Современный интерфейс с использованием пакета **flutter_slidable** для удобного удаления элементов из списков, а также реализация TabBar для перехода между разделами.  |
| **Управление состоянием**| Использование паттерна **ScopedModel** для управления состоянием и обновления данных в реальном времени.                                                                     |

---

## Структура проекта

Проект разбит на несколько модулей, каждый из которых отвечает за свою функциональность:

| Модуль          | Файлы                                                                                                                        | Описание                                                                                                 |
|-----------------|------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------|
| **Встречи**     | `appointments.dart`, `appointmentsdbworker.dart`, `appointmentsentry.dart`, `appointmentslist.dart`, `appointmentsmodel.dart`  | Модуль для планирования и управления встречами. Отображение списка встреч, редактирование и CRUD-операции.  |
| **Контакты**    | `contacts.dart`, `contactsdbworker.dart`, `contactsentry.dart`, `contactslist.dart`, `contactsmodel.dart`                    | Модуль для хранения контактов. Включает функционал редактирования контактов, загрузки аватаров и удаление записей. |
| **Заметки**     | `notes.dart`, `notesdbworker.dart`, `notesentry.dart`, `noteslist.dart`, `notesmodel.dart`                                    | Модуль для создания заметок. Реализована возможность выбора цвета заметки и форматированное отображение информации.      |
| **Задачи**      | `tasks.dart`, `tasksdbworker.dart`, `tasksentry.dart`, `taskslist.dart`, `tasksmodel.dart`                                    | Модуль для управления задачами. Возможность отметить выполнение, установить дату выполнения и редактировать описание.      |
| **Общие файлы** | `basemodel.dart`, `main.dart`, `utils.dart`, `pubspec.yaml`                                                                 | Основной файл приложения, утилиты, базовая модель для управления состоянием и описание зависимостей проекта.              |

---

## Установка и запуск

1. **Клонирование репозитория**

   ```bash
   git clone https://github.com/your_username/planner.git
   cd planner
   ```

2. **Установка зависимостей**

   Убедитесь, что у вас установлен Flutter SDK. Затем выполните команду:

   ```bash
   flutter pub get
   ```

3. **Запуск приложения**

   Для запуска приложения на эмуляторе или подключённом устройстве выполните:

   ```bash
   flutter run
   ```

---

## Использование

При запуске приложение отображает четыре вкладки:
- **Встречи**: Позволяет планировать и редактировать встречи. При выборе встречи открывается форма для редактирования с возможностью задать заголовок, описание, дату и время.
- **Заметки**: Позволяет создавать заметки. В заметках можно выбрать цвет, который будет отображаться в списке.
- **Задачи**: Отображает список задач с возможностью отметки выполнения и редактирования описания задачи. Дата выполнения форматируется для удобства.
- **Контакты**: Управление контактами с возможностью добавления, редактирования и удаления. Реализована поддержка загрузки аватара для контакта.

Каждый модуль использует стандартные CRUD-операции, выполняемые через базу данных **sqflite**, что позволяет сохранять данные локально на устройстве.

---

## Зависимости

Приложение построено с использованием следующих пакетов:

- [**flutter_localizations**](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html) — локализация для Flutter.
- [**scoped_model**](https://pub.dev/packages/scoped_model) — управление состоянием.
- [**sqflite**](https://pub.dev/packages/sqflite) — работа с SQLite базой данных.
- [**path_provider**](https://pub.dev/packages/path_provider) — доступ к файловой системе устройства.
- [**flutter_slidable**](https://pub.dev/packages/flutter_slidable) — реализация слайдера для удаления элементов.
- [**intl**](https://pub.dev/packages/intl) — интернационализация и форматирование дат.
- [**image_picker**](https://pub.dev/packages/image_picker) — выбор изображений для аватаров.
- [**flutter_calendar_carousel**](https://pub.dev/packages/flutter_calendar_carousel) — календарь для выбора дат (при необходимости).

Полный список зависимостей указан в файле [pubspec.yaml](pubspec.yaml).

---

## Лицензия

Этот проект не предназначен для публикации на [pub.dev](https://pub.dev) и распространяется под лицензией, указанной в файле LICENSE (если применимо).

---

## Полезные ссылки

- [Документация Flutter](https://docs.flutter.dev/)
- [Руководство по работе с базой данных sqflite](https://pub.dev/packages/sqflite)
- [Scoped Model на GitHub](https://github.com/brianegan/scoped_model)
- [Интернационализация и локализация в Flutter](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

---

## Контакты разработчика

Если у вас есть вопросы или предложения, пожалуйста, свяжитесь с разработчиком проекта по адресу: [your_email@example.com](mailto:your_email@example.com).

---

*Спасибо за использование Планировщика!*
```
