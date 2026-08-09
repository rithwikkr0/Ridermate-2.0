// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:ridermate/core/errors/result.dart';
import 'package:ridermate/core/errors/app_error.dart';
import 'package:ridermate/core/models/ride_point_model.dart';
import 'package:ridermate/core/services/location_service.dart';
import 'package:ridermate/features/memories/controllers/memory_controller.dart';
import 'package:ridermate/features/memories/models/memory_model.dart';
import 'package:ridermate/features/memories/repositories/memory_repository.dart';
import 'package:ridermate/features/rides/models/ride_engine_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test Doubles
// ─────────────────────────────────────────────────────────────────────────────

class _TestMemoryRepository implements MemoryRepository {
  final List<MemoryModel> _memories = [];
  final List<String> deletedFilePaths = [];

  @override
  Future<Result<MemoryModel>> createMemory(MemoryModel memory) async {
    _memories.insert(0, memory);
    return Result.success(memory);
  }

  @override
  Future<Result<List<MemoryModel>>> getMemories({required String userId}) async {
    final list = _memories.where((m) => m.userId == userId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Result.success(list);
  }

  @override
  Future<Result<MemoryModel?>> getMemoryById(String id, {required String userId}) async {
    final match = _memories.cast<MemoryModel?>().firstWhere(
          (m) => m?.id == id && m?.userId == userId,
          orElse: () => null,
        );
    return Result.success(match);
  }

  @override
  Future<Result<MemoryModel>> updateMemory(MemoryModel memory) async {
    final index = _memories.indexWhere((m) => m.id == memory.id && m.userId == memory.userId);
    if (index != -1) {
      final updated = memory.copyWith(updatedAt: DateTime.now());
      _memories[index] = updated;
      return Result.success(updated);
    }
    return Result.failure(const StorageError('Memory not found'));
  }

  @override
  Future<Result<bool>> deleteMemory(String id, {required String userId}) async {
    final index = _memories.indexWhere((m) => m.id == id && m.userId == userId);
    if (index != -1) {
      final removed = _memories.removeAt(index);
      deletedFilePaths.add(removed.imagePath);
      if (removed.thumbnailPath != null) {
        deletedFilePaths.add(removed.thumbnailPath!);
      }
      return Result.success(true);
    }
    return Result.success(false);
  }

  @override
  Future<Result<List<MemoryModel>>> getMemoriesForRide(String rideId, {required String userId}) async {
    final list = _memories
        .where((m) => m.userId == userId && m.rideId == rideId)
        .toList();
    return Result.success(list);
  }

  @override
  Future<Result<List<MemoryModel>>> getMemoriesWithLocation({required String userId}) async {
    final list = _memories
        .where((m) => m.userId == userId && m.latitude != null && m.longitude != null)
        .toList();
    return Result.success(list);
  }

  @override
  Future<Result<List<MemoryModel>>> searchMemories(String query, {required String userId}) async {
    final q = query.toLowerCase();
    final list = _memories.where((m) {
      if (m.userId != userId) return false;
      final captionMatch = m.caption.toLowerCase().contains(q);
      final locationMatch = m.locationName?.toLowerCase().contains(q) ?? false;
      return captionMatch || locationMatch;
    }).toList();
    return Result.success(list);
  }
}

class _TestLocationService implements LocationService {
  RidePointModel? _point;
  bool shouldFail = false;

  void setLocation(double lat, double lng) {
    _point = RidePointModel(
      latitude: lat,
      longitude: lng,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      speed: 0,
      accuracy: 10,
    );
  }

  @override
  Future<Result<RidePointModel>> getCurrentLocation() async {
    if (shouldFail || _point == null) {
      return Result.failure(const LocationError('GPS unavailable'));
    }
    return Result.success(_point!);
  }

  @override
  Stream<RidePointModel> getLocationStream() => const Stream.empty();
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  group('1. MemoryModel — Serialization & Enums', () {
    test('MemoryPrivacy enum values are private, friends, public', () {
      expect(MemoryPrivacy.values, contains(MemoryPrivacy.private));
      expect(MemoryPrivacy.values, contains(MemoryPrivacy.friends));
      expect(MemoryPrivacy.values, contains(MemoryPrivacy.public));
    });

    test('toMap and fromMap round-trip preserves all fields', () {
      final now = DateTime.now();
      final memory = MemoryModel(
        id: 'mem_1',
        userId: 'user_abc',
        rideId: 'ride_123',
        imagePath: '/storage/memories/memory_1.jpg',
        thumbnailPath: '/storage/memories/thumb_1.jpg',
        caption: 'Sunset ride in Mysuru',
        latitude: 12.2958,
        longitude: 76.6394,
        locationName: 'Mysore Palace, Mysuru',
        createdAt: now,
        updatedAt: now,
        privacy: MemoryPrivacy.friends,
        rideDistance: 32.5,
        rideDuration: 3600,
      );

      final map = memory.toMap();
      final restored = MemoryModel.fromMap(map);

      expect(restored.id, memory.id);
      expect(restored.userId, memory.userId);
      expect(restored.rideId, memory.rideId);
      expect(restored.imagePath, memory.imagePath);
      expect(restored.thumbnailPath, memory.thumbnailPath);
      expect(restored.caption, memory.caption);
      expect(restored.latitude, memory.latitude);
      expect(restored.longitude, memory.longitude);
      expect(restored.locationName, memory.locationName);
      expect(restored.privacy, MemoryPrivacy.friends);
      expect(restored.rideDistance, memory.rideDistance);
      expect(restored.rideDuration, memory.rideDuration);
    });

    test('copyWith updates specified fields only', () {
      final now = DateTime.now();
      final original = MemoryModel(
        id: 'mem_1',
        userId: 'user_1',
        imagePath: '/path/1.jpg',
        caption: 'Original caption',
        createdAt: now,
        updatedAt: now,
      );

      final copy = original.copyWith(caption: 'Updated caption', privacy: MemoryPrivacy.public);

      expect(copy.id, 'mem_1');
      expect(copy.caption, 'Updated caption');
      expect(copy.privacy, MemoryPrivacy.public);
      expect(copy.imagePath, '/path/1.jpg');
    });
  });

  group('2. MemoryRepository & User Isolation', () {
    late _TestMemoryRepository repository;

    setUp(() {
      repository = _TestMemoryRepository();
    });

    test('createMemory inserts memory into repository', () async {
      final now = DateTime.now();
      final mem = MemoryModel(
        id: 'm1',
        userId: 'u1',
        imagePath: '/path/m1.jpg',
        caption: 'First memory',
        createdAt: now,
        updatedAt: now,
      );

      final result = await repository.createMemory(mem);
      expect(result.isSuccess, isTrue);

      final fetch = await repository.getMemories(userId: 'u1');
      expect(fetch.dataOrNull?.length, 1);
      expect(fetch.dataOrNull?.first.caption, 'First memory');
    });

    test('User isolation: User B cannot see User A private memories', () async {
      final now = DateTime.now();
      await repository.createMemory(MemoryModel(
        id: 'm1',
        userId: 'userA',
        imagePath: '/path/a.jpg',
        caption: 'User A Memory',
        privacy: MemoryPrivacy.private,
        createdAt: now,
        updatedAt: now,
      ));

      await repository.createMemory(MemoryModel(
        id: 'm2',
        userId: 'userB',
        imagePath: '/path/b.jpg',
        caption: 'User B Memory',
        privacy: MemoryPrivacy.private,
        createdAt: now,
        updatedAt: now,
      ));

      final userAMemories = await repository.getMemories(userId: 'userA');
      final userBMemories = await repository.getMemories(userId: 'userB');

      expect(userAMemories.dataOrNull?.length, 1);
      expect(userAMemories.dataOrNull?.first.id, 'm1');

      expect(userBMemories.dataOrNull?.length, 1);
      expect(userBMemories.dataOrNull?.first.id, 'm2');

      final crossGet = await repository.getMemoryById('m1', userId: 'userB');
      expect(crossGet.dataOrNull, isNull);
    });

    test('updateMemory modifies caption and privacy in database', () async {
      final now = DateTime.now();
      final mem = MemoryModel(
        id: 'm1',
        userId: 'u1',
        imagePath: '/path/1.jpg',
        caption: 'Old Caption',
        privacy: MemoryPrivacy.private,
        createdAt: now,
        updatedAt: now,
      );

      await repository.createMemory(mem);
      final updatedMem = mem.copyWith(caption: 'New Caption', privacy: MemoryPrivacy.friends);
      await repository.updateMemory(updatedMem);

      final fetched = await repository.getMemoryById('m1', userId: 'u1');
      expect(fetched.dataOrNull?.caption, 'New Caption');
      expect(fetched.dataOrNull?.privacy, MemoryPrivacy.friends);
    });

    test('deleteMemory removes database record and registers file cleanup', () async {
      final now = DateTime.now();
      final mem = MemoryModel(
        id: 'm1',
        userId: 'u1',
        imagePath: '/path/mem1.jpg',
        thumbnailPath: '/path/thumb1.jpg',
        caption: 'ToDelete',
        createdAt: now,
        updatedAt: now,
      );

      await repository.createMemory(mem);
      final deleteResult = await repository.deleteMemory('m1', userId: 'u1');

      expect(deleteResult.isSuccess, isTrue);
      expect(repository.deletedFilePaths, contains('/path/mem1.jpg'));
      expect(repository.deletedFilePaths, contains('/path/thumb1.jpg'));

      final list = await repository.getMemories(userId: 'u1');
      expect(list.dataOrNull, isEmpty);
    });

    test('Memories are returned in newest-first order (created_at DESC)', () async {
      final older = DateTime(2026, 1, 1);
      final newer = DateTime(2026, 8, 8);

      await repository.createMemory(MemoryModel(
        id: 'm_old',
        userId: 'u1',
        imagePath: '/path/old.jpg',
        caption: 'Older',
        createdAt: older,
        updatedAt: older,
      ));

      await repository.createMemory(MemoryModel(
        id: 'm_new',
        userId: 'u1',
        imagePath: '/path/new.jpg',
        caption: 'Newer',
        createdAt: newer,
        updatedAt: newer,
      ));

      final list = await repository.getMemories(userId: 'u1');
      expect(list.dataOrNull?.first.id, 'm_new');
      expect(list.dataOrNull?.last.id, 'm_old');
    });

    test('searchMemories filters by caption and locationName', () async {
      final now = DateTime.now();
      await repository.createMemory(MemoryModel(
        id: 'm1',
        userId: 'u1',
        imagePath: '/path/1.jpg',
        caption: 'Coastal beach ride',
        locationName: 'Goa',
        createdAt: now,
        updatedAt: now,
      ));

      await repository.createMemory(MemoryModel(
        id: 'm2',
        userId: 'u1',
        imagePath: '/path/2.jpg',
        caption: 'Mountain trail',
        locationName: 'Manali',
        createdAt: now,
        updatedAt: now,
      ));

      final searchBeach = await repository.searchMemories('beach', userId: 'u1');
      expect(searchBeach.dataOrNull?.length, 1);
      expect(searchBeach.dataOrNull?.first.id, 'm1');

      final searchManali = await repository.searchMemories('Manali', userId: 'u1');
      expect(searchManali.dataOrNull?.length, 1);
      expect(searchManali.dataOrNull?.first.id, 'm2');
    });

    test('getMemoriesWithLocation filters items with null coordinates', () async {
      final now = DateTime.now();
      await repository.createMemory(MemoryModel(
        id: 'm_geo',
        userId: 'u1',
        imagePath: '/path/geo.jpg',
        caption: 'Geo tagged',
        latitude: 12.9716,
        longitude: 77.5946,
        createdAt: now,
        updatedAt: now,
      ));

      await repository.createMemory(MemoryModel(
        id: 'm_nogeo',
        userId: 'u1',
        imagePath: '/path/nogeo.jpg',
        caption: 'No GPS',
        latitude: null,
        longitude: null,
        createdAt: now,
        updatedAt: now,
      ));

      final geoList = await repository.getMemoriesWithLocation(userId: 'u1');
      expect(geoList.dataOrNull?.length, 1);
      expect(geoList.dataOrNull?.first.id, 'm_geo');
    });
  });

  group('3. MemoryController & Draft Flow', () {
    late _TestMemoryRepository repository;
    late _TestLocationService locationService;
    late MemoryController controller;

    setUp(() {
      repository = _TestMemoryRepository();
      locationService = _TestLocationService();
      controller = MemoryController(repository, locationService);
    });

    tearDown(() {
      controller.dispose();
    });

    test('resetDraft clears buffer to default state', () {
      controller.draftImagePath = '/old.jpg';
      controller.draftCaption = 'Old';
      controller.resetDraft();

      expect(controller.draftImagePath, isNull);
      expect(controller.draftCaption, isEmpty);
      expect(controller.draftPrivacy, MemoryPrivacy.private);
    });

    test('setCaption and setPrivacy update draft parameters', () {
      controller.resetDraft();
      controller.setCaption('My Awesome Ride');
      controller.setPrivacy(MemoryPrivacy.public);

      expect(controller.draftCaption, 'My Awesome Ride');
      expect(controller.draftPrivacy, MemoryPrivacy.public);
    });

    test('setRide associates ride details with draft', () {
      controller.resetDraft();
      final fakeRide = RideEngineModel(
        id: 'ride_999',
        title: 'Morning Cruise',
        vehicle: 'Interceptor 650',
        startTime: DateTime.now(),
        duration: const Duration(minutes: 45),
        distanceKm: 28.4,
        averageSpeedKmh: 35.0,
        maxSpeedKmh: 75.0,
        elevationMeters: 100,
        caloriesBurned: 500,
        weather: 'Sunny',
        routePoints: const [],
        rideScore: 95,
      );

      controller.setRide(fakeRide);

      expect(controller.draftRideId, 'ride_999');
      expect(controller.draftRideDistance, 28.4);
      expect(controller.draftRideDuration, 2700);

      controller.setRide(null);
      expect(controller.draftRideId, isNull);
      expect(controller.draftRideDistance, isNull);
    });

    test('fetchCurrentLocation updates lat/lng on valid GPS fix', () async {
      locationService.setLocation(12.9716, 77.5946);
      controller.resetDraft();

      await controller.fetchCurrentLocation();

      expect(controller.draftLatitude, 12.9716);
      expect(controller.draftLongitude, 77.5946);
    });

    test('Memory without GPS can be saved successfully', () async {
      controller.resetDraft();
      controller.draftImagePath = '/valid/photo.jpg';
      controller.setCaption('Indoor ride log without GPS');

      final success = await controller.saveMemory('user1');
      expect(success, isTrue);

      final list = await repository.getMemories(userId: 'user1');
      expect(list.dataOrNull?.length, 1);
      expect(list.dataOrNull?.first.latitude, isNull);
    });

    test('saveMemory fails if no image is attached', () async {
      controller.resetDraft();
      controller.setCaption('Caption only');

      final success = await controller.saveMemory('user1');
      expect(success, isFalse);
      expect(controller.memoryError, contains('photo'));
    });
  });
}
