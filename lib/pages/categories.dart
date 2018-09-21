import 'package:flutter/material.dart';

import '../utils/ui.dart';

class CategoriesRoute extends StatefulWidget {
  @override
  _CategoriesRoute createState() => new _CategoriesRoute();
}

class _CategoriesRoute extends State<CategoriesRoute> {
  @override
  void initState() {
    super.initState();
    print("init state !");
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldWrapper(
      context: context,
      appBar: new AppBar(
        leading: new IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Categories', style: TextStyle(color: Colors.black)),
        backgroundColor: primaryColor,
      ),
    );
  }
}
