import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:simple_permissions/simple_permissions.dart';

import '../pages/capture.dart';
import '../pages/home.dart';
import '../config/application.dart';
import '../utils/ui.dart';
import '../models/Category.dart';

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
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (BuildContext context, _, __) {
          return HomeRoute();
        },
        transitionDuration: const Duration(milliseconds: 500),
        transitionsBuilder: (_, Animation<double> animation, __, Widget child) {
          return new FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Future<bool> requestPermissions() async {
    final writeAccess = await SimplePermissions.requestPermission(
        Permission.WriteExternalStorage);
    final cameraAccess =
        await SimplePermissions.requestPermission(Permission.Camera);
    final recordAudio =
        await SimplePermissions.requestPermission(Permission.RecordAudio);

    if (writeAccess != PermissionStatus.authorized) {
      return false;
    }
    if (cameraAccess != PermissionStatus.authorized) {
      return false;
    }
    if (recordAudio != PermissionStatus.authorized) {
      return false;
    }

    return true;
  }

  @override
  void initState() {
    super.initState();

    requestPermissions().then((ok) {
      if (ok) {
        _handleStart();
      } else {
        this.initState();
      }
    });
  }

  _handleStart() {
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
