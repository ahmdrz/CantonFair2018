import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intl/intl.dart';

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
  const _CardTile(this.gridImage);
  @override
  Widget build(BuildContext context) {
    return Padding(
      child: new GestureDetector(
        onTap: () {
          print("$gridImage");
        },
        child: new Container(
          decoration: new BoxDecoration(
            color: primaryColor,
            boxShadow: [
              new BoxShadow(
                offset: Offset(0.0, 8.0),
                color: Colors.black.withOpacity(0.35),
                blurRadius: 8.0,
              ),
            ],
            image: new DecorationImage(
              image: new AssetImage(gridImage),
              fit: BoxFit.cover,
            ),
            borderRadius: new BorderRadius.all(const Radius.circular(10.0)),
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: 30.0),
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
      ],
    );
  }

  _scaffold() {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: Icon(Icons.arrow_back, color: whiteColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(_makeTitle(_selectedSeries.title),
            style: TextStyle(color: whiteColor)),
        backgroundColor: primaryColor,
      ),
      body: _items.length > 0
          ? TabBarView(
              controller: _tabController,
              children: <Widget>[
                _listView(),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
                  child: new Swiper(
                    viewportFraction: 0.8,
                    scale: 0.9,
                    itemBuilder: (BuildContext context, int index) {
                      return _CardTile(_items[index].filePath);
                    },
                    itemCount: _items.length,
                  ),
                )
              ],
            )
          : _listView(),
      bottomNavigationBar: _items.length > 0
          ? new TabBar(
              controller: _tabController,
              tabs: [
                Tab(
                  text: "Detials",
                ),
                _items.length > 0
                    ? Tab(
                        text: "Gallery",
                      )
                    : null,
              ],
              labelColor: secondaryColor,
              unselectedLabelColor: Colors.black,
            )
          : null,
    );
  }

  _showImage(image) {}
}
