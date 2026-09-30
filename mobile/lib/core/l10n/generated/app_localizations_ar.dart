// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'طلبات التوصيل';

  @override
  String get navDeliveries => 'الطلبات';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get offlineBannerTitle => 'لا يوجد اتصال بالإنترنت';

  @override
  String get offlineBannerBody =>
      'تعديلاتك محفوظة على الجهاز. سنرسلها تلقائيًا عند عودة الاتصال.';

  @override
  String get backOnline => 'عاد الاتصال. جارٍ إرسال التحديثات المحفوظة…';

  @override
  String get deliveriesSearching => 'لا توجد طلبات للعرض حاليًا';

  @override
  String get searchHint => 'رقم الطلب أو اسم العميل';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPending => 'بانتظار التسليم';

  @override
  String get filterDelivered => 'تم التسليم';

  @override
  String get filterFailed => 'لم يتم التسليم';

  @override
  String get deliveryStatusPending => 'بانتظار التسليم';

  @override
  String get deliveryStatusDelivered => 'تم التسليم';

  @override
  String get deliveryStatusFailed => 'تعذّر التسليم';

  @override
  String get syncStatusSynced => 'تم حفظ التحديث';

  @override
  String get syncStatusWaitingToSync => 'بانتظار الإرسال';

  @override
  String get syncStatusSyncing => 'جارٍ إرسال التحديث…';

  @override
  String get syncStatusFailedToSync => 'لم يُرسل التحديث';

  @override
  String get paymentCash => 'نقدًا';

  @override
  String get paymentInstapay => 'إنستا باي';

  @override
  String get emptyDeliveriesTitle => 'لا توجد طلبات مسندة إليك';

  @override
  String get emptyDeliveriesBody => 'ستظهر طلباتك هنا عند إسنادها إليك.';

  @override
  String get noSearchResults => 'لا توجد طلبات تطابق البحث أو التصفية.';

  @override
  String get errorLoadDeliveries => 'لم نتمكن من تحميل الطلبات. حاول مرة أخرى.';

  @override
  String get retry => 'حاول مرة أخرى';

  @override
  String get retryAll => 'إعادة إرسال الكل';

  @override
  String get detailsTitle => 'تفاصيل الطلب';

  @override
  String get customerInfo => 'بيانات العميل';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get amountDue => 'المبلغ المستحق';

  @override
  String get recipientNameLabel => 'اسم المستلم';

  @override
  String get recipientNameHint => 'اسم من استلم الطلب';

  @override
  String get recipientNameRequired => 'اكتب اسم المستلم، حرفين على الأقل.';

  @override
  String get noteLabel => 'ملاحظة (اختياري)';

  @override
  String get noteHint => 'أضف تفاصيل تساعد على توثيق التسليم';

  @override
  String get photoTitle => 'صورة التسليم';

  @override
  String get photoHint => 'أرفق صورة للتسليم (اختياري)';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'معرض الصور';

  @override
  String get confirmDelivery => 'تأكيد التسليم';

  @override
  String get confirmFailure => 'تأكيد عدم التسليم';

  @override
  String get failureReasonLabel => 'سبب عدم التوصيل';

  @override
  String get failureReasonRequired => 'اختر سبب عدم التسليم.';

  @override
  String get reasonCustomerUnavailable => 'لم نتمكن من الوصول إلى العميل';

  @override
  String get reasonWrongAddress => 'العنوان غير صحيح';

  @override
  String get reasonCustomerRefused => 'رفض العميل الاستلام';

  @override
  String get reasonDamagedPackage => 'الشحنة تالفة';

  @override
  String get reasonOther => 'سبب آخر';

  @override
  String get markDelivered => 'تم التسليم';

  @override
  String get markFailed => 'تعذّر التسليم';

  @override
  String get actionsFrozenWhileSync => 'جارٍ إرسال التحديث. انتظر قليلًا.';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get aboutVersion => 'طلبات التوصيل — الإصدار 1.0.0';

  @override
  String get deliveryNotFound => 'هذا الطلب غير موجود';

  @override
  String get copyPhone => 'نسخ رقم الهاتف';

  @override
  String get phoneCopied => 'تم نسخ رقم الهاتف';

  @override
  String get callCustomer => 'اتصال';

  @override
  String get deliveredBy => 'استلم الطلب';

  @override
  String get deliveredOrderBanner => 'تم تسليم الطلب.';

  @override
  String get failedOrderBanner => 'لم يتم تسليم الطلب.';

  @override
  String get deliveryCompletedLocally =>
      'تم تسجيل التسليم. سنرسل التحديث عند توفر الاتصال.';

  @override
  String get deliveryFailedLocally =>
      'تم تسجيل عدم التسليم. سنرسل التحديث عند توفر الاتصال.';

  @override
  String get removePhoto => 'حذف الصورة';

  @override
  String get chooseSource => 'إضافة صورة';

  @override
  String get photoAttachSuccess => 'تمت إضافة الصورة';

  @override
  String get actionTypeComplete => 'تسليم الطلب';

  @override
  String get actionTypeFail => 'عدم تسليم الطلب';

  @override
  String get retries => 'عدد المحاولات';

  @override
  String get orderPrefix => 'الطلب ';

  @override
  String get viewDetails => 'عرض التفاصيل';

  @override
  String get phoneInvalid => 'رقم الهاتف غير صالح';

  @override
  String get viewPhoto => 'عرض الصورة';

  @override
  String get cannotMakeCall => 'لا يمكن إجراء المكالمات من هذا الجهاز';

  @override
  String get orderSummary => 'ملخص الطلب';

  @override
  String get compressingImage => 'جارٍ تجهيز الصورة…';

  @override
  String get snackbarSuccess => 'تم';

  @override
  String get snackbarError => 'تعذّر إكمال العملية';

  @override
  String get snackbarWarning => 'تنبيه';

  @override
  String get snackbarInfo => 'ملاحظة';

  @override
  String get viewOnMap => 'عرض الموقع';

  @override
  String get openInGoogleMaps => 'فتح خرائط Google';

  @override
  String get customerLocation => 'موقع العميل';
}
