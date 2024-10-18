// lib/core/di/injection_container.dart
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// Splash feature
import '../../features/splash/data/repositories/splash_repository_impl.dart';
import '../../features/splash/domain/repositories/splash_repository.dart';
import '../../features/splash/presentation/bloc/splash_bloc.dart';

// Authentication feature
import '../../features/authentication/data/datasources/auth_remote_data_source.dart';
import '../../features/authentication/data/repositories/auth_repository_impl.dart';
import '../../features/authentication/domain/repositories/auth_repository.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/register_usecase.dart';
import '../../features/authentication/domain/usecases/forgot_password_usecase.dart';
import '../../features/authentication/presentation/bloc/auth_bloc.dart';

// Journal feature
import '../../features/journal/data/datasources/journal_local_data_source.dart';
import '../../features/journal/data/repositories/journal_repository_impl.dart';
import '../../features/journal/domain/repositories/journal_repository.dart';
import '../../features/journal/domain/usecases/get_journals.dart';
import '../../features/journal/domain/usecases/add_journal.dart';
import '../../features/journal/presentation/bloc/journal_bloc.dart';

// My Device feature
import '../../features/my_device/data/datasources/ble_device_data_source.dart';
import '../../features/my_device/data/repositories/my_device_repository_impl.dart';
import '../../features/my_device/domain/repositories/my_device_repository.dart';
import '../../features/my_device/domain/usecases/scan_devices.dart';
import '../../features/my_device/domain/usecases/connect_device.dart';
import '../../features/my_device/presentation/bloc/my_device_bloc.dart';

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
    () => MyDeviceRepositoryImpl(dataSource: getIt()),
  );
  getIt.registerLazySingleton(() => ScanDevices(getIt()));
  getIt.registerLazySingleton(() => ConnectDevice(getIt()));
  getIt.registerFactory(
    () => MyDeviceBloc(
      scanDevices: getIt(),
      connectDevice: getIt(),
    ),
  );
}
