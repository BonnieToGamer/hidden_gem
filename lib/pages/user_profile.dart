import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/pages/settings.dart';
import 'package:hidden_gem/pages/view_post.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/navigation_bar.dart';
import 'package:transparent_image/transparent_image.dart';

class UserProfile extends StatefulWidget {
  final User user;

  UserProfile({super.key, required this.user});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Stream<List<Post>> _postStream;

  @override
  void initState() {
    super.initState();
    _postStream = PostsService.getPosts(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.user.displayName}'s profile"),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Settings()),
              );
            },
            icon: Icon(Icons.settings, color: Theme.of(context).primaryColor),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: _postStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text("There was an error");
          }

          final List<Post> posts;
          if (snapshot.hasData) {
            posts = snapshot.data!;
          } else {
            posts = [];
          }

          return Column(
            children: [
              buildProfileHeader(posts.length),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: postGridWidth,
                  ),
                  itemCount: posts.length,
                  itemBuilder: (BuildContext context, int index) {
                    Future<List<String>> imageURLs = ImageService.getImageUrls(
                      posts[index].imageIds,
                    );

                    return FutureBuilder(
                      future: imageURLs,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final imageUrl = snapshot.data!;

                        return Padding(
                          padding: const EdgeInsets.all(1.0),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewPost(
                                    user: widget.user,
                                    post: posts[index],
                                  ),
                                ),
                              );
                            },
                            child: Image.network(
                              imageUrl[0],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: CustomNavigationBar(
        currentIndex: 2,
        user: widget.user,
      ),
    );
  }

  Padding buildProfileHeader(int postCount) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.user.photoURL ?? ""),
                radius: 40,
              ),
              SizedBox(width: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      "${widget.user.displayName}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "$postCount",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("posts"),
                        ],
                      ),
                      SizedBox(width: 20),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "xx", // TODO: replace with actual numbers
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("followers"),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
