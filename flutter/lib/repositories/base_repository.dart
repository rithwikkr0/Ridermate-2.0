import '../core/errors/result.dart';

/// RiderMate 2.0 — Base Repository Pattern
abstract class BaseRepository<T, ID> {
  Future<Result<List<T>>> getAll();
  Future<Result<T?>> getById(ID id);
  Future<Result<T>> save(T item);
  Future<Result<bool>> delete(ID id);
}
