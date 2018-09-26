import 'package:flutter/material.dart';

import '../utils/ui.dart';
import '../models/Series.dart';
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
  List<ImageModel> _images = List<ImageModel>();

  _SelectedSeriesRoute({this.uuid}) {
    Series.getSelectedSeriesByUUID(uuid).then((series) {
      ImageModel.getImagesOfSeries(uuid).then((images) {
        setState(() {
          _selectedSeries = series;
          _images = images;
          _loading = false;
        });
      });
    });
  }

  @override
  void initState() {
    super.initState();
  }

  _scaffold() {
    return scaffoldWrapper(
      context: context,
      childPage: true,
      pageName: "Series '${_selectedSeries.title}'",
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
    return _loading ? _loadingContainer() : _scaffold();
  }
}
