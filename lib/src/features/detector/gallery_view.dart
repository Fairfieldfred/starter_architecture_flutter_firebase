import 'dart:convert';
// import 'dart:ffi';
import 'dart:io';

import 'package:a_hole_meter/src/features/detector/painters/gallery_face_detector_painter.dart';
import 'package:camera/camera.dart';
import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '/src/utils/utils.dart';

class GalleryView extends StatefulWidget {
  const GalleryView(
      {super.key,
      required this.title,
      this.text,
      required this.onImage,
      required this.onDetectorViewModeChanged});

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;
  ImagePicker? _imagePicker;
  double scaleX = 1.0;
  double scaleY = 1.0;
  GalleryFaceDetectorPainter? _customPainter;
  final _cameraLensDirection = CameraLensDirection.front;
  final InputImageRotation rotation = InputImageRotation.rotation0deg;
  Size? imageSize;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
      enableClassification: true,
    ),
  );

  List<Face> faces = [];

  @override
  void initState() {
    super.initState();

    _imagePicker = ImagePicker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: widget.onDetectorViewModeChanged,
                child: Icon(
                  Platform.isIOS ? Icons.camera_alt_outlined : Icons.camera,
                ),
              ),
            ),
          ],
        ),
        body: _galleryBody());
  }

  Widget _galleryBody() {
    return ListView(shrinkWrap: true, children: [
      _image != null
          ? SizedBox(
              height: 400,
              // ignore: sort_child_properties_last
              child: Stack(fit: StackFit.expand, children: [
                Image.file(
                  _image!,
                ),
                CustomPaint(painter: _customPainter),
              ]),
            )
          : const Icon(
              Icons.image,
              size: 200,
            ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          onPressed: _getImageAsset,
          child: const Text('From Assets'),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('From Gallery'),
          onPressed: () => _getImage(ImageSource.gallery),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: ElevatedButton(
          child: const Text('Take a picture'),
          onPressed: () => _getImage(ImageSource.camera),
        ),
      ),
      if (_image != null)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}'),
        ),
    ]);
  }

  Future _getImage(ImageSource source) async {
    setState(() {
      _image = null;
      _path = null;
    });
    final pickedFile = await _imagePicker?.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
    }
  }

  Future _getImageAsset() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    final assets = manifestMap.keys
        .where((String key) => key.contains('images/'))
        .where((String key) =>
            key.contains('.jpg') ||
            key.contains('.jpeg') ||
            key.contains('.png') ||
            key.contains('.webp'))
        .toList();

    // ignore: use_build_context_synchronously
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Select image',
                    style: TextStyle(fontSize: 20),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.7),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          for (final path in assets)
                            GestureDetector(
                              onTap: () async {
                                Navigator.of(context).pop();
                                _processFile(await getAssetPath(path));
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image.asset(path),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel')),
                ],
              ),
            ),
          );
        });
  }

//   Future _processFile(String path) async {
//     final File imageFile = File(path);
//     final tempFaces = await _faceDetector.processImage(
//         InputImage.fromFile(imageFile)); // replace with your image path
//     final imglib.Image? originalImage =
//         imglib.decodeImage(await imageFile.readAsBytes());
//     final imageSize =
//         Size(originalImage!.width.toDouble(), originalImage.height.toDouble());
//     scaleX = MediaQuery.of(context).size.width / imageSize.width;
//     scaleY = 400 / imageSize.height;
//     setState(() {
//       _image = File(path);
//       faces = tempFaces;
//     });
//     _path = path;
//     final inputImage = InputImage.fromFilePath(path);
//     widget.onImage(inputImage);
//   }
// }

  Future _processFile(String path) async {
    final File imageFile = File(path);
    final imglib.Image? originalImage =
        imglib.decodeImage(await imageFile.readAsBytes());
    final imglib.Image bakedImage = imglib.bakeOrientation(originalImage!);
    final tempDir = await getTemporaryDirectory();
    final tempPath = tempDir.path;
    File bakedImageFile = File('$tempPath/image.jpg')
      ..writeAsBytesSync(imglib.encodeJpg(bakedImage));
    final tempFaces = await _faceDetector.processImage(
        InputImage.fromFile(bakedImageFile)); // replace with your image path

    imageSize =
        Size(originalImage.width.toDouble(), originalImage.height.toDouble());
    final fileBytes = File(path).readAsBytesSync();
    final exifData = await readExifFromBytes(fileBytes);
    final orientation = exifData['Image Orientation'];
    debugPrint('orientation: $orientation');
    final lensModel = exifData['EXIF LensModel'];
    debugPrint('lensmodel: $lensModel');
    _customPainter = GalleryFaceDetectorPainter(
      tempFaces,
      imageSize!,
      _cameraLensDirection,
    );
    setState(() {
      _image = File(path);
      faces = tempFaces;
    });
    _path = path;
    final inputImage = InputImage.fromFilePath(path);
    widget.onImage(inputImage);
  }
}

class RectanglePainter extends CustomPainter {
  final Rect? rect;

  RectanglePainter({this.rect});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    if (rect != null) {
      canvas.drawRect(rect!, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
