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

class UploadExample extends StatelessWidget {
  const UploadExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
            onPressed: () {
              LargeFileUploader(
                jsWorkerName: 'upload_worker.js',
              ).selectFileAndUpload(
                method: 'POST',
                fileKeyInFormData: 'file',
                uploadUrl: 'https://baseurl.com/upload-path',
                data: {
                  'title': 'awesome file',
                },
                headers: {'Authorization': 'Bearer jwtToken'},
                onSendProgress: (progress) =>
                    debugPrint('onSendProgress:$progress'),
                fakePreProcessMaxProgress: 30,
                fakePreProcessProgressPeriodInMillisecond: 500,
                onSendWithFakePreProcessProgress: (progress) =>
                    debugPrint('onSendWithFakePreProcessProgress:$progress'),
                onComplete: () => debugPrint('onComplete'),
                onFailure: () => debugPrint('onFailure'),
              );
            },
            child: const Text("Select File And Upload")),
      ],
    );
  }
}
