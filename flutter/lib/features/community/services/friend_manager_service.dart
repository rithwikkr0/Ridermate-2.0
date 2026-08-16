import '../models/friend_model.dart';
import '../../../core/errors/result.dart';

abstract class FriendManagerService {
  Future<List<FriendModel>> getFriendsList();
  Future<Result<bool>> sendFriendRequest(String userId);
  Future<Result<bool>> removeFriend(String userId);
  Future<Result<bool>> blockRider(String userId);
}

class MockFriendManagerService implements FriendManagerService {
  final List<FriendModel> _friends = [
    FriendModel(
      id: 'f1',
      userId: 'u_curr',
      friendId: 'f1',
      fullName: 'Arjun K.',
      username: 'arjunk',
      createdAt: DateTime.now(),
    ),
    FriendModel(
      id: 'f2',
      userId: 'u_curr',
      friendId: 'f2',
      fullName: 'Priya S.',
      username: 'priyas',
      createdAt: DateTime.now(),
    ),
    FriendModel(
      id: 'f3',
      userId: 'u_curr',
      friendId: 'f3',
      fullName: 'Rahul M.',
      username: 'rahulm',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<FriendModel>> getFriendsList() async => List.unmodifiable(_friends);

  @override
  Future<Result<bool>> sendFriendRequest(String userId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return Result.success(true);
  }

  @override
  Future<Result<bool>> removeFriend(String userId) async {
    _friends.removeWhere((f) => f.friendId == userId || f.id == userId);
    return Result.success(true);
  }

  @override
  Future<Result<bool>> blockRider(String userId) async {
    _friends.removeWhere((f) => f.friendId == userId || f.id == userId);
    return Result.success(true);
  }
}
