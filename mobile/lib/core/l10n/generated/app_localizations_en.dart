// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Delivery Tracker';

  @override
  String get navDeliveries => 'Deliveries';

  @override
  String get navSyncQueue => 'Sync Queue';

  @override
  String get navSettings => 'Settings';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get offlineBannerTitle => 'You\'re Offline';

  @override
  String get offlineBannerBody =>
      'No internet connection. Actions are saved locally and will sync automatically when back online.';

  @override
  String get backOnline => 'Back online — synchronizing pending actions...';

  @override
  String get deliveriesSearching => 'Searching for nearby deliveries...';

  @override
  String get searchHint => 'Search by order number or customer name...';

  @override
  String get filterAll => 'All';

  @override
  String get filterPending => 'Pending';

  @override
  String get filterDelivered => 'Delivered';

  @override
  String get filterFailed => 'Failed';

  @override
  String get deliveryStatusPending => 'Pending';

  @override
  String get deliveryStatusDelivered => 'Delivered';

  @override
  String get deliveryStatusFailed => 'Failed';

  @override
  String get syncStatusSynced => 'Synced';

  @override
  String get syncStatusWaitingToSync => 'Waiting to sync';

  @override
  String get syncStatusSyncing => 'Syncing...';

  @override
  String get syncStatusFailedToSync => 'Failed to sync';

  @override
  String get paymentCash => 'Cash';

  @override
  String get paymentInstapay => 'InstaPay';

  @override
  String get emptyDeliveriesTitle => 'No Deliveries Assigned';

  @override
  String get emptyDeliveriesBody =>
      'You have no active deliveries assigned at the moment.';

  @override
  String get noSearchResults => 'No deliveries match your search or filter.';

  @override
  String get errorLoadDeliveries => 'Failed to load deliveries. Tap to retry.';

  @override
  String get retry => 'Retry';

  @override
  String get retryAll => 'Retry All';

  @override
  String get detailsTitle => 'Delivery Details';

  @override
  String get customerInfo => 'Customer Information';

  @override
  String get deliveryAddress => 'Delivery Address';

  @override
  String get amountDue => 'Amount Due';

  @override
  String get recipientNameLabel => 'Recipient Name';

  @override
  String get recipientNameHint => 'Enter the recipient\'s name';

  @override
  String get recipientNameRequired =>
      'Recipient name is required (at least 2 characters)';

  @override
  String get noteLabel => 'Note (Optional)';

  @override
  String get noteHint => 'Add delivery note or landmark...';

  @override
  String get photoTitle => 'Photo Proof';

  @override
  String get photoHint => 'Capture delivery photo proof (optional)';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Photo Gallery';

  @override
  String get confirmDelivery => 'Confirm Delivery';

  @override
  String get confirmFailure => 'Confirm Failure';

  @override
  String get failureReasonLabel => 'Failure Reason';

  @override
  String get failureReasonRequired => 'Please select a failure reason';

  @override
  String get reasonCustomerUnavailable => 'Customer unavailable';

  @override
  String get reasonWrongAddress => 'Wrong address';

  @override
  String get reasonCustomerRefused => 'Customer refused';

  @override
  String get reasonDamagedPackage => 'Damaged package';

  @override
  String get reasonOther => 'Other reason';

  @override
  String get markDelivered => 'Mark as Delivered';

  @override
  String get markFailed => 'Mark as Failed';

  @override
  String get actionsFrozenWhileSync =>
      'Action is currently syncing. Please wait.';

  @override
  String get syncQueueTitle => 'Sync Queue';

  @override
  String get syncQueuePendingTab => 'Pending';

  @override
  String get syncQueueFailedTab => 'Failed';

  @override
  String get emptyPendingQueue => 'No pending sync actions 🎉';

  @override
  String get emptyFailedQueue => 'No failed sync actions';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get language => 'Language';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get aboutVersion => 'Delivery Tracker v1.0.0';

  @override
  String get deliveryNotFound => 'Delivery not found';

  @override
  String get copyPhone => 'Copy Phone';

  @override
  String get phoneCopied => 'Phone number copied to clipboard';

  @override
  String get callCustomer => 'Call';

  @override
  String get deliveredBy => 'Delivered by';

  @override
  String get deliveredOrderBanner =>
      'This order has been successfully delivered.';

  @override
  String get failedOrderBanner => 'This delivery was marked as failed.';

  @override
  String get deliveryCompletedLocally =>
      'Delivery recorded and queued for sync.';

  @override
  String get deliveryFailedLocally =>
      'Delivery failure recorded and queued for sync.';

  @override
  String get removePhoto => 'Remove photo';

  @override
  String get chooseSource => 'Choose image source';

  @override
  String get photoAttachSuccess => 'Photo attached successfully';

  @override
  String get actionTypeComplete => 'Delivery Completion';

  @override
  String get actionTypeFail => 'Delivery Failure';

  @override
  String get retries => 'Retries';

  @override
  String get orderPrefix => 'Order #';

  @override
  String get viewDetails => 'View Details';
}
