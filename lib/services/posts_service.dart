import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire_plus/geoflutterfire_plus.dart';
import 'package:hidden_gem/models/comment.dart';
import 'package:hidden_gem/models/friend.dart';
import 'package:hidden_gem/models/like.dart';
import 'package:hidden_gem/models/post.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/services/friend_service.dart';
import 'package:hidden_gem/services/image_service.dart';
import 'package:rxdart/rxdart.dart';

class PostsService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final String _collectionPath = "posts";
  static DocumentSnapshot? _lastPostDocument;
  static DocumentSnapshot? _lastCommentDocument;

  const PostsService._();

  static Future<void> addPost(Post post) async {
    await _db.collection(_collectionPath).add(post.toMap());
  }

  static Future<void> createPost(
    UserProfileInfo author,
    String name,
    String description,
    GeoFirePoint point,
    Timestamp timestamp,
    List<String> imageIds,
    bool isPublic,
  ) async {
    try {
      final post = Post(
        authorId: author.uid,
        name: name,
        description: description,
        point: point,
        timestamp: timestamp,
        imageIds: imageIds,
        isPublic: isPublic,
      );
      await _db.collection(_collectionPath).add(post.toMap());
    } catch (e) {
      print("Error in createPost $e");
    }
  }

  static Stream<List<Post>> getAllPosts(String userId,
      Stream<List<String>> friendIdsStream,) {
    return friendIdsStream.switchMap((friendIds) {
      final publicStream = FirebaseFirestore.instance
          .collection('posts')
          .where('isPublic', isEqualTo: true)
          .where(
        'authorId',
        whereIn: friendIds.isEmpty ? ['__dummy__'] : friendIds,
      )
          .orderBy('timestamp', descending: true)
          .snapshots();

      final ownStream = FirebaseFirestore.instance
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots();

      return Rx.combineLatest2(publicStream, ownStream, (publicSnap, ownSnap) {
        final allDocs = [...publicSnap.docs, ...ownSnap.docs];
        final uniqueDocs = {
          for (var doc in allDocs) doc.id: doc,
        }.values.toList();
        return uniqueDocs.map((doc) => Post.fromFirestore(doc)).toList();
      });
    });
  }

  static Stream<List<Post>> getOwnPosts(String userId) {
    // Query posts by current user
    final ownStream = _db
        .collection('posts')
        .where('authorId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots();

    return ownStream.map(
      (snapshot) =>
          snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
    );
  }

  static Stream<List<Post>> getUsersPosts(String userId,
      Stream<List<String>> friendIdsStream,) {
    return friendIdsStream.switchMap((friendIds) {
      // Query posts by current user
      final ownStream = _db
          .collection('posts')
          .where('authorId', isEqualTo: userId)
          .where(
        'authorId',
        whereIn: friendIds.isEmpty ? ['__dummy__'] : friendIds,
      )
          .where('isPublic', isEqualTo: true)
          .orderBy('timestamp', descending: true)
          .snapshots();

      return ownStream.map(
            (snapshot) =>
            snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
      );
    });
  }

  // updates a post
  // returns true if it succeeded otherwise false.
  static Future<bool> updatePost(Post post) async {
    try {
      await _db
          .collection(_collectionPath)
          .doc(post.postId)
          .update(post.toMap());
      return true;
    } catch (e) {
      print("Error updating post: $e");
      return false;
    }
  }

  static Future<bool> deletePost(Post post) async {
    try {
      for (String id in post.imageIds) {
        await ImageService.deleteImage(id, "images");
      }

      await _db.collection(_collectionPath).doc(post.postId).delete();
      return true;
    } catch (e) {
      print("Error deleting post: $e");
      return false;
    }
  }

  static void resetPostPagination() {
    _lastPostDocument = null;
  }

  static Future<List<Post>> getPagedPosts(String uid, List<String> friendIds,
      {int limit = 10}) async {
    Query query = _db
        .collection("posts")
        .where(
      "authorId",
      whereIn: friendIds.isEmpty ? ['__dummy__'] : friendIds,
    )
        .where("isPublic", isEqualTo: true)
        .orderBy("timestamp", descending: true)
        .limit(limit);

    if (_lastPostDocument != null) {
      query = query.startAfterDocument(_lastPostDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastPostDocument = querySnapshot.docs.last;
    }

    final posts = querySnapshot.docs
        .map((doc) => Post.fromFirestore(doc))
        .where((post) => post.authorId != uid)
        .toList();

    return posts;
  }

  static Future<void> likePost(Post post, String uid) async {
    await _db
        .collection("likes")
        .add(
      Like(
        postId: post.postId!,
        userId: uid,
        timestamp: Timestamp.now(),
      ).toMap(),
    );
  }

  static Future<void> unlikePost(Like like) async {
    await _db.collection("likes").doc(like.id!).delete();
  }

  static Stream<Like> getLikeStatus(Post post, String uid) {
    return _db
        .collection('likes')
        .where('postId', isEqualTo: post.postId)
        .where('userId', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map(
          (snapshot) =>
          snapshot.docs.map((doc) => Like.fromFirestore(doc)).toList()[0],
    );
  }

  static Stream<int> getLikeCount(Post post) {
    return _db
        .collection('likes')
        .where('postId', isEqualTo: post.postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  static Stream<int> getCommentCount(Post post) {
    return _db
        .collection('comments')
        .where('postId', isEqualTo: post.postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  static Future<void> postComment(Comment comment) async {
    await _db.collection("comments").add(comment.toMap());
  }

  static Future<void> deleteComment(Comment comment) async {
    await _db.collection("comments").doc(comment.id).delete();
  }

  static Future<List<Comment>> getPagedComments(String postId, {
    int limit = 10,
  }) async {
    Query query = _db
        .collection("comments")
        .where("postId", isEqualTo: postId)
        .orderBy("timestamp", descending: true)
        .limit(limit);

    if (_lastCommentDocument != null) {
      query = query.startAfterDocument(_lastCommentDocument!);
    }

    final querySnapshot = await query.get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastCommentDocument = querySnapshot.docs.last;
    }

    return querySnapshot.docs.map((doc) => Comment.fromFirestore(doc)).toList();
  }

  static void resetCommentPagination() {
    _lastCommentDocument = null;
  }

  // make this actually work :(
  // https://www.geeksforgeeks.org/dsa/haversine-formula-to-find-distance-between-two-points-on-a-sphere/
  // Stream<List<Post>> getPosts(LatLng center, double radiusInKm) {
  //   final collectionReference = _db.collection("posts").withConverter<Post>(
  //       fromFirestore: (ds, _) => Post.fromFirestore(ds),
  //       toFirestore: (obj, _) => obj.toMap()
  //   );
  //
  //   // final stream = GeoCollectionReference(collectionReference)
  //   //   .subscribeWithin(
  //   //     center: GeoFirePoint(GeoPoint(center.latitude, center.longitude)),
  //   //     radiusInKm: radiusInKm,
  //   //     field: 'point',
  //   //     geopointFrom: (Post data) => data.point.geopoint
  //   // );
  //   //
  //   // return stream.map((snapshots) =>
  //   //   snapshots.map(
  //   //           (docSnap) => docSnap.data()!
  //   //   ).toList()
  //   // );
  // }
}
