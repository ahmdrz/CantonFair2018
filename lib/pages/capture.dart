import 'dart:async';
import 'dart:io';

import 'package:audio_recorder/audio_recorder.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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

enum Options {
  video,
  videoRecording,
  photo,
  audio,
  audioRecording,
  hqVideo,
  hqPhoto,
}

class _CaptureRoute extends State<CaptureRoute> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  CameraController controller;
  CaptureModel model;
  String openTime;

  var _state = Options.photo;
  bool _initializing = false;

  Category _category;
  bool _loading = false;

  final String uuid;
  _CaptureRoute({this.uuid}) {
    openTime = timestamp();
  }

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
  void dispose() {
    print("capture dispose");
    super.dispose();
    this.controller?.dispose();
  }

  @override
  void initState() {
    _prepare();
    super.initState();
  }

  void onAudioRecordButtonPressed() {
    setState(() => _loading = true);
    startAudioRecord().then((String filePath) {
      _state = Options.audioRecording;
      if (mounted) {
        setState(() => _loading = false);
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

  void onHQTakePhotoButtonPressed() {
    setState(() => _loading = true);
    hqTakePhoto().then((String filePath) {
      if (mounted) {
        _state = Options.hqPhoto;
        setState(() => _loading = false);
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

  void onHQVideoRecordButtonPressed() {
    setState(() => _loading = true);
    hqVideoRecord().then((String filePath) {
      if (mounted) {
        _state = Options.hqVideo;
        setState(() => _loading = false);
        if (filePath != null) {
          model = CaptureModel(
              filePath: filePath,
              seriesUUID: uuid,
              captureMode: CaptureMode.video);
          CaptureModel.updateItem(model);
        }
        setState(() {});
      }
    });
  }

  Future<String> hqTakePhoto() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    if (image == null) return null;
    final String dirPath =
        '${Application.appDir}/Categories/${_category.name}/${openTime}_$uuid/Photos';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';
    await image.copy(filePath);
    await image.delete();
    return filePath;
  }

  Future<String> hqVideoRecord() async {
    var video = await ImagePicker.pickVideo(source: ImageSource.camera);
    if (video == null) return null;
    final String dirPath =
        '${Application.appDir}/Categories/${_category.name}/${openTime}_$uuid/Movies';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.mp4';
    await video.copy(filePath);
    await video.delete();
    return filePath;
  }

  void onTakePictureButtonPressed() {
    setState(() => _loading = true);
    takePicture().then((String filePath) {
      if (mounted) {
        _state = Options.photo;
        setState(() => _loading = false);
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
    setState(() => _loading = true);
    startVideoRecording().then((String filePath) {
      if (mounted) {
        _state = Options.videoRecording;
        setState(() => _loading = false);
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

  Future<String> startAudioRecord() async {
    final String dirPath =
        '${Application.appDir}/Categories/${_category.name}/${openTime}_$uuid/Audios';
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

  Future<String> startVideoRecording() async {
    if (!controller.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    final String dirPath =
        '${Application.appDir}/Categories/${_category.name}/${openTime}_$uuid/Movies';
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
        '${Application.appDir}/Categories/${_category.name}/${openTime}_$uuid/Pictures';
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
            IconButton(
              color: whiteColor,
              icon: Icon(Icons.ondemand_video),
              onPressed:
                  _changeIfState(_state == Options.hqVideo, Options.hqVideo),
            ),
            IconButton(
              color: whiteColor,
              icon: Icon(Icons.camera_enhance),
              onPressed:
                  _changeIfState(_state == Options.hqPhoto, Options.hqPhoto),
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
    if (_loading || _initializing) return null;
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
      } else if (_state == Options.hqVideo) {
        onHQVideoRecordButtonPressed();
      } else if (_state == Options.hqPhoto) {
        onHQTakePhotoButtonPressed();
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
      backgroundColor:
          (_state == Options.audioRecording || _state == Options.videoRecording)
              ? whiteColor
              : secondaryColor,
      child: _floatingButtonChild(),
      onPressed: _captureButtonHandler(),
    );
  }

  Widget _floatingButtonChild() {
    if (_loading || _initializing) {
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
        size: 35.0,
        color: Colors.redAccent,
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
    setState(() => _initializing = true);
    await Future.delayed(Duration(milliseconds: 250));
    _category = await Series.getCategoryOfSeriesUUID(uuid);
    if (_category == null) {
      showInSnackBar("Category not found !");
      return;
    }
    await onNewCameraSelected(choices[0].camera);
    await Future.delayed(Duration(milliseconds: 250));
    setState(() => _initializing = false);
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
