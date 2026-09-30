import 'package:hive/hive.dart';
import '../../features/delivery/domain/entities/delivery_action.dart';
import '../../features/delivery/domain/entities/delivery_entity.dart';

/// Centralized registry of Hive box names and strongly typed box accessors.
abstract final class HiveBoxes {
  /// Box storing cached [DeliveryEntity] domain records.
  static const String deliveriesBox = 'deliveries_box';

  /// Box storing durable offline [DeliveryAction] mutation intents.
  static const String pendingActionsBox = 'pending_actions_box';

  /// Typed accessor for the deliveries box.
  static Box<DeliveryEntity> get deliveries =>
      Hive.box<DeliveryEntity>(deliveriesBox);

  /// Typed accessor for the pending actions box.
  static Box<DeliveryAction> get pendingActions =>
      Hive.box<DeliveryAction>(pendingActionsBox);
}
