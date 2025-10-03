import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';

class GalleryImage extends StatelessWidget {
  const GalleryImage({
    super.key,
    required this.entity,
    required this.option,
    required this.selected,
    this.onTap,
  });

  final bool selected;
  final AssetEntity entity;
  final ThumbnailOption option;
  final GestureTapCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
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
            ),
          ),
        ),
        Positioned(
          top: 2.0,
          left: 2.0,
          child: Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.check_circle_outline_rounded,
            color: selected
                ? Theme.of(context).primaryColor
                : Theme.of(context).disabledColor.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}
