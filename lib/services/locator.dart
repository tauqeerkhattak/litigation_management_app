import 'dart:convert';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../models/case_model.dart';
import '../models/hearing.dart';
import '../models/user_model.dart';

part 'auth_service.dart';
part 'case_service.dart';
part 'file_service.dart';
part 'notification_service.dart';
part 'storage_service.dart';

final locator = GetIt.instance;

Future<void> initializeDependencies() async {
  await locator.reset();
  locator
    ..registerLazySingleton(() => AuthService._())
    ..registerLazySingleton(() => CaseService._())
    ..registerLazySingleton(() => StorageService._())
    ..registerLazySingleton(() => NotificationService._())
    ..registerLazySingleton(() => FileService._());
}
