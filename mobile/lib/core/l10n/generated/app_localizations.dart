import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Tracker'**
  String get appTitle;

  /// No description provided for @navDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get navDeliveries;

  /// No description provided for @navSyncQueue.
  ///
  /// In en, this message translates to:
  /// **'Sync Queue'**
  String get navSyncQueue;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @online.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @offlineBannerTitle.
  ///
  /// In en, this message translates to:
  /// **'You\'re Offline'**
  String get offlineBannerTitle;

  /// No description provided for @offlineBannerBody.
  ///
  /// In en, this message translates to:
  /// **'No internet connection. Actions are saved locally and will sync automatically when back online.'**
  String get offlineBannerBody;

  /// No description provided for @backOnline.
  ///
  /// In en, this message translates to:
  /// **'Back online — synchronizing pending actions...'**
  String get backOnline;

  /// No description provided for @deliveriesSearching.
  ///
  /// In en, this message translates to:
  /// **'Searching for nearby deliveries...'**
  String get deliveriesSearching;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by order number or customer name...'**
  String get searchHint;

  /// No description provided for @filterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// No description provided for @filterPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get filterPending;

  /// No description provided for @filterDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get filterDelivered;

  /// No description provided for @filterFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get filterFailed;

  /// No description provided for @deliveryStatusPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get deliveryStatusPending;

  /// No description provided for @deliveryStatusDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get deliveryStatusDelivered;

  /// No description provided for @deliveryStatusFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get deliveryStatusFailed;

  /// No description provided for @syncStatusSynced.
  ///
  /// In en, this message translates to:
  /// **'Synced'**
  String get syncStatusSynced;

  /// No description provided for @syncStatusWaitingToSync.
  ///
  /// In en, this message translates to:
  /// **'Waiting to sync'**
  String get syncStatusWaitingToSync;

  /// No description provided for @syncStatusSyncing.
  ///
  /// In en, this message translates to:
  /// **'Syncing...'**
  String get syncStatusSyncing;

  /// No description provided for @syncStatusFailedToSync.
  ///
  /// In en, this message translates to:
  /// **'Failed to sync'**
  String get syncStatusFailedToSync;

  /// No description provided for @paymentCash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get paymentCash;

  /// No description provided for @paymentInstapay.
  ///
  /// In en, this message translates to:
  /// **'InstaPay'**
  String get paymentInstapay;

  /// No description provided for @emptyDeliveriesTitle.
  ///
  /// In en, this message translates to:
  /// **'No Deliveries Assigned'**
  String get emptyDeliveriesTitle;

  /// No description provided for @emptyDeliveriesBody.
  ///
  /// In en, this message translates to:
  /// **'You have no active deliveries assigned at the moment.'**
  String get emptyDeliveriesBody;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No deliveries match your search or filter.'**
  String get noSearchResults;

  /// No description provided for @errorLoadDeliveries.
  ///
  /// In en, this message translates to:
  /// **'Failed to load deliveries. Tap to retry.'**
  String get errorLoadDeliveries;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @retryAll.
  ///
  /// In en, this message translates to:
  /// **'Retry All'**
  String get retryAll;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Delivery Details'**
  String get detailsTitle;

  /// No description provided for @customerInfo.
  ///
  /// In en, this message translates to:
  /// **'Customer Information'**
  String get customerInfo;

  /// No description provided for @deliveryAddress.
  ///
  /// In en, this message translates to:
  /// **'Delivery Address'**
  String get deliveryAddress;

  /// No description provided for @amountDue.
  ///
  /// In en, this message translates to:
  /// **'Amount Due'**
  String get amountDue;

  /// No description provided for @recipientNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Recipient Name'**
  String get recipientNameLabel;

  /// No description provided for @recipientNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the recipient\'s name'**
  String get recipientNameHint;

  /// No description provided for @recipientNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Recipient name is required (at least 2 characters)'**
  String get recipientNameRequired;

  /// No description provided for @noteLabel.
  ///
  /// In en, this message translates to:
  /// **'Note (Optional)'**
  String get noteLabel;

  /// No description provided for @noteHint.
  ///
  /// In en, this message translates to:
  /// **'Add delivery note or landmark...'**
  String get noteHint;

  /// No description provided for @photoTitle.
  ///
  /// In en, this message translates to:
  /// **'Photo Proof'**
  String get photoTitle;

  /// No description provided for @photoHint.
  ///
  /// In en, this message translates to:
  /// **'Capture delivery photo proof (optional)'**
  String get photoHint;

  /// No description provided for @camera.
  ///
  /// In en, this message translates to:
  /// **'Camera'**
  String get camera;

  /// No description provided for @gallery.
  ///
  /// In en, this message translates to:
  /// **'Photo Gallery'**
  String get gallery;

  /// No description provided for @confirmDelivery.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delivery'**
  String get confirmDelivery;

  /// No description provided for @confirmFailure.
  ///
  /// In en, this message translates to:
  /// **'Confirm Failure'**
  String get confirmFailure;

  /// No description provided for @failureReasonLabel.
  ///
  /// In en, this message translates to:
  /// **'Failure Reason'**
  String get failureReasonLabel;

  /// No description provided for @failureReasonRequired.
  ///
  /// In en, this message translates to:
  /// **'Please select a failure reason'**
  String get failureReasonRequired;

  /// No description provided for @reasonCustomerUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Customer unavailable'**
  String get reasonCustomerUnavailable;

  /// No description provided for @reasonWrongAddress.
  ///
  /// In en, this message translates to:
  /// **'Wrong address'**
  String get reasonWrongAddress;

  /// No description provided for @reasonCustomerRefused.
  ///
  /// In en, this message translates to:
  /// **'Customer refused'**
  String get reasonCustomerRefused;

  /// No description provided for @reasonDamagedPackage.
  ///
  /// In en, this message translates to:
  /// **'Damaged package'**
  String get reasonDamagedPackage;

  /// No description provided for @reasonOther.
  ///
  /// In en, this message translates to:
  /// **'Other reason'**
  String get reasonOther;

  /// No description provided for @markDelivered.
  ///
  /// In en, this message translates to:
  /// **'Mark as Delivered'**
  String get markDelivered;

  /// No description provided for @markFailed.
  ///
  /// In en, this message translates to:
  /// **'Mark as Failed'**
  String get markFailed;

  /// No description provided for @actionsFrozenWhileSync.
  ///
  /// In en, this message translates to:
  /// **'Action is currently syncing. Please wait.'**
  String get actionsFrozenWhileSync;

  /// No description provided for @syncQueueTitle.
  ///
  /// In en, this message translates to:
  /// **'Sync Queue'**
  String get syncQueueTitle;

  /// No description provided for @syncQueuePendingTab.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get syncQueuePendingTab;

  /// No description provided for @syncQueueFailedTab.
  ///
  /// In en, this message translates to:
  /// **'Failed'**
  String get syncQueueFailedTab;

  /// No description provided for @emptyPendingQueue.
  ///
  /// In en, this message translates to:
  /// **'No pending sync actions 🎉'**
  String get emptyPendingQueue;

  /// No description provided for @emptyFailedQueue.
  ///
  /// In en, this message translates to:
  /// **'No failed sync actions'**
  String get emptyFailedQueue;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get arabic;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @aboutVersion.
  ///
  /// In en, this message translates to:
  /// **'Delivery Tracker v1.0.0'**
  String get aboutVersion;

  /// No description provided for @deliveryNotFound.
  ///
  /// In en, this message translates to:
  /// **'Delivery not found'**
  String get deliveryNotFound;

  /// No description provided for @copyPhone.
  ///
  /// In en, this message translates to:
  /// **'Copy Phone'**
  String get copyPhone;

  /// No description provided for @phoneCopied.
  ///
  /// In en, this message translates to:
  /// **'Phone number copied to clipboard'**
  String get phoneCopied;

  /// No description provided for @callCustomer.
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get callCustomer;

  /// No description provided for @deliveredBy.
  ///
  /// In en, this message translates to:
  /// **'Delivered by'**
  String get deliveredBy;

  /// No description provided for @deliveredOrderBanner.
  ///
  /// In en, this message translates to:
  /// **'This order has been successfully delivered.'**
  String get deliveredOrderBanner;

  /// No description provided for @failedOrderBanner.
  ///
  /// In en, this message translates to:
  /// **'This delivery was marked as failed.'**
  String get failedOrderBanner;

  /// No description provided for @deliveryCompletedLocally.
  ///
  /// In en, this message translates to:
  /// **'Delivery recorded and queued for sync.'**
  String get deliveryCompletedLocally;

  /// No description provided for @deliveryFailedLocally.
  ///
  /// In en, this message translates to:
  /// **'Delivery failure recorded and queued for sync.'**
  String get deliveryFailedLocally;

  /// No description provided for @removePhoto.
  ///
  /// In en, this message translates to:
  /// **'Remove photo'**
  String get removePhoto;

  /// No description provided for @chooseSource.
  ///
  /// In en, this message translates to:
  /// **'Choose image source'**
  String get chooseSource;

  /// No description provided for @photoAttachSuccess.
  ///
  /// In en, this message translates to:
  /// **'Photo attached successfully'**
  String get photoAttachSuccess;

  /// No description provided for @actionTypeComplete.
  ///
  /// In en, this message translates to:
  /// **'Delivery Completion'**
  String get actionTypeComplete;

  /// No description provided for @actionTypeFail.
  ///
  /// In en, this message translates to:
  /// **'Delivery Failure'**
  String get actionTypeFail;

  /// No description provided for @retries.
  ///
  /// In en, this message translates to:
  /// **'Retries'**
  String get retries;

  /// No description provided for @orderPrefix.
  ///
  /// In en, this message translates to:
  /// **'Order #'**
  String get orderPrefix;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Details'**
  String get viewDetails;

  /// No description provided for @phoneInvalid.
  ///
  /// In en, this message translates to:
  /// **'Invalid phone number'**
  String get phoneInvalid;

  /// No description provided for @viewPhoto.
  ///
  /// In en, this message translates to:
  /// **'View Photo'**
  String get viewPhoto;

  /// No description provided for @cannotMakeCall.
  ///
  /// In en, this message translates to:
  /// **'Cannot make calls on this device'**
  String get cannotMakeCall;

  /// No description provided for @orderSummary.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orderSummary;

  /// No description provided for @compressingImage.
  ///
  /// In en, this message translates to:
  /// **'Optimizing image...'**
  String get compressingImage;

  /// No description provided for @snackbarSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get snackbarSuccess;

  /// No description provided for @snackbarError.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get snackbarError;

  /// No description provided for @snackbarWarning.
  ///
  /// In en, this message translates to:
  /// **'Attention'**
  String get snackbarWarning;

  /// No description provided for @snackbarInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get snackbarInfo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
