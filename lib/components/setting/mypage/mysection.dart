import 'package:flutter/material.dart';
import 'package:smart_safe_return/components/setting/profile/myprofile.dart';
import 'package:smart_safe_return/components/setting/safeguard/mysafeguard.dart';
import 'package:smart_safe_return/components/setting/sossms/mysossms.dart';
import 'package:smart_safe_return/components/setting/backhomelog/backhome_list.dart';
import 'package:smart_safe_return/components/setting/inquiry/inquiry.dart';

class MySection extends StatelessWidget {
  const MySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // SingleChildScrollView로 감싸서 스크롤 가능하게 변경
      child: Column(
        children: [
          _buildMenuItem(context, Icons.person, '내 정보 수정', const MyProfile()),
          _buildDivider(),
          _buildMenuItem(
              context, Icons.contact_phone, '긴급 연락처 설정', const MySafeguard()),
          _buildDivider(),
          _buildMenuItem(
            context,
            Icons.sms,
            'SOS 메시지 내용 설정',
            const MySosSms(),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            Icons.map,
            '귀가 기록 보기',
            const BackHomeList(),
          ),
          _buildDivider(),
          _buildMenuItem(
            context,
            Icons.help_outline,
            '문의하기',
            const Inquiry(),
          ),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      BuildContext context, IconData icon, String label, Widget page) {
    Color iconColor;
    switch (icon) {
      case Icons.person:
        iconColor = Colors.blueAccent;
        break;
      case Icons.contact_phone:
        iconColor = Colors.green;
        break;
      case Icons.sms:
        iconColor = Colors.orange;
        break;
      case Icons.map:
        iconColor = Colors.purple;
        break;
      case Icons.help_outline:
        iconColor = Colors.indigo;
        break;
      default:
        iconColor = Colors.grey;
    }

    return SizedBox(
      height: 85,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(label, style: const TextStyle(fontSize: 17)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFE0E0E0),
      indent: 12,
      endIndent: 12,
    );
  }
}
