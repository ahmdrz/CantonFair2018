import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import './config/application.dart';
import './pages/camera.dart';
import './pages/categories.dart';
import './pages/home.dart';
import './pages/settings.dart';
import './pages/splash-screen.dart';
import './pages/series.dart';
import './pages/selected-series.dart';
import './pages/selected-phase.dart';
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
      '/camera/:series_uuid',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new CameraRoute(
          uuid: params['series_uuid'][0],
        );
      }),
    );
    router.define(
      '/series',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new SeriesRoute();
      }),
    );
    router.define(
      '/series/:series_uuid',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new SelectedSeriesRoute(
          uuid: params['series_uuid'][0],
        );
      }),
    );
    router.define(
      '/phases/:phase',
      handler: Handler(handlerFunc:
          (BuildContext context, Map<String, List<String>> params) {
        return new SelectedPhaseRoute(
          phase: params['phase'][0],
        );
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
