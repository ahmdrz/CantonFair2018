import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import '../config/application.dart';
import '../models/Series.dart';
import '../utils/ui.dart';

class SeriesRoute extends StatefulWidget {
  final String phase;
  final String category;

  SeriesRoute({this.phase, this.category});

  @override
  _SeriesRoute createState() =>
      new _SeriesRoute(phase: phase, category: category);
}

class _SeriesRoute extends State<SeriesRoute>
    with SingleTickerProviderStateMixin {
  String sortInv = 'DESC';

  final String phase;

  final String category;
  List<Series> list = new List<Series>();

  List<Series> displayList = new List<Series>();
  bool _ready = false;
  _SeriesRoute({this.phase, this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _renderSpeedDial(),
      body: new NestedScrollView(
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
    super.dispose();
  }

  @override
  void initState() {
    _sortBy('created_at');
    super.initState();
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

  _renderSpeedDial() {
    return SpeedDial(
      overlayOpacity: 0.1,
      overlayColor: primaryColor,
      animatedIcon: AnimatedIcons.menu_close,
      animatedIconTheme: IconThemeData(size: 22.0),
      curve: Curves.elasticInOut,
      children: [
        SpeedDialChild(
          child: Icon(Icons.sort_by_alpha, color: Colors.white),
          backgroundColor: primaryColor,
          onTap: () => _sortBy('title'),
          label: 'Alphabet',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
        ),
        SpeedDialChild(
          child: Icon(Icons.star, color: Colors.white),
          backgroundColor: primaryColor,
          onTap: () => _sortBy('rating'),
          label: 'Rating',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
        ),
        SpeedDialChild(
          child: Icon(Icons.date_range, color: Colors.white),
          backgroundColor: primaryColor,
          onTap: () => _sortBy('created_at'),
          label: 'Created At',
          labelStyle: TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
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
    return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        Series item = displayList[index];
        var formatter = DateFormat('MM/dd HH:mm');
        return ListTile(
          leading: Icon(_getIconNumber(item.count), color: primaryColor),
          title: Text('${_makeTitle(item.title)}'),
          subtitle: Row(
            children: <Widget>[
              Text('${item.description}', style: TextStyle(fontSize: 12.0)),
              Text(
                ' ( ${formatter.format(item.createdAt)} / phase ${item.phase} )',
                style: TextStyle(fontSize: 10.0),
              ),
            ],
          ),
          trailing: Text(
            "${item.rating}/5 (${item.count} images)",
            style: TextStyle(fontSize: 12.0),
          ),
          onTap: item.count > 0 ? () => _openSeries(item.uuid) : null,
        );
      },
    );
  }

  void _sortBy(order) {
    Future<List<Series>> handler;
    var inv = sortInv;

    if (phase != null)
      handler = Series.getSeriesByPhase(phase, order: order, inv: inv);
    else if (category != null)
      handler =
          Series.getSeriesByCategory(category, order: order, inv: inv);
    else
      handler = Series.getSeries(order: order, inv: inv);

    handler.then((result) {
      setState(() {
        if (inv == 'DESC') 
          sortInv = 'ASC';
        else
          sortInv = 'DESC';       
        list = result;
        displayList = list;
        _ready = true;
      });
    });
  }
}
