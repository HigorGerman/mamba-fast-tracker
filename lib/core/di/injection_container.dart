import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../notifications/notification_service.dart';
import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/fasting/data/datasources/fasting_local_datasource.dart';
import '../../features/fasting/data/repositories/fasting_repository_impl.dart';
import '../../features/fasting/domain/repositories/fasting_repository.dart';
import '../../features/fasting/domain/usecases/get_active_session_usecase.dart';
import '../../features/fasting/domain/usecases/get_fasting_history_usecase.dart';
import '../../features/fasting/domain/usecases/start_fasting_usecase.dart';
import '../../features/fasting/domain/usecases/stop_fasting_usecase.dart';
import '../../features/fasting/presentation/cubit/fasting_cubit.dart';
import '../../features/history_metrics/domain/usecases/get_weekly_metrics_usecase.dart';
import '../../features/history_metrics/presentation/cubit/history_metrics_cubit.dart';
import '../../features/meals/data/datasources/meal_local_datasource.dart';
import '../../features/meals/data/repositories/meal_repository_impl.dart';
import '../../features/meals/domain/repositories/meal_repository.dart';
import '../../features/meals/domain/usecases/add_meal_usecase.dart';
import '../../features/meals/domain/usecases/delete_meal_usecase.dart';
import '../../features/meals/domain/usecases/get_meals_by_date_usecase.dart';
import '../../features/meals/domain/usecases/update_meal_usecase.dart';
import '../../features/meals/presentation/cubit/meals_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // 1. Initialize Hive Local Storage
  await Hive.initFlutter();
  
  final activeBox = await Hive.openBox(FastingLocalDataSourceImpl.activeSessionBoxName);
  final historyBox = await Hive.openBox(FastingLocalDataSourceImpl.historyBoxName);
  final mealsBox = await Hive.openBox(MealLocalDataSourceImpl.mealsBoxName);
  final authBox = await Hive.openBox(AuthLocalDataSourceImpl.authBoxName);

  // 2. Notification Service
  final notificationService = NotificationServiceImpl();
  await notificationService.init();
  sl.registerLazySingleton<NotificationService>(() => notificationService);

  // 3. Data Sources
  sl.registerLazySingleton<FastingLocalDataSource>(
    () => FastingLocalDataSourceImpl(
      activeBox: activeBox,
      historyBox: historyBox,
    ),
  );

  sl.registerLazySingleton<MealLocalDataSource>(
    () => MealLocalDataSourceImpl(mealsBox: mealsBox),
  );

  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(authBox: authBox),
  );

  // 4. Repositories
  sl.registerLazySingleton<FastingRepository>(
    () => FastingRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<MealRepository>(
    () => MealRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl()),
  );

  // 5. Use Cases - Auth
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => CheckAuthStatusUseCase(sl()));

  // 6. Use Cases - Fasting
  sl.registerLazySingleton(() => StartFastingUseCase(sl()));
  sl.registerLazySingleton(() => StopFastingUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveSessionUseCase(sl()));
  sl.registerLazySingleton(() => GetFastingHistoryUseCase(sl()));

  // 7. Use Cases - Meals
  sl.registerLazySingleton(() => GetMealsByDateUseCase(sl()));
  sl.registerLazySingleton(() => AddMealUseCase(sl()));
  sl.registerLazySingleton(() => UpdateMealUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMealUseCase(sl()));

  // 8. Use Cases - History Metrics
  sl.registerLazySingleton(
    () => GetWeeklyMetricsUseCase(
      fastingRepository: sl(),
      mealRepository: sl(),
    ),
  );

  // 9. Cubits
  sl.registerFactory(
    () => AuthCubit(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      checkAuthStatusUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => FastingCubit(
      startFastingUseCase: sl(),
      stopFastingUseCase: sl(),
      getActiveSessionUseCase: sl(),
      getFastingHistoryUseCase: sl(),
      notificationService: sl(),
    ),
  );

  sl.registerFactory(
    () => MealsCubit(
      getMealsByDateUseCase: sl(),
      addMealUseCase: sl(),
      updateMealUseCase: sl(),
      deleteMealUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => HistoryMetricsCubit(
      getWeeklyMetricsUseCase: sl(),
    ),
  );
}
