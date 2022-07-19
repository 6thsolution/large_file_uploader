// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:flutter/material.dart';
import 'package:large_file_uploader/large_file_uploader.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const UploadExample(),
    );
  }
}

class UploadExample extends StatefulWidget {
  const UploadExample({Key? key}) : super(key: key);

  @override
  State<UploadExample> createState() => _UploadExampleState();
}

class _UploadExampleState extends State<UploadExample> {
  late final LargeFileUploader _largeFileUploader;

  html.File? pickedFile;
  html.File? pickedThumbnail;

  bool isFileSelected = false;
  bool isThumbnailSelected = false;

  final accessToken = '';
  final url = '';

  @override
  void initState() {
    _largeFileUploader = LargeFileUploader();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  _largeFileUploader.pick(
                      type: FileTypes.file,
                      callback: (file) {
                        setState(() {
                          pickedFile = file;
                          isFileSelected = false;
                        });
                      });
                },
                child: const Text("Select File And Upload")),
            const SizedBox(
              height: 8,
            ),
            if (isFileSelected)
              const Text(
                "You need to select a file first",
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () {
                  _largeFileUploader.pick(
                      type: FileTypes.image,
                      callback: (file) {
                        setState(() {
                          pickedThumbnail = file;
                          isThumbnailSelected = false;
                        });
                      });
                },
                child: const Text("Select Thumbnail")),
            const SizedBox(
              height: 8,
            ),
            if (isThumbnailSelected)
              const Text(
                "You need to select a thumbnail first",
                style: TextStyle(color: Colors.red),
              ),
            const SizedBox(
              height: 8,
            ),
            ElevatedButton(
                onPressed: () {
                  if (pickedFile != null && pickedThumbnail != null) {
                    _largeFileUploader.upload(
                      uploadUrl: url,
                      name: '1',
                      headers: {"Authorization": "Bearer $accessToken"},
                      data: {"title": "Sample Title", "thumbnail": pickedThumbnail, "file": pickedFile},
                      onSendProgress: (progress, id) => debugPrint('$id: $progress'),
                      onComplete: (response) => debugPrint(response.toString()),
                    );

                    setState(() {
                      isFileSelected = false;
                      isThumbnailSelected = false;
                    });
                  } else {
                    setState(() {
                      isFileSelected = true;
                      isThumbnailSelected = true;
                    });
                  }
                },
                child: const Text("Upload selected file")),
          ],
        ),
      ),
    );
  }
}
