// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
export 'package:get_it/get_it.dart' show GetIt;

// Feature: Splash
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';

// Feature: Authentication
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/forgot_password_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

// Feature: Journal
import '../../features/journal/data/datasources/journal_local_data_source.dart';
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/journal/domain/usecases/get_journals.dart';
import '../../features/journal/domain/usecases/add_journal.dart';
import '../../features/journal/presentation/bloc/journal_bloc.dart';

// Feature: My Device
import '../../features/my_device/data/datasources/ble_device_data_source.dart';
import '../../features/my_device/data/repositories/my_device_repository_impl.dart';
import '../../features/my_device/domain/repositories/my_device_repository.dart';
import '../../features/my_device/domain/usecases/scan_devices.dart';
import '../../features/my_device/domain/usecases/connect_device.dart';
import '../../features/my_device/domain/usecases/disconnect_device.dart';
import '../../features/my_device/presentation/bloc/my_device_bloc.dart';

// Feature: Session Timer
import '../../features/session_timer/presentation/bloc/background_session_bloc.dart';

// Feature: Settings
import '../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/domain/usecases/get_regions.dart';
import '../../features/settings/domain/usecases/set_regions.dart';
import '../../features/settings/domain/usecases/get_wavelengths.dart';
import '../../features/settings/domain/usecases/set_wavelengths.dart';
import '../../features/settings/domain/usecases/get_output_power.dart';
import '../../features/settings/domain/usecases/set_output_power.dart';
import '../../features/settings/domain/usecases/get_frequency.dart';
import '../../features/settings/domain/usecases/set_frequency.dart';

// Feature: Power Monitoring
import '../../features/power_monitoring/data/datasources/power_monitoring_data_source.dart';
import '../../features/power_monitoring/data/repositories/power_monitoring_repository_impl.dart';
import '../../features/power_monitoring/domain/repositories/power_monitoring_repository.dart';
import '../../features/power_monitoring/presentation/bloc/power_monitoring_bloc.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton(() => sharedPreferences);
  getIt.registerLazySingleton(() => http.Client());

  //! Features

  // Splash
  getIt.registerLazySingleton<SplashRepository>(
    () => SplashRepositoryImpl(getIt()),
  );
  getIt.registerFactory(() => SplashBloc(getIt()));

  // Authentication
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: getIt()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => ForgotPasswordUseCase(getIt()));
  getIt.registerFactory(
    () => AuthBloc(
      loginUseCase: getIt(),
      registerUseCase: getIt(),
      forgotPasswordUseCase: getIt(),
    ),
  );

  // Journal
  getIt.registerLazySingleton<JournalLocalDataSource>(
    () => JournalLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<JournalRepository>(
    () => JournalRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetJournals(getIt()));
  getIt.registerLazySingleton(() => AddJournal(getIt()));
  getIt.registerFactory(
    () => JournalBloc(
      getJournals: getIt(),
      addJournal: getIt(),
    ),
  );

  // My Device
  getIt.registerLazySingleton<BleDeviceDataSource>(
    () => BleDeviceDataSourceImpl(),
  );
  getIt.registerLazySingleton<MyDeviceRepository>(
    () => MyDeviceRepositoryImpl(dataSource: getIt<BleDeviceDataSource>()),
  );
  getIt.registerLazySingleton(() => ScanDevices(getIt()));
  getIt.registerLazySingleton(() => ConnectDevice(getIt()));
  getIt.registerLazySingleton(() => DisconnectDevice(getIt()));
  getIt.registerFactory(
    () => MyDeviceBloc(
      scanDevices: getIt(),
      connectDevice: getIt(),
      disconnectDevice: getIt(),
      dataSource: getIt<BleDeviceDataSource>(),
    ),
  );

  // Session Timer
  getIt.registerFactory(() => BackgroundSessionBloc());

  // Settings
  getIt.registerLazySingleton<SettingsLocalDataSource>(
    () => SettingsLocalDataSourceImpl(sharedPreferences: getIt()),
  );
  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(localDataSource: getIt()),
  );
  getIt.registerLazySingleton(() => GetRegions(getIt()));
  getIt.registerLazySingleton(() => SetRegions(getIt()));
  getIt.registerLazySingleton(() => GetWavelengths(getIt()));
  getIt.registerLazySingleton(() => SetWavelengths(getIt()));
  getIt.registerLazySingleton(() => GetOutputPower(getIt()));
  getIt.registerLazySingleton(() => SetOutputPower(getIt()));
  getIt.registerLazySingleton(() => GetFrequency(getIt()));
  getIt.registerLazySingleton(() => SetFrequency(getIt()));

  // Power Monitoring Feature
  getIt.registerLazySingleton<PowerMonitoringDataSource>(
    () => PowerMonitoringDataSourceImpl(
      deviceBloc: getIt<MyDeviceBloc>(),
    ),
  );

  getIt.registerLazySingleton<PowerMonitoringRepository>(
    () => PowerMonitoringRepositoryImpl(
      dataSource: getIt<PowerMonitoringDataSource>(),
    ),
  );

  getIt.registerFactory(
    () => PowerMonitoringBloc(
      repository: getIt<PowerMonitoringRepository>(),
    ),
  );
}
