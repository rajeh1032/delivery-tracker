// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'متتبع التوصيل';

  @override
  String get navDeliveries => 'الطلبات';

  @override
  String get navSyncQueue => 'طابور المزامنة';

  @override
  String get navSettings => 'الإعدادات';

  @override
  String get online => 'متصل';

  @override
  String get offline => 'غير متصل';

  @override
  String get offlineBannerTitle => 'أنت غير متصل بالإنترنت';

  @override
  String get offlineBannerBody =>
      'لا يوجد اتصال بالإنترنت. يتم حفظ تعديلاتك محلياً وستتم المزامنة تلقائياً فور عودة الاتصال.';

  @override
  String get backOnline =>
      'تمت استعادة الاتصال — جاري مزامنة العمليات المعلقة...';

  @override
  String get deliveriesSearching => 'جاري البحث عن طلبات قريبة ....';

  @override
  String get searchHint => 'ابحث برقم الطلب أو اسم العميل...';

  @override
  String get filterAll => 'الكل';

  @override
  String get filterPending => 'قيد التوصيل';

  @override
  String get filterDelivered => 'تم التوصيل';

  @override
  String get filterFailed => 'فشل التوصيل';

  @override
  String get deliveryStatusPending => 'قيد التوصيل';

  @override
  String get deliveryStatusDelivered => 'تم التوصيل';

  @override
  String get deliveryStatusFailed => 'فشل التوصيل';

  @override
  String get syncStatusSynced => 'متزامن';

  @override
  String get syncStatusWaitingToSync => 'بانتظار المزامنة';

  @override
  String get syncStatusSyncing => 'جاري المزامنة...';

  @override
  String get syncStatusFailedToSync => 'فشلت المزامنة';

  @override
  String get paymentCash => 'كاش';

  @override
  String get paymentInstapay => 'انستاباي';

  @override
  String get emptyDeliveriesTitle => 'لا توجد طلبات معينة';

  @override
  String get emptyDeliveriesBody =>
      'ليس لديك أي طلبات توصيل نشطة في الوقت الحالي.';

  @override
  String get noSearchResults => 'لا توجد طلبات مطابقة للبحث أو الفلتر المحدد.';

  @override
  String get errorLoadDeliveries => 'تعذر تحميل الطلبات. اضغط لإعادة المحاولة.';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get retryAll => 'إعادة محاولة الكل';

  @override
  String get detailsTitle => 'تفاصيل الطلب';

  @override
  String get customerInfo => 'معلومات العميل';

  @override
  String get deliveryAddress => 'عنوان التوصيل';

  @override
  String get amountDue => 'المبلغ المطلوب تحصيله';

  @override
  String get recipientNameLabel => 'اسم المستلم';

  @override
  String get recipientNameHint => 'أدخل اسم الشخص المستلم';

  @override
  String get recipientNameRequired => 'اسم المستلم مطلوب (حرفين على الأقل)';

  @override
  String get noteLabel => 'ملاحظات (اختياري)';

  @override
  String get noteHint => 'أضف ملاحظة أو علامة مميزة...';

  @override
  String get photoTitle => 'صورة الإثبات';

  @override
  String get photoHint => 'التقاط صورة إثبات التوصيل (اختياري)';

  @override
  String get camera => 'الكاميرا';

  @override
  String get gallery => 'معرض الصور';

  @override
  String get confirmDelivery => 'تأكيد التوصيل';

  @override
  String get confirmFailure => 'تأكيد فشل التوصيل';

  @override
  String get failureReasonLabel => 'سبب عدم التوصيل';

  @override
  String get failureReasonRequired => 'يرجى تحديد سبب عدم التوصيل';

  @override
  String get reasonCustomerUnavailable => 'العميل غير متاح';

  @override
  String get reasonWrongAddress => 'العنوان غير صحيح';

  @override
  String get reasonCustomerRefused => 'العميل رفض الاستلام';

  @override
  String get reasonDamagedPackage => 'الشحنة تالفة';

  @override
  String get reasonOther => 'سبب آخر';

  @override
  String get markDelivered => 'تحديد كمكتمل';

  @override
  String get markFailed => 'تحديد كفاشل';

  @override
  String get actionsFrozenWhileSync =>
      'جاري مزامنة العملية حالياً. يرجى الانتظار.';

  @override
  String get syncQueueTitle => 'طابور المزامنة';

  @override
  String get syncQueuePendingTab => 'معلق';

  @override
  String get syncQueueFailedTab => 'فشل';

  @override
  String get emptyPendingQueue => 'لا توجد عمليات معلقة بانتظار المزامنة 🎉';

  @override
  String get emptyFailedQueue => 'لا توجد عمليات فاشلة في المزامنة';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String get language => 'اللغة';

  @override
  String get arabic => 'العربية';

  @override
  String get english => 'English';

  @override
  String get aboutVersion => 'متتبع التوصيل v1.0.0';

  @override
  String get deliveryNotFound => 'لم يتم العثور على الطلب';

  @override
  String get copyPhone => 'نسخ رقم الهاتف';

  @override
  String get phoneCopied => 'تم نسخ رقم الهاتف للحافظة';

  @override
  String get callCustomer => 'اتصال';

  @override
  String get deliveredBy => 'تم الاستلام بواسطة';

  @override
  String get deliveredOrderBanner => 'تم تسليم هذا الطلب بنجاح.';

  @override
  String get failedOrderBanner => 'تم تحديد هذا الطلب كفاشل.';

  @override
  String get deliveryCompletedLocally =>
      'تم تسجيل التوصيل بنجاح وجدولة المزامنة.';

  @override
  String get deliveryFailedLocally => 'تم تسجيل فشل التوصيل وجدولة المزامنة.';

  @override
  String get removePhoto => 'حذف الصورة';

  @override
  String get chooseSource => 'اختر مصدر الصورة';

  @override
  String get photoAttachSuccess => 'تم إرفاق الصورة بنجاح';

  @override
  String get actionTypeComplete => 'إتمام التوصيل';

  @override
  String get actionTypeFail => 'تعذر التوصيل';

  @override
  String get retries => 'محاولات';

  @override
  String get orderPrefix => 'طلب #';

  @override
  String get viewDetails => 'عرض التفاصيل';
}
