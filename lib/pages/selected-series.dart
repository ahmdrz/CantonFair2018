import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// import 'package:flutter_swiper/flutter_swiper.dart';

import '../models/Category.dart';
import '../models/CaptureModel.dart';
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
  const _CardTile(this.gridImage, this.typeOfItem);

  IconData _getIcon(type) {
    switch (type) {
      case CaptureMode.audio:
        return Icons.audiotrack;
      case CaptureMode.video:
        return Icons.videocam;
      case CaptureMode.picture:
        return Icons.photo_camera;
      default:
        return Icons.perm_media;
    }
  }

  String _getImage(type) {
    switch (type) {
      case CaptureMode.picture:
        return gridImage;
      default:
        return "assets/purple-materials.jpg";
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: () {
        print("$gridImage");
      },
      child: new Container(
        child: Container(
          color: primaryColor.withOpacity(0.3),
          child: Center(
            child: Icon(
              _getIcon(typeOfItem),
              color: Colors.white.withOpacity(0.75),
              size: width * 0.2,
            ),
          ),
        ),
        decoration: new BoxDecoration(
          color: primaryColor,
          boxShadow: [
            new BoxShadow(
              offset: Offset(0.0, 4.0),
              color: Colors.black.withOpacity(0.25),
              blurRadius: 4.0,
            ),
          ],
          image: new DecorationImage(
            image: new AssetImage(_getImage(typeOfItem)),
            fit: BoxFit.cover,
          ),
          borderRadius: new BorderRadius.all(const Radius.circular(5.0)),
        ),
      ),
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  heading(text) {
    return Text(text, style: TextStyle(fontSize: 18.0));
  }

  @override
  void initState() {
    super.initState();
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
            Navigator.popAndPushNamed(context, "/camera/${_selectedSeries.uuid}");
          },
        ),
      ],
    );
  }

  _scaffold() {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _makeTitle(_selectedSeries.title),
        ),
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
        return Container(
          margin: EdgeInsets.all(10.0),
          child: _CardTile(_items[index].filePath, _items[index].captureMode),
        );
      }),
    );
  }
}
