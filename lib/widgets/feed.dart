import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/post.dart';
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

    _user = Provider.of<User>(context, listen: false);

    _fetchMorePosts();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchMorePosts();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    PostsService.resetPagination();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: _posts.length + 1,
      itemBuilder: (context, index) {
        if (index < _posts.length) {
          return PostWidget(post: _posts[index]);
        } else if (_hasMore) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return SizedBox();
        }
      },
    );
  }

  Future<void> _fetchMorePosts() async {
    setState(() {
      _isLoading = true;
    });

    List<Post> newPosts = await PostsService.getPagedPosts(
      _user.uid,
      limit: 10,
    );

    setState(() {
      _posts.addAll(newPosts);
      _isLoading = false;
      if (newPosts.length < 10) {
        _hasMore = false;
      }
    });
  }
}
