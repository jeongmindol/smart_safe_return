import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter/foundation.dart';
import 'package:proj4dart/proj4dart.dart' as proj4;

class TmapService {
  static String get apiKey => dotenv.env["TMAP_API_KEY"] ?? "";

  static final proj4.Projection _epsg3857 = proj4.Projection.get('EPSG:3857')!;
  static final proj4.Projection _wgs84 = proj4.Projection.get('EPSG:4326')!;

  // 라디안 → 도(degree) 변환 함수
  static double _radToDeg(double rad) => rad * 180 / 3.141592653589793;

  // EPSG:3857 → WGS84 변환 (도 단위)
  static NLatLng _convertEPSG3857ToWGS84(double x, double y) {
    final point = proj4.Point(x: x, y: y);
    final projected = _epsg3857.inverse(point);
    final latDeg = _radToDeg(projected.y);
    final lonDeg = _radToDeg(projected.x);
    return NLatLng(latDeg, lonDeg); // (위도, 경도)
  }

  /// 좌표 → 주소 변환
  static Future<String?> getAddressFromLatLng(NLatLng latLng) async {
    if (apiKey.isEmpty) {
      throw Exception("🚨 T맵 API Key가 설정되지 않았습니다.");
    }

    final String url = "https://apis.openapi.sk.com/tmap/geo/reversegeocoding"
        "?version=1&format=json&appKey=$apiKey"
        "&lat=${Uri.encodeComponent(latLng.latitude.toString())}"
        "&lon=${Uri.encodeComponent(latLng.longitude.toString())}"
        "&coordType=WGS84GEO";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['addressInfo'] != null) {
          return data['addressInfo']['fullAddress'];
        } else {
          debugPrint("⚠️ 주소 데이터가 존재하지 않음: ${response.body}");
        }
      } else {
        debugPrint("🚨 좌표-주소 변환 API 호출 실패: HTTP status ${response.statusCode}");
        // debugPrint("응답 데이터: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 API 요청 중 예외 발생: $e");
    }

    return null;
  }

  /// 보행자 경로 가져오기
  static Future<List<NLatLng>?> getWalkingRoute(
      double startLat, double startLng, double endLat, double endLng) async {
    if (apiKey.isEmpty) {
      throw Exception("🚨 T맵 API Key가 설정되지 않았습니다.");
    }

    debugPrint("📡 API 요청 시작 - 보행자 길찾기");
    final url = Uri.parse(
        "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1");

    try {
      final body = jsonEncode({
        "startX": startLng.toString(),
        "startY": startLat.toString(),
        "endX": endLng.toString(),
        "endY": endLat.toString(),
        "reqCoordType": "WGS84GEO",
        "resCoordType": "EPSG3857",
        "startName": "출발지",
        "endName": "도착지"
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "appKey": apiKey,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is! Map<String, dynamic> || data["features"] is! List) {
          debugPrint("⚠️ API 응답 데이터 형식 오류: ${response.body}");
          return null;
        }

        List<NLatLng> routePoints = [];
        for (var feature in data["features"]) {
          if (feature is! Map<String, dynamic>) continue;

          var geometry = feature["geometry"];
          if (geometry is Map<String, dynamic> &&
              geometry["type"] == "LineString") {
            var coordinates = geometry["coordinates"];
            if (coordinates is List) {
              for (var coord in coordinates) {
                if (coord is List && coord.length >= 2) {
                  double x = coord[0].toDouble(); // EPSG3857 X
                  double y = coord[1].toDouble(); // EPSG3857 Y
                  final latLng = _convertEPSG3857ToWGS84(x, y);
                  routePoints.add(latLng);
                }
              }
            }
          }
        }

        // debugPrint("✅ 변환된 경로 포인트 개수: ${routePoints.length}");
        return routePoints;
      } else {
        debugPrint("🚨 Tmap 보행자 길찾기 API 호출 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 길찾기 API 요청 중 예외 발생: $e");
    }

    return null;
  }

  /// 예상 도착 시간 (초 단위) 가져오기
  static Future<int?> getEstimatedTime(
      double startLat, double startLng, double endLat, double endLng) async {
    if (apiKey.isEmpty) {
      throw Exception("🚨 T맵 API Key가 설정되지 않았습니다.");
    }

    final url = Uri.parse(
        "https://apis.openapi.sk.com/tmap/routes/pedestrian?version=1");

    try {
      final body = jsonEncode({
        "startX": startLng.toString(),
        "startY": startLat.toString(),
        "endX": endLng.toString(),
        "endY": endLat.toString(),
        "reqCoordType": "WGS84GEO",
        "resCoordType": "EPSG3857",
        "startName": "출발지",
        "endName": "도착지"
      });

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "appKey": apiKey,
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["features"] is List && data["features"].isNotEmpty) {
          final properties = data["features"][0]["properties"];
          if (properties != null && properties["totalTime"] != null) {
            return properties["totalTime"]; // 단위: 초
          }
        }
      } else {
        debugPrint("🚨 예상 시간 API 호출 실패: ${response.body}");
      }
    } catch (e) {
      debugPrint("🔥 예상 시간 요청 중 예외 발생: $e");
    }

    return null;
  }
}
