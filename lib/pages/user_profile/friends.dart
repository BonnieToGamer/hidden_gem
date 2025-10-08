import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hidden_gem/models/friendRequest.dart';
import 'package:hidden_gem/models/user_info.dart';
import 'package:hidden_gem/services/auth_service.dart';
import 'package:hidden_gem/services/friend_service.dart';
import 'package:hidden_gem/services/user_service.dart';
import 'package:provider/provider.dart';

class FriendsPage extends StatefulWidget {
  FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

enum _RequestButtonState { addFriend, sentRequest, alreadyFriends, request }

class _FriendsPageState extends State<FriendsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  late TextEditingController _searchController;
  late User _selfUser;
  Timer? _debounce;
  List<UserProfileInfo> _searchResult = [];
  List<UserProfileInfo> _friends = [];
  List<UserProfileInfo> _requests = [];

  final Map<String, _RequestButtonState> _requestButtonStates = {};

  @override
  void initState() {
    super.initState();

    _searchController = TextEditingController();
    _selfUser = Provider.of<AuthState>(context, listen: false).user!;
    _loadFriends();
    _loadSentRequests();
    _loadRequests();
  }

  Future<void> _loadFriends() async {
    final friends = await FriendService.getFriends(_selfUser.uid);
    setState(() {
      _friends = friends;
      for (final user in friends) {
        _requestButtonStates[user.uid] = _RequestButtonState.alreadyFriends;
      }
    });
  }

  Future<void> _loadSentRequests() async {
    final requests = await FriendService.sentRequests(_selfUser.uid);

    setState(() {
      for (final user in requests) {
        _requestButtonStates[user.toId] = _RequestButtonState.sentRequest;
      }
    });
  }

  Future<void> _loadRequests() async {
    final requests = await FriendService.getRequests(_selfUser.uid);

    List<UserProfileInfo> userInfoList = [];

    for (final request in requests) {
      final userInfo = await UserService.getUser(request.fromId);
      userInfoList.add(userInfo);
    }

    setState(() {
      _requests = userInfoList;
      for (final user in requests) {
        _requestButtonStates[user.fromId] = _RequestButtonState.request;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Friends")),

      body: Column(
        children: [_friendRequests(), _searchNewFriends(), _friendsWidget()],
      ),
    );
  }

  Widget _searchNewFriends() {
    return Column(
      children: [
        Form(
          key: _formKey,
          child: TextFormField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: "Search for new friends...",
              prefixIcon: const Icon(Icons.search),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _friendRequests() {
    return _createFriendsList(_requests);
  }

  Widget _friendsWidget() {
    if (_searchController.text.isEmpty) {
      return _currentFriends();
    }

    return _searchedFriends();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      if (query.isNotEmpty) {
        final searchResult = await FriendService.searchUsers(query);

        setState(() {
          _searchResult = searchResult;
        });
      } else {
        setState(() {
          _searchResult = [];
        });
      }
    });
  }

  Widget _currentFriends() {
    return _createFriendsList(_friends);
  }

  Widget _searchedFriends() {
    return _createFriendsList(_searchResult);
  }

  Widget _createFriendsList(List<UserProfileInfo> list) {
    return Expanded(
      child: ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          final user = list[index];

          if (_requestButtonStates.containsKey(user.uid) == false) {
            _requestButtonStates[user.uid] = _RequestButtonState.addFriend;
          }

          if (_requestButtonStates[user.uid] == _RequestButtonState.request) {
            return _addFriendWidget(user);
          }

          return _createFriendWidget(user);
        },
      ),
    );
  }

  ListTile _createFriendWidget(UserProfileInfo user) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        height: 32,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.avatar,
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
      ),
      title: Text(user.name),
      trailing: _requestButtonStates[user.uid] != _RequestButtonState.addFriend
          ? Text(
              _requestButtonStates[user.uid] ==
                      _RequestButtonState.alreadyFriends
                  ? ""
                  : "Request sent",
            )
          : ElevatedButton(
              onPressed: () {
                if (_requestButtonStates[user.uid] ==
                    _RequestButtonState.sentRequest) {
                  return;
                }

                FriendService.createFriendRequest(_selfUser.uid, user.uid);
                setState(() {
                  _requestButtonStates[user.uid] =
                      _RequestButtonState.sentRequest;
                });
              },
              child: Text("Add friend"),
            ),
    );
  }

  Widget _addFriendWidget(UserProfileInfo user) {
    return ListTile(
      leading: SizedBox(
        width: 32,
        height: 32,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: user.avatar,
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
      ),
      title: Text(user.name),
      trailing: ElevatedButton(
        onPressed: () {
          FriendService.acceptRequest(_selfUser.uid, user.uid);
          setState(() {
            _requestButtonStates[user.uid] = _RequestButtonState.alreadyFriends;

            _requests.remove(user);
          });
        },
        child: Text("Accept request"),
      ),
    );
  }
}
