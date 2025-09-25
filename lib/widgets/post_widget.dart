import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:intl/intl.dart';

class PostWidget extends StatefulWidget {
  final Post post;
  final ImageService imageService = ImageService();

  PostWidget({super.key, required this.post});

  @override
  State<PostWidget> createState() => _PostWidgetState();
}

class _PostWidgetState extends State<PostWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: widget.imageService.getImageUrls(widget.post.imageIds),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return const Text("Error loading images");
        }

        final urls = snapshot.data ?? [];

        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CarouselSlider(
              options: CarouselOptions(
                enableInfiniteScroll: false,
                autoPlay: false,
                initialPage: 0,
                height: 300,
                disableCenter: true,
                enlargeCenterPage: false,

              ),
              items: urls.map((url) {
                return Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: InteractiveViewer(
                              child: Image.network(url) // TODO: check out https://pub.dev/packages/photo_view
                          )
                        )
                      );
                    },
                    child: Image.network(
                      url,
                      fit: BoxFit.scaleDown
                    ),
                  )
                );
              }).toList(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.post.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    )
                  ),
                  Text(widget.post.description),
                  Text(
                    DateFormat("MMM d").format(widget.post.timestamp.toDate()),
                    style: TextStyle(
                      fontWeight: FontWeight.w300
                    ),
                  )
                ],
              ),
            ),
          ],
        );
      }
    );
  }
}