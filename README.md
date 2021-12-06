# Large File Uploader (Only Web)

A plugin for uploading large file in flutter web.

# Let's get started

### 1 - Depend on it

##### Add it to your package's pubspec.yaml file

```yml
dependencies:
  large_file_uploader: ^0.0.5
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

### 4 - Copy It

##### Copy upload_worker.js to project public folder

## How to use?
##### Simple usage

```dart
LargeFileUploader().selectFileAndUpload(
    uploadUrl:
      'https://baseurl.com/upload-path',
    data: {
      'title': 'My image', //Additional fields to send with file
    },
    headers: {
      'Authorization':
          'Bearer <accessToken>' 
    },
    onSendProgress: (progress) =>
        debugPrint('onSendProgress:$progress'),
    onComplete: () => debugPrint('onComplete'),
    onFailure: () => debugPrint('onFailure'),
  );
```

##### Advanced usage

```dart
  import 'dart:html' as html;
  import 'package:large_file_uploader/large_file_uploader.dart';

  ...

  final _largeFileUploader = LargeFileUploader();
  html.File? file; 
  html.File? thumbnail;

  _largeFileUploader._largeFileUploader.pick(
        type: FileTypes.video, 
        callback: (file) {
        pickedThumbnail = file;
    });
  );

  _largeFileUploader._largeFileUploader.pick(
        customType: 'image/jpeg', 
        callback: (file) {
        thumbnail = file;
    });
  );
  
  if(file != null){
    _largeFileUploader.upload(
        uploadUrl: url,
        headers: {"Authorization": "Bearer <accessToken>"},
        data: {"title": "My Image", "thumbnail": thumbnail, "file": file},
        onSendProgress: (progress) => debugPrint(progress.toString()),
        onComplete: (response) => debugPrint(response.toString()),
    );
  }
  
```