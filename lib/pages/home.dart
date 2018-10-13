import 'package:flutter/material.dart';

import '../utils/rating.dart';
import '../utils/ui.dart';
import '../config/application.dart';

import '../models/Category.dart';
import '../models/Series.dart';

class HomeRoute extends StatefulWidget {
  @override
  _HomeRoute createState() => new _HomeRoute();
}

class _HomeRoute extends State<HomeRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Category> _categories = new List<Category>();
  Category _category = new Category();

  int _phaseSelector = 1;

  String _title = '';
  TextEditingController _inputTitleController = new TextEditingController();

  String _description = '';
  TextEditingController _inputDescriptionController =
      new TextEditingController();

  double _rating = 4.0;

  bool _readyForCamera = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _categories = Application.cache["categories"];
      if (_categories.length > 0) {
        _category = _categories[0];
      }
    });
  }

  _getDescriptionDialog() async {
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: secondaryColor,
        foregroundColor: whiteColor,
        elevation: 8.0,
        child: Icon(Icons.blur_on),
        onPressed: () {
          if (!_readyForCamera) {
            showInSnackBar("You have to fill them up.");
            return;
          }

          Series currentSeries = Series(
            description: _description,
            title: _title,
            phase: _phaseSelector,
            rating: _rating.toInt(),
            categoryUUID: _category.uuid,
          );
          Series.updateCategory(currentSeries).then((_) {
            Application.router
                .navigateTo(context, '/camera/${currentSeries.uuid}');
          });
        },
      ),
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        color: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              IconButton(
                color: whiteColor,
                icon: Icon(Icons.refresh),
                onPressed: () {
                  Application.router.navigateTo(context, '/');
                },
                iconSize: 30.0,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        child: Center(
          child: Container(
            child: ListView(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              children: <Widget>[
                ListTile(
                  title: Text("Phase"),
                  leading: Icon(Icons.class_),
                  trailing: DropdownButton<int>(
                    value: _phaseSelector,
                    onChanged: (int newValue) {
                      setState(() {
                        _phaseSelector = newValue;
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
                  onLongPress: () {
                    Application.router.navigateTo(context, '/categories');
                  },
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
                  subtitle: _title != '' ? Text(_title) : Text("Tap to edit"),
                  onTap: () {
                    _getTitleDialog();
                  },
                ),
                ListTile(
                  leading: Icon(Icons.description),
                  title: Text("Write description"),
                  subtitle: _description != '' ? Text(_description) : Text("Tap to edit"),
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
              ],
            ),
            width: 400.0,
          ),
        ),
      ),
    );
  }
}
