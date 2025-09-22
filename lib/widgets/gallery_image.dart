import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class GalleryImage extends StatelessWidget {
  const GalleryImage({
    super.key,
    required this.entity,
    required this.option,
    this.onTap,
  });

  final AssetEntity entity;
  final ThumbnailOption option;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(0.5),
        child: AssetEntityImage(
          entity,
          isOriginal: false,
          thumbnailSize: option.size,
          thumbnailFormat: option.format,
          fit: BoxFit.cover,
        ),
      )
    );
  }
}