import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';

import '../models/CaptureModel.dart';
import '../utils/ui.dart';

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

Widget _overlay(BuildContext context, typeOfItem) {
  double width = MediaQuery.of(context).size.width;

  return Container(
    decoration: new BoxDecoration(
      color: primaryColor.withOpacity(0.3),
      borderRadius: new BorderRadius.all(const Radius.circular(5.0)),
    ),
    child: Center(
      child: Icon(
        _getIcon(typeOfItem),
        color: Colors.white.withOpacity(0.75),
        size: width * 0.2,
      ),
    ),
  );
}

class AudioAppCard extends StatefulWidget {
  final String filepath;
  AudioAppCard({this.filepath});

  @override
  _AudioAppCardState createState() => _AudioAppCardState(filepath);
}

class _AudioAppCardState extends State<AudioAppCard> {
  String filepath;

  _AudioAppCardState(filepath) {
    this.filepath = filepath;
  }

  void dispose() {
    print("audio dispose !");
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Building audio card ...");
    return Container(
      child: _overlay(context, CaptureMode.audio),
      decoration: new BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        image: new DecorationImage(
          image: new AssetImage(filepath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ImageAppCard extends StatefulWidget {
  final String filepath;
  ImageAppCard({this.filepath});

  @override
  _ImageAppCardState createState() => _ImageAppCardState(filepath);
}

class _ImageAppCardState extends State<ImageAppCard> {
  String filepath;
  Image image;

  _ImageAppCardState(filepath) {
    this.filepath = filepath;
  }

  @override
  Widget build(BuildContext context) {
    print("Building image card ...");
    return Container(
      decoration: new BoxDecoration(
        color: Colors.black.withOpacity(0.25),
        image: new DecorationImage(
          image: new AssetImage(filepath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class VideoAppCard extends StatefulWidget {
  final String filepath;
  final String loadingImage;
  VideoAppCard({this.filepath, this.loadingImage});

  @override
  _VideoAppCardState createState() =>
      _VideoAppCardState(filepath, loadingImage);
}

class _VideoAppCardState extends State<VideoAppCard> {
  String filepath;
  String loadingImage;

  _VideoAppCardState(filepath, loadingImage) {
    this.filepath = filepath;
    this.loadingImage = loadingImage;
  }

  @override
  Widget build(BuildContext context) {
    print("Building video card ...");
    return Container(
      child: _overlay(context, CaptureMode.video),
      decoration: new BoxDecoration(
        color: Colors.black.withOpacity(0.5),
        image: new DecorationImage(
          image: new AssetImage(loadingImage),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
