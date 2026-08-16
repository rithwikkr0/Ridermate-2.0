import '../../../core/errors/result.dart';
import '../../../repositories/base_repository.dart';
import '../models/ride_engine_model.dart';
import '../services/mock_ride_generator.dart';

import '../models/active_ride_draft.dart';

abstract class RideRepository implements BaseRepository<RideEngineModel, String> {
  Future<Result<List<RideEngineModel>>> getHistory({String? query, String? filter, int page = 1, int pageSize = 20});
  Future<Result<ActiveRideDraft?>> getActiveDraft(String userId);
  Future<Result<void>> saveActiveDraft(ActiveRideDraft draft);
  Future<Result<void>> clearActiveDraft(String userId);
}

class MockRideRepository implements RideRepository {
  final List<RideEngineModel> _rides = MockRideGenerator.generateList(100);
  ActiveRideDraft? _mockDraft;

  @override
  Future<Result<List<RideEngineModel>>> getAll() async {
    return Result.success(_rides);
  }

  @override
  Future<Result<RideEngineModel?>> getById(String id) async {
    final ride = _rides.firstWhere((r) => r.id == id, orElse: () => _rides.first);
    return Result.success(ride);
  }

  @override
  Future<Result<RideEngineModel>> save(RideEngineModel item) async {
    _rides.insert(0, item);
    return Result.success(item);
  }

  @override
  Future<Result<bool>> delete(String id) async {
    _rides.removeWhere((r) => r.id == id);
    return Result.success(true);
  }

  @override
  Future<Result<List<RideEngineModel>>> getHistory({String? query, String? filter, int page = 1, int pageSize = 20}) async {
    Iterable<RideEngineModel> filtered = _rides;
    if (query != null && query.isNotEmpty) {
      filtered = filtered.where((r) => r.title.toLowerCase().contains(query.toLowerCase()));
    }
    final startIndex = (page - 1) * pageSize;
    final list = filtered.skip(startIndex).take(pageSize).toList();
    return Result.success(list);
  }

  @override
  Future<Result<ActiveRideDraft?>> getActiveDraft(String userId) async {
    return Result.success(_mockDraft);
  }

  @override
  Future<Result<void>> saveActiveDraft(ActiveRideDraft draft) async {
    _mockDraft = draft;
    return Result.success(null);
  }

  @override
  Future<Result<void>> clearActiveDraft(String userId) async {
    _mockDraft = null;
    return Result.success(null);
  }
}
