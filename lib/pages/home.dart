import 'package:flutter/material.dart';

import '../utils/rating.dart';
import '../utils/ui.dart';

class HomeRoute extends StatefulWidget {
  @override
  _HomeRoute createState() => new _HomeRoute();
}

class _HomeRoute extends State<HomeRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int phaseSelector = 1;
  String categorySelector;
  String _title = '';
  String _description = '';
  TextEditingController _inputTitleController = new TextEditingController();
  TextEditingController _inputDescriptionController =
      new TextEditingController();
  double _rating = 2.5;

  bool _readyForCamera = false;

  @override
  void initState() {
    super.initState();
    print("init state !");
  }

  _getDescriptionDialog() async {
    _inputTitleController = new TextEditingController();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Enter descritption"),
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    controller: _inputDescriptionController,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Description',
                      hintText: 'eg. Shoes',
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    setState(() {
                      _description = _inputDescriptionController.text;
                    });
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  _getTitleDialog() async {
    _inputTitleController = new TextEditingController();
    await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return new AlertDialog(
            title: new Text("Enter your title"),
            contentPadding: const EdgeInsets.all(16.0),
            content: new Row(
              children: <Widget>[
                new Expanded(
                  child: new TextField(
                    controller: _inputTitleController,
                    autofocus: true,
                    decoration: new InputDecoration(
                      labelText: 'Title',
                      hintText: 'eg. Shoes',
                    ),
                  ),
                )
              ],
            ),
            actions: <Widget>[
              new FlatButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    setState(() {
                      _title = _inputTitleController.text;
                    });
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'HIDE',
            onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldWrapper(
      context: context,
      key: _scaffoldKey,
      body: Container(
        child: Center(
          child: Container(
            child: ListView(
              children: <Widget>[
                ListTile(
                  title: Text("Phase"),
                  leading: Icon(Icons.class_),
                  trailing: DropdownButton<int>(
                    value: phaseSelector,
                    onChanged: (int newValue) {
                      setState(() {
                        phaseSelector = newValue;
                      });
                    },
                    items: <int>[1, 2, 3].map((int number) {
                      return DropdownMenuItem<int>(
                        value: number,
                        child: Text("Phase $number"),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  title: Text("Category"),
                  leading: Icon(Icons.list),
                  trailing: DropdownButton<String>(
                    value: categorySelector,
                    onChanged: (String newValue) {
                      setState(() {
                        categorySelector = newValue;
                      });
                    },
                    items: <String>['One', 'Two', 'Free', 'Four']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.title),
                  title: Text("Enter your title"),
                  subtitle: _title != '' ? Text(_title) : null,
                  onTap: () {
                    _getTitleDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text("Write description"),
                  subtitle: _description != '' ? Text(_description) : null,
                  onTap: () {
                    _getDescriptionDialog();
                  },
                ),
                Divider(),
                Container(
                  padding: EdgeInsets.all(20.0),
                  child: StarRating(
                    rating: _rating,
                    color: primaryColor,
                    borderColor: Colors.grey,
                    size: 40.0,
                    starCount: 5,
                    onRatingChanged: (rating) => setState(
                          () {
                            this._rating = rating;
                          },
                        ),
                  ),
                ),
                Divider(),
                ListTile(
                  subtitle: Text(!_readyForCamera
                      ? 'You have to fill them up.'
                      : "I'm ready to capture your moments"),
                  title: Text("Open camera"),
                  leading: Icon(Icons.camera,
                      color: _readyForCamera ? primaryColor : Colors.red),
                  onTap: () {
                    if (!_readyForCamera) {
                      showInSnackBar("You have to fill them up.");
                      return;
                    }

                    Navigator.pushNamed(context, '/camera');
                  },
                  // onTap: _showDialog,
                ),
              ],
            ),
            width: 400.0,
            padding: EdgeInsets.all(20.0),
          ),
        ),
      ),
    );
  }
}
