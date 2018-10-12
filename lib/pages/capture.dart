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

class _CaptureRoute extends State<CaptureRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController controller;
  CaptureModel model;

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
          model = CaptureModel(
              filePath: filePath,
              seriesUUID: uuid,
              captureMode: CaptureMode.audio);
        }
      }
    });
  }

  void onAudioStopButtonPressed() {
    stopAudioRecording().then((_) {
      _state = Options.audio;
      CaptureModel.updateItem(model);
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
    _loading = true;
    takePicture().then((String filePath) {
      if (mounted) {
        _loading = false;
        if (filePath != null) {
          model = CaptureModel(
              filePath: filePath,
              seriesUUID: uuid,
              captureMode: CaptureMode.picture);
          CaptureModel.updateItem(model);
        }
        setState(() {});
      }
    });
  }

  void onVideoRecordButtonPressed() {
    _loading = true;
    startVideoRecording().then((String filePath) {
      if (mounted) {
        _state = Options.videoRecording;
        _loading = false;
        if (filePath != null) {
          model = CaptureModel(
              filePath: filePath,
              seriesUUID: uuid,
              captureMode: CaptureMode.video);
        }
        setState(() {});
      }
    });
  }

  void onVideoStopButtonPressed() {
    stopVideoRecording().then((_) {
      _state = Options.video;
      CaptureModel.updateItem(model);
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
      return Icon(
        Icons.stop,
        size: 50.0,
        color: Colors.black.withRed(50),
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
