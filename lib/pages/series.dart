import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';

import '../utils/search.dart';
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

  bool _ready = false;
  _SeriesRoute({this.phase, this.category});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _renderSpeedDial(),
      body: _ready ? _showResults() : _showLoading(),
      appBar: AppBar(
        title: Text('Series'),
        actions: <Widget>[
          IconButton(
            onPressed: _ready ? () => _showMaterialSearch(context) : null,
            tooltip: 'Search',
            icon: Icon(Icons.search),
          )
        ],
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

  _buildMaterialSearchPage(BuildContext context) {
    return new MaterialPageRoute<String>(
        settings: new RouteSettings(
          name: 'material_search',
          isInitialRoute: false,
        ),
        builder: (BuildContext context) {
          return new Material(
            child: new MaterialSearch<Series>(
              placeholder: 'Search',
              results: list
                  .map(
                    (Series s) => new MaterialSearchResult<Series>(
                          widget: ListTile(
                            subtitle: Text("${_makeTitle(s.description)}"),
                            leading: Icon(Icons.dehaze),
                            title: Text("${_makeTitle(s.title)}"),
                          ),
                          // icon: Icons.dehaze,
                          value: s,
                          // subtitle: "${_makeTitle(s.description)}",
                          // text: "${_makeTitle(s.title)}",
                        ),
                  )
                  .toList(),
              filter: (dynamic value, String criteria) {
                value = value as Series;
                var _titleCondition = value.title
                    .toLowerCase()
                    .trim()
                    .contains(RegExp(r'' + criteria.toLowerCase().trim() + ''));
                var _descriptionCondition = value.description
                    .toLowerCase()
                    .trim()
                    .contains(RegExp(r'' + criteria.toLowerCase().trim() + ''));
                return _titleCondition || _descriptionCondition;
              },
              onSelect: (dynamic value) {
                Navigator.pop(context, (value as Series).uuid);
              },
              onSubmit: (dynamic value) {},
            ),
          );
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

  Widget _showLoading() {
    return Container(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(primaryColor),
        ),
      ),
    );
  }

  _showMaterialSearch(BuildContext context) {
    Navigator.of(context)
        .push(_buildMaterialSearchPage(context))
        .then((dynamic value) {
      if (value == null) return;
      _openSeries(value as String);
    });
  }

  Widget _showResults() {
    return ListView.builder(
      padding: EdgeInsets.all(0.0),
      itemCount: list.length,
      itemBuilder: (context, index) {
        Series item = list[index];
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
      handler = Series.getSeriesByCategory(category, order: order, inv: inv);
    else
      handler = Series.getSeries(order: order, inv: inv);

    handler.then((result) {
      setState(() {
        if (inv == 'DESC')
          sortInv = 'ASC';
        else
          sortInv = 'DESC';
        list = result;
        _ready = true;
      });
    });
  }
}
