import 'package:flutter/material.dart';
import 'package:hotel_management_app/pages/tasks_page.dart';
import 'services/auth_service.dart';
import 'pages/login_page.dart';

void main() {
  runApp(const HotelManagementApp());
}

class HotelManagementApp extends StatelessWidget {
  const HotelManagementApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '酒店管理系统',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'system-ui',
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: AuthWrapper(), // 使用一个包装器来处理路由
      debugShowCheckedModeBanner: false,
    );
  }
}

/// AuthWrapper 负责在 App 启动时检查登录状态
class AuthWrapper extends StatefulWidget {
  @override
  _AuthWrapperState createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  late Future<bool> _checkLoginFuture;

  @override
  void initState() {
    super.initState();
    _checkLoginFuture = _authService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _checkLoginFuture,
      builder: (context, snapshot) {
        // 正在检查登录状态时，显示加载动画
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        // 如果检查结果为已登录，进入主页
        if (snapshot.hasData && snapshot.data == true) {
          return const TasksPage();
        }

        // 否则，进入登录页
        return const LoginPage();
      },
    );
  }
}
