import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../features/delivery/domain/entities/delivery_action.dart';
import '../../features/delivery/domain/entities/delivery_entity.dart';
import 'adapters/delivery_action_adapter.dart';
import 'adapters/delivery_adapter.dart';
import 'hive_boxes.dart';

/// Injectable service managing the Hive persistence engine lifecycle,
/// adapter registrations, and typed box instances.
@lazySingleton
class LocalStorageService {
  Box<DeliveryEntity>? _deliveriesBox;
  Box<DeliveryAction>? _pendingActionsBox;
  bool _isInitialized = false;

  LocalStorageService();

  /// Named constructor for testing with mock or pre-opened boxes.
  LocalStorageService.test({
    Box<DeliveryEntity>? deliveriesBox,
    Box<DeliveryAction>? pendingActionsBox,
  })  : _deliveriesBox = deliveriesBox,
        _pendingActionsBox = pendingActionsBox,
        _isInitialized = deliveriesBox != null && pendingActionsBox != null;

  /// Returns whether Hive boxes have been opened and are ready for operations.
  bool get isInitialized =>
      _isInitialized &&
      (_deliveriesBox?.isOpen ?? false) &&
      (_pendingActionsBox?.isOpen ?? false);

  /// Provides typed access to the opened deliveries box.
  Box<DeliveryEntity> get deliveriesBox {
    if (_deliveriesBox == null || !_deliveriesBox!.isOpen) {
      throw StateError(
        'LocalStorageService: deliveriesBox is not open. Call init() first.',
      );
    }
    return _deliveriesBox!;
  }

  /// Provides typed access to the opened pending actions box.
  Box<DeliveryAction> get pendingActionsBox {
    if (_pendingActionsBox == null || !_pendingActionsBox!.isOpen) {
      throw StateError(
        'LocalStorageService: pendingActionsBox is not open. Call init() first.',
      );
    }
    return _pendingActionsBox!;
  }

  /// Initializes Hive storage directory, registers type adapters, and opens default boxes.
  ///
  /// In tests, provide a custom [path] to a temporary directory.
  Future<void> init({String? path}) async {
    if (isInitialized) return;

    if (path != null) {
      Hive.init(path);
    } else {
      final appDir = await getApplicationDocumentsDirectory();
      Hive.init(appDir.path);
    }

    registerAdapters();

    _deliveriesBox =
        await Hive.openBox<DeliveryEntity>(HiveBoxes.deliveriesBox);
    _pendingActionsBox =
        await Hive.openBox<DeliveryAction>(HiveBoxes.pendingActionsBox);
    _isInitialized = true;
  }

  /// Safely registers domain type adapters if not already present in the Hive registry.
  static void registerAdapters() {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(DeliveryAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(DeliveryActionAdapter());
    }
  }

  /// Clears all entries from both cached deliveries and pending actions.
  Future<void> clearAll() async {
    if (_deliveriesBox?.isOpen ?? false) {
      await _deliveriesBox!.clear();
    }
    if (_pendingActionsBox?.isOpen ?? false) {
      await _pendingActionsBox!.clear();
    }
  }

  /// Closes all opened boxes and resets the initialization state.
  Future<void> close() async {
    if (_deliveriesBox?.isOpen ?? false) {
      await _deliveriesBox!.close();
    }
    if (_pendingActionsBox?.isOpen ?? false) {
      await _pendingActionsBox!.close();
    }
    _isInitialized = false;
  }
}
