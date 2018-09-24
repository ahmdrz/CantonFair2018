import 'package:flutter/material.dart';

import '../utils/ui.dart';
import '../data/database.dart';
import '../models/Category.dart';

class CategoriesRoute extends StatefulWidget {
  @override
  _CategoriesRoute createState() => new _CategoriesRoute();
}

class _CategoriesRoute extends State<CategoriesRoute> {
  List<Category> _categories = new List<Category>();

  @override
  void initState() {
    super.initState();
    print("running init func");
    CategoryDatabase.get().getCategories().then((data) {
      setState(() {
        _categories = data;
      });
    });
  }

  TextEditingController _inputCategoryTitleController =
      new TextEditingController();
  String _inputCategoryTitle = '';

  _getTitleDialog() async {
    _inputCategoryTitleController = new TextEditingController();
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
                    controller: _inputCategoryTitleController,
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
                    CategoryDatabase.get().updateCategory(
                      Category(name: _inputCategoryTitleController.text),
                    );
                    print("submit func");
                    setState(() {});
                    Navigator.pop(context);
                  })
            ],
          );
        });
  }

  void _categoryPressed(Category category) {
    print("Category ${category.name} pressed !");
  }

  @override
  Widget build(BuildContext context) {
    print("running build func");
    List<Widget> list = new List<Widget>();
    for (Category category in _categories) {
      String title =
          category.name[0].toUpperCase() + category.name.substring(1);
      list.add(
        Container(
          child: ListTile(
            leading: Icon(Icons.view_list),
            title: Text(title),
            onTap: () => _categoryPressed(category),
            onLongPress: () {
              confirmDialog(context, "Are you sure ?", () {});
            },
          ),
          padding: EdgeInsets.all(10.0),
        ),
      );
    }
    return scaffoldWrapper(
      context: context,
      body: ListView(children: list),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        elevation: 4.0,
        child: Icon(Icons.add),
        onPressed: () {
          _getTitleDialog();
        },
      ),
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
