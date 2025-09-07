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
    bool isLargeImage = false,
  }) {
    final imageBytes = decodeBase64Image(imageUrl);

    Widget imageWidget;
    
    if (imageBytes != null) {
      // BASE64 - użyj Image.memory()
      imageWidget = Image.memory(
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
      //  HTTP URL - użyj Image.network()
      imageWidget = Image.network(
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
      //  BRAK OBRAZKA - placeholder
      return placeholder ?? _buildDefaultPlaceholder(context, width, height);
    }
    if(isLargeImage) {
      return Container(
        width: width,
        height: height,
        constraints: BoxConstraints(
          maxWidth: width ?? double.infinity,
          maxHeight: height ?? 200,
           minHeight: 200,
        ),
        decoration: BoxDecoration(
          borderRadius:BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
      );
    }
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: imageWidget,
      );
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
static Widget buildLargePlaceholder(BuildContext context, {double width = double.infinity, double height = 250}) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(50),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.gif_box_outlined, // ✅ IKONA DLA GIF
          size: 80,
          color: Theme.of(context).colorScheme.primary,
        ),
        SizedBox(height: 12),
        Text(
          'Exercise Animation',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Loading...',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
          ),
        ),
      ],
    ),
  );
}
}