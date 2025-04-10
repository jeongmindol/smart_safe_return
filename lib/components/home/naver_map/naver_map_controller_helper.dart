import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';

Future<NMarker> addMarker(
  BuildContext context,
  NaverMapController? controller,
  NLatLng position,
  String id,
  Color color, {
  NMarker? refMarker,
}) async {
  if (refMarker != null) {
    controller?.deleteOverlay(refMarker.info);
  }

  final marker = NMarker(
    id: id,
    position: position,
    icon: await NOverlayImage.fromWidget(
      context: context,
      widget: Icon(Icons.location_on, color: color, size: 50),
      size: const Size(50, 50),
    ),
  );

  controller?.addOverlay(marker);
  return marker;
}

String formatDuration(Duration duration) {
  final int minutes = duration.inMinutes;
  final int hours = duration.inHours;
  if (hours > 0) {
    return "$hours시간 ${minutes % 60}분";
  } else {
    return "$minutes분";
  }
}

String adjustTimeString(String original, int deltaMinutes) {
  final hourReg = RegExp(r'(\d+)\s*시간');
  final minReg = RegExp(r'(\d+)\s*분');

  final hourMatch = hourReg.firstMatch(original);
  final minMatch = minReg.firstMatch(original);

  int hours = hourMatch != null ? int.parse(hourMatch.group(1)!) : 0;
  int mins = minMatch != null ? int.parse(minMatch.group(1)!) : 0;

  int total = (hours * 60 + mins + deltaMinutes).clamp(1, 999);
  final h = total ~/ 60;
  final m = total % 60;

  return h > 0 ? "$h시간 $m분" : "$m분";
}
