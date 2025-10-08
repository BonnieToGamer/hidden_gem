import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/comment.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/services/user_service.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentWidget extends StatefulWidget {
  final Comment comment;
  final void Function(String commentId) onDelete;

  const CommentWidget(
      {super.key, required this.comment, required this.onDelete});

  @override
  State<CommentWidget> createState() => _CommentWidgetState();
}

class _CommentWidgetState extends State<CommentWidget> {
  UserProfileInfo? _user;

  @override
  void initState() {
    super.initState();

    _getUser();
  }

  Future<void> _getUser() async {
    UserProfileInfo user = await UserService.getUser(widget.comment.userId);

    if (!mounted) return;

    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return SizedBox();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _profilePicture(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _userName(),
                    SizedBox(width: 5),
                    _date(),
                    Spacer(),
                    _popUp(),
                  ],
                ),
                _content(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _content() {
    return Text(widget.comment.content, softWrap: true);
  }

  Text _userName() {
    return Text(_user!.name, style: TextStyle(fontSize: 16));
  }

  Text _date() {
    return Text(
      DateFormat("MMM d H:mm").format(widget.comment.timestamp.toDate()),
      style: TextStyle(fontWeight: FontWeight.w300),
    );
  }

  SizedBox _profilePicture() {
    return SizedBox(
      width: 32,
      height: 32,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: _user!.avatar,
          fit: BoxFit.contain,
          placeholder: (context, url) => const SizedBox(
            width: 32,
            height: 32,
            child: Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => const SizedBox(
            width: 32,
            height: 32,
            child: Center(child: Icon(Icons.error)),
          ),
        ),
      ),
    );
  }

  Widget _popUp() {
    final user = Provider
        .of<AuthState>(context, listen: false)
        .user!;
    if (_user!.uid != user.uid) {
      return SizedBox();
    }

    return SizedBox(
      height: 16,
      child: PopupMenuButton(
        itemBuilder: (context) =>
        [
          PopupMenuItem(value: 1, child: Row(
            children: [
              Icon(Icons.delete),
              Text("Delete?")
            ],
          )),
        ],
        onSelected: (value) async {
          if (value == 1) {
            await PostsService.deleteComment(widget.comment);
            widget.onDelete(widget.comment.id!);
          }
        },
        iconSize: 16,
        icon: const Icon(Icons.more_horiz),
        padding: EdgeInsets.zero,
        elevation: 2,
      ),
    );
  }
}
