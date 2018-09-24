import 'package:flutter/material.dart';

import '../utils/rating.dart';
import '../utils/ui.dart';
import '../config/application.dart';
import '../models/Category.dart';

class HomeRoute extends StatefulWidget {
  @override
  _HomeRoute createState() => new _HomeRoute();
}

class _HomeRoute extends State<HomeRoute> {
  List<Category> _categories = new List<Category>();
  Category _category = new Category();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int phaseSelector = 1;
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
    setState(() {
      _categories = Application.cache["categories"];
      if (_categories.length > 0) {
        _category = _categories[0];
      }
    });
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
    if (_title != null && _description != null) {
      setState(() {
        _readyForCamera = _title.length * _description.length > 0;
      });
    }
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
                  subtitle:
                      _category.name != null ? Text(_category.name) : null,
                  trailing: _category.name != null
                      ? DropdownButton<Category>(
                          onChanged: (Category newValue) {
                            setState(() {
                              _category = newValue;
                            });
                          },
                          value: _category,
                          items: _categories.map((Category item) {
                            String title = item.name[0].toUpperCase() +
                                item.name.substring(1);
                            return DropdownMenuItem<Category>(
                              value: item,
                              child: Text("$title"),
                            );
                          }).toList(),
                        )
                      : null,
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

                    Application.router.navigateTo(context, '/camera');
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
