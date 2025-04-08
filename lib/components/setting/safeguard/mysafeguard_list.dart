import 'package:flutter/material.dart';

class MySafeguardList extends StatefulWidget {
  final List<Map<String, String>> guardians;

  const MySafeguardList({super.key, required this.guardians});

  @override
  State<MySafeguardList> createState() => _MySafeguardListState();
}

class _MySafeguardListState extends State<MySafeguardList> {
  int? expandedIndex;

  // 💙 signatureColor 정의
  final Color signatureColor = const Color.fromARGB(255, 102, 247, 255);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.guardians.length,
      itemBuilder: (context, index) {
        final guardian = widget.guardians[index];
        final isExpanded = expandedIndex == index;

        return Column(
          children: [
            InkWell(
              onTap: () {
                setState(() {
                  expandedIndex = isExpanded ? null : index;
                });
              },
              child: Container(
                height: 90,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        guardian['name']!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print("선택됨: ${guardian['name']}");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: signatureColor,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: const Text('선택'),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: isExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(
                          top: 12.0, left: 60.0, right: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            guardian['phone']!,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () {
                              print("수정 클릭: ${guardian['name']}");
                            },
                            child: const Text(
                              '수정',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        );
      },
    );
  }
}
