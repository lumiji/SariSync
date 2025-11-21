import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageHelper {
  /// Prefetch the first few images from a list of URLs
  static void prefetchImages({
    required BuildContext context,
    required List<String?> urls,
    int limit = 8,
    int? lastPrefetchedCount,
  }) {
    final int toPrefetch = urls.length < limit ? urls.length : limit;

    if (lastPrefetchedCount != null && lastPrefetchedCount == urls.length) return;

    for (int i = 0; i < toPrefetch; i++) {
      final url = urls[i];
      if (url != null && url.isNotEmpty) {
        final provider = CachedNetworkImageProvider(url);
        precacheImage(provider, context).catchError((_) {});
      }
    }
  }
}
