import '../models/community_models.dart';
import '../../../core/errors/result.dart';

abstract class FriendManagerService {
  Future<List<FriendModel>> getFriendsList();
  Future<Result<bool>> sendFriendRequest(String userId);
  Future<Result<bool>> removeFriend(String userId);
  Future<Result<bool>> blockRider(String userId);
}

class MockFriendManagerService implements FriendManagerService {
  final List<FriendModel> _friends = [
    const FriendModel(id: 'f1', name: 'Arjun K.', username: '@arjunk', avatarUrl: '', isOnline: true, lastSeenText: 'Online'),
    const FriendModel(id: 'f2', name: 'Priya S.', username: '@priyas', avatarUrl: '', isOnline: false, lastSeenText: '2h ago'),
    const FriendModel(id: 'f3', name: 'Rahul M.', username: '@rahulm', avatarUrl: '', isOnline: false, lastSeenText: 'Yesterday'),
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
    _friends.removeWhere((f) => f.id == userId);
    return Result.success(true);
  }

  @override
  Future<Result<bool>> blockRider(String userId) async {
    _friends.removeWhere((f) => f.id == userId);
    return Result.success(true);
  }
}
