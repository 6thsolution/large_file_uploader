# Large File Uploader (Only Web)

A plugin for uploading large file in flutter web.

# Let's get started

### 1 - Depend on it

##### Add it to your package's pubspec.yaml file

```yml
dependencies:
  large_file_uploader: ^0.0.2
```


### 2 - Install it

##### Install packages from the command line
```sh
flutter pub get
```


### 3 - Import it

##### Import it to your project
```dart
import 'package:large_file_uploader/large_file_uploader.dart';
```

### 4 - Add the js file

##### Add the [upload_worker.js](https://github.com/6thsolution/large_file_uploader/blob/master/example/web/upload_worker.js) file to your project web folder.



## How to use?
##### Simple usage

```dart
LargeFileUploader().selectFileAndUpload(
    uploadUrl:
      'https://baseurl.com/upload-path',
    data: {
      'title': 'awesome file',
    },
    headers: {
      'Authorization':
          'Bearer jwtToken'
    },
    onSendProgress: (progress) =>
        debugPrint('onSendProgress:$progress'),
    onComplete: () => debugPrint('onComplete'),
    onFailure: () => debugPrint('onFailure'),
  );
```

##### Advanced usage

```dart
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
```