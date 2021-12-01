enum FileTypes {
  file,
  image,
  imagePng,
  imageGif,
  imageJpeg,
  audio,
  video,
}

extension FileTypesExtention on FileTypes {
  String get value {
    switch (this) {
      case FileTypes.file:
        return '';
      case FileTypes.image:
        return 'image/*';
      case FileTypes.imagePng:
        return 'image/png';
      case FileTypes.imageGif:
        return 'image/gif';
      case FileTypes.imageJpeg:
        return 'image/jpeg';
      case FileTypes.audio:
        return 'audio/*';
      case FileTypes.video:
        return 'video/*';
    }
  }
}
