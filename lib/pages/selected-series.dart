import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:open_directory/open_directory.dart';

import '../config/application.dart';
import '../utils/card.dart';
import '../pages/item-view.dart';
import '../models/CaptureModel.dart';
import '../models/Category.dart';
import '../models/Series.dart';
import '../utils/ui.dart';

class SelectedSeriesRoute extends StatefulWidget {
  final String uuid;
  SelectedSeriesRoute({this.uuid});

  @override
  _SelectedSeriesRoute createState() => new _SelectedSeriesRoute(uuid: uuid);
}

class _CardTile extends StatelessWidget {
  final gridImage;
  final typeOfItem;
  final tag;
  const _CardTile(this.tag, this.gridImage, this.typeOfItem);

  Widget _childWidget(BuildContext context) {
    if (typeOfItem == CaptureMode.picture) {
      return ImageAppCard(
        filepath: gridImage,
      );
    } else if (typeOfItem == CaptureMode.video) {
      return VideoAppCard(
        filepath: gridImage,
        loadingImage: "assets/purple-materials.jpg",
      );
    } else {
      return AudioAppCard(
        filepath: "assets/purple-materials.jpg",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _childWidget(context),
      decoration:
          BoxDecoration(border: Border.all(width: 1.0, color: primaryColor)),
    );
  }
}

class _SelectedSeriesRoute extends State<SelectedSeriesRoute>
    with SingleTickerProviderStateMixin {
  final String uuid;

  bool _loading = true;
  Series _selectedSeries = Series();
  Category _selectedCategory = Category(name: "unknown");
  List<CaptureModel> _items = List<CaptureModel>();

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  TabController _tabController;

  _SelectedSeriesRoute({this.uuid}) {
    Series.getSelectedSeriesByUUID(uuid).then((series) {
      CaptureModel.getItemsOfSeries(uuid).then((items) {
        Category.getCategoryByUUID(series.categoryUUID).then((category) {
          setState(() {
            _items = items;
            _selectedCategory = category;
            _selectedSeries = series;
            _loading = false;
            _tabController = new TabController(vsync: this, length: 2);
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading ? _loadingContainer() : _scaffold();
  }

  heading(text) {
    return Text(text, style: TextStyle(fontSize: 18.0));
  }

  @override
  void initState() {
    super.initState();
  }

  Widget _bottomBar() {
    return TabBar(
      controller: _tabController,
      tabs: [
        Tab(
          text: "Detials",
        ),
        Tab(
          text: "Gallery",
        ),
      ],
      labelColor: secondaryColor,
      unselectedLabelColor: Colors.black,
    );
  }

  Widget _galleryView() {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(_items.length, (index) {
        return GridTile(
            child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) {
                  return ItemViewRoute(_items, index, _items[index].uuid);
                },
              ),
            );
          },
          child: Hero(
            child: _CardTile(_items[index].uuid, _items[index].filePath,
                _items[index].captureMode),
            tag: _items[index].uuid,
          ),
        ));
      }),
    );
  }

  Widget _listView() {
    var formatter = DateFormat("yyyy/MM/dd 'at' HH:mm:ss");

    return ListView(
      children: <Widget>[
        ListTile(
          title: Text("Title:"),
          subtitle: Text(_makeTitle(_selectedSeries.title)),
          leading: Icon(Icons.title),
        ),
        ListTile(
          title: Text("Description:"),
          subtitle: Text(_makeTitle(_selectedSeries.description)),
          leading: Icon(Icons.description),
        ),
        ListTile(
          title: Text("UUID:"),
          subtitle: Text(_selectedSeries.uuid),
          leading: Icon(Icons.code),
        ),
        ListTile(
          title: Text("Created at:"),
          subtitle: Text(formatter.format(_selectedSeries.createdAt)),
          leading: Icon(Icons.calendar_today),
        ),
        ListTile(
          title: Text("Rating:"),
          subtitle: Text("Score was ${_selectedSeries.rating}/5"),
          leading: Icon(Icons.stars),
        ),
        ListTile(
          title: Text("Phase:"),
          subtitle: Text("Phase ${_selectedSeries.phase} (tap for more info)"),
          leading: Icon(Icons.class_),
          onTap: () {
            Navigator.pushNamed(context, '/phases/${_selectedSeries.phase}');
          },
        ),
        ListTile(
          title: Text("Category:"),
          subtitle: Text("${_selectedCategory.name} (tap for more info)"),
          leading: Icon(Icons.list),
          onTap: () {
            Navigator.pushNamed(
                context, '/categories/${_selectedCategory.uuid}');
          },
        ),
        ListTile(
          title: Text("Delete this series"),
          subtitle: Text("(Hold this item to delete)"),
          leading: Icon(Icons.delete),
          onTap: () {},
          onLongPress: () {
            confirmDialog(
              context,
              "Do you want to delete this series ?",
              () => Series.deleteSeries(uuid).then((_) {
                    Navigator.pop(context);
                  }),
            );
          },
        ),
        ListTile(
          title: Text("Add new items"),
          subtitle: Text("(Hold to open capture page)"),
          leading: Icon(Icons.camera),
          onTap: () {},
          onLongPress: () {
            Navigator.popAndPushNamed(
                context, "/camera/${_selectedSeries.uuid}");
          },
        ),
      ],
    );
  }

  _loadingContainer() {
    return Container(
      color: primaryColor,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(whiteColor),
        ),
      ),
    );
  }

  String _makeTitle(String input) {
    String title = input[0].toUpperCase() + input.substring(1);
    return title;
  }

  _scaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _makeTitle(_selectedSeries.title),
        ),
        actions: <Widget>[
          FlatButton(
            child: Text(
              "Open as",
              style: TextStyle(
                color: whiteColor,
              ),
            ),
            onPressed: () {
              final String dirPath = '${Application.appDir}/Categories/${_selectedCategory.name}/${_selectedSeries.uuid}';
              canOpen(dirPath).then((result) {
                openDirectory(dirPath);
              });
            },
          )
        ],
      ),
      body: _items.length > 0 ? _tabBarView() : _listView(),
      bottomNavigationBar: _items.length > 0 ? _bottomBar() : null,
    );
  }

  Widget _tabBarView() {
    return TabBarView(
      controller: _tabController,
      children: <Widget>[
        _listView(),
        _galleryView(),
      ],
    );
  }
}
