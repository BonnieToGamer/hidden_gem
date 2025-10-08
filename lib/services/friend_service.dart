import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hidden_gem/models/friend.dart';
import 'package:hidden_gem/models/friendRequest.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/services/posts_service.dart';
import 'package:hidden_gem/services/user_service.dart';

class FriendService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  const FriendService._();

  static Future<void> createFriendRequest(String fromId, String toId) async {
    final request = FriendRequest(
      id: "",
      fromId: fromId,
      toId: toId,
      timestamp: Timestamp.now(),
    );

    await _db.collection("friendRequests").add(request.toMap());
  }

  static Future<List<FriendRequest>> getRequests(String user) async {
    return (await _db
            .collection("friendRequests")
            .where("toId", isEqualTo: user)
            .get())
        .docs
        .map((doc) => FriendRequest.fromFirestore(doc))
        .toList();
  }

  static Future<List<FriendRequest>> sentRequests(String user) async {
    return (await _db
            .collection("friendRequests")
            .where("fromId", isEqualTo: user)
            .get())
        .docs
        .map((doc) => FriendRequest.fromFirestore(doc))
        .toList();
  }

  static Future<List<UserProfileInfo>> searchUsers(String query) async {
    // https://stackoverflow.com/a/56815787/16052290
    return (await _db
            .collection('users')
            .where('name', isGreaterThanOrEqualTo: query)
            .where('name', isLessThanOrEqualTo: '$query\uf8ff')
            .limit(20)
            .get())
        .docs
        .map((doc) => UserProfileInfo.fromFirestore(doc))
        .toList();
  }

  static Future<List<UserProfileInfo>> getFriends(String userId) async {
    final friendData =
        (await _db.collection("users").doc(userId).collection("friends").get())
            .docs
            .map((doc) => FriendData.fromFirestore(doc))
            .toList();

    List<UserProfileInfo> users = [];

    for (final friend in friendData) {
      final user = await UserService.getUser(friend.friendId);
      users.add(user);
    }

    return users;
  }

  static Future<void> acceptRequest(String toId, String fromId) async {
    final query = await _db
        .collection("friendRequests")
        .where("fromId", isEqualTo: fromId)
        .where("toId", isEqualTo: toId)
        .limit(1)
        .get();

    await _db.runTransaction((transaction) async {
      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
      }

      final timestamp = Timestamp.now();
      final fromFriendData = FriendData(
        id: "",
        friendId: toId,
        timestamp: timestamp,
      );
      final toFriendData = FriendData(
        id: "",
        friendId: fromId,
        timestamp: timestamp,
      );

      /**
       * Ok, I had this debate with myself and just wanna write it down
       * for future reference. Yes, this is bad practice since technically
       * anyone with the firebase key can add anyone as friends without
       * explicit permission from the 'victim'. I can think of another
       * way of doing this but it requires some synchronization across
       * both users.
       * The current flow is
       * - User1 sends friend request to user2.
       * - User2 accepts friend request
       * - User2 modifies both User1 and User2's friends section
       *   in firestore
       * - They are now friends
       *
       * A more proper way would be
       * - User1 sends friend request to user2.
       * - User2 accepts friend request
       * - User2 sets friend request status to 'accepted'
       * - User2 edits their friends section
       * - Next time User1 logs in check the request status
       *     - If accepted remove request from firestore
       *       and edit friends section to reflect new friend.
       *
       * I don't currently know how to do that in a proper way
       * So I'm gonna keep it as is.
       */

      transaction.set(
        _db.collection("users").doc(fromId).collection("friends").doc(toId),
        fromFriendData.toMap(),
      );

      transaction.set(
        _db.collection("users").doc(toId).collection("friends").doc(fromId),
        toFriendData.toMap(),
      );
    });

    await PostsService.getFriendIds(toId);
  }
}
