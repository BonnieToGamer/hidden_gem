import 'package:flutter/material.dart';
import 'package:hidden_gem/models/comment.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/comment_widget.dart';

class Comments extends StatefulWidget {
  final String postId;

  const Comments({super.key, required this.postId});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  final ScrollController _scrollController = ScrollController();
  List<Comment> _comments = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();

    _fetchMoreComments();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoading &&
          _hasMore) {
        _fetchMoreComments();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    PostsService.resetCommentPagination();

    super.dispose();
  }

  Future<void> _fetchMoreComments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    List<Comment> newComments = await PostsService.getPagedComments(
      widget.postId,
      limit: 10,
    );

    if (!mounted) return;
    setState(() {
      _comments.addAll(newComments);
      _isLoading = false;
      if (newComments.length < 10) {
        _hasMore = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      controller: _scrollController,
      itemCount: _comments.length + 1,
      itemBuilder: (context, index) {
        if (index < _comments.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: CommentWidget(comment: _comments[index]),
          );
        } else if (_hasMore) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return SizedBox();
        }
      },
    );
  }
}
