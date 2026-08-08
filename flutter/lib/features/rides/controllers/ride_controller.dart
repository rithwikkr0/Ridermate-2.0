import 'dart:async';
import '../../../core/models/ride_point_model.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../providers/base_controller.dart';
import '../models/ride_engine_model.dart';
import '../models/route_model.dart';
import '../repositories/ride_repository.dart';
import '../services/statistics_engine.dart';

enum RideLifecycle { idle, starting, running, paused, stopping, completed, error }

class RideController extends BaseController {
  RideController(this.repository, this.locationService) { loadHistory(); }
  final RideRepository repository;
  final LocationService locationService;
  StreamSubscription<RidePointModel>? _subscription;
  Timer? _timer;
  final List<RoutePoint> _points = [];
  final List<RideEngineModel> rides = [];
  RideLifecycle lifecycle = RideLifecycle.idle;
  DateTime? _startedAt;
  Duration _pausedDuration = Duration.zero;
  DateTime? _pausedAt;
  double _distanceKm = 0;
  double _maxSpeed = 0;
  RideEngineModel? selectedRide;
  String? rideError;
  bool get isTracking => lifecycle == RideLifecycle.running || lifecycle == RideLifecycle.paused;
  bool get isPaused => lifecycle == RideLifecycle.paused;
  Duration get duration => _startedAt == null ? Duration.zero : (isPaused ? _pausedAt! : DateTime.now()).difference(_startedAt!) - _pausedDuration;
  double get currentSpeedKmh => _points.isEmpty ? 0 : _points.last.speedKmh;
  double get distanceKm => _distanceKm;

  Future<void> loadHistory() async { final result=await repository.getAll(); if(result.isSuccess){rides..clear()..addAll(result.dataOrNull!); notifyListeners();} }
  Future<void> startRide() async {
    if (isTracking) return;
    lifecycle=RideLifecycle.starting; rideError=null; notifyListeners();
    final first=await locationService.getCurrentLocation();
    if(first.isFailure){_fail(first.errorOrNull!.message); return;}
    _points.clear(); _distanceKm=0; _maxSpeed=0; _pausedDuration=Duration.zero; _startedAt=DateTime.now();
    _record(first.dataOrNull!);
    lifecycle=RideLifecycle.running; _timer=Timer.periodic(const Duration(seconds: 1), (_) => notifyListeners());
    _subscription=locationService.getLocationStream().listen(_record,onError:(e)=>_fail('$e'));
    notifyListeners();
  }
  void _record(RidePointModel point) {
    if(lifecycle != RideLifecycle.running || point.latitude.abs()>90 || point.longitude.abs()>180) return;
    final next=RoutePoint(latitude:point.latitude,longitude:point.longitude,speedKmh:point.speed,timestamp:point.timestamp,elevationMeters:0);
    if(_points.isNotEmpty){ final gap=GeoUtils.calculateDistance(_points.last.latitude,_points.last.longitude,next.latitude,next.longitude); if(gap>1 || (gap<0.003 && DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(_points.last.timestamp)).inSeconds<3)) return; _distanceKm+=gap; }
    _points.add(next); _maxSpeed=_maxSpeed>next.speedKmh?_maxSpeed:next.speedKmh; notifyListeners();
  }
  void pauseRide(){if(lifecycle==RideLifecycle.running){lifecycle=RideLifecycle.paused;_pausedAt=DateTime.now();notifyListeners();}}
  void resumeRide(){if(lifecycle==RideLifecycle.paused){_pausedDuration+=DateTime.now().difference(_pausedAt!);_pausedAt=null;lifecycle=RideLifecycle.running;notifyListeners();}}
  Future<void> stopRide() async { if(!isTracking)return; lifecycle=RideLifecycle.stopping;notifyListeners(); await _subscription?.cancel();_timer?.cancel(); final ride=RideEngineModel(id:'ride-${_startedAt!.millisecondsSinceEpoch}',title:'Ride ${_startedAt!.toLocal().toString().substring(0,16)}',vehicle:'Unassigned vehicle',startTime:_startedAt!,endTime:DateTime.now(),duration:duration,distanceKm:_distanceKm,averageSpeedKmh:duration.inSeconds==0?0:_distanceKm/(duration.inSeconds/3600),maxSpeedKmh:_maxSpeed,elevationMeters:0,caloriesBurned:StatisticsEngine.calculateCalories(_distanceKm,duration),weather:'Not recorded',routePoints:List.unmodifiable(_points),rideScore:StatisticsEngine.calculateRideScore(0,_maxSpeed,0)); final result=await repository.save(ride); if(result.isFailure){_fail(result.errorOrNull!.message);return;} selectedRide=ride;rides.insert(0,ride);lifecycle=RideLifecycle.completed;notifyListeners(); }
  void discardRide(){_subscription?.cancel();_timer?.cancel();_points.clear();lifecycle=RideLifecycle.idle;notifyListeners();}
  void selectRide(RideEngineModel ride){selectedRide=ride;notifyListeners();}
  void _fail(String error){rideError=error;lifecycle=RideLifecycle.error;setState(ViewState.error);}
  @override void dispose(){_subscription?.cancel();_timer?.cancel();super.dispose();}
}
