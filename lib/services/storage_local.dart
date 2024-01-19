import 'package:shared_preferences/shared_preferences.dart';


Future<void> saveLocalData(int key, String value) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString(key.toString(), value);
}

Future<void> removeLocalData(int key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove(key.toString());
}

Future<String?> getLocalData(int key) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString(key.toString());
}

Future<bool> checkLocalStorage(int id, String value) async {
  String? storedValue = await getLocalData(id);
  return storedValue == value;
}

void removeDeprecatedKeys(events) async {
  /// Cleans up keys from passed events
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Set<int> ids = events.map((event) => event.id).toSet();
  for (String key in prefs.getKeys()) {
    if (!ids.contains(int.parse(key))) {
      await prefs.remove(key);
    }
  }
}
