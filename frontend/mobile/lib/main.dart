import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'providers/auth_provider.dart';
import 'providers/karya_provider.dart';
import 'providers/admin_provider.dart';
import 'screens/widgets/custom_bottom_nav.dart';
import 'screens/home/jelajah_karya_screen.dart';
import 'screens/mahasiswa/karya_saya_screen.dart';
import 'screens/mahasiswa/unggah_karya_screen.dart';
import 'screens/kurator/panel_kurator_screen.dart';
import 'screens/admin/kelola_akun_admin_screen.dart';
import 'screens/auth/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ImmortalCampusApp());
}

class ImmortalCampusApp extends StatelessWidget {
  const ImmortalCampusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => KaryaProvider()),
        ChangeNotifierProvider(create: (_) => AdminProvider()),
      ],
      child: MaterialApp(
        title: 'Immortal Campus Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            surface: AppColors.surface,
          ),
          scaffoldBackgroundColor: AppColors.surface,
          appBarTheme: const AppBarTheme(
            backgroundColor: AppColors.surfaceWhite,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            centerTitle: false,
          ),
        ),
        home: const MainNavigationShell(),
      ),
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProv = context.watch<AuthProvider>();
    final role = authProv.currentUser?.role ?? 'penulis';

    List<Widget> screens;

    if (role == 'admin') {
      screens = [
        JelajahKaryaScreen(onOpenUpload: () => setState(() => _currentIndex = 2)),
        const PanelKuratorScreen(),
        const KelolaAkunAdminScreen(),
        LoginScreen(onLoginSuccess: () => setState(() => _currentIndex = 0)),
      ];
    } else if (role == 'kurator') {
      screens = [
        JelajahKaryaScreen(onOpenUpload: () => setState(() => _currentIndex = 1)),
        const PanelKuratorScreen(),
        const PanelKuratorScreen(),
        LoginScreen(onLoginSuccess: () => setState(() => _currentIndex = 0)),
      ];
    } else {
      screens = [
        JelajahKaryaScreen(onOpenUpload: () => setState(() => _currentIndex = 2)),
        const KaryaSayaScreen(),
        const UnggahKaryaScreen(),
        LoginScreen(onLoginSuccess: () => setState(() => _currentIndex = 1)),
      ];
    }

    final safeIndex = _currentIndex < screens.length ? _currentIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: safeIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        userRole: role,
      ),
    );
  }
}
