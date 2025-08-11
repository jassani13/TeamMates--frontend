import 'package:base_code/package/config_packages.dart';

class AppPref {
  Future? _isPreferenceInstanceReady;
  late SharedPreferences _preferences;

  static final AppPref _instance = AppPref._internal();

  factory AppPref() => _instance;

  AppPref._internal() {
    _isPreferenceInstanceReady = SharedPreferences.getInstance().then((preferences) => _preferences = preferences);
  }

  Future? get isPreferenceReady => _isPreferenceInstanceReady;

  String get languageCode => _preferences.getString('languageCode') ?? '';

  set languageCode(String value) => _preferences.setString('languageCode', value);

  bool? get isDark => _preferences.getBool('isDark');

  set isDark(bool? value) => _preferences.setBool('isDark', value ?? false);

  bool? get isFirstTime => _preferences.getBool('isFirstTime');

  set isFirstTime(bool? value) => _preferences.setBool('isFirstTime', value ?? false);

  String? get token => _preferences.getString('token');

  set token(String? value) => _preferences.setString('token', value ?? "");


  String? get fcmToken => _preferences.getString('fcmToken');

  set fcmToken(String? value) => _preferences.setString('fcmToken', value ?? "");
  String? get role => _preferences.getString('role');

  set role(String? value) => _preferences.setString('role', value ?? "");

  String? get userPin => _preferences.getString('userPin');

  set userPin(String? value) => _preferences.setString('userPin', value ?? "");

  int? get userId => _preferences.getInt('userId');

  set userId(int? value) => _preferences.setInt('userId', value ?? 0);

  int? get playerCode => _preferences.getInt('playerCode');

  set playerCode(int? value) => _preferences.setInt('playerCode', value ?? 0);

  bool? get isLogin => _preferences.getBool('token');
  set isLogin(bool? value) => _preferences.setBool('token', value ?? false);

  bool? get isSmartAuthSet => _preferences.getBool('isSmartAuthSet');

  set isSmartAuthSet(bool? value) => _preferences.setBool('isSmartAuthSet', value ?? false);


  bool? get proUser => _preferences.getBool('proUser');

  set proUser(bool? value) => _preferences.setBool('proUser', value ?? false);

  set userModel(UserModel? user) {
    if (user == null) {
      _preferences.remove("user_model");
    } else {
      _preferences.setString("user_model", jsonEncode(user.toJson()));
    }
  }

  UserModel? get userModel {
    String? userData = _preferences.getString("user_model");
    if (userData != null && userData.isNotEmpty) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }

  String get userPhone => _preferences.getString('userEmail') ?? '';

  set userPhone(String value) => _preferences.setString('userEmail', value);

  void clear() async {
    _preferences.clear();
  }
}
