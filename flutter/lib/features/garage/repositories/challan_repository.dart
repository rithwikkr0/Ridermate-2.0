import 'package:ridermate/core/errors/result.dart';
import 'package:ridermate/core/errors/app_error.dart';
import '../models/challan_model.dart';

abstract class ChallanRepository {
  Future<Result<void, AppError>> addChallan(ChallanModel challan);
  Future<Result<List<ChallanModel>, AppError>> getChallansByVehicle(String vehicleId);
  Future<Result<List<ChallanModel>, AppError>> getChallansByUser(String userId);
  Future<Result<void, AppError>> updateChallanStatus(String id, String status);
  Future<Result<void, AppError>> deleteChallan(String id);
}
