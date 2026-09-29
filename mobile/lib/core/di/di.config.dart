// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart'
    as _i161;
import 'package:pretty_dio_logger/pretty_dio_logger.dart' as _i528;
import 'package:shared_preferences/shared_preferences.dart' as _i460;

import '../../features/delivery/data_sources/repositories/delivery_repo_impl.dart'
    as _i99;
import '../../features/delivery/data_sources/sources/local/delivery_local_ds.dart'
    as _i336;
import '../../features/delivery/data_sources/sources/local/delivery_local_ds_impl.dart'
    as _i942;
import '../../features/delivery/data_sources/sources/remote/delivery_remote_ds.dart'
    as _i356;
import '../../features/delivery/data_sources/sources/remote/delivery_remote_ds_impl.dart'
    as _i187;
import '../../features/delivery/domain/repositories/delivery_repository.dart'
    as _i1007;
import '../../features/delivery/domain/use_case/complete_delivery_use_case.dart'
    as _i43;
import '../../features/delivery/domain/use_case/fail_delivery_use_case.dart'
    as _i77;
import '../../features/delivery/domain/use_case/get_deliveries_use_case.dart'
    as _i963;
import '../../features/delivery/domain/use_case/get_delivery_by_id_use_case.dart'
    as _i497;
import '../../features/delivery/domain/use_case/retry_action_use_case.dart'
    as _i397;
import '../database/local_storage_service.dart' as _i824;
import '../general_cubits/locale_cubit.dart' as _i959;
import '../helpers/shared_pref.dart' as _i42;
import '../network/api_services.dart' as _i804;
import '../network/external_modules.dart' as _i576;
import '../services/connectivity_service.dart' as _i47;
import '../services/language_interceptor.dart' as _i32;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final externalModules = _$ExternalModules();
    await gh.factoryAsync<_i460.SharedPreferences>(
      () => externalModules.provideSharedPreferences,
      preResolve: true,
    );
    gh.lazySingleton<_i824.LocalStorageService>(
      () => _i824.LocalStorageService(),
    );
    gh.lazySingleton<_i959.LocaleCubit>(() => _i959.LocaleCubit());
    gh.lazySingleton<_i528.PrettyDioLogger>(
      () => externalModules.providePrettyDioLogger(),
    );
    gh.lazySingleton<_i161.InternetConnection>(
      () => externalModules.provideInternetConnection(),
    );
    gh.factory<_i42.SharedPrefHelper>(
      () => _i42.SharedPrefHelper(gh<_i460.SharedPreferences>()),
    );
    gh.factory<_i336.DeliveryLocalDataSource>(
      () => _i942.DeliveryLocalDataSourceImpl(gh<_i824.LocalStorageService>()),
    );
    gh.lazySingleton<_i32.LanguageInterceptor>(
      () => _i32.LanguageInterceptor(gh<_i42.SharedPrefHelper>()),
    );
    gh.lazySingleton<_i361.Dio>(
      () => externalModules.provideDio(
        gh<_i528.PrettyDioLogger>(),
        gh<_i32.LanguageInterceptor>(),
      ),
    );
    gh.factory<_i804.ApiServices>(() => _i804.ApiServices(gh<_i361.Dio>()));
    gh.lazySingleton<_i47.ConnectivityService>(
      () => _i47.ConnectivityService(
        gh<_i161.InternetConnection>(),
        gh<_i361.Dio>(),
      ),
    );
    gh.factory<_i356.DeliveryRemoteDs>(
      () => _i187.DeliveryRemoteDsImpl(gh<_i804.ApiServices>()),
    );
    gh.factory<_i1007.DeliveryRepository>(
      () => _i99.DeliveryRepositoryImpl(
        gh<_i336.DeliveryLocalDataSource>(),
        gh<_i356.DeliveryRemoteDs>(),
      ),
    );
    gh.factory<_i43.CompleteDeliveryUseCase>(
      () => _i43.CompleteDeliveryUseCase(gh<_i1007.DeliveryRepository>()),
    );
    gh.factory<_i77.FailDeliveryUseCase>(
      () => _i77.FailDeliveryUseCase(gh<_i1007.DeliveryRepository>()),
    );
    gh.factory<_i963.GetDeliveriesUseCase>(
      () => _i963.GetDeliveriesUseCase(gh<_i1007.DeliveryRepository>()),
    );
    gh.factory<_i497.GetDeliveryByIdUseCase>(
      () => _i497.GetDeliveryByIdUseCase(gh<_i1007.DeliveryRepository>()),
    );
    gh.factory<_i397.RetryActionUseCase>(
      () => _i397.RetryActionUseCase(gh<_i1007.DeliveryRepository>()),
    );
    return this;
  }
}

class _$ExternalModules extends _i576.ExternalModules {}
