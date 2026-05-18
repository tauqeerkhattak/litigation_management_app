import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:litigation_management_app/exceptions/app_exception.dart';

import '../main.dart';

abstract class BaseViewModel<S> extends Notifier<S> {
  final S initialValue;

  BaseViewModel(this.initialValue);

  @override
  S build() {
    WidgetsBinding.instance.addPostFrameCallback((_) => init());
    ref.onDispose(dispose);
    return initialValue;
  }

  Future<T?> runSafely<T>(AsyncValueGetter<T> action) async {
    try {
      return await action.call();
    } on AppException catch (e, s) {
      log(e.toString(), stackTrace: s);
      handleError(e.message);
      return null;
    } catch (e, s) {
      log(e.toString(), stackTrace: s);
      handleError(e.toString());
      return null;
    }
  }

  @mustCallSuper
  void init() {
    log('INITIALIZING $runtimeType');
  }

  @mustCallSuper
  void dispose() {
    log('DISPOSING $runtimeType');
  }

  void handleError(String message) {
    log('ERROR: $message');
    ScaffoldMessenger.of(navigatorKey.currentContext!).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.red,
      ),
    );
  }
}
