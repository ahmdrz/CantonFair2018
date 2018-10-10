import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

import '../utils/ui.dart';
import '../models/CaptureModel.dart';

class ItemViewRoute extends StatefulWidget {
  final List<CaptureModel> list;
  final int index;
  final String tag;
  ItemViewRoute(this.list, this.index, this.tag);

  @override
  _ItemViewRouteRoute createState() =>
      new _ItemViewRouteRoute(list: list, index: index, tag: tag);
}

class _ItemViewRouteRoute extends State<ItemViewRoute> {
  final List<CaptureModel> list;
  final int index;
  final String tag;

  _ItemViewRouteRoute({this.tag, this.list, this.index});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Scaffold(        
        body: Container(
          child: Swiper(
            pagination: new SwiperPagination(
              margin: new EdgeInsets.all(5.0),
            ),
            control: new SwiperControl(
              color: whiteColor,
            ),
            index: index,
            itemBuilder: (BuildContext context, int index) {
              CaptureMode type = list[index].captureMode;
              if (type == CaptureMode.video) return Container();
              if (type == CaptureMode.audio) return Container();
              if (type == CaptureMode.picture)
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      image: DecorationImage(
                        image: AssetImage(list[index].filePath),
                        fit: BoxFit.cover,
                      )),
                );
            },
            itemCount: list.length,
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
  }
}
