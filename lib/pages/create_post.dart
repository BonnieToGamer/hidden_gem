import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/widgets/gallery_image.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:oktoast/oktoast.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:transparent_image/transparent_image.dart';

// https://pub.dev/packages/photo_manager/example

class CreatePost extends StatefulWidget {
  final User user;

  const CreatePost({super.key, required this.user});

  @override
  State<StatefulWidget> createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  final int _sizePerPage = 64;
  final int _maxSelectedImages = 5;
  static const int _gridWidth = 4;

  bool _loading = false;
  bool _loadingMore = false;
  bool _hasMoreToLoad = true;

  AssetPathEntity? _path;
  List<AssetEntity>? _entities;
  int _totalEntitiesCount = 0;
  int _page = 0;

  Map<int, bool> _selectedImages = {};

  @override
  void initState() {
    super.initState();
    _requestAssets();
  }

  Future<void> _requestAssets() async {
    setState(() {
      _loading = true;
    });

    final PermissionState ps = await PhotoManager.requestPermissionExtend();

    if (!mounted) {
      return;
    }
    
    if (!ps.hasAccess) {
      setState(() {
        _loading = false;
      });

      showToast("Permission was denied");
      return;
    }

    final PMFilter filter = FilterOptionGroup(
      imageOption: const FilterOption(
        sizeConstraint: SizeConstraint(ignoreSize: true)
      )
    );

    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList(
      onlyAll: true,
      filterOption: filter
    );

    if (!mounted) {
      return;
    }

    if (paths.isEmpty) {
      setState(() {
        _loading = false;
      });

      showToast("No images found");
      return;
    }

    setState(() {
      _path = paths.first;
    });

    _totalEntitiesCount = await _path!.assetCountAsync;
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
        page: 0,
        size: _sizePerPage
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _entities = entities;
      _loading = false;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
    });
  }

  Future<void> _loadMoreAssets() async {
    final List<AssetEntity> entities = await _path!.getAssetListPaged(
        page: _page + 1,
        size: _sizePerPage
    );

    if (!mounted) {
      return;
    }

    setState(() {
      _entities!.addAll(entities);
      _page++;
      _hasMoreToLoad = _entities!.length < _totalEntitiesCount;
      _loadingMore = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildGallery(),
      bottomNavigationBar: CustomNavigationBar(currentIndex: 1, user: widget.user),
    );
  }

  Widget _buildGallery() {
    if (_loading || _path == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_entities?.isEmpty == true) {
      return const Center(child: Text("No images where found on this device."));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _gridWidth,
      ),
      itemCount: _entities!.length,
      itemBuilder: (BuildContext context, int index) {
        if (index == _entities!.length - (_gridWidth * 2) && !_loadingMore && _hasMoreToLoad) {
          _loadMoreAssets();
        }
        final AssetEntity entity = _entities![index];
        return GalleryImage(
          key: ValueKey<int>(index),
          entity: entity,
          option: const ThumbnailOption(size: ThumbnailSize.square(200)),
        );
      },
    );
  }
}