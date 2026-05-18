import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/case_model.dart';
import '../models/user_model.dart';

part 'auth_service.dart';
part 'file_service.dart';
part 'notification_service.dart';
part 'storage_service.dart';

final locator = GetIt.instance;

Future<void> initializeDependencies() async {
  await locator.reset();
  locator
    ..registerLazySingleton(() => AuthService._())
    ..registerLazySingleton(() => StorageService._())
    ..registerLazySingleton(() => NotificationService._())
    ..registerLazySingleton(() => FileService._());
}
