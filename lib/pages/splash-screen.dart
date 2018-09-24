import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';

import '../config/application.dart';
import '../utils/ui.dart';
import '../models/Category.dart';

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
    Category controller = Category();
    Application.cache = new Map<String, dynamic>();

    Application.closeDatabase().then((result) {
      Application.initDatabase().then((data) {
        controller.getCategories().then((categories) {
          Application.cache["categories"] = categories;
          if (categories.length == 0) {
            controller.name = "Other";
            controller.updateCategory(controller).then((_) {
              _startApp();
            });
          } else {
            _startApp();
          }
        });
      });
    });
  }
}
