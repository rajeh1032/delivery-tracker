import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:delivery_tracker/core/helpers/customer_location_helper.dart';
import 'package:delivery_tracker/core/utils/constants.dart';

void main() {
  group('CustomerLocationHelper', () {
    test('returns explicit coordinates when provided', () {
      final coords = CustomerLocationHelper.getCoordinates(
        address: 'Salmiya, Block 4',
        latitude: 25.1234,
        longitude: 55.4321,
      );

      expect(coords.latitude, 25.1234);
      expect(coords.longitude, 55.4321);
    });

    test('resolves Salmiya coordinates from address', () {
      final coords = CustomerLocationHelper.getCoordinates(
        address: 'Salmiya, Block 4, Street 12',
      );

      expect(coords.latitude, 29.3344);
      expect(coords.longitude, 48.0828);
    });

    test('resolves Hawally coordinates from address', () {
      final coords = CustomerLocationHelper.getCoordinates(
        address: 'Hawally, Block 2, Street 5',
      );

      expect(coords.latitude, 29.3364);
      expect(coords.longitude, 48.0266);
    });

    test('resolves Sharq/Kuwait City coordinates from address', () {
      final coords = CustomerLocationHelper.getCoordinates(
        address: 'Kuwait City, Sharq, Block 1, Tower 3',
      );

      expect(coords.latitude, 29.3820);
      expect(coords.longitude, 47.9890);
    });

    test('resolves Farwaniya coordinates from address', () {
      final coords = CustomerLocationHelper.getCoordinates(
        address: 'Farwaniya, Block 3, Street 20',
      );

      expect(coords.latitude, 29.2780);
      expect(coords.longitude, 47.9580);
    });

    test('resolves Arabic address keyword (السالمية)', () {
      final coords = CustomerLocationHelper.getCoordinates(
        address: 'شارع سالم المبارك، السالمية',
      );

      expect(coords.latitude, 29.3344);
      expect(coords.longitude, 48.0828);
    });

    test('returns default Kuwait center for unknown address or empty address', () {
      final coordsEmpty = CustomerLocationHelper.getCoordinates(address: '');
      expect(coordsEmpty, CustomerLocationHelper.defaultCoordinates);

      final coordsNull = CustomerLocationHelper.getCoordinates(address: null);
      expect(coordsNull, CustomerLocationHelper.defaultCoordinates);

      final coordsUnknown = CustomerLocationHelper.getCoordinates(
        address: 'Random Unknown Place 12345',
      );
      expect(coordsUnknown, CustomerLocationHelper.defaultCoordinates);
    });

    test('googleMapsApiKey reads from environment safely without throwing', () {
      expect(CustomerLocationHelper.googleMapsApiKey, isA<String>());
    });

    test('googleMapsApiKey returns loaded key when dotenv is initialized', () {
      dotenv.loadFromString(
        envString: '${AppConstants.googleMapsApiKey}=test_maps_key',
      );
      expect(CustomerLocationHelper.googleMapsApiKey, 'test_maps_key');
      dotenv.clean();
    });
  });
}
