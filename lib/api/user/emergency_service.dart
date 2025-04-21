import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:smart_safe_return/utils/CustomHttpClient.dart';

/// ✅ SOS 메시지 모델
class SosMessage {
  final dynamic id;
  final dynamic content;
  final DateTime createDate;

  SosMessage({
    required this.id,
    required this.content,
    required this.createDate,
  });

  factory SosMessage.fromJson(Map<String, dynamic> json) {
    return SosMessage(
      id: json['sos_message_id'],
      content: json['content'],
      createDate: DateTime.parse(json['created_date']), // ✅ 키 이름 수정
    );
  }
}

/// ✅ 비상 연락처 모델
class EmergencyContact {
  final dynamic id;
  final dynamic name;
  final dynamic phone;
  final DateTime createDate;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    required this.createDate,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['emergency_contact_id'],
      name: json['name'],
      phone: json['phone'],
      createDate: DateTime.parse(json['created_date']),
    );
  }
}

/// ✅ SOS 메시지 가져오기
Future<SosMessage?> fetchSosMessage() async {
  final prefs = await SharedPreferences.getInstance();
  final memberNumber = prefs.getString('memberNumber');
  if (memberNumber == null) return null;

  final client = CustomHttpClient();
  final url = Uri.parse(
      '${dotenv.env['API_BASE_URL']}/api/sos-message/member/$memberNumber');

  try {
    final request = http.Request('GET', url);
    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final jsonData = json.decode(utf8.decode(response.bodyBytes));
      print('📦 받아온 SOS 메시지 데이터: $jsonData');
      return SosMessage.fromJson(jsonData);
    } else {
      print('❌ SOS 메시지 가져오기 실패: ${response.statusCode}');
      print('Body: ${response.body}');
      return null;
    }
  } catch (e) {
    print('🚨 SOS 메시지 요청 중 에러 발생: $e');
    return null;
  }
}

/// ✅ 비상 연락처 가져오기
Future<List<EmergencyContact>> fetchEmergencyContact() async {
  final prefs = await SharedPreferences.getInstance();
  final memberNumber = prefs.getString('memberNumber');
  if (memberNumber == null) return [];

  final client = CustomHttpClient();
  final url = Uri.parse(
      '${dotenv.env['API_BASE_URL']}/api/emergency-contact/member/$memberNumber');

  try {
    final request = http.Request('GET', url);
    final streamedResponse = await client.send(request);
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final List<dynamic> jsonData =
          json.decode(utf8.decode(response.bodyBytes));
      print('📦 받아온 비상 연락처 데이터: $jsonData');
      return jsonData.map((e) => EmergencyContact.fromJson(e)).toList();
    } else {
      print('❌ 비상 연락처 가져오기 실패: ${response.statusCode}');
      print('Body: ${response.body}');
      return [];
    }
  } catch (e) {
    print('🚨 비상 연락처 요청 중 에러 발생: $e');
    return [];
  }
}
