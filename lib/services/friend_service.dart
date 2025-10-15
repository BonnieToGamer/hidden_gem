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
      status: "pending",
      timestamp: Timestamp.now(),
    );

    await _db.collection("friendRequests").add(request.toMap());
  }

  static Future<List<FriendRequest>> getRequests(String user) async {
    return (await _db
            .collection("friendRequests")
            .where("toId", isEqualTo: user)
            .where("status", isEqualTo: "pending")
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

  static Future<void> acceptRequest(FriendRequest request) async {
    FriendRequest newRequest = FriendRequest(
      id: request.id,
      fromId: request.fromId,
      toId: request.toId,
      status: "accepted",
      timestamp: Timestamp.now(),
    );

    await _db
        .collection("friendRequests")
        .doc(newRequest.id)
        .set(newRequest.toMap());

    FriendData data = FriendData(
      id: "",
      friendId: request.fromId,
      timestamp: Timestamp.now(),
    );

    await _db
        .collection("users")
        .doc(request.toId)
        .collection("friends")
        .doc(request.fromId)
        .set(data.toMap());

    /**
     * My previous rant has ben annulled. I just did it :)
     * The new flow is:
     * - User1 sends friend request to user2.
     * - User2 accepts friend requests and updates
     *   the friendRequests status to "accepted"
     * - User2 edits their friends collection to
     *   add the new friend
     * - Next time User1 logs in or opens the app,
     *   They will automatically check if the status
     *   is "accepted" and delete any requests that are
     *   and also add that friend
     */
  }

  /*
   * If a friendRequest's status is set to 'accepted'
   * change it to 'finalized' and add the friend.
   */
  static Future<void> acceptSentRequests(String uid) async {
    final requests =
        (await _db
                .collection("friendRequests")
                .where("fromId", isEqualTo: uid)
                .where("status", isEqualTo: "accepted")
                .get())
            .docs
            .map((doc) => FriendRequest.fromFirestore(doc));

    if (requests.isEmpty) {
      return;
    }

    for (final request in requests) {
      FriendData data = FriendData(
        id: "",
        friendId: request.toId,
        timestamp: Timestamp.now(),
      );

      await _db
          .collection("users")
          .doc(uid)
          .collection("friends")
          .doc(request.toId)
          .set(data.toMap());

      await _db.collection("friendRequests").doc(request.id).delete();
    }
  }

  static Future<void> removeFriend(String selfId, String otherId) async {
    final collection = FirebaseFirestore.instance.collection('friendRequests');

    // get the request (if it exists)
    final querySnapshot = await collection
        .where('fromId', whereIn: [selfId, otherId])
        .where('toId', whereIn: [selfId, otherId])
        .get();

    // delete it
    for (final doc in querySnapshot.docs) {
      final data = doc.data();
      if ((data['fromId'] == selfId && data['toId'] == otherId) ||
          (data['fromId'] == otherId && data['toId'] == selfId)) {
        await collection.doc(doc.id).delete();
      }
    }

    final request = FriendRequest(
      id: "",
      fromId: selfId,
      toId: otherId,
      status: "removed",
      timestamp: Timestamp.now(),
    );

    await collection.add(request.toMap());
    await _db
        .collection("users")
        .doc(selfId)
        .collection("friends")
        .doc(otherId)
        .delete();
  }

  static Future<void> handleDeletedRequests(String uid) async {
    final collection = FirebaseFirestore.instance.collection('friendRequests');

    // Query where uid is the receiver
    final toQuery = await collection
        .where('toId', isEqualTo: uid)
        .where('status', isEqualTo: 'removed')
        .get();

    final allDocs = [
      ...toQuery.docs,
    ].map((doc) => FriendRequest.fromFirestore(doc));

    for (final request in allDocs) {
      await _db
          .collection("users")
          .doc(uid)
          .collection("friends")
          .doc(request.fromId)
          .delete();

      await _db.collection("friendRequests").doc(request.id).delete();
    }
  }
}
