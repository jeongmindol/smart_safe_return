import 'package:permission_handler/permission_handler.dart'; // permission_handler만 사용

class PermissionService {
  static Future<bool> requestLocationPermission() async {
    // permission_handler를 사용하여 위치 권한 확인
    PermissionStatus status = await Permission.location.status;

    // 권한이 거부된 경우
    if (status == PermissionStatus.denied ||
        status == PermissionStatus.permanentlyDenied) {
      // 권한을 요청
      status = await Permission.location.request();

      if (status == PermissionStatus.granted) {
        return true; // 권한이 부여되었으면 true 반환
      } else if (status == PermissionStatus.denied) {
        return false; // 권한 요청이 거부되었으면 false 반환
      }
    }

    return true; // 권한이 부여되었으면 true 반환
  }
}
