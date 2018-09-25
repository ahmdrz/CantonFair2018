import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import './config/application.dart';
import './pages/camera.dart';
import './pages/categories.dart';
import './pages/home.dart';
import './pages/settings.dart';
import './pages/splash-screen.dart';
import './utils/ui.dart';

main() {
  runApp(CantonFair());
}

class CantonFair extends StatelessWidget {
  @override
  CantonFair() {
    final router = new Router();
    router.define(
      '/',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new SplashScreenRoute();
      }),
    );
    router.define(
      '/home',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new HomeRoute();
      }),
    );
    router.define(
      '/camera',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new CameraRoute();
      }),
    );
    router.define(
      '/categories',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new CategoriesRoute();
      }),
    );
    router.define(
      '/settings',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new SettingsRoute();
      }),
    );
    Application.router = router;
  }

  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CantonFair',
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: primaryColor,
      ),
      onGenerateRoute: Application.router.generator,
    );
  }
}
