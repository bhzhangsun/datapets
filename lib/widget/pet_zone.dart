import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:provider/provider.dart';

class PetZone extends StatefulWidget {
  const PetZone({super.key, required this.camera});
  final CameraDescription camera;
  @override
  State<PetZone> createState() => _PetZoneState();
}

class _PetZoneState extends State<PetZone> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late ObjectDetector _objectDetector;
  List<DetectedObject> _objects = [];

  @override
  void initState() {
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21 // for Android
          : ImageFormatGroup.bgra8888, // for iOS
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _initializeController();

    _objectDetector = ObjectDetector(
        options: ObjectDetectorOptions(
            mode: DetectionMode.single,
            classifyObjects: false,
            multipleObjects: false));

    super.initState();
  }

  Future<void> _initializeController() async {
    await _controller.initialize();
    var count = 50;
    await _controller.startImageStream((image) async {
      print("image: ${image.hashCode}");
      final inputImage = _inputImageFromCameraImage(widget.camera, image);

      if (inputImage == null) return;
      if (count == 0) {
        count = 100;
        print(
            "imputImage: ${inputImage.filePath}, ${inputImage.type.toString()}, ${inputImage.metadata?.toJson().toString()}");
        final List<DetectedObject> objects =
            await _objectDetector.processImage(inputImage);
        if (objects.length == 0) return;

        print(
            "boundingBox: ${objects[0]?.boundingBox.left},${objects[0]?.boundingBox.top},${objects[0]?.boundingBox.width},${objects[0]?.boundingBox.height}");
        setState(() {
          _objects = objects;
        });
      }
      count--;
      print("count: $count");
    });
  }

  InputImage? _inputImageFromCameraImage(
      CameraDescription camera, CameraImage image) {
    final _orientations = {
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeLeft: 90,
      DeviceOrientation.portraitDown: 180,
      DeviceOrientation.landscapeRight: 270,
    };

    // get image rotation
    // it is used in android to convert the InputImage from Dart to Java
    // `rotation` is not used in iOS to convert the InputImage from Dart to Obj-C
    // in both platforms `rotation` and `camera.lensDirection` can be used to compensate `x` and `y` coordinates on a canvas
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(0);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        // front-facing
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        // back-facing
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    // get image format
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    // validate format depending on platform
    // only supported formats:
    // * nv21 for Android
    // * bgra8888 for iOS
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    // since format is constraint to nv21 or bgra8888, both only have one plane
    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    // compose InputImage using bytes
    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation, // used only in Android
        format: format, // used only in iOS
        bytesPerRow: plane.bytesPerRow, // used only in iOS
      ),
    );
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    _objectDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Stack(children: [
            CameraPreview(_controller),
            ..._objects.map((obj) {
              return Positioned(
                  top: obj.boundingBox.top,
                  left: obj.boundingBox.left,
                  child: Container(
                      width: obj.boundingBox.width,
                      height: obj.boundingBox.height,
                      decoration: BoxDecoration(
                          border: Border.all(
                        color: Colors.green, //边框颜色
                        width: 1, //宽度
                      )),
                      child: Text(obj.trackingId.toString())));
            })
          ]);
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
