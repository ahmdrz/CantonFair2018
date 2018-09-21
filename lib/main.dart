import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import './pages/home.dart';
import './pages/camera.dart';
import './pages/categories.dart';

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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CantonFair',
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      routes: {
        '/': (context) => HomeRoute(),
        '/camera': (context) => CameraRoute(),
        '/categories': (context) => CategoriesRoute(),
      },
    );
  }
}
