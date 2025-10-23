import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/pages/post/new_post.dart';
import 'package:hidden_gem/pages/post/take_picture.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/gallery_image.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:photo_manager/photo_manager.dart';

// https://pub.dev/packages/photo_manager/example

class CreatePost extends StatefulWidget {
  const CreatePost({super.key});

  @override
  State<StatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost>
    with AutomaticKeepAliveClientMixin<CreatePost> {
  final int _sizePerPage = 64;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMoreToLoad = true;
  bool _permissionDenied = false;

  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  int _totalEntitiesCount = 0;
  int _page = 0;

  final _selectedGalleryImages = <int, bool>{};
  int _totalSelectedImages = 0;

  @override
  void initState() {
    super.initState();
    _requestAssets();
  }

  // Ask for permission and get images.
  Future<void> _requestAssets() async {
    setState(() {
      _loading = true;
    });

    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!mounted) return;

    if (!ps.hasAccess) {
      setState(() {
        _loading = false;
        _permissionDenied = true;
      });
      return;
    }

    final PMFilter filter = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true),
      ),
    );

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: filter,
    );

    if (!mounted) return;

    if (paths.isEmpty) {
      setState(() {
        _loading = false;
      });
      return;
    }

    setState(() {
      _path = paths.first;
    });

    _totalEntitiesCount = await _path!.assetCountAsync;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: 0,
      size: _sizePerPage,
    );

    if (!mounted) return;

    setState(() {
      _entities = entities;
      _loading = false;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
    });
  }

  // Load more images.
  Future<void> _loadMoreAssets() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
      page: _page + 1,
      size: _sizePerPage,
    );

    if (!mounted) return;

    setState(() {
      _entities!.addAll(entities);
      _page++;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return selectImagesState();
  }

  // State for selecting images from gallery.
  Scaffold selectImagesState() {
    return Scaffold(
      appBar: AppBar(title: Text("Select up to $maxImagesPerPost images.")),
      body: Column(
        verticalDirection: VerticalDirection.down,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton.icon(
              onPressed: _loading
                  ? null
                  : () async {
                      setState(() => _loading = true);

                      try {
                        await PostsService.syncPosts();
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Offline posts synced!"),
                          ),
                        );

                        await ImageService.clearOfflineImages();
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Sync failed: $e")),
                        );
                      } finally {
                        if (mounted) setState(() => _loading = false);
                      }
                    },
              icon: _loading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.sync),
              label: _loading
                  ? const Text("Syncing...")
                  : const Text("Sync Offline Posts"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Theme.of(context).canvasColor,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),

          Expanded(child: _buildGallery()),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TakePicture()),
                );
              },
              child: Icon(Icons.camera_alt),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                );
              },
              child: _totalSelectedImages >= 1
                  ? ElevatedButton(
                      key: ValueKey("sendBtn"),
                      onPressed: () async {
                        List<File> images = [];
                        if (_entities != null) {
                          for (final ent in _entities!) {
                            final int index = _entities!.indexOf(ent);
                            if (_selectedGalleryImages.containsKey(index) ==
                                    false ||
                                _selectedGalleryImages[index] == false) {
                              continue;
                            }

                            print(
                              "Key $index exists? ${_selectedGalleryImages.containsKey(index)}",
                            );

                            final file = await ent.file;
                            if (file != null) {
                              images.add(file);
                            }
                          }
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NewPost(images: images),
                          ),
                        );
                      },
                      child: Icon(Icons.send),
                    )
                  : const SizedBox.shrink(key: ValueKey("empty")),
            ),
          ],
        ),
      ),
    );
  }

  // Build the gallery widget.
  Widget _buildGallery() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_permissionDenied) {
      return const Center(child: Text("Permission was denied"));
    }

    if (_path == null) {
      return const Center(child: Text("No images found."));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: galleryGridWidth,
      ),
      itemCount: _entities!.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == _entities!.length - (galleryGridWidth * 2) &&
            !_loadingMore &&
            _hasMoreToLoad) {
          _loadMoreAssets();
        }
        final AssetEntity entity = _entities![index];

        bool isSelected;
        if (_selectedGalleryImages.containsKey(index)) {
          isSelected = _selectedGalleryImages[index]!;
        } else {
          _selectedGalleryImages[index] = false;
          isSelected = false;
        }

        return GalleryImage(
          key: ValueKey<int>(index),
          entity: entity,
          option: const ThumbnailOption(size: ThumbnailSize.square(200)),
          selected: isSelected,
          onTap: () {
            if (_totalSelectedImages >= maxImagesPerPost && !isSelected) {
              return;
            }

            setState(() {
              if (isSelected) {
                _totalSelectedImages--;
              } else {
                _totalSelectedImages++;
              }

              _selectedGalleryImages[index] = !isSelected;
            });
          },
        );
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}
