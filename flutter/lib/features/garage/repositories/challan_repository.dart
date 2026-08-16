import 'package:ridermate/core/errors/result.dart';
import '../models/challan_model.dart';

abstract class ChallanRepository {
  Future<Result<void>> addChallan(ChallanModel challan);
  Future<Result<List<ChallanModel>>> getChallansByVehicle(String vehicleId);
  Future<Result<List<ChallanModel>>> getChallansByUser(String userId);
  Future<Result<void>> updateChallanStatus(String id, String status);
  Future<Result<void>> deleteChallan(String id);
}
