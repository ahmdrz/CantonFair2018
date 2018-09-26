import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

import '../pages/camera.dart';
import '../config/application.dart';
import '../utils/ui.dart';
import '../models/Category.dart';

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

class SplashScreenRoute extends StatefulWidget {
  @override
  _SplashScreenRoute createState() => new _SplashScreenRoute();
}

class _SplashScreenRoute extends State<SplashScreenRoute> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: primaryColor,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  _startApp() {
    Future.delayed(Duration(seconds: 2)).then((delay) {
      Application.router
          .navigateTo(context, "/home", transition: TransitionType.fadeIn);
    });
  }

  @override
  void initState() {
    super.initState();
    Application.cache = new Map<String, dynamic>();

    try {
      availableCameras().then((cameras) {
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

        Application.closeDatabase().then((result) {
          Application.initDatabase().then((data) {
            Category.getCategories().then((categories) {
              Application.cache["categories"] = categories;
              _startApp();
            });
          });
        });
      });
    } on CameraException catch (e) {
      logError(e.code, e.description);
    }
  }
}
