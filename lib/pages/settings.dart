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
              confirmDialog(context, "Are you sure ?", () {});
            },
          ),
        ],
      ),
      pageName: 'Settings',
      childPage: true,
    );
  }
}
