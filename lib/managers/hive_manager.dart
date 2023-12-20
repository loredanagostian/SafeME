import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:safe_me/models/account.dart';

class HiveManager {
  late Box<Account> accountBox;
  late Box<UserCredential> userBox;
  static final instance = HiveManager._internal();

  factory HiveManager() {
    return instance;
  }

  HiveManager._internal();

  Future<void> initHiveManager() async {
    Hive.registerAdapter(AccountAdapter());

    accountBox = await Hive.openBox('accounts');
    userBox = await Hive.openBox('users');
  }
}
