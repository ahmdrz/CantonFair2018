import 'package:flutter/material.dart';

import 'package:intl/intl.dart';

import '../utils/ui.dart';
import '../models/Series.dart';
import '../models/Category.dart';
import '../models/ImageModel.dart';

class SelectedSeriesRoute extends StatefulWidget {
  final String uuid;
  SelectedSeriesRoute({this.uuid});

  @override
  _SelectedSeriesRoute createState() => new _SelectedSeriesRoute(uuid: uuid);
}

class _SelectedSeriesRoute extends State<SelectedSeriesRoute> {
  final String uuid;
  bool _loading = true;
  Series _selectedSeries = Series();
  Category _selectedCategory = Category(name: "unknown");
  List<ImageModel> _images = List<ImageModel>();

  _SelectedSeriesRoute({this.uuid}) {
    Series.getSelectedSeriesByUUID(uuid).then((series) {
      ImageModel.getImagesOfSeries(uuid).then((images) {
        Category.getCategoryByUUID(series.categoryUUID).then((category) {
          setState(() {
            _selectedCategory = category;
            _selectedSeries = series;
            _images = images;
            _loading = false;
          });
        });
      });
    });
  }

  String _makeTitle(String input) {
    String title = input[0].toUpperCase() + input.substring(1);
    return title;
  }

  @override
  void initState() {
    super.initState();
  }

  _showImage(image) {

  }

  _scaffold() {
    var formatter = DateFormat("yyyy/MM/dd 'at' HH:mm:ss");

    return Container(
      child: Center(
        child: Container(
          width: 400.0,
          child: ListView.builder(
            itemCount: _images.length + 4,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return ListTile(
                  leading: Icon(Icons.description),
                  title: Text(_makeTitle(_selectedSeries.description)),
                );
              }
              if (index == 1) {
                return ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text(formatter.format(_selectedSeries.createdAt)),
                );
              }
              if (index == 2) {
                return ListTile(
                  leading: Icon(Icons.category),
                  title: Text(_makeTitle(_selectedCategory.name)),
                );
              }
              if (index == 3) {
                return Divider();
              }
              index -= 4;

              return GestureDetector(
                onTap: () => _showImage(_images[index]),
                child: Card(
                  margin: EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                    height: 300.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(4.0)),
                      image: DecorationImage(
                        image: AssetImage(_images[index].filePath),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  _loadingContainer() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return scaffoldWrapper(
      context: context,
      childPage: true,
      pageName: _loading ? "Loading ..." : "${_makeTitle(_selectedSeries.title)}",
      body: _loading ? _loadingContainer() : _scaffold(),
    );
  }
}
