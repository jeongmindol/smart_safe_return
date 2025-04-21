import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_safe_return/provider/setting/backhomelog/backhomelog_provider.dart';
import 'package:smart_safe_return/provider/setting/user/user_provider.dart';
import 'package:smart_safe_return/components/setting/backhomelog/backhome_map.dart';

final currentMemberNumberProvider = Provider<int>((ref) {
  final Map<String, String?> jwt = ref.watch(jwtProvider);
  final memberNumberStr = jwt['memberNumber'];
  if (memberNumberStr == null) throw Exception('로그인 정보가 없습니다.');
  final memberNumber = int.tryParse(memberNumberStr);
  if (memberNumber == null || memberNumber == 0) {
    throw Exception('memberNumber 파싱 실패');
  }
  return memberNumber;
});

class BackHomeList extends ConsumerStatefulWidget {
  const BackHomeList({Key? key}) : super(key: key);

  @override
  ConsumerState<BackHomeList> createState() => _BackHomeListState();
}

class _BackHomeListState extends ConsumerState<BackHomeList> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    int memberNumber;
    try {
      memberNumber = ref.watch(currentMemberNumberProvider);
    } catch (e) {
      return Scaffold(
        body: Center(child: Text('❌ 사용자 정보 오류: $e')),
      );
    }

    final routeAsync = ref.watch(safeRouteListProvider(memberNumber));

    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: signatureColor,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  const Text(
                    '안전 귀가 기록',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: routeAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('경로 불러오기 실패: $err')),
                data: (routes) {
                  if (routes.isEmpty) {
                    return const Center(child: Text("🔍 안전 귀가 기록이 없습니다."));
                  }

                  return ListView.builder(
                    itemCount: routes.length,
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      final displayIndex = routes.length - index;
                      final isExpanded = expandedIndex == index;

                      return Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                expandedIndex = isExpanded ? null : index;
                              });
                            },
                            child: ListTile(
                              tileColor: Colors.white,
                              title: Text(
                                "안전귀가 $displayIndex",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                              ),
                              trailing: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BackHomeMap(
                                        routePath: route.routePath,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: signatureColor,
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text('지도', style: TextStyle(fontSize: 16)),
                              ),
                            ),
                          ),
                          if (isExpanded)
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _infoRow("출발지", route.startLocation),
                                  _infoRow("목적지", route.endLocation),
                                  _infoRow("소요 시간", route.durationInMinutes),
                                  _infoRow("도착 여부", route.successStatus),
                                  _infoRow("생성일", route.formattedDate),
                                ],
                              ),
                            ),
                          const Divider(),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
