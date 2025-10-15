import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/friend_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/post_widget.dart';
import 'package:provider/provider.dart';

class Feed extends StatefulWidget {
  const Feed({super.key});

  @override
  State<Feed> createState() => _FeedState();
}

class _FeedState extends State<Feed> {
  final ScrollController _scrollController = ScrollController();
  late User _user;
  List<Post> _posts = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _user = Provider.of<AuthState>(context, listen: false).user!;

    _fetchMorePosts();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    PostsService.resetPostPagination();

    super.dispose();
  }

  Future<void> _refreshData() async {
    PostsService.resetPostPagination();

    setState(() {
      _posts.clear();
      _hasMore = true;
    });

    await _fetchMorePosts();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        key: PageStorageKey("feed_list_view"),
        controller: _scrollController,
        itemCount: _posts.length + 1,
        physics: const AlwaysScrollableScrollPhysics(),
        cacheExtent: 1000,
        itemBuilder: (context, index) {
          if (index < _posts.length) {
            return PostWidget(
              key: ValueKey(_posts[index].postId!),
              post: _posts[index],
              inlineComments: false,
            );
          } else if (_hasMore) {
            return Center(
              child: TextButton(
                onPressed: () {
                  _fetchMorePosts();
                },
                child: Text("Load more"),
              ),
            );
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }

  Future<void> _fetchMorePosts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    List<Post> newPosts = await PostsService.getPagedPosts(
      _user.uid,
      await FriendService.getFriendIdsStream(_user.uid).first,
      limit: 10,
    );

    if (!mounted) return;

    setState(() {
      _posts.addAll(newPosts);
      _isLoading = false;
      if (newPosts.length < 10) {
        _hasMore = false;
      }
    });
  }
}
