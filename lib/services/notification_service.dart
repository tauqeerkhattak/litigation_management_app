part of 'locator.dart';

class NotificationService {
  NotificationService._();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // ✅ v18 uses positional param, not named 'settings:'
    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
    );
  }

  Future<void> requestPermissions() async {
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    await androidImplementation?.requestNotificationsPermission();
    await androidImplementation?.requestExactAlarmsPermission();
  }

  Future<void> scheduleHearingReminder(
    int id,
    String title,
    DateTime hearingDate,
  ) async {
    final reminderDate = hearingDate.subtract(const Duration(days: 3));

    if (reminderDate.isBefore(DateTime.now())) return;

    // ✅ v18 uses positional params, not named params
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id: id,
      title: 'Upcoming Hearing Reminder',
      body:
          'Case: $title is scheduled for ${hearingDate.day}/${hearingDate.month}',
      scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'hearing_reminders',
          'Hearing Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
      // uiLocalNotificationDateInterpretation:
      // UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}

//muneeb

// class NotificationService {
//   NotificationService._();
//
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//
//   Future<void> init() async {
//     tz.initializeTimeZones();
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//
//     await flutterLocalNotificationsPlugin.initialize(
//       settings: initializationSettings,
//     );
//   }
//
//   Future<void> scheduleHearingReminder(
//     int id,
//     String title,
//     DateTime hearingDate,
//   ) async {
//     final reminderDate = hearingDate.subtract(const Duration(days: 3));
//
//     // Don't schedule if the reminder date is in the past
//     if (reminderDate.isBefore(DateTime.now())) return;
//
//     await flutterLocalNotificationsPlugin.zonedSchedule(
//       id: id,
//       title: 'Upcoming Hearing Reminder',
//       body:
//           'Case: $title is scheduled for ${hearingDate.day}/${hearingDate.month}',
//       scheduledDate: tz.TZDateTime.from(reminderDate, tz.local),
//       notificationDetails: const NotificationDetails(
//         android: AndroidNotificationDetails(
//           'hearing_reminders',
//           'Hearing Reminders',
//           importance: Importance.high,
//           priority: Priority.high,
//         ),
//       ),
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       matchDateTimeComponents: DateTimeComponents.dateAndTime,
//       // uiLocalNotificationDateInterpretation:
//       //     UILocalNotificationDateInterpretation.absoluteTime,
//     );
//   }
// }
