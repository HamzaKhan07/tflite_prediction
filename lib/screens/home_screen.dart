import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_tflite/flutter_tflite.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? image;
  File? imageFile;
  bool isLoading = false;
  String result = '';

  @override
  void initState() {
    super.initState();
    loadModel();
  }

  Future loadModel() async {
    setState(() {
      isLoading = true;
    });
    Tflite.close();
    String res;
    res = (await Tflite.loadModel(
        model: "assets/model-covid.tflite", labels: "assets/labels.txt"))!;
    print("Models loading status: $res");
    setState(() {
      isLoading = false;
    });
  }

  Future imageClassification(File image) async {
    final List? recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 1,
      threshold: 0.05,
      imageMean: 0,
      imageStd: 255,
    );

    String confidence = recognitions![0]['confidence'].toString();
    String label = recognitions[0]['label'].toString();

    setState(() {
      result = '$label - $confidence';
    });

    // setState(() {
    //   _results = recognitions!;
    //   _image = image;
    //   imageSelect = true;
    // });
    print(recognitions);
  }

  void pickImage() async {
    final ImagePicker _picker = ImagePicker();
    // Pick an image
    image = await _picker.pickImage(source: ImageSource.gallery);
    setState(() {
      imageFile = File(image!.path);
    });
    imageClassification(imageFile!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pickImage();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text('TFLite'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 20,
              ),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.5,
                decoration: const BoxDecoration(
                  color: Colors.lightBlueAccent,
                  borderRadius: BorderRadius.all(
                    Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20.0),
                  child: imageFile == null
                      ? null
                      : Image.file(
                          imageFile!,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Text(result),
            ],
          ),
        ),
      ),
    );
  }
}
