import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:video_player/video_player.dart';

import '../utils/ui.dart';

List<Choice> choices;

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class CameraRoute extends StatefulWidget {
  @override
  _CameraRoute createState() => new _CameraRoute();
}

class Choice {
  final String title;

  final IconData icon;
  final CameraDescription camera;
  const Choice({this.title, this.icon, this.camera});
}

class _CameraRoute extends State<CameraRoute>
    with SingleTickerProviderStateMixin {    
  CameraController controller;
  String imagePath;
  String videoPath;
  VideoPlayerController videoController;
  VoidCallback videoPlayerListener;
  bool _isVideoSelected;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return scaffoldWrapper(
      context: context,
      pageName: "Camera",
      key: _scaffoldKey,
      backgroundColor: Colors.black,      
      appBar: _makeAppBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: secondaryColor,
        foregroundColor: controller != null && controller.value.isRecordingVideo
            ? Colors.red
            : whiteColor,
        elevation: 4.0,
        icon: Icon(_isVideoSelected ? Icons.videocam : Icons.camera),
        label: Text(_isVideoSelected
            ? (controller.value.isRecordingVideo
                ? 'Stop recording'
                : 'Start recording')
            : 'Take picture'),
        onPressed: () {
          if (_isVideoSelected) {
            if (controller.value.isRecordingVideo)
              onStopButtonPressed();
            else
              onVideoRecordButtonPressed();
          } else
            onTakePictureButtonPressed();
        },
      ),
      bottomNavigationBar: BottomAppBar(
        color: primaryColor,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: new Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.search),
                onPressed: () {},
                iconSize: 30.0,
                color: whiteColor,
              ),
              IconButton(
                color: whiteColor,
                icon: Icon(!_isVideoSelected ? Icons.videocam : Icons.camera),
                onPressed: controller != null &&
                        controller.value.isInitialized &&
                        controller.value.isRecordingVideo
                    ? null
                    : () {
                        setState(() {
                          _isVideoSelected = !_isVideoSelected;
                        });
                      },
                iconSize: 30.0,
              ),
            ],
          ),
        ),
      ),
      body: Align(
        child: _cameraPreviewWidget(),
      ),
    );
  }

  @override
  void initState() {
    _isVideoSelected = false;
    super.initState();
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
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
      if (mounted) setState(() {});
      showInSnackBar('Video recorded to: $videoPath');
    });
  }

  void onTakePictureButtonPressed() {
    takePicture().then((String filePath) {
      if (mounted) {
        setState(() {
          imagePath = filePath;
          videoController?.dispose();
          videoController = null;
        });
        if (filePath != null) showInSnackBar('Picture saved to $filePath');
      }
    });
  }

  void onVideoRecordButtonPressed() {
    startVideoRecording().then((String filePath) {
      if (mounted) setState(() {});
      if (filePath != null) showInSnackBar('Saving video to $filePath');
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

    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Movies/flutter_test';
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
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/Pictures/flutter_test';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${timestamp()}.jpg';

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

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      onNewCameraSelected(choices[0].camera);
      return Container();
    } else {
      // return SizedBox(child: CameraPreview(controller));

      return AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: CameraPreview(controller),
      );
    }
  }

  Widget _makeAppBar() {
    return AppBar(
      leading: new IconButton(
        icon: Icon(Icons.arrow_back, color: whiteColor),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text('Camera handler', style: TextStyle(color: whiteColor)),
      backgroundColor: primaryColor,
      actions: <Widget>[
        PopupMenuButton<Choice>(        
          icon: new Icon(Icons.more_vert, color: whiteColor),
          padding: EdgeInsets.all(10.0),
          onSelected: _select,
          itemBuilder: (BuildContext context) {
            return choices.map((Choice choice) {
              return PopupMenuItem<Choice>(
                value: choice,
                child: Text(choice.title),
              );
            }).toList();
          },
        ),
      ],
    );
  }

  void _select(Choice choice) {
    // onNewCameraSelected(choice.camera);
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}
