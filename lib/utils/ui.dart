import 'package:flutter/material.dart';
import '../config/application.dart';

Color primaryColor = Colors.lightGreen;

Color secondaryColor = Colors.lightGreenAccent;

confirmDialog(BuildContext context, String title, Function onPress) async {
  await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(title),
          contentPadding: const EdgeInsets.all(16.0),
          actions: <Widget>[
            new FlatButton(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                }),
            new FlatButton(
                child: const Text('Yes'),
                onPressed: () {
                  onPress();
                  Navigator.pop(context);
                })
          ],
        );
      });
}

Widget scaffoldWrapper({
  GlobalKey<ScaffoldState> key,
  Widget appBar,
  Widget body,
  FloatingActionButton floatingActionButton,
  FloatingActionButtonLocation floatingActionButtonLocation,
  FloatingActionButtonAnimator floatingActionButtonAnimator,
  List<Widget> persistentFooterButtons,
  Widget drawer,
  Widget endDrawer,
  Widget bottomNavigationBar,
  Widget bottomSheet,
  Color backgroundColor,
  bool resizeToAvoidBottomPadding = true,
  bool primary = true,
  String pageName,
  @required BuildContext context,
}) {
  if (drawer == null) drawer = makeDrawer(context);
  if (appBar == null)
    appBar = AppBar(
      leading: new IconButton(
        icon: Icon(Icons.menu, color: Colors.black),
        onPressed: () => key.currentState.openDrawer(),
      ),
      actions: <Widget>[
        new FlatButton(
            child: Text("Restart"),
            onPressed: () {
              Application.router.navigateTo(context, '/');
            }),
      ],
      title: const Text('Lemon App', style: TextStyle(color: Colors.black)),
      backgroundColor: primaryColor,
    );
  return Scaffold(
    key: key,
    appBar: appBar,
    body: body,
    floatingActionButton: floatingActionButton,
    floatingActionButtonAnimator: floatingActionButtonAnimator,
    floatingActionButtonLocation: floatingActionButtonLocation,
    persistentFooterButtons: persistentFooterButtons,
    drawer: drawer,
    endDrawer: endDrawer,
    bottomNavigationBar: bottomNavigationBar,
    bottomSheet: bottomSheet,
    backgroundColor: backgroundColor,
    resizeToAvoidBottomPadding: resizeToAvoidBottomPadding,
    primary: primary,
  );
}

Widget makeDrawer(BuildContext context) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: <Widget>[
        DrawerHeader(
          child: Text('Drawer Header'),
          decoration: BoxDecoration(
            color: primaryColor,
          ),
        ),
        ListTile(
          leading: new Icon(Icons.list),
          title: Text('Categories'),
          onTap: () {
            Application.router.navigateTo(context, '/categories');
            // Navigator.pushNamed(context, '/categories');
          },
        ),
        ListTile(
          leading: new Icon(Icons.cloud),
          title: Text('Server'),
          onTap: () {
            // Update the state of the app
            // ...
          },
        ),
        ListTile(
          leading: new Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            // Navigator.pushNamed(context, '/settings');
            Application.router.navigateTo(context, '/settings');
          },
        ),
      ],
    ),
  );
}
