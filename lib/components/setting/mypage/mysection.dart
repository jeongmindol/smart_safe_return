import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/components/setting/profile/myprofile.dart';
import 'package:smart_safe_return/components/setting/safeguard/mysafeguard.dart';
import 'package:smart_safe_return/components/setting/sossms/mysossms.dart';
import 'package:smart_safe_return/components/setting/backhomelog/backhome_list.dart';
import 'package:smart_safe_return/components/setting/inquiry/inquiry.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:smart_safe_return/provider/popup_box/popup_box.dart';

class MySection extends ConsumerWidget {
  const MySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMenuItem(context, ref, Icons.person, '내 정보 수정', const MyProfile()),
          _buildDivider(),
          _buildMenuItem(context, ref, Icons.contact_phone, '긴급 연락처 설정', const MySafeguard()),
          _buildDivider(),
          _buildMenuItem(context, ref, Icons.sms, 'SOS 메시지 내용 설정', const MySosSms()),
          _buildDivider(),
          _buildMenuItem(context, ref, Icons.map, '귀가 기록 보기', const BackHomeList()),
          _buildDivider(),
          _buildMenuItem(context, ref, Icons.help_outline, '문의하기', const Inquiry()),
          _buildDivider(),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context,
    WidgetRef ref,
    IconData icon,
    String label,
    Widget page,
  ) {
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

    final jwt = ref.watch(jwtProvider);
    final isLoggedIn = jwt['id'] != null && jwt['id'].toString().trim().isNotEmpty;

    return SizedBox(
      height: 85,
      child: ListTile(
        leading: Icon(icon, color: iconColor, size: 30),
        title: Text(label, style: const TextStyle(fontSize: 17)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          if (isLoggedIn) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          } else {
            showLoginRequiredPopup(context);
          }
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
