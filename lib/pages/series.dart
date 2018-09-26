import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../config/application.dart';
import '../models/Series.dart';
import '../utils/ui.dart';

class SeriesRoute extends StatefulWidget {
  @override
  _SeriesRoute createState() => new _SeriesRoute();
}

class _SeriesRoute extends State<SeriesRoute>
    with SingleTickerProviderStateMixin {
  ScrollController _scrollViewController;

  List<Series> list = new List<Series>();
  List<Series> displayList = new List<Series>();
  bool _ready = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: new NestedScrollView(
        controller: _scrollViewController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            new SliverAppBar(
              elevation: 4.0,
              forceElevated: true,
              snap: true,
              pinned: true,
              title: new Text("Series"),
              floating: true,
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(60.0),
                child: Theme(
                  data: Theme.of(context).copyWith(accentColor: Colors.white),
                  child: Container(
                    height: 60.0,
                    alignment: Alignment.center,
                    child: ListTile(
                      leading: Icon(Icons.search, color: whiteColor),
                      title: new TextField(
                        style: TextStyle(color: whiteColor),
                        onChanged: (text) => _searchHandler(text),
                        decoration: new InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Search based on description and title ...',
                          hintStyle: TextStyle(
                            color: Colors.white70,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ];
        },
        body: _ready ? _showResults() : _showLoading(),
      ),
    );
  }

  @override
  void dispose() {
    _scrollViewController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _scrollViewController = new ScrollController();

    Series.getSeries().then((result) {
      setState(() {
        list = result;
        displayList = list;
        _ready = true;
      });
    });
  }

  _getIconNumber(number) {
    switch (number) {
      case 0:
        return Icons.filter_none;
      case 1:
        return Icons.filter_1;
      case 2:
        return Icons.filter_2;
      case 3:
        return Icons.filter_3;
      case 4:
        return Icons.filter_4;
      case 5:
        return Icons.filter_5;
      case 6:
        return Icons.filter_6;
      case 7:
        return Icons.filter_7;
      case 8:
        return Icons.filter_8;
      case 9:
        return Icons.filter_9;
      default:
        return Icons.filter_9_plus;
    }
  }

  String _makeTitle(String input) {
    String title = input[0].toUpperCase() + input.substring(1);
    return title;
  }

  void _openSeries(uuid) {
    Application.router.navigateTo(context, '/series/$uuid');
  }

  _searchHandler(text) {
    setState(() {
      displayList = list.where((t) {
        return t.title.contains(text) || t.description.contains(text);
      }).toList();
    });
  }

  Widget _showLoading() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    );
  }

  Widget _showResults() {
    List<Widget> headerList = List<Widget>();
    // headerList.add(
    //   ListTile(
    //     leading: Icon(Icons.search, color: primaryColor),
    //     title: new TextField(
    //       onChanged: (text) => _searchHandler(text),
    //       decoration: new InputDecoration(hintText: 'Search...'),
    //     ),
    //   ),
    // );
    return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemCount: displayList.length + headerList.length,
      itemBuilder: (context, index) {
        if (index < headerList.length) {
          return headerList[index];
        }

        index -= headerList.length;
        Series item = displayList[index];
        var formatter = DateFormat('MM/dd HH:mm');
        return ListTile(
          leading: Icon(_getIconNumber(item.count), color: primaryColor),
          title: Text('${_makeTitle(item.title)}'),
          subtitle: Row(
            children: <Widget>[
              Text('${item.description}', style: TextStyle(fontSize: 12.0)),
              Text(
                ' ( ${formatter.format(item.createdAt)} )',
                style: TextStyle(fontSize: 10.0),
              ),
            ],
          ),
          trailing: Text(
            "${item.rating}/5 (${item.count} images)",
            style: TextStyle(fontSize: 12.0),
          ),
          onTap: () => _openSeries(item.uuid),
        );
      },
    );
  }
}
