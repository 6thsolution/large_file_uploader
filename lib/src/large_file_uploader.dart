import 'dart:async';

import 'package:universal_html/html.dart' as html;

/// Callback exposing currently upload progress.
typedef UploadProgressListener = Function(int progress);

/// Callback exposing upload fail event.
typedef UploadFailureListener = Function();

/// Callback exposing upload complete event.
typedef UploadCompleteListener = Function();

/// Uploading large file util by using JS in flutter web.
class LargeFileUploader {
  LargeFileUploader({this.jsWorkerName = 'upload_worker.js'})
      : _worker = html.Worker(jsWorkerName);

  /// The name of the js file in the web folder.
  ///
  /// Defaults to 'upload_worker.js'
  final String jsWorkerName;
  final html.Worker _worker;
  Timer? _timer;
  int _fakeProgress = 0;

  void selectFileAndUpload({
    String method = 'POST',
    String fileKeyInFormData = 'file',
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
    html.FileUploadInputElement fileUploadInputElement =
        html.FileUploadInputElement();
    fileUploadInputElement.multiple = false;
    fileUploadInputElement.click();

    html.File? file;

    fileUploadInputElement.onChange.listen((_) {
      file = fileUploadInputElement.files?.first;

      if (file != null) {
        _worker.postMessage({
          'method': method,
          'fileKeyInFormData': fileKeyInFormData,
          'uploadUrl': uploadUrl,
          'data': data,
          'headers': headers,
          'file': file,
        });

        if (onSendWithFakePreProcessProgress != null) {
          _timer = Timer.periodic(
              Duration(milliseconds: fakePreProcessProgressPeriodInMillisecond),
              (Timer timer) {
            if (_fakeProgress != fakePreProcessMaxProgress) {
              _fakeProgress++;
              onSendWithFakePreProcessProgress.call(_fakeProgress);
            } else {
              _disposeTimerAndFakeProgress();
            }
          });
        }

        _worker.onMessage.listen((data) {
          _handleCallbacks(data.data,
              onSendProgress: onSendProgress,
              fakePreProcessMaxProgress: fakePreProcessMaxProgress,
              onSendWithFakePreProcessProgress:
                  onSendWithFakePreProcessProgress,
              onFailure: onFailure,
              onComplete: onComplete);
        });
      } else {
        onFailure?.call();
      }
    });
  }

  void _handleCallbacks(
    data, {
    required UploadProgressListener onSendProgress,
    required int fakePreProcessMaxProgress,
    UploadProgressListener? onSendWithFakePreProcessProgress,
    UploadFailureListener? onFailure,
    UploadCompleteListener? onComplete,
  }) {
    if (data == null) return;

    if (data is int) {
      onSendProgress.call(data);
      if (data != 0) {
        _disposeTimerAndFakeProgress();
        onSendWithFakePreProcessProgress?.call((fakePreProcessMaxProgress +
                (data * ((100 - fakePreProcessMaxProgress) / 100)))
            .toInt());
      }
    } else if (data.toString() == 'done') {
      onSendProgress.call(100);
      onSendWithFakePreProcessProgress?.call(100);
      _disposeTimerAndFakeProgress();
      onComplete?.call();
    } else if (data.toString() == 'request failed') {
      _disposeTimerAndFakeProgress();
      onFailure?.call();
    }
  }

  void _disposeTimerAndFakeProgress() {
    if (_timer?.isActive ?? false) {
      _fakeProgress = 0;
      _timer?.cancel();
    }
  }
}
