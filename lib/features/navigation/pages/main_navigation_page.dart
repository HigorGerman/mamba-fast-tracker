import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/mamba_theme.dart';
import '../../auth/presentation/cubit/auth_cubit.dart';
import '../../fasting/presentation/pages/fasting_page.dart';
import '../../history_metrics/presentation/pages/history_metrics_page.dart';
import '../../meals/presentation/pages/meals_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    FastingPage(),
    MealsPage(),
    HistoryMetricsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0, // Hidden default app bar since individual pages manage top title
      ),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
          // Subtle Floating Logout Button at top-right
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: GestureDetector(
                onTap: () {
                  _showLogoutDialog(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: MambaTheme.cardSurface.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: MambaTheme.alertRed.withValues(alpha: 0.4)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.logout, color: MambaTheme.alertRed, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'SAIR',
                        style: TextStyle(
                          color: MambaTheme.alertRed,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: MambaTheme.surface,
          border: Border(
            top: BorderSide(color: MambaTheme.cardSurface, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: MambaTheme.surface,
          selectedItemColor: MambaTheme.neonGold,
          unselectedItemColor: MambaTheme.textMuted,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.timer_outlined),
              activeIcon: Icon(Icons.bolt, color: MambaTheme.neonGold),
              label: 'Timer Jejum',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_outlined),
              activeIcon: Icon(Icons.restaurant, color: MambaTheme.neonGreen),
              label: 'Refeições',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart, color: MambaTheme.neonCyan),
              label: 'Métricas',
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: MambaTheme.cardSurface,
        title: const Text('Encerrar Sessão?'),
        content: const Text(
          'Deseja realmente sair da sua conta Mamba Tracker?',
          style: TextStyle(color: MambaTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('VOLTAR', style: TextStyle(color: MambaTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<AuthCubit>().logout();
            },
            child: const Text('SAIR', style: TextStyle(color: MambaTheme.alertRed, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
