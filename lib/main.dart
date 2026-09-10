import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart';
import 'core/theme/mamba_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/cubit/auth_state.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/fasting/presentation/cubit/fasting_cubit.dart';
import 'features/history_metrics/presentation/cubit/history_metrics_cubit.dart';
import 'features/meals/presentation/cubit/meals_cubit.dart';
import 'features/navigation/pages/main_navigation_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive, Notifications & GetIt DI container
  await initDependencies();

  runApp(const MambaApp());
}

class MambaApp extends StatelessWidget {
  const MambaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => sl<AuthCubit>()..checkAuthStatus(),
        ),
        BlocProvider<FastingCubit>(
          create: (_) => sl<FastingCubit>()..init(),
        ),
        BlocProvider<MealsCubit>(
          create: (_) => sl<MealsCubit>()..loadMealsForDate(DateTime.now()),
        ),
        BlocProvider<HistoryMetricsCubit>(
          create: (_) => sl<HistoryMetricsCubit>(),
        ),
      ],
      child: MaterialApp(
        title: 'Mamba Fast Tracker',
        debugShowCheckedModeBanner: false,
        theme: MambaTheme.darkTheme,
        home: const AuthGateway(),
      ),
    );
  }
}

class AuthGateway extends StatelessWidget {
  const AuthGateway({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is Authenticated) {
          return const MainNavigationPage();
        } else if (state is Unauthenticated || state is AuthError) {
          return const LoginPage();
        }

        return const Scaffold(
          body: Center(
            child: CircularProgressIndicator(color: MambaTheme.neonGold),
          ),
        );
      },
    );
  }
}
