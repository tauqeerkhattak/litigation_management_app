import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
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
    } on FirebaseAuthException catch (e, s) {
      final message = _handleAuthException(e);
      log(message, stackTrace: s);
      handleError(message);
      return null;
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

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return e.message ?? 'Authentication failed.';
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
