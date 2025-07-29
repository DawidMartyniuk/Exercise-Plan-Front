import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:typed_data';

class ImageUtils {
  /// Konwertuje base64 data URL na Uint8List
  static Uint8List? decodeBase64Image(String? gifUrl) {
    if (gifUrl == null || !gifUrl.startsWith('data:image')) {
      return null;
    }
    
    try {
      final base64String = gifUrl.split(',').last;
      return base64Decode(base64String);
    } catch (e) {
      print("❌ Błąd dekodowania base64: $e");
      return null;
    }
  }

  /// Buduje widget obrazka z obsługą base64 i HTTP URL
  static Widget buildImage({
    required String? imageUrl,
    required BuildContext context,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget Function(BuildContext, Object, StackTrace?)? errorBuilder,
  }) {
    final imageBytes = decodeBase64Image(imageUrl);
    
    if (imageBytes != null) {
      // ✅ BASE64 - użyj Image.memory()
      return Image.memory(
        imageBytes,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: errorBuilder ?? (context, error, stackTrace) {
          print("❌ Błąd MemoryImage: $error");
          return placeholder ?? _buildDefaultPlaceholder(context, width, height);
        },
      );
    } else if (imageUrl != null && 
               imageUrl.isNotEmpty && 
               imageUrl.startsWith('http')) {
      // ✅ HTTP URL - użyj Image.network()
      return Image.network(
        imageUrl,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return SizedBox(
            width: width,
            height: height,
            child: Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        },
        errorBuilder: errorBuilder ?? (context, error, stackTrace) {
          print("❌ Błąd NetworkImage: $error");
          return placeholder ?? _buildDefaultPlaceholder(context, width, height);
        },
      );
    } else {
      // ✅ BRAK OBRAZKA - placeholder
      return placeholder ?? _buildDefaultPlaceholder(context, width, height);
    }
  }

  /// Tworzy ImageProvider z obsługą base64 i HTTP URL
  static ImageProvider? createImageProvider(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return null;
    }
    
    if (imageUrl.startsWith('data:image')) {
      // BASE64 - dekoduj i użyj MemoryImage
      try {
        final base64String = imageUrl.split(',').last;
        final bytes = base64Decode(base64String);
        return MemoryImage(bytes);
      } catch (e) {
        print("❌ Błąd dekodowania base64: $e");
        return null;
      }
    } else if (imageUrl.startsWith('http')) {
      // HTTP URL - użyj NetworkImage
      return NetworkImage(imageUrl);
    }
    
    return null;
  }

  /// Domyślny placeholder
  static Widget _buildDefaultPlaceholder(BuildContext context, double? width, double? height) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
      child: Icon(
        Icons.fitness_center,
        size: (width != null && height != null) 
            ? (width < height ? width : height) * 0.4 
            : 40,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Placeholder dla małych obrazków (listy)
  static Widget buildSmallPlaceholder(BuildContext context, {double size = 50}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fitness_center,
        size: size * 0.6,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }

  /// Placeholder dla dużych obrazków (szczegóły)
  static Widget buildLargePlaceholder(BuildContext context, {double width = double.infinity, double height = 300}) {
    return Container(
      width: width,
      height: height,
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.fitness_center,
            size: 100,
            color: Theme.of(context).colorScheme.primary,
          ),
          SizedBox(height: 8),
          Text(
            'No image available',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}