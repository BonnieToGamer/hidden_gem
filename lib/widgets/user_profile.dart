import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/constants.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/pages/post/view_post.dart';
import 'package:hidden_gem/pages/user_profile/friends.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/friend_service.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatefulWidget {
  final UserProfileInfo user;
  final Stream<List<Post>> postStream;

  const UserProfile({super.key, required this.user, required this.postStream});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  late Stream<List<UserProfileInfo>> _friendsFuture;

  @override
  void initState() {
    super.initState();

    _friendsFuture = FriendService.getFriends(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.postStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print("ERROR ON USER PROFILE: ${snapshot.error}");
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
                    "images",
                  );

                  return FutureBuilder(
                    future: imageURLs,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final imageUrl = snapshot.data!;

                      return Padding(
                        padding: const EdgeInsets.all(1.0),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ViewPost(post: posts[index]),
                              ),
                            );
                          },
                          child: CachedNetworkImage(
                            imageUrl: imageUrl[0],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) =>
                                const Center(child: Icon(Icons.error)),
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
    );
  }

  Padding buildProfileHeader(int postCount) {
    final user = Provider.of<AuthState>(context, listen: false).user!;
    final ownProfile = user.uid == widget.user.uid;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.user.avatar),
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
                      widget.user.name,
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
                      GestureDetector(
                        onTap: ownProfile ? _onTapFriends : null,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            StreamBuilder(
                              stream: _friendsFuture,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Text(
                                    "0",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }

                                int amount = 0;
                                if (snapshot.hasData) {
                                  amount = snapshot.data!.length;
                                }

                                return Text(
                                  "$amount",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                );
                              },
                            ),
                            Text("friends"),
                          ],
                        ),
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

  void _onTapFriends() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FriendsPage(newFriendCallback: newFriendCallback),
      ),
    );
  }

  void newFriendCallback() {
    setState(() {});
  }
}
