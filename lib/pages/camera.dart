import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../config/application.dart';
import '../models/Category.dart';
import '../models/ImageModel.dart';
import '../models/Series.dart';
import '../utils/ui.dart';

List<Choice> choices;

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class CameraRoute extends StatefulWidget {
  final String uuid;
  CameraRoute({this.uuid});

  @override
  _CameraRoute createState() => new _CameraRoute(uuid: uuid);
}

class Choice {
  final String title;

  final IconData icon;
  final CameraDescription camera;
  const Choice({this.title, this.icon, this.camera});
}

enum Options { video, videoRecording, photo, audio, audioRecording }

class _CameraRoute extends State<CameraRoute> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  AnimationController _animationController;
  Animation _animation;

  CameraController controller;
  String imagePath;
  String videoPath;

  var _state = Options.photo;
  bool _initializing = false;

  Category _category;
  bool _loading = false;

  final String uuid;
  _CameraRoute({this.uuid});

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

  Future onNewCameraSelected(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }
    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
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

  void onStopButtonPressed() {
    stopVideoRecording().then((_) {
      _state = Options.video;
      if (mounted) setState(() {});
    });
  }

  void onTakePictureButtonPressed() {
    setState(() {
      _loading = true;
    });
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          _loading = false;
        });
        if (filePath != null) {
          ImageModel image = ImageModel(filePath: filePath, seriesUUID: uuid);
          ImageModel.updateImage(image);
        }
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      _state = Options.videoRecording;
      if (mounted) setState(() {});
    });
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
        '${Application.appDir}/Categories/${_category.name}/Movies';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';

    if (controller.value.isRecordingVideo) {
      // A recording is already started, do nothing.
      return null;
    }

    try {
      videoPath = filePath;
      await controller.startVideoRecording(filePath);
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return filePath;
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
        '${Application.appDir}/Categories/Pictures/${_category.name}';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

    print("$filePath");

    if (controller.value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return null;
    }

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
        onStopButtonPressed();
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

  Widget _floatingButton() {
    return FloatingActionButton(
      backgroundColor: secondaryColor,
      foregroundColor: whiteColor,
      child: _floatingButtonChild(),
      onPressed: _captureButtonHandler(),
    );
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
