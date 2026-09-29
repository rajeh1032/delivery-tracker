import 'package:delivery_tracker/core/helpers/shared_pref.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPrefHelper helper;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'existing_key': 'initial_value',
    });
    prefs = await SharedPreferences.getInstance();
    helper = SharedPrefHelper(prefs);
  });

  group('SharedPrefHelper', () {
    test('saveData and getData with String', () async {
      final success = await helper.saveData(key: 'str_key', val: 'hello');
      expect(success, isTrue);
      expect(helper.getData(key: 'str_key'), 'hello');
    });

    test('saveData and getData with int', () async {
      final success = await helper.saveData(key: 'int_key', val: 42);
      expect(success, isTrue);
      expect(helper.getData(key: 'int_key'), 42);
    });

    test('saveData and getData with double', () async {
      final success = await helper.saveData(key: 'double_key', val: 3.14);
      expect(success, isTrue);
      expect(helper.getData(key: 'double_key'), 3.14);
    });

    test('saveData and getData with bool', () async {
      final success = await helper.saveData(key: 'bool_key', val: true);
      expect(success, isTrue);
      expect(helper.getData(key: 'bool_key'), true);
    });

    test('saveData and getData with List<String>', () async {
      final success = await helper.saveData(
        key: 'list_key',
        val: ['a', 'b', 'c'],
      );
      expect(success, isTrue);
      expect(helper.getData(key: 'list_key'), ['a', 'b', 'c']);
    });

    test('removeData deletes key', () async {
      expect(helper.getData(key: 'existing_key'), 'initial_value');
      final removed = await helper.removeData(key: 'existing_key');
      expect(removed, isTrue);
      expect(helper.getData(key: 'existing_key'), isNull);
    });

    test('clearData removes all stored keys', () async {
      await helper.saveData(key: 'k1', val: 'v1');
      await helper.saveData(key: 'k2', val: 'v2');
      final cleared = await helper.clearData();
      expect(cleared, isTrue);
      expect(helper.getData(key: 'k1'), isNull);
      expect(helper.getData(key: 'k2'), isNull);
    });

    test('saveData throws ArgumentError for unsupported types', () {
      expect(
        () => helper.saveData(key: 'invalid_key', val: DateTime.now()),
        throwsA(isA<ArgumentError>()),
      );
    });

  });
}
