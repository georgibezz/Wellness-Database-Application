import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:rxdart/rxdart.dart';
import 'package:september_twenty_nine_user/utils/objectbox.store.dart';

import '../entities/user.entity.dart';
import '../objectbox.g.dart';

class AuthService {
late final Box<User> _userBox;
final PublishSubject<User?> _authStateSubject = PublishSubject<User?>();

AuthService() {
  ObjectBox.getInstance().then((ObjectBox objectBox) {
    _userBox = objectBox.getUserBox();
  });
}

Stream<User?> get authStateChanges => _authStateSubject.stream;

Future<User?> signInWithEmailAndPassword(String email, String password) async {
  final users = _userBox.query(User_.email.equals(email)).build().find();
  if (users.isNotEmpty) {
    final user = users.first;
    if (_validatePassword(password, user.passwordHash)) {
      _authStateSubject.add(user);
      return user;
    }
  }
  return null;
}

  Future<User?> registerWithEmailAndPassword(String name, String email, String password) async {
    final existingUsers = _userBox.query(User_.email.equals(email)).build().find();
    if (existingUsers.isEmpty) {
      final passwordHash = _hashPassword(password);
      final newUser = User( name: name, email: email, passwordHash: passwordHash);
      _userBox.put(newUser);
      _authStateSubject.add(newUser);
      return newUser;
    }
    return null;
  }

  bool accountExists(String email) {
    final users = _userBox.query(User_.email.equals(email)).build().find();
    return users.isNotEmpty;
  }

  bool _validatePassword(String password, String hash) {
    final inputHash = _hashPassword(password);
    return inputHash == hash;
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }
}
