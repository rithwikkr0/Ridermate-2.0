import '../../../providers/base_controller.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

/// RiderMate 2.0 — Weather Controller
class WeatherController extends BaseController {
  final WeatherService weatherService;
  WeatherModel weather = WeatherModel.mock();

  WeatherController(this.weatherService) {
    refreshWeather();
  }

  Future<void> refreshWeather({double latitude = 19.0760, double longitude = 72.8777}) async {
    setState(ViewState.loading);
    final res = await weatherService.getCurrentWeather(latitude: latitude, longitude: longitude);
    if (res.isSuccess) {
      weather = res.dataOrNull ?? WeatherModel.mock();
      setState(ViewState.success);
    } else {
      weather = WeatherModel.mock();
      setState(ViewState.error, error: res.errorOrNull);
    }
  }
}
