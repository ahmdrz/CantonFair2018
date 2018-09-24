import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import './config/application.dart';
import './pages/home.dart';
import './pages/camera.dart';
import './pages/categories.dart';
import './pages/settings.dart';

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
  throw ArgumentError('Unknown lens direction');
}

String getCameraName(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return "Rear";
    case CameraLensDirection.front:
      return "Front";
    default:
      return "External";
  }
}

Future<Null> main() async {
  try {
    List<CameraDescription> cameras = await availableCameras();
    choices = List<Choice>();
    for (CameraDescription camera in cameras) {
      choices.add(
        Choice(
          title: getCameraName(camera.lensDirection),
          icon: getCameraLensIcon(camera.lensDirection),
          camera: camera,
        ),
      );
    }
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
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
        primarySwatch: Colors.green,
      ),
      onGenerateRoute: Application.router.generator,
    );
  }
}
