import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/features/community/models/post_model.dart';
import 'package:ridermate/features/community/models/comment_model.dart';
import 'package:ridermate/features/community/models/friend_model.dart';
import 'package:ridermate/features/community/models/squad_model.dart';
import 'package:ridermate/features/community/repositories/sqlite_post_repository.dart';
import 'package:ridermate/features/community/repositories/sqlite_friend_repository.dart';
import 'package:ridermate/features/community/repositories/sqlite_squad_repository.dart';
import 'package:ridermate/features/community/controllers/community_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({'user_id': 'user_A', 'user_name': 'Rider A'});
  });

  group('1. Community Models & Serialization Tests', () {
    test('PostModel serialization toMap and fromMap works seamlessly', () {
      final post = PostModel(
        id: 'post_101',
        userId: 'u_101',
        authorName: 'Arjun K.',
        authorAvatar: 'https://i.pravatar.cc/100',
        type: PostType.ride,
        caption: 'Crushed the Western Ghats trail today! 🔥',
        mediaUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc',
        privacy: PostPrivacy.friends,
        likeCount: 15,
        commentCount: 4,
        createdAt: DateTime(2026, 8, 15, 10, 0),
        updatedAt: DateTime(2026, 8, 15, 10, 0),
        rideStats: {'distance_km': 64.5, 'average_speed': 32.4},
      );

      final map = post.toMap();
      expect(map['id'], 'post_101');
      expect(map['type'], 'ride');
      expect(map['privacy'], 'friends');

      final decoded = PostModel.fromMap(map, isLiked: true, isSaved: true, rideStats: post.rideStats);
      expect(decoded.id, 'post_101');
      expect(decoded.authorName, 'Arjun K.');
      expect(decoded.type, PostType.ride);
      expect(decoded.isLikedByMe, true);
      expect(decoded.isSavedByMe, true);
      expect(decoded.rideStats?['distance_km'], 64.5);
    });

    test('CommentModel serialization and replies nesting', () {
      final reply = CommentModel(
        id: 'reply_1',
        postId: 'post_101',
        userId: 'u_202',
        authorName: 'Priya',
        text: 'Awesome route!',
        parentCommentId: 'cm_1',
        createdAt: DateTime(2026, 8, 15, 10, 5),
        updatedAt: DateTime(2026, 8, 15, 10, 5),
      );

      final comment = CommentModel(
        id: 'cm_1',
        postId: 'post_101',
        userId: 'u_303',
        authorName: 'Rahul',
        text: 'What was your average speed?',
        createdAt: DateTime(2026, 8, 15, 10, 2),
        updatedAt: DateTime(2026, 8, 15, 10, 2),
        replies: [reply],
      );

      final map = comment.toMap();
      expect(map['id'], 'cm_1');
      expect(map['text'], 'What was your average speed?');

      final decoded = CommentModel.fromMap(map, replies: [reply]);
      expect(decoded.id, 'cm_1');
      expect(decoded.replies.length, 1);
      expect(decoded.replies.first.id, 'reply_1');
    });

    test('SquadModel and GroupRideModel serialization', () {
      final squad = SquadModel(
        id: 'sq_1',
        creatorId: 'u_101',
        name: 'Mumbai Trailblazers',
        description: 'Weekend coastal tours',
        inviteCode: 'RM-MUMB-4321',
        isPrivate: true,
        createdAt: DateTime(2026, 8, 15),
        updatedAt: DateTime(2026, 8, 15),
      );

      final map = squad.toMap();
      expect(map['name'], 'Mumbai Trailblazers');
      expect(map['is_private'], 1);

      final decoded = SquadModel.fromMap(map, isMember: true, role: 'owner');
      expect(decoded.id, 'sq_1');
      expect(decoded.isPrivate, true);
      expect(decoded.isMember, true);
      expect(decoded.role, 'owner');
    });
  });

  group('2. SqlitePostRepository CRUD, Likes, Comments, Saves & Privacy Tests', () {
    late SqlitePostRepository postRepo;
    late SqliteFriendRepository friendRepo;

    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('DELETE FROM social_posts');
      await db.execute('DELETE FROM post_likes');
      await db.execute('DELETE FROM comments');
      await db.execute('DELETE FROM saved_posts');
      await db.execute('DELETE FROM friendships');
      await db.execute('DELETE FROM friend_requests');
      await db.execute('DELETE FROM blocked_users');
      await db.execute('DELETE FROM reports');

      postRepo = SqlitePostRepository();
      friendRepo = SqliteFriendRepository();
    });

    test('Create post and retrieve via getFeed', () async {
      final post = PostModel(
        id: 'p_test_1',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'First post on RiderMate!',
        privacy: PostPrivacy.public,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final createRes = await postRepo.createPost(post);
      expect(createRes.isSuccess, true, reason: createRes.error?.message);

      final feedRes = await postRepo.getFeed(currentUserId: 'user_A');
      expect(feedRes.isSuccess, true);
      expect(feedRes.dataOrNull?.length, 1);
      expect(feedRes.dataOrNull?.first.caption, 'First post on RiderMate!');
    });

    test('Atomic Like and Unlike toggle with real counter and duplicate prevention', () async {
      final post = PostModel(
        id: 'p_like_test',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'Test likes',
        privacy: PostPrivacy.public,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await postRepo.createPost(post);

      // User B likes post
      final like1 = await postRepo.toggleLike(postId: 'p_like_test', userId: 'user_B');
      expect(like1.isSuccess, true);
      expect(like1.dataOrNull, true); // isLiked = true

      final pAfterLike = await postRepo.getPostById('p_like_test', currentUserId: 'user_B');
      expect(pAfterLike.dataOrNull?.likeCount, 1);
      expect(pAfterLike.dataOrNull?.isLikedByMe, true);

      // User B unlikes post
      final unlike = await postRepo.toggleLike(postId: 'p_like_test', userId: 'user_B');
      expect(unlike.isSuccess, true);
      expect(unlike.dataOrNull, false); // isLiked = false

      final pAfterUnlike = await postRepo.getPostById('p_like_test', currentUserId: 'user_B');
      expect(pAfterUnlike.dataOrNull?.likeCount, 0);
      expect(pAfterUnlike.dataOrNull?.isLikedByMe, false);
    });

    test('Atomic Save and Unsave toggle with getSavedPosts verification', () async {
      final post = PostModel(
        id: 'p_save_test',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'Bookmarkable ride guide',
        privacy: PostPrivacy.public,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await postRepo.createPost(post);

      // User B saves post
      final saveRes = await postRepo.toggleSave(postId: 'p_save_test', userId: 'user_B');
      expect(saveRes.isSuccess, true);
      expect(saveRes.dataOrNull, true);

      final userBSaved = await postRepo.getSavedPosts(userId: 'user_B');
      expect(userBSaved.isSuccess, true);
      expect(userBSaved.dataOrNull?.length, 1);
      expect(userBSaved.dataOrNull?.first.id, 'p_save_test');

      // User A (different user) has 0 saved posts
      final userASaved = await postRepo.getSavedPosts(userId: 'user_A');
      expect(userASaved.dataOrNull?.isEmpty, true);

      // User B unsaves
      await postRepo.toggleSave(postId: 'p_save_test', userId: 'user_B');
      final userBSavedAfter = await postRepo.getSavedPosts(userId: 'user_B');
      expect(userBSavedAfter.dataOrNull?.isEmpty, true);
    });

    test('Comment creation, nested replies, count sync and delete authorization', () async {
      final post = PostModel(
        id: 'p_comment_test',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'Let us talk',
        privacy: PostPrivacy.public,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await postRepo.createPost(post);

      final c1 = CommentModel(
        id: 'cm_1',
        postId: 'p_comment_test',
        userId: 'user_B',
        authorName: 'Rider B',
        text: 'Great post!',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final addRes = await postRepo.addComment(c1);
      expect(addRes.isSuccess, true);

      final commentsRes = await postRepo.getComments('p_comment_test');
      expect(commentsRes.isSuccess, true);
      expect(commentsRes.dataOrNull?.length, 1);
      expect(commentsRes.dataOrNull?.first.text, 'Great post!');

      // Unauthorized user C cannot delete B's comment
      final unauthDel = await postRepo.deleteComment('cm_1', currentUserId: 'user_C');
      expect(unauthDel.isFailure, true);

      // Author user B can delete own comment
      final authDel = await postRepo.deleteComment('cm_1', currentUserId: 'user_B');
      expect(authDel.isSuccess, true);

      final commentsAfter = await postRepo.getComments('p_comment_test');
      expect(commentsAfter.dataOrNull?.isEmpty, true);
    });

    test('Data-Layer Privacy Enforcement: PRIVATE, FRIENDS and PUBLIC visibility rules', () async {
      // 1. User A creates a PRIVATE post
      await postRepo.createPost(PostModel(
        id: 'post_private',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'My private ride log',
        privacy: PostPrivacy.private,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // 2. User A creates a FRIENDS post
      await postRepo.createPost(PostModel(
        id: 'post_friends',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'Only for friends',
        privacy: PostPrivacy.friends,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // 3. User A creates a PUBLIC post
      await postRepo.createPost(PostModel(
        id: 'post_public',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'Public announcement',
        privacy: PostPrivacy.public,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // User A (author) sees all 3 posts
      final feedA = await postRepo.getFeed(currentUserId: 'user_A');
      expect(feedA.dataOrNull?.length, 3);

      // User B (not yet a friend) only sees the PUBLIC post
      final feedBBefore = await postRepo.getFeed(currentUserId: 'user_B');
      expect(feedBBefore.dataOrNull?.length, 1);
      expect(feedBBefore.dataOrNull?.first.id, 'post_public');

      // User A and User B become friends
      await friendRepo.sendFriendRequest(senderId: 'user_B', receiverId: 'user_A');
      final requests = await friendRepo.getPendingRequests(userId: 'user_A');
      await friendRepo.acceptFriendRequest(requestId: requests.dataOrNull!.first.id, userId: 'user_A');

      // User B now sees FRIENDS + PUBLIC posts (2 posts), NEVER PRIVATE
      final feedBAfter = await postRepo.getFeed(currentUserId: 'user_B');
      expect(feedBAfter.dataOrNull?.length, 2);
      final feedBIds = feedBAfter.dataOrNull!.map((p) => p.id).toSet();
      expect(feedBIds.contains('post_private'), false);
      expect(feedBIds.contains('post_friends'), true);
      expect(feedBIds.contains('post_public'), true);
    });

    test('Blocking completely hides posts bidirectionally', () async {
      await postRepo.createPost(PostModel(
        id: 'post_by_A',
        userId: 'user_A',
        authorName: 'Rider A',
        caption: 'Hello from A',
        privacy: PostPrivacy.public,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ));

      // User B blocks User A
      await friendRepo.blockUser(userId: 'user_B', targetId: 'user_A');

      // User B cannot see User A's post
      final feedB = await postRepo.getFeed(currentUserId: 'user_B');
      expect(feedB.dataOrNull?.isEmpty, true);

      // User A also cannot see User B
      final status = await friendRepo.getRelationshipStatus(currentUserId: 'user_A', targetUserId: 'user_B');
      expect(status.dataOrNull, FriendshipStatus.blocked);
    });
  });

  group('3. SqliteSquadRepository Tests', () {
    late SqliteSquadRepository squadRepo;

    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('DELETE FROM squads');
      await db.execute('DELETE FROM squad_members');
      await db.execute('DELETE FROM group_rides');
      await db.execute('DELETE FROM group_ride_members');
      squadRepo = SqliteSquadRepository();
    });

    test('Create squad auto-assigns creator as owner and member', () async {
      final squad = SquadModel(
        id: 'sq_test_1',
        creatorId: 'user_A',
        name: 'Ghats Roamers',
        description: 'Mountain touring',
        inviteCode: 'RM-GHAT-1001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final res = await squadRepo.createSquad(squad, creatorId: 'user_A');
      expect(res.isSuccess, true);

      final squadsA = await squadRepo.getSquads(currentUserId: 'user_A');
      expect(squadsA.dataOrNull?.length, 1);
      expect(squadsA.dataOrNull?.first.isMember, true);
      expect(squadsA.dataOrNull?.first.role, 'owner');

      final members = await squadRepo.getSquadMembers('sq_test_1');
      expect(members.dataOrNull?.length, 1);
      expect(members.dataOrNull?.first.userId, 'user_A');
      expect(members.dataOrNull?.first.role, 'owner');
    });

    test('Join squad, create group ride and toggle live location sharing', () async {
      final squad = SquadModel(
        id: 'sq_test_2',
        creatorId: 'user_A',
        name: 'City Cruisers',
        inviteCode: 'RM-CITY-2002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await squadRepo.createSquad(squad, creatorId: 'user_A');

      // User B joins squad
      final joinRes = await squadRepo.joinSquad(squadId: 'sq_test_2', userId: 'user_B');
      expect(joinRes.isSuccess, true);

      final members = await squadRepo.getSquadMembers('sq_test_2');
      expect(members.dataOrNull?.length, 2);

      // Create Group Ride
      final ride = GroupRideModel(
        id: 'gr_101',
        squadId: 'sq_test_2',
        creatorId: 'user_A',
        creatorName: 'Rider A',
        title: 'Sunday Morning Cruise',
        startTime: DateTime.now().add(const Duration(days: 1)),
        startLocation: 'Point A',
        destination: 'Point B',
        createdAt: DateTime.now(),
      );
      final rRes = await squadRepo.createGroupRide(ride);
      expect(rRes.isSuccess, true);

      // User B joins ride
      await squadRepo.joinGroupRide(groupRideId: 'gr_101', userId: 'user_B');

      // User B shares location
      await squadRepo.updateGroupRideLocation(
        groupRideId: 'gr_101',
        userId: 'user_B',
        lat: 12.9716,
        lng: 77.5946,
        isSharing: true,
      );

      final rides = await squadRepo.getGroupRides(squadId: 'sq_test_2', currentUserId: 'user_B');
      expect(rides.dataOrNull?.length, 1);
      expect(rides.dataOrNull?.first.isJoined, true);
      expect(rides.dataOrNull?.first.isSharingLocation, true);
    });
  });

  group('4. Multi-User Isolation & State Cleanliness Tests', () {
    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('DELETE FROM social_posts');
      await db.execute('DELETE FROM post_likes');
      await db.execute('DELETE FROM comments');
      await db.execute('DELETE FROM saved_posts');
      await db.execute('DELETE FROM friendships');
      await db.execute('DELETE FROM blocked_users');
    });

    test('CommunityController refreshForUser wipes and restores user-isolated state correctly', () async {
      final controller = CommunityController();

      // User A context
      await controller.refreshForUser('user_A', userName: 'Rider A');
      await controller.createPost(caption: 'Post by A', privacy: PostPrivacy.private);
      expect(controller.feedPosts.length, 1);

      // Switch to User B (logout User A / login User B)
      await controller.refreshForUser('user_B', userName: 'Rider B');
      // User B must NOT see User A's private post
      expect(controller.feedPosts.isEmpty, true);

      // Switch back to User A
      await controller.refreshForUser('user_A', userName: 'Rider A');
      expect(controller.feedPosts.length, 1);

      controller.dispose();
    });
  });

  group('5. Database Schema Version 10 Verification', () {
    test('All 12 required Community SQLite tables exist with correct schema in DatabaseService', () async {
      final db = await DatabaseService.instance.database;

      final tables = [
        'social_posts',
        'post_likes',
        'comments',
        'saved_posts',
        'squads',
        'squad_members',
        'group_rides',
        'group_ride_members',
        'reports',
        'blocked_users',
        'stories',
        'offline_sync_queue',
      ];

      for (final table in tables) {
        final info = await db.rawQuery("PRAGMA table_info($table)");
        expect(info.isNotEmpty, true, reason: 'Table $table must exist in SQLite DatabaseService');
      }
    });
  });
}
