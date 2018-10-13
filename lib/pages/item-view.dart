import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_swiper/flutter_swiper.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:video_player/video_player.dart';
import 'package:video_launcher/video_launcher.dart';

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
  int index;
  String tag;
  SwiperController controller = new SwiperController();
  AudioPlayer audioPlayer = new AudioPlayer();
  VideoPlayerController videoController;

  _ItemViewRouteRoute({this.tag, this.list, this.index});

  @override
  void dispose() {
    super.dispose();
    videoController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      child: Scaffold(
        body: Container(
          child: Swiper(
            onIndexChanged: (current) {
              audioPlayer?.stop();
              if (videoController != null) {
                if (videoController.value.isPlaying) {
                  videoController?.seekTo(Duration(seconds: 0));
                  videoController?.pause();
                }
              }
              setState(() {
                tag = list[current].uuid;
                index = current;
              });
            },
            controller: controller,
            pagination: new SwiperPagination(
              alignment: Alignment.topCenter,
              margin: new EdgeInsets.all(35.0),
            ),
            control: new SwiperControl(
              color: whiteColor,
            ),
            index: index,
            itemBuilder: (BuildContext context, int index) {
              CaptureMode type = list[index].captureMode;
              if (type == CaptureMode.video)
                return VideoPlayerWidget(videoController, list[index].filePath);
              if (type == CaptureMode.audio)
                return AudioPlayerWidget(audioPlayer, list[index].filePath);
              if (type == CaptureMode.picture)
                return ImageViewWidget(list[index].filePath);
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

class ImageViewWidget extends StatelessWidget {
  final String filePath;
  ImageViewWidget(this.filePath);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                image: DecorationImage(
                  image: AssetImage(filePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          new Container(
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Text("Image Viewer", style: TextStyle(color: whiteColor)),
                  onPressed: null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String filePath;
  final VideoPlayerController controller;
  VideoPlayerWidget(this.controller, this.filePath);

  @override
  _VideoPlayerWidget createState() =>
      new _VideoPlayerWidget(this.controller, this.filePath);
}

class _VideoPlayerWidget extends State<VideoPlayerWidget> {
  VideoPlayerController controller;
  final String filePath;
  bool _isPlaying = false;
  _VideoPlayerWidget(this.controller, this.filePath);

  @override
  void initState() {
    super.initState();
    controller = VideoPlayerController.file(File(filePath))
      ..addListener(() {
        final bool isPlaying = controller.value.isPlaying;
        if (isPlaying != _isPlaying) {
          if (mounted)
            setState(() {
              _isPlaying = isPlaying;
            });
        }
      })
      ..initialize().then((_) {
        if (mounted) setState(() {});
      });
  }

  Future<bool> _launchVideo(path) async {
    if (await canLaunchVideo(path, isLocal: true)) {
      await launchVideo(path, isLocal: true);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          new Expanded(
            child: controller.value.initialized
                ? Center(
                    child: Align(
                      child: VideoPlayer(controller),
                    ),
                  )
                : Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      image: DecorationImage(
                        image: AssetImage("assets/purple-materials.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
          ),
          new Container(
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Icon(
                      controller.value.isPlaying
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: whiteColor),
                  onPressed: () {
                    if (controller.value.isPlaying)
                      controller.pause();
                    else
                      controller.play();
                  },
                ),
                FlatButton(
                  child: Icon(Icons.stop, color: whiteColor),
                  onPressed: () {
                    if (controller.value.isPlaying) {
                      controller.seekTo(Duration(seconds: 0));
                      controller.pause();
                    }
                  },
                ),
                FlatButton(
                  child: Icon(Icons.open_with, color: whiteColor),
                  onPressed: () {
                    _launchVideo(filePath).then((result) {
                      print("Error on launch video !");
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AudioPlayerWidget extends StatefulWidget {
  final String filePath;
  final AudioPlayer player;
  AudioPlayerWidget(this.player, this.filePath);

  @override
  _AudioPlayerWidget createState() =>
      new _AudioPlayerWidget(this.player, this.filePath);
}

class _AudioPlayerWidget extends State<AudioPlayerWidget> {
  final String filePath;
  _AudioPlayerWidget(this.audioPlayer, this.filePath);
  int state = 0;
  AudioPlayer audioPlayer;
  Duration duration = Duration(seconds: 0), position = Duration(seconds: 0);

  Function _playHandler() {
    if (state == 0) {
      return () {
        audioPlayer.play(filePath, isLocal: true).then((result) {
          setState(() {
            state = 1;
          });
        });
      };
    }
    if (state == 2) {
      return () {
        audioPlayer.resume().then((result) {
          setState(() {
            state = 1;
          });
        });
      };
    }
    return null;
  }

  Function _stopHandler() {
    if (state != 0) {
      return () {
        audioPlayer.stop().then((result) {
          setState(() {
            state = 0;
            duration = Duration(seconds: 0);
            position = Duration(seconds: 0);
          });
        });
      };
    }
    return null;
  }

  Function _pauseHandler() {
    if (state == 1) {
      return () {
        audioPlayer.pause().then((result) {
          setState(() {
            state = 2;
          });
        });
      };
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    audioPlayer.positionHandler = (Duration p) {
      setState(() => position = p);
    };
    audioPlayer.durationHandler = (Duration d) {
      setState(() => duration = d);
    };
    audioPlayer.completionHandler = () {
      setState(() {
        state = 0;
        position = duration;
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          new Expanded(
            child: new Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                image: DecorationImage(
                  image: AssetImage("assets/purple-materials.jpg"),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          new LinearProgressIndicator(
            value: (position.inSeconds / (duration.inSeconds * 1.0)),
          ),
          new Container(
            color: primaryColor,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Icon(Icons.play_arrow, color: whiteColor),
                  onPressed: _playHandler(),
                ),
                FlatButton(
                  child: Icon(Icons.pause, color: whiteColor),
                  onPressed: _pauseHandler(),
                ),
                FlatButton(
                  child: Icon(Icons.stop, color: whiteColor),
                  onPressed: _stopHandler(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
