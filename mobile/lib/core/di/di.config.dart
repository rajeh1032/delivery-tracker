// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/delivery/data_sources/sources/local/delivery_local_ds.dart'
    as _i336;
import '../../features/delivery/data_sources/sources/local/delivery_local_ds_impl.dart'
    as _i942;
import '../database/local_storage_service.dart' as _i824;
import '../general_cubits/locale_cubit.dart' as _i959;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i824.LocalStorageService>(
      () => _i824.LocalStorageService(),
    );
    gh.lazySingleton<_i959.LocaleCubit>(() => _i959.LocaleCubit());
    gh.factory<_i336.DeliveryLocalDataSource>(
      () => _i942.DeliveryLocalDataSourceImpl(gh<_i824.LocalStorageService>()),
    );
    return this;
  }
}
