import 'dart:async';
import 'dart:io';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../config/application.dart';
import '../models/CaptureModel.dart';
import '../models/Category.dart';
import '../models/Series.dart';
import '../utils/ui.dart';
import '../utils/image_thumbnail.dart';

List<Choice> choices;

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class CaptureRoute extends StatefulWidget {
  final String uuid;
  CaptureRoute({this.uuid});

  @override
  _CaptureRoute createState() => new _CaptureRoute(uuid: uuid);
}

class Choice {
  final String title;

  final IconData icon;
  final CameraDescription camera;
  const Choice({this.title, this.icon, this.camera});
}

enum Options { video, videoRecording, photo, audio, audioRecording }

class _CaptureRoute extends State<CaptureRoute> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _animationController;
  Animation _animation;

  CameraController controller;

  var _state = Options.photo;
  bool _initializing = false;

  Category _category;
  bool _loading = false;

  final String uuid;
  _CaptureRoute({this.uuid});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.black,
      appBar: _makeAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: _floatingButton(),
      bottomNavigationBar: _bottomAppBar(),
      body: _initializing ? _showLoading() : _cameraPreviewWidget(),
    );
  }

  @override
  void initState() {
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: 5),
    );

    _animation = Tween(begin: 0.0, end: 500.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.fastOutSlowIn,
      ),
    );

    _prepare();
    super.initState();
  }

  void onAudioRecordButtonPressed() {
    setState(() {
      _loading = true;
    });
    startAudioRecord().then((String filePath) {
      _state = Options.audioRecording;
      if (mounted) {
        setState(() {
          _loading = false;
        });
        if (filePath != null) {
          CaptureModel audio = CaptureModel(
              filePath: filePath,
              seriesUUID: uuid,
              captureMode: CaptureMode.audio);
          CaptureModel.updateItem(audio);
        }
      }
    });
  }

  void onAudioStopButtonPressed() {
    stopAudioRecording().then((_) {
      _state = Options.audio;
      if (mounted) setState(() {});
    });
  }

  Future onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    controller.addListener(() {
      if (mounted) setState(() {});
      if (controller.value.hasError) {
        showInSnackBar('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onTakePictureButtonPressed() {
    setState(() {
      _loading = true;
    });
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
        if (filePath != null) {
          CaptureModel image = CaptureModel(
              filePath: filePath,
              seriesUUID: uuid,
              captureMode: CaptureMode.picture);
          CaptureModel.updateItem(image);
        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    setState(() {
      _loading = true;
    });
    startVideoRecording().then((String filePath) {
      _state = Options.videoRecording;
      if (mounted) {
        setState(() {
          _loading = false;
        });
        if (filePath != null) {
          CaptureModel video = CaptureModel(
              filePath: filePath,
              seriesUUID: uuid,
              captureMode: CaptureMode.video);
          CaptureModel.updateItem(video);
        }
      }
    });
  }

  void onVideoStopButtonPressed() {
    stopVideoRecording().then((_) {
      _state = Options.video;
      if (mounted) setState(() {});
    });
  }

  Future<String> startAudioRecord() async {
    final String dirPath =
        '${Application.appDir}/Categories/${_category.name}/$uuid/Audios';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.aac';

    try {
      await AudioRecorder.start(
          path: filePath, audioOutputFormat: AudioOutputFormat.AAC);
    } on Exception catch (e) {
      showInSnackBar(e.toString());
      return null;
    }
    return filePath;
  }

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
            label: 'HIDE',
            onPressed: _scaffoldKey.currentState.hideCurrentSnackBar),
      ),
    );
  }

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final String dirPath =
        '${Application.appDir}/Categories/${_category.name}/$uuid/Movies';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    print("$filePath");

    try {
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  Future<void> stopAudioRecording() async {
    try {
      await AudioRecorder.stop();
    } on Exception catch (e) {
      showInSnackBar(e.toString());
      return null;
    }
  }

  Future<void> stopVideoRecording() async {
    if (!controller.value.isRecordingVideo) {
      return null;
    }

    try {
      await controller.stopVideoRecording();
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
  }

  Future<String> takePicture() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }
    final String dirPath =
        '${Application.appDir}/Categories/${_category.name}/$uuid/Pictures';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    try {
      await controller.takePicture(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  _bottomAppBar() {
    return BottomAppBar(
      elevation: 4.0,
      color: primaryColor,
      shape: CircularNotchedRectangle(),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: new Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              color: whiteColor,
              icon: Icon(Icons.photo_camera),
              onPressed: _changeIfState(_state == Options.photo, Options.photo),
            ),
            IconButton(
              color: whiteColor,
              icon: Icon(Icons.videocam),
              onPressed: _changeIfState(
                _state == Options.video || _state == Options.videoRecording,
                Options.video,
              ),
            ),
            IconButton(
              color: whiteColor,
              icon: Icon(Icons.record_voice_over),
              onPressed: _changeIfState(
                _state == Options.audio || _state == Options.audioRecording,
                Options.audio,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cameraPreviewWidget() {
    return Align(
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      ),
    );
  }

  Function _captureButtonHandler() {
    if (_loading) return null;
    return () {
      if (_state == Options.photo) {
        onTakePictureButtonPressed();
      } else if (_state == Options.video) {
        _animationController.repeat();
        onVideoRecordButtonPressed();
      } else if (_state == Options.videoRecording) {
        onVideoStopButtonPressed();
      } else if (_state == Options.audio) {
        onAudioRecordButtonPressed();
      } else if (_state == Options.audioRecording) {
        onAudioStopButtonPressed();
      }
    };
  }

  Function _changeIfState(condition, target) {
    void changeState() {
      setState(() {
        _state = target;
      });
    }

    return condition ? null : changeState;
  }

  Widget _floatingButton() {
    return FloatingActionButton(
      backgroundColor: secondaryColor,
      foregroundColor: whiteColor,
      child: _floatingButtonChild(),
      onPressed: _captureButtonHandler(),
    );
  }

  Widget _floatingButtonChild() {
    if (_loading) {
      return Padding(
        padding: EdgeInsets.all(15.0),
        child: CircularProgressIndicator(
          valueColor: new AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }
    if (_state == Options.audioRecording || _state == Options.videoRecording) {
      return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget child) {
          int value = (_animation.value as double).toInt();
          if (value > 250) {
            value = 500 - value;
          }
          double size = value / 5.0;
          if (size < 30.0) {
            size = 30.0;
          }
          return Icon(
            Icons.stop,
            size: size,
            color: Colors.black.withRed(value),
          );
        },
      );
    }
    return Icon(Icons.archive);
  }

  Widget _makeAppBar() {
    return AppBar(
      title: Text('Capture', style: TextStyle(color: whiteColor)),
      backgroundColor: primaryColor,
      elevation: 4.0,
    );
  }

  void _prepare() async {
    _initializing = true;
    _category = await Series.getCategoryOfSeriesUUID(uuid);
    await onNewCameraSelected(choices[0].camera);
    await Future.delayed(Duration(milliseconds: 500));
    _initializing = false;
    setState(() {});
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
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
}
