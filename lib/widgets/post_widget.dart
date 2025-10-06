import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/pages/user_profile/view_user_profile.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  const PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  late Future<List<String>> _imageUrlsFuture;
  late UserProfileInfo _author;
  int _current = 0;
  int _amountLikes = 0;

  @override
  void initState() {
    super.initState();
    _imageUrlsFuture = imageUrls();
  }

  Future<List<String>> imageUrls() async {
    _author = await UserService.getUser(widget.post.authorId);
    return ImageService.getImageUrls(widget.post.imageIds, "images");
  }

  @override
  Widget build(BuildContext context) {
    // TODO: move this further down into the carousel
    return FutureBuilder(
      future: _imageUrlsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text("Error loading images");
        }

        final urls = snapshot.data ?? [];

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_images(urls, context), _info(context)],
        );
      },
    );
  }

  Column _images(List<String> urls, BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            enableInfiniteScroll: false,
            autoPlay: false,
            initialPage: 0,
            height: 300,
            disableCenter: true,
            enlargeCenterPage: false,
            onPageChanged: (index, reason) {
              setState(() {
                _current = index;
              });
            },
          ),
          items: urls.map((url) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      child: InteractiveViewer(
                        child: CachedNetworkImage(
                          imageUrl: url,
                          placeholder: (context, url) =>
                          const SizedBox(
                            width: double.infinity,
                            height: 150,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          errorWidget: (context, url, error) =>
                          const SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: Center(child: Icon(Icons.error))
                          ),
                        ), // TODO: check out https://pub.dev/packages/photo_view
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (context, url) =>
                  const SizedBox(
                    width: double.infinity,
                    height: 150,
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) =>
                  const SizedBox(
                      width: double.infinity,
                      height: 150,
                      child: Center(child: Icon(Icons.error))
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        ?(widget.post.imageIds.length > 1)
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: widget.post.imageIds.asMap().entries.map((entry) {
                  return Container(
                    width: 8.0,
                    height: 8.0,
                    margin: EdgeInsets.symmetric(
                      vertical: 8.0,
                      horizontal: 4.0,
                    ),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color:
                          (Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black)
                              .withValues(
                                alpha: _current == entry.key ? 0.9 : 0.4,
                              ),
                    ),
                  );
                }).toList(),
              )
            : null,
      ],
    );
  }

  Padding _info(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_likes(context), _header(context), _description(), _date()],
      ),
    );
  }

  Text _date() {
    return Text(
      DateFormat("MMM d").format(widget.post.timestamp.toDate()),
      style: TextStyle(fontWeight: FontWeight.w300),
    );
  }

  Text _description() =>
      Text(widget.post.description, style: TextStyle(fontSize: 16));

  Row _header(BuildContext context) {
    return Row(
      children: [
        TextButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ViewUserProfile(user: _author),
              ),
            );
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.only(right: 5.0),
            minimumSize: Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            _author.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        Text(widget.post.name,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _likes(BuildContext context) {
    final user = Provider.of<AuthState>(context, listen: false).user!;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: Row(
        children: [
          StreamBuilder(
            stream: PostsService.getLikeStatus(widget.post, user.uid),
            builder: (context, snapshot) {
              final likedData = snapshot.data;

              return GestureDetector(
                onTap: () {
                  if (likedData != null) {
                    PostsService.unlikePost(likedData);
                  } else {
                    PostsService.likePost(widget.post, user.uid);
                  }

                  setState(() {});
                },
                child: Icon(
                  likedData != null ? Icons.favorite : Icons.favorite_outline,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          StreamBuilder<int>(
            stream: PostsService.getLikeCount(widget.post),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != 0) {
                _amountLikes = snapshot.data!;
              }

              return Text(
                "$_amountLikes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
