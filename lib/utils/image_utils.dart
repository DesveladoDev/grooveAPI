import 'dart:io';
import 'dart:ui' as ui;

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart' as picker;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:salas_beats/utils/exceptions.dart';
import 'package:salas_beats/utils/permissions.dart';

enum ImageSource {
  camera,
  gallery,
  network,
  asset,
}

enum ImageFormat {
  jpeg,
  png,
  webp,
  gif,
  bmp,
}

enum ImageQuality {
  low(30),
  medium(60),
  high(80),
  veryHigh(95),
  original(100);
  
  const ImageQuality(this.value);
  final int value;
}

class ImageDimensions {
  
  const ImageDimensions(this.width, this.height);
  final int width;
  final int height;
  
  double get aspectRatio => width / height;
  int get totalPixels => width * height;
  
  bool get isLandscape => width > height;
  bool get isPortrait => height > width;
  bool get isSquare => width == height;
  
  ImageDimensions scaled(double factor) => ImageDimensions(
      (width * factor).round(),
      (height * factor).round(),
    );
  
  ImageDimensions resizedToFit(int maxWidth, int maxHeight) {
    final scaleX = maxWidth / width;
    final scaleY = maxHeight / height;
    final scale = scaleX < scaleY ? scaleX : scaleY;
    
    return ImageDimensions(
      (width * scale).round(),
      (height * scale).round(),
    );
  }
  
  @override
  String toString() => '${width}x$height';
  
  @override
  bool operator ==(Object other) => other is ImageDimensions && 
           other.width == width && 
           other.height == height;
  
  @override
  int get hashCode => Object.hash(width, height);
}

class ImageProcessingOptions { // -1.0 to 1.0
  
  const ImageProcessingOptions({
    this.targetSize,
    this.quality = ImageQuality.high,
    this.format = ImageFormat.jpeg,
    this.maintainAspectRatio = true,
    this.backgroundColor,
    this.removeExif = true,
    this.rotation,
    this.flipHorizontal = false,
    this.flipVertical = false,
    this.blur,
    this.brightness,
    this.contrast,
    this.saturation,
  });
  final ImageDimensions? targetSize;
  final ImageQuality quality;
  final ImageFormat format;
  final bool maintainAspectRatio;
  final Color? backgroundColor;
  final bool removeExif;
  final int? rotation; // degrees
  final bool flipHorizontal;
  final bool flipVertical;
  final double? blur;
  final double? brightness; // -1.0 to 1.0
  final double? contrast; // -1.0 to 1.0
  final double? saturation;
}

class ImagePickerOptions {
  
  const ImagePickerOptions({
    required this.source,
    this.quality = ImageQuality.high,
    this.maxWidth,
    this.maxHeight,
    this.allowMultiple = false,
    this.allowedExtensions,
    this.maxSizeBytes,
    this.enableCropping = false,
    this.cropAspectRatio,
  });
  final ImageSource source;
  final ImageQuality quality;
  final int? maxWidth;
  final int? maxHeight;
  final bool allowMultiple;
  final List<String>? allowedExtensions;
  final int? maxSizeBytes;
  final bool enableCropping;
  final CropAspectRatio? cropAspectRatio;
}

class ImageMetadata {
  
  const ImageMetadata({
    this.fileName,
    this.fileSize,
    this.dimensions,
    this.format,
    this.dateCreated,
    this.dateModified,
    this.exifData,
    this.mimeType,
  });
  final String? fileName;
  final int? fileSize;
  final ImageDimensions? dimensions;
  final ImageFormat? format;
  final DateTime? dateCreated;
  final DateTime? dateModified;
  final Map<String, dynamic>? exifData;
  final String? mimeType;
}

class ImageUtils {
  static final picker.ImagePicker _picker = picker.ImagePicker();
  
  // Pick image from source
  static Future<File?> pickImage(ImagePickerOptions options) async {
    try {
      // Check permissions
      if (options.source == ImageSource.camera) {
        final cameraPermission = await PermissionManager.requestPermission(
          PermissionType.camera,
        );
        if (!cameraPermission.isGranted) {
          throw FileException.permissionDenied('Camera permission required');
        }
      } else if (options.source == ImageSource.gallery) {
        final storagePermission = await PermissionManager.requestPermission(
          PermissionType.storage,
        );
        if (!storagePermission.isGranted) {
          throw FileException.permissionDenied('Storage permission required');
        }
      }
      
      picker.XFile? pickedFile;
      
      switch (options.source) {
        case ImageSource.camera:
          pickedFile = await _picker.pickImage(
            source: picker.ImageSource.camera,
            maxWidth: options.maxWidth?.toDouble(),
            maxHeight: options.maxHeight?.toDouble(),
            imageQuality: options.quality.value,
          );
          break;
          
        case ImageSource.gallery:
          if (options.allowMultiple) {
            final files = await _picker.pickMultiImage(
              maxWidth: options.maxWidth?.toDouble(),
              maxHeight: options.maxHeight?.toDouble(),
              imageQuality: options.quality.value,
            );
            pickedFile = files.isNotEmpty ? files.first : null;
          } else {
            pickedFile = await _picker.pickImage(
              source: picker.ImageSource.gallery,
              maxWidth: options.maxWidth?.toDouble(),
              maxHeight: options.maxHeight?.toDouble(),
              imageQuality: options.quality.value,
            );
          }
          break;
          
        default:
          throw FileException.unsupportedFormat('Unsupported image source');
      }
      
      if (pickedFile == null) return null;
      
      var imageFile = File(pickedFile.path);
      
      // Validate file size
      if (options.maxSizeBytes != null) {
        final fileSize = await imageFile.length();
        if (fileSize > options.maxSizeBytes!) {
          throw FileException.fileTooLarge(
            'File size exceeds ${options.maxSizeBytes} bytes',
          );
        }
      }
      
      // Validate file extension
      if (options.allowedExtensions != null) {
        final extension = path.extension(imageFile.path).toLowerCase();
        if (!options.allowedExtensions!.contains(extension)) {
          throw FileException.unsupportedFormat(
            'File extension $extension not allowed',
          );
        }
      }
      
      // Crop image if enabled
      if (options.enableCropping) {
        imageFile = await cropImage(
          imageFile,
          aspectRatio: options.cropAspectRatio,
        ) ?? imageFile;
      }
      
      return imageFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException.processingError('Failed to pick image: $e');
    }
  }
  
  // Pick multiple images
  static Future<List<File>> pickMultipleImages(ImagePickerOptions options) async {
    try {
      final storagePermission = await PermissionManager.requestPermission(
        PermissionType.storage,
      );
      if (!storagePermission.isGranted) {
        throw FileException.permissionDenied('Storage permission required');
      }
      
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: options.maxWidth?.toDouble(),
        maxHeight: options.maxHeight?.toDouble(),
        imageQuality: options.quality.value,
      );
      
      final imageFiles = <File>[];
      
      for (final pickedFile in pickedFiles) {
        final imageFile = File(pickedFile.path);
        
        // Validate file size
        if (options.maxSizeBytes != null) {
          final fileSize = await imageFile.length();
          if (fileSize > options.maxSizeBytes!) {
            continue; // Skip files that are too large
          }
        }
        
        // Validate file extension
        if (options.allowedExtensions != null) {
          final extension = path.extension(imageFile.path).toLowerCase();
          if (!options.allowedExtensions!.contains(extension)) {
            continue; // Skip unsupported formats
          }
        }
        
        imageFiles.add(imageFile);
      }
      
      return imageFiles;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException.processingError('Failed to pick images: $e');
    }
  }
  
  // Crop image
  static Future<File?> cropImage(
    File imageFile, {
    CropAspectRatio? aspectRatio,
    List<CropAspectRatioPreset>? aspectRatioPresets,
    CropStyle cropStyle = CropStyle.rectangle,
    ImageCompressFormat compressFormat = ImageCompressFormat.jpg,
    int compressQuality = 90,
  }) async {
    try {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imageFile.path,
        aspectRatio: aspectRatio,
        compressFormat: compressFormat,
        compressQuality: compressQuality,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Image',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Image',
            doneButtonTitle: 'Done',
            cancelButtonTitle: 'Cancel',
          ),
        ],
      );
      
      return croppedFile != null ? File(croppedFile.path) : null;
    } catch (e) {
      throw FileException.processingError('Failed to crop image: $e');
    }
  }
  
  // Process image with options
  static Future<File> processImage(
    File inputFile,
    ImageProcessingOptions options,
  ) async {
    try {
      final bytes = await inputFile.readAsBytes();
      final image = img.decodeImage(bytes);
      final exifData = await readExifFromBytes(bytes);
      
      if (image == null) {
        throw FileException.processingError('Failed to decode image');
      }
      
      var processedImage = image;
      
      // Apply rotation
      if (options.rotation != null) {
        processedImage = img.copyRotate(
          processedImage,
          angle: options.rotation! * (3.14159 / 180), // Convert to radians
        );
      }
      
      // Apply flips
      if (options.flipHorizontal) {
        processedImage = img.flipHorizontal(processedImage);
      }
      if (options.flipVertical) {
        processedImage = img.flipVertical(processedImage);
      }
      
      // Resize image
      if (options.targetSize != null) {
        if (options.maintainAspectRatio) {
          final originalDimensions = ImageDimensions(
            processedImage.width,
            processedImage.height,
          );
          final targetDimensions = originalDimensions.resizedToFit(
            options.targetSize!.width,
            options.targetSize!.height,
          );
          processedImage = img.copyResize(
            processedImage,
            width: targetDimensions.width,
            height: targetDimensions.height,
          );
        } else {
          processedImage = img.copyResize(
            processedImage,
            width: options.targetSize!.width,
            height: options.targetSize!.height,
          );
        }
      }
      
      // Apply blur
      if (options.blur != null) {
        processedImage = img.gaussianBlur(
          processedImage,
          radius: options.blur!.toInt(),
        );
      }
      
      // Apply brightness
      if (options.brightness != null) {
        processedImage = img.adjustColor(
          processedImage,
          brightness: options.brightness,
        );
      }
      
      // Apply contrast
      if (options.contrast != null) {
        processedImage = img.contrast(
          processedImage,
          contrast: options.contrast!,
        );
      }
      
      // Apply saturation
      if (options.saturation != null) {
        processedImage = img.adjustColor(
          processedImage,
          saturation: options.saturation,
        );
      }
      
      // Remove EXIF data if requested
      if (options.removeExif) {
        processedImage.exif.clear();
      }
      
      // Encode image
      Uint8List encodedBytes;
      switch (options.format) {
        case ImageFormat.jpeg:
          encodedBytes = Uint8List.fromList(
            img.encodeJpg(processedImage, quality: options.quality.value),
          );
          break;
        case ImageFormat.png:
          encodedBytes = Uint8List.fromList(img.encodePng(processedImage));
          break;
        case ImageFormat.webp:
          // WebP encoding not supported, using JPEG instead
          encodedBytes = Uint8List.fromList(
            img.encodeJpg(processedImage, quality: options.quality.value),
          );
          break;
        case ImageFormat.gif:
          encodedBytes = Uint8List.fromList(img.encodeGif(processedImage));
          break;
        case ImageFormat.bmp:
          encodedBytes = Uint8List.fromList(img.encodeBmp(processedImage));
          break;
      }
      
      // Save processed image
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.${options.format.name}';
      final outputFile = File(path.join(tempDir.path, fileName));
      await outputFile.writeAsBytes(encodedBytes);
      
      return outputFile;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException.processingError('Failed to process image: $e');
    }
  }
  
  // Get image metadata
  static Future<ImageMetadata> getImageMetadata(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw FileException.processingError('Failed to decode image');
      }
      
      final stat = await imageFile.stat();
      final fileName = path.basename(imageFile.path);
      final extension = path.extension(imageFile.path).toLowerCase();
      
      // Extract EXIF data
      final exifData = await readExifFromBytes(bytes);
      
      ImageFormat? format;
      switch (extension) {
        case '.jpg':
        case '.jpeg':
          format = ImageFormat.jpeg;
          break;
        case '.png':
          format = ImageFormat.png;
          break;
        case '.webp':
          format = ImageFormat.webp;
          break;
        case '.gif':
          format = ImageFormat.gif;
          break;
        case '.bmp':
          format = ImageFormat.bmp;
          break;
      }
      
      return ImageMetadata(
        fileName: fileName,
        fileSize: stat.size,
        dimensions: ImageDimensions(image.width, image.height),
        format: format,
        dateCreated: stat.changed,
        dateModified: stat.modified,
        exifData: exifData.isNotEmpty ? exifData.map((key, value) => MapEntry(key, value.toString())) : null,
        mimeType: _getMimeType(extension),
      );
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException.processingError('Failed to get image metadata: $e');
    }
  }
  
  // Get MIME type from extension
  static String? _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      default:
        return null;
    }
  }
  
  // Compress image
  static Future<File> compressImage(
    File imageFile, {
    ImageQuality quality = ImageQuality.medium,
    int? maxWidth,
    int? maxHeight,
  }) async {
    final options = ImageProcessingOptions(
      quality: quality,
      targetSize: maxWidth != null && maxHeight != null
          ? ImageDimensions(maxWidth, maxHeight)
          : null,
    );
    
    return processImage(imageFile, options);
  }
  
  // Create thumbnail
  static Future<File> createThumbnail(
    File imageFile, {
    int size = 150,
    ImageQuality quality = ImageQuality.medium,
  }) async {
    final options = ImageProcessingOptions(
      targetSize: ImageDimensions(size, size),
      quality: quality,
      maintainAspectRatio: false,
    );
    
    return processImage(imageFile, options);
  }
  
  // Convert image format
  static Future<File> convertImageFormat(
    File imageFile,
    ImageFormat targetFormat, {
    ImageQuality quality = ImageQuality.high,
  }) async {
    final options = ImageProcessingOptions(
      format: targetFormat,
      quality: quality,
    );
    
    return processImage(imageFile, options);
  }
  
  // Capture widget as image
  static Future<File> captureWidget(
    GlobalKey key, {
    double pixelRatio = 1.0,
    ImageFormat format = ImageFormat.png,
  }) async {
    try {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      
      final image = await boundary.toImage(
        pixelRatio: pixelRatio,
      );
      
      final byteData = await image.toByteData(
        format: format == ImageFormat.png
            ? ui.ImageByteFormat.png
            : ui.ImageByteFormat.rawRgba,
      );
      
      if (byteData == null) {
        throw FileException.processingError('Failed to capture widget');
      }
      
      final tempDir = await getTemporaryDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.${format.name}';
      final file = File(path.join(tempDir.path, fileName));
      
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      return file;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException.processingError('Failed to capture widget: $e');
    }
  }
  
  // Load image from assets
  static Future<Uint8List> loadAssetImage(String assetPath) async {
    try {
      final data = await rootBundle.load(assetPath);
      return data.buffer.asUint8List();
    } catch (e) {
      throw FileException.notFound();
    }
  }
  
  // Save image to gallery
  static Future<bool> saveImageToGallery(
    File imageFile, {
    String? albumName,
  }) async {
    try {
      final storagePermission = await PermissionManager.requestPermission(
        PermissionType.storage,
      );
      if (!storagePermission.isGranted) {
        throw FileException.permissionDenied('Storage permission required');
      }
      
      // This would require platform-specific implementation
      // For now, just copy to a public directory
      final documentsDir = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imageFile.path);
      final savedFile = File(path.join(documentsDir.path, fileName));
      
      await imageFile.copy(savedFile.path);
      
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Generate image hash for duplicate detection
  static String generateImageHash(File imageFile) {
    // This is a simplified implementation
    // In practice, you'd use perceptual hashing algorithms
    final fileName = path.basename(imageFile.path);
    final fileSize = imageFile.lengthSync();
    return '${fileName}_$fileSize'.hashCode.toString();
  }
  
  // Check if file is a valid image
  static Future<bool> isValidImage(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      return image != null;
    } catch (e) {
      return false;
    }
  }
  
  // Get image color palette
  static Future<List<Color>> getImageColorPalette(
    File imageFile, {
    int maxColors = 8,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);
      
      if (image == null) {
        throw FileException.processingError('Failed to decode image');
      }
      
      // Resize image for faster processing
      final resized = img.copyResize(image, width: 100, height: 100);
      
      final colorMap = <int, int>{};
      
      // Sample colors from the image
      for (var y = 0; y < resized.height; y += 5) {
        for (var x = 0; x < resized.width; x += 5) {
          final pixel = resized.getPixel(x, y);
          final color = pixel.r.toInt() << 16 | pixel.g.toInt() << 8 | pixel.b.toInt();
          colorMap[color] = (colorMap[color] ?? 0) + 1;
        }
      }
      
      // Sort by frequency and take top colors
      final sortedColors = colorMap.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      
      final palette = <Color>[];
      for (var i = 0; i < maxColors && i < sortedColors.length; i++) {
        palette.add(Color(sortedColors[i].key));
      }
      
      return palette;
    } catch (e) {
      if (e is AppException) rethrow;
      throw FileException.processingError('Failed to extract color palette: $e');
    }
  }
  
  // Calculate image similarity (simplified)
  static Future<double> calculateImageSimilarity(
    File image1,
    File image2,
  ) async {
    try {
      final bytes1 = await image1.readAsBytes();
      final bytes2 = await image2.readAsBytes();
      
      final img1 = img.decodeImage(bytes1);
      final img2 = img.decodeImage(bytes2);
      
      if (img1 == null || img2 == null) {
        return 0.0;
      }
      
      // Resize both images to same size for comparison
      final resized1 = img.copyResize(img1, width: 64, height: 64);
      final resized2 = img.copyResize(img2, width: 64, height: 64);
      
      var totalPixels = 0;
      var similarPixels = 0;
      
      for (var y = 0; y < 64; y++) {
        for (var x = 0; x < 64; x++) {
          final pixel1 = resized1.getPixel(x, y);
          final pixel2 = resized2.getPixel(x, y);
          
          // Simple color difference calculation using pixel values
          final color1 = pixel1.r.toInt() << 16 | pixel1.g.toInt() << 8 | pixel1.b.toInt();
          final color2 = pixel2.r.toInt() << 16 | pixel2.g.toInt() << 8 | pixel2.b.toInt();
          final diff = (color1 - color2).abs();
          
          if (diff < 1000000) { // Threshold for similarity (adjusted for integer comparison)
            similarPixels++;
          }
          totalPixels++;
        }
      }
      
      return similarPixels / totalPixels;
    } catch (e) {
      return 0.0;
    }
  }
}

// Image cache manager
class ImageCacheManager {
  static final Map<String, Uint8List> _cache = {};
  static const int _maxCacheSize = 50; // Maximum number of cached images
  
  static Future<Uint8List?> getCachedImage(String key) async => _cache[key];
  
  static Future<void> cacheImage(String key, Uint8List imageData) async {
    if (_cache.length >= _maxCacheSize) {
      // Remove oldest entry
      final oldestKey = _cache.keys.first;
      _cache.remove(oldestKey);
    }
    
    _cache[key] = imageData;
  }
  
  static void clearCache() {
    _cache.clear();
  }
  
  static int get cacheSize => _cache.length;
  
  static int get cacheSizeBytes => _cache.values.fold(0, (sum, data) => sum + data.length);
}

// Image widget extensions
extension ImageFileExtension on File {
  Future<ImageMetadata> getMetadata() => ImageUtils.getImageMetadata(this);
  
  Future<File> compress({
    ImageQuality quality = ImageQuality.medium,
    int? maxWidth,
    int? maxHeight,
  }) => ImageUtils.compressImage(
    this,
    quality: quality,
    maxWidth: maxWidth,
    maxHeight: maxHeight,
  );
  
  Future<File> createThumbnail({
    int size = 150,
    ImageQuality quality = ImageQuality.medium,
  }) => ImageUtils.createThumbnail(
    this,
    size: size,
    quality: quality,
  );
  
  Future<File> convertFormat(
    ImageFormat format, {
    ImageQuality quality = ImageQuality.high,
  }) => ImageUtils.convertImageFormat(
    this,
    format,
    quality: quality,
  );
  
  Future<bool> get isValidImage => ImageUtils.isValidImage(this);
  
  String get imageHash => ImageUtils.generateImageHash(this);
  
  Future<List<Color>> getColorPalette({int maxColors = 8}) =>
      ImageUtils.getImageColorPalette(this, maxColors: maxColors);
}