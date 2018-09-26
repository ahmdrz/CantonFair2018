import 'package:flutter/material.dart';
import '../config/application.dart';

final Color primaryColor = Colors.purple;
final Color secondaryColor = Colors.purpleAccent;
final Color whiteColor = Colors.white;

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
  List<Widget> appBarActions = const <Widget>[],
  bool resizeToAvoidBottomPadding = true,
  bool primary = true,
  String pageName = '',
  bool appBarShadow = true,
  @required BuildContext context,
  bool childPage = false,
}) {
  if (drawer == null) drawer = makeDrawer(context);
  if (appBar == null) {
    appBar = !childPage
        ? AppBar(
            leading: new IconButton(
              icon: Icon(Icons.menu, color: whiteColor),
              onPressed: () => key.currentState.openDrawer(),
            ),
            actions: <Widget>[
              new FlatButton(
                  child: Text("Restart", style: TextStyle(color: whiteColor)),
                  onPressed: () {
                    Application.router.navigateTo(context, '/');
                  }),
            ],
            title: Text('CantonFair 2018', style: TextStyle(color: whiteColor)),
            backgroundColor: primaryColor,
            elevation: appBarShadow ? 4.0 : 0.0,
          )
        : AppBar(
            actions: appBarActions,
            elevation: appBarShadow ? 4.0 : 0.0,
            leading: new IconButton(
              icon: Icon(Icons.arrow_back, color: whiteColor),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(pageName, style: TextStyle(color: whiteColor)),
            backgroundColor: primaryColor,
          );
  }
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
          child: Center(
              child: Text(
            'CantonFair 2018',
            style: TextStyle(color: whiteColor),
          )),
          decoration: BoxDecoration(
            color: primaryColor,
          ),
        ),
        ListTile(
          leading: new Icon(Icons.list),
          title: Text('Categories'),
          onTap: () {
            Navigator.pop(context);
            Application.router.navigateTo(context, '/categories');
          },
        ),
        ListTile(
          leading: new Icon(Icons.cake),
          title: Text('Series'),
          onTap: () {
            Navigator.pop(context);
            Application.router.navigateTo(context, '/series');
          },
        ),
        ListTile(
          leading: new Icon(Icons.cloud),
          title: Text('Server'),
          onTap: () {
            Navigator.pop(context);
          },
        ),
        ListTile(
          leading: new Icon(Icons.settings),
          title: Text('Settings'),
          onTap: () {
            Navigator.pop(context);
            Application.router.navigateTo(context, '/settings');
          },
        ),
      ],
    ),
  );
}
