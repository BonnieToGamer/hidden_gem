import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/pages/post/edit_post.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/widgets/post_widget.dart';
import 'package:provider/provider.dart';

class ViewPost extends StatelessWidget {
  final Post post;

  const ViewPost({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context, listen: false);
    bool isOwnPost = post.authorId == user.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text("View Post"),
        actions: [
          ?(isOwnPost)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm Delete'),
                          content: const Text(
                            'Are you sure you want to delete this post?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Delete',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );

                      if (confirm == true) {
                  await PostsService.deletePost(post);
                  Navigator.pop(context);
                }
              },
              child: Icon(Icons.delete),
            ),
          )
              : null,
          ?(isOwnPost)
              ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditPost(post: post),
                  ),
                );
              },
              child: Icon(Icons.edit),
            ),
          )
              : null,
        ],
      ),
      body: PostWidget(post: post),
    );
  }
}
