import 'package:flutter/material.dart';

import '../utils/ui.dart';
import '../config/application.dart';

class SettingsRoute extends StatefulWidget {
  @override
  _SettingsRoute createState() => new _SettingsRoute();
}

class _SettingsRoute extends State<SettingsRoute> {
  bool _loading = false;

  @override
  void initState() {
    super.initState();
  }

  Widget _showLoading() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldWrapper(
      context: context,
      body: _loading
          ? _showLoading()
          : ListView(
              children: <Widget>[
                // ListTile(
                //   title: Text("Clear database"),
                //   leading: Icon(Icons.storage),
                //   onTap: () {
                //     confirmDialog(context, "Are you sure ?", () {});
                //   },
                // ),
                ListTile(
                  title: Text("Backup from database"),
                  leading: Icon(Icons.backup),
                  onTap: () {
                    confirmDialog(
                        context, "Do you want to backup your database ?", () {
                      setState(() {
                        _loading = true;
                      });
                      Application.backupDatabase().then((_) {
                        setState(() {
                          _loading = false;
                        });
                      });
                    });
                  },
                ),
              ],
            ),
      pageName: 'Settings',
      childPage: true,
    );
  }
}
