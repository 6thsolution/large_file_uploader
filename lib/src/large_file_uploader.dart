import 'dart:async';

import 'package:large_file_uploader/src/enum/file_types.dart';
import 'package:universal_html/html.dart' as html;

/// Callback exposing currently upload progress.
typedef UploadProgressListener = Function(int progress, String id);

/// Callback exposing upload fail event.
typedef UploadFailureListener = Function();

/// Callback exposing upload complete event.
typedef UploadCompleteListener = Function(String response);

/// Callback exposing one or multiple files selected.
typedef OnFileSelectedListener = Function(html.File file);

/// Uploading large file util by using JS in flutter web.
class LargeFileUploader {
  LargeFileUploader() : _worker = html.Worker('upload_worker.js');

  final html.Worker _worker;
  Timer? _timer;
  int _fakeProgress = 0;

  StreamSubscription? _streamSubscription;

  void selectFileAndUpload({
    String method = 'POST',
    FileTypes type = FileTypes.file,
    String? customFileType,
    bool allowMultiple = false,
    required String uploadUrl,
    Map<String, dynamic>? data,
    Map<String, dynamic>? headers,
    required UploadProgressListener onSendProgress,
    int fakePreProcessMaxProgress = 30,
    int fakePreProcessProgressPeriodInMillisecond = 500,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) {
    pick(
      type: type,
      customFileType: customFileType,
      allowMultiple: allowMultiple,
      callback: (file) {
        data ??= {};
        data!["file"] = file;
        upload(
          method: method,
          name: file.name,
          uploadUrl: uploadUrl,
          data: data!,
          headers: headers,
          onSendProgress: onSendProgress,
          fakePreProcessMaxProgress: fakePreProcessMaxProgress,
          fakePreProcessProgressPeriodInMillisecond: fakePreProcessProgressPeriodInMillisecond,
          onSendWithFakePreProcessProgress: onSendWithFakePreProcessProgress,
          onFailure: onFailure,
          onComplete: onComplete,
        );
      },
    );
  }

  void pick({
    FileTypes type = FileTypes.file,
    String? customFileType,
    bool allowMultiple = false,
    required OnFileSelectedListener callback,
  }) {
    html.FileUploadInputElement fileUploadInputElement = html.FileUploadInputElement();
    fileUploadInputElement.accept = customFileType ?? type.value;
    fileUploadInputElement.multiple = allowMultiple;
    fileUploadInputElement.click();

    fileUploadInputElement.onChange.listen((_) {
      if (fileUploadInputElement.files != null) {
        for (final file in fileUploadInputElement.files!) {
          callback.call(file);
        }
      }
    });
  }

  void upload({
    String method = 'POST',
    required String name,
    required String uploadUrl,
    required Map<String, dynamic> data,
    Map<String, dynamic>? headers,
    required UploadProgressListener onSendProgress,
    int fakePreProcessMaxProgress = 30,
    int fakePreProcessProgressPeriodInMillisecond = 500,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) async {
    _worker.postMessage({
      'method': method,
      'uploadUrl': uploadUrl,
      'data': data,
      'headers': headers,
    });

    if (onSendWithFakePreProcessProgress != null) {
      _timer = Timer.periodic(Duration(milliseconds: fakePreProcessProgressPeriodInMillisecond), (Timer timer) {
        if (_fakeProgress != fakePreProcessMaxProgress) {
          _fakeProgress++;
          onSendWithFakePreProcessProgress.call(_fakeProgress, 'fake');
        } else {
          _disposeTimerAndFakeProgress();
        }
      });
    }

    _streamSubscription = _worker.onMessage.listen((data) {
      _handleCallbacks(
        data.data,
        name: name,
        onSendProgress: onSendProgress,
        fakePreProcessMaxProgress: fakePreProcessMaxProgress,
        onSendWithFakePreProcessProgress: onSendWithFakePreProcessProgress,
        onFailure: onFailure,
        onComplete: onComplete,
      );
    });
  }

  void _handleCallbacks(
    data, {
    required String name,
    required UploadProgressListener onSendProgress,
    required int fakePreProcessMaxProgress,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) {
    if (data == null) return;

    if (data is int) {
      onSendProgress.call(data, name);
      if (data != 0) {
        _disposeTimerAndFakeProgress();
        onSendWithFakePreProcessProgress?.call(
          (fakePreProcessMaxProgress + (data * ((100 - fakePreProcessMaxProgress) / 100))).toInt(),
          name,
        );
      }
    } else if (data.toString() == 'request failed') {
      _disposeTimerAndFakeProgress();
      onFailure?.call();
    } else {
      onSendWithFakePreProcessProgress?.call(100, name);
      _disposeTimerAndFakeProgress();
      onComplete?.call(data);
      _streamSubscription?.cancel();
    }
  }

  void _disposeTimerAndFakeProgress() {
    if (_timer?.isActive ?? false) {
      _fakeProgress = 0;
      _timer?.cancel();
    }
  }
}
