import 'package:flutter/material.dart';

import '../utils/ui.dart';

class SettingsRoute extends StatefulWidget {
  @override
  _SettingsRoute createState() => new _SettingsRoute();
}

class _SettingsRoute extends State<SettingsRoute> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldWrapper(
      context: context,
      body: ListView(
        children: <Widget>[          
          ListTile(
            title: Text("Clear database"),
            leading: Icon(Icons.storage),
            onTap: () {
              confirmDialog(context, "Are you sure ?", () {

              });
            },
          ),
        ],
      ),
      appBar: new AppBar(
        leading: new IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Settings', style: TextStyle(color: Colors.black)),
        backgroundColor: primaryColor,
      ),
    );
  }
}
