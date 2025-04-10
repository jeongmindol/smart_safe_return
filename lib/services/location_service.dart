import 'package:location/location.dart'; // 위치 관련 기능

class LocationService {
  static Future<LocationData?> getCurrentLocation() async {
    Location location = Location();

    // 위치 서비스가 활성화되어 있는지 확인
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // 위치 서비스가 비활성화되어 있으면 사용자에게 활성화를 요청
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null; // 위치 서비스 활성화가 거부되면 null 반환
      }
    }

    // 위치 데이터를 가져와 반환
    return await location.getLocation();
  }
}
