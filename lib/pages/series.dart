import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/Series.dart';
import '../utils/ui.dart';
import '../config/application.dart';

class SeriesRoute extends StatefulWidget {
  @override
  _SeriesRoute createState() => new _SeriesRoute();
}

class _SeriesRoute extends State<SeriesRoute> {
  List<Series> list = new List<Series>();
  List<Series> displayList = new List<Series>();
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Series.getSeries().then((result) {
      setState(() {
        list = result;
        displayList = list;
        _ready = true;
      });
    });
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

  Widget _showResults() {
    return ListView.builder(
      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
      itemCount: displayList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return ListTile(
            leading: Icon(Icons.search),
            title: new TextField(
              onChanged: (text) => _searchHandler(text),
              decoration: new InputDecoration(hintText: 'Search...'),
            ),
          );
        }

        Series item = displayList[index - 1];
        var formatter = DateFormat('MM/dd HH:mm');
        return ListTile(
          leading: Icon(_getIconNumber(item.count)),
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

  Widget _showLoading() {
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
      pageName: 'Series',
      body: Container(
        child: Center(
          child: Container(
            child: _ready ? _showResults() : _showLoading(),
            width: 400.0,
          ),
        ),
      ),
    );
  }
}
