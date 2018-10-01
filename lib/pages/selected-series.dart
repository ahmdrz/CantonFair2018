import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:intl/intl.dart';

import '../models/Category.dart';
import '../models/ImageModel.dart';
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
  List<ImageModel> _images = List<ImageModel>();

  TabController _tabController;

  _SelectedSeriesRoute({this.uuid}) {
    Series.getSelectedSeriesByUUID(uuid).then((series) {
      ImageModel.getImagesOfSeries(uuid).then((images) {
        Category.getCategoryByUUID(series.categoryUUID).then((category) {
          setState(() {
            _images = images;
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

  _scaffold() {
    var formatter = DateFormat("yyyy/MM/dd 'at' HH:mm:ss");

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
      body: TabBarView(
        controller: _tabController,
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            child: ListView(
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
                  subtitle: Text(
                      "Phase ${_selectedSeries.phase} (tap for more info)"),
                  leading: Icon(Icons.class_),
                ),
                ListTile(
                  title: Text("Category:"),
                  subtitle:
                      Text("${_selectedCategory.name} (tap for more info)"),
                  leading: Icon(Icons.list),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0, bottom: 30.0),
            child: new Swiper(
              viewportFraction: 0.8,
              scale: 0.9,
              itemBuilder: (BuildContext context, int index) {
                return _CardTile(_images[index].filePath);
              },
              itemCount: _images.length,
            ),
          ),
        ],
      ),
      bottomNavigationBar: new TabBar(
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
      ),
    );
  }

  _showImage(image) {}
}
