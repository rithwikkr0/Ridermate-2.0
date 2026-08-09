import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/location_service.dart';
import '../../../providers/base_controller.dart';
import '../../rides/models/ride_engine_model.dart';
import '../models/memory_model.dart';
import '../repositories/memory_repository.dart';

enum MemoryState { idle, loading, creating, saving, loaded, error }

class MemoryController extends BaseController {
  final MemoryRepository repository;
  final LocationService locationService;
  final ImagePicker _picker = ImagePicker();

  MemoryController(this.repository, this.locationService);

  MemoryState _memoryState = MemoryState.idle;
  MemoryState get memoryState => _memoryState;

  List<MemoryModel> _memories = [];
  List<MemoryModel> get memories => List.unmodifiable(_memories);

  MemoryModel? _selectedMemory;
  MemoryModel? get selectedMemory => _selectedMemory;

  String? memoryError;

  // ── Draft State for Create / Edit ───────────────────────────────────────
  String? draftId;
  String? draftImagePath;
  String draftCaption = '';
  double? draftLatitude;
  double? draftLongitude;
  String? draftLocationName;
  MemoryPrivacy draftPrivacy = MemoryPrivacy.private;
  String? draftRideId;
  double? draftRideDistance;
  int? draftRideDuration;

  bool _isLocating = false;
  bool get isLocating => _isLocating;

  bool get canSaveDraft =>
      (draftImagePath != null && draftImagePath!.isNotEmpty) ||
      draftCaption.trim().isNotEmpty;

  // ── Load Feed ────────────────────────────────────────────────────────────
  Future<void> loadMemories(String userId) async {
    _memoryState = MemoryState.loading;
    notifyListeners();

    final result = await repository.getMemories(userId: userId);
    if (result.isSuccess) {
      _memories = result.dataOrNull ?? [];
      _memoryState = MemoryState.loaded;
      setState(ViewState.success);
    } else {
      memoryError = result.errorOrNull?.message ?? 'Failed to load memories';
      _memoryState = MemoryState.error;
      setState(ViewState.error);
    }
  }

  // ── Draft Initialization ────────────────────────────────────────────────
  void resetDraft() {
    draftId = null;
    draftImagePath = null;
    draftCaption = '';
    draftLatitude = null;
    draftLongitude = null;
    draftLocationName = null;
    draftPrivacy = MemoryPrivacy.private;
    draftRideId = null;
    draftRideDistance = null;
    draftRideDuration = null;
    _isLocating = false;
    memoryError = null;
    _memoryState = MemoryState.creating;
    notifyListeners();
  }

  void initEditDraft(MemoryModel memory) {
    draftId = memory.id;
    draftImagePath = memory.imagePath;
    draftCaption = memory.caption;
    draftLatitude = memory.latitude;
    draftLongitude = memory.longitude;
    draftLocationName = memory.locationName;
    draftPrivacy = memory.privacy;
    draftRideId = memory.rideId;
    draftRideDistance = memory.rideDistance;
    draftRideDuration = memory.rideDuration;
    _isLocating = false;
    memoryError = null;
    _memoryState = MemoryState.creating;
    notifyListeners();
  }

  // ── Camera / Gallery Pickers ─────────────────────────────────────────────
  Future<void> pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (file != null) {
        draftImagePath = file.path;
        notifyListeners();
      }
    } catch (e) {
      memoryError = 'Failed to select image from gallery: $e';
      notifyListeners();
    }
  }

  Future<void> captureFromCamera() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (file != null) {
        draftImagePath = file.path;
        notifyListeners();
      }
    } catch (e) {
      memoryError = 'Failed to capture photo from camera: $e';
      notifyListeners();
    }
  }

  void removeSelectedImage() {
    draftImagePath = null;
    notifyListeners();
  }

  // ── Setters ─────────────────────────────────────────────────────────────
  void setCaption(String caption) {
    draftCaption = caption;
    notifyListeners();
  }

  void setPrivacy(MemoryPrivacy privacy) {
    draftPrivacy = privacy;
    notifyListeners();
  }

  void setLocation(double? lat, double? lng, String? name) {
    draftLatitude = lat;
    draftLongitude = lng;
    draftLocationName = name;
    notifyListeners();
  }

  void setRide(RideEngineModel? ride) {
    if (ride == null) {
      draftRideId = null;
      draftRideDistance = null;
      draftRideDuration = null;
    } else {
      draftRideId = ride.id;
      draftRideDistance = ride.distanceKm;
      draftRideDuration = ride.duration.inSeconds;
    }
    notifyListeners();
  }

  // ── GPS Geo-Tagging & Reverse Geocoding ─────────────────────────────────
  Future<void> fetchCurrentLocation() async {
    _isLocating = true;
    notifyListeners();

    try {
      final locResult = await locationService.getCurrentLocation();
      if (locResult.isSuccess && locResult.dataOrNull != null) {
        final pt = locResult.dataOrNull!;
        draftLatitude = pt.latitude;
        draftLongitude = pt.longitude;

        // Try reverse geocoding via Nominatim
        final name = await reverseGeocode(pt.latitude, pt.longitude);
        draftLocationName = name ??
            '${pt.latitude.toStringAsFixed(4)}, ${pt.longitude.toStringAsFixed(4)}';
      } else {
        memoryError = 'Location unavailable';
      }
    } catch (e) {
      memoryError = 'Location error: $e';
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  Future<String?> reverseGeocode(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=14',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': 'RiderMate/2.0'}).timeout(
        const Duration(seconds: 4),
      );
      if (response.statusCode == 200) {
        final map = jsonDecode(response.body) as Map<String, dynamic>;
        final displayName = map['display_name'] as String?;
        if (displayName != null && displayName.isNotEmpty) {
          // Format shorter location string
          final parts = displayName.split(', ');
          if (parts.length >= 3) {
            return '${parts[0]}, ${parts[1]}, ${parts[2]}';
          }
          return displayName;
        }
      }
    } catch (_) {
      // Offline fallback: keep coordinates, return null
    }
    return null;
  }

  // ── Save Memory ──────────────────────────────────────────────────────────
  Future<bool> saveMemory(String userId) async {
    if (draftImagePath == null || draftImagePath!.isEmpty) {
      memoryError = 'Please select or capture a photo';
      notifyListeners();
      return false;
    }

    _memoryState = MemoryState.saving;
    notifyListeners();

    final now = DateTime.now();
    final memoryId = draftId ?? 'mem_${now.millisecondsSinceEpoch}';

    final memory = MemoryModel(
      id: memoryId,
      userId: userId,
      rideId: draftRideId,
      imagePath: draftImagePath!,
      thumbnailPath: null,
      caption: draftCaption.trim(),
      latitude: draftLatitude,
      longitude: draftLongitude,
      locationName: draftLocationName,
      createdAt: draftId == null ? now : (_selectedMemory?.createdAt ?? now),
      updatedAt: now,
      privacy: draftPrivacy,
      rideDistance: draftRideDistance,
      rideDuration: draftRideDuration,
    );

    final Result<MemoryModel> result;
    if (draftId != null) {
      result = await repository.updateMemory(memory);
    } else {
      result = await repository.createMemory(memory);
    }

    if (result.isSuccess) {
      await loadMemories(userId);
      _selectedMemory = result.dataOrNull;
      resetDraft();
      return true;
    } else {
      memoryError = result.errorOrNull?.message ?? 'Failed to save memory';
      _memoryState = MemoryState.error;
      notifyListeners();
      return false;
    }
  }

  // ── Delete Memory ────────────────────────────────────────────────────────
  Future<bool> deleteMemory(String id, String userId) async {
    _memoryState = MemoryState.loading;
    notifyListeners();

    final result = await repository.deleteMemory(id, userId: userId);
    if (result.isSuccess && (result.dataOrNull ?? false)) {
      _memories.removeWhere((m) => m.id == id);
      if (_selectedMemory?.id == id) _selectedMemory = null;
      _memoryState = MemoryState.loaded;
      notifyListeners();
      return true;
    } else {
      memoryError = result.errorOrNull?.message ?? 'Failed to delete memory';
      _memoryState = MemoryState.error;
      notifyListeners();
      return false;
    }
  }

  // ── Search Memories ──────────────────────────────────────────────────────
  Future<void> searchMemories(String query, String userId) async {
    if (query.trim().isEmpty) {
      await loadMemories(userId);
      return;
    }

    _memoryState = MemoryState.loading;
    notifyListeners();

    final result = await repository.searchMemories(query.trim(), userId: userId);
    if (result.isSuccess) {
      _memories = result.dataOrNull ?? [];
      _memoryState = MemoryState.loaded;
    } else {
      memoryError = result.errorOrNull?.message ?? 'Search failed';
      _memoryState = MemoryState.error;
    }
    notifyListeners();
  }

  void selectMemory(MemoryModel memory) {
    _selectedMemory = memory;
    notifyListeners();
  }
}
