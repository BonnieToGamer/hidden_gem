import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:intl/intl.dart';

class PostWidget extends StatefulWidget {
  final Post post;

  PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  final CarouselController _controller = CarouselController();
  late Future<List<String>> _imageUrlsFuture;
  int _current = 0;

  @override
  void initState() {
    super.initState();
    _imageUrlsFuture = ImageService.getImageUrls(widget.post.imageIds);
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
          children: [
            Column(
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
                                child: Image.network(
                                  url,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(),
                                        );
                                      },
                                ), // TODO: check out https://pub.dev/packages/photo_view
                              ),
                            ),
                          );
                        },
                        child: Image.network(
                          url,
                          fit: BoxFit.scaleDown,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return SizedBox(
                              width: double.infinity,
                              height: 150,
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                ?(widget.post.imageIds.length > 1) ? Row(
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
                                .withValues(alpha:
                                  _current == entry.key ? 0.9 : 0.4,
                                ),
                      ),
                    );
                  }).toList(),
                ) : null,
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(widget.post.description),
                  Text(
                    DateFormat("MMM d").format(widget.post.timestamp.toDate()),
                    style: TextStyle(fontWeight: FontWeight.w300),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
