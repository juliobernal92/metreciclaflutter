import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:metrecicla_app/screens/login_screen.dart';
import 'package:metrecicla_app/controllers/login_controller.dart';
import 'package:metrecicla_app/controllers/api_interceptor.dart';
import 'package:metrecicla_app/services/auth_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.lazyPut<AuthService>(() => AuthService());
  Get.put(LoginController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Met Recicla',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const LoginScreen(),
      builder: (context, child) {
        return ApiInterceptorProvider(
          interceptor: ApiInterceptor(context),
          child: child!,
        );
      },
    );
  }
}

class ApiInterceptorProvider extends InheritedWidget {
  final ApiInterceptor interceptor;

  const ApiInterceptorProvider({
    super.key,
    required this.interceptor,
    required super.child,
  });

  static ApiInterceptor of(BuildContext context) {
    return (context
            .dependOnInheritedWidgetOfExactType<ApiInterceptorProvider>()!)
        .interceptor;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}
