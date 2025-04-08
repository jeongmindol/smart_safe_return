import 'package:flutter/material.dart';

class IdPwSearchTab extends StatefulWidget {
  const IdPwSearchTab({super.key});

  @override
  State<IdPwSearchTab> createState() => _IdPwSearchTabState();
}

class _IdPwSearchTabState extends State<IdPwSearchTab>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 아이디 찾기용
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  // 비밀번호 찾기용
  final idController = TextEditingController();
  final pwNameController = TextEditingController();
  final pwPhoneController = TextEditingController();

  String idMethod = '휴대전화';
  String pwMethod = '휴대전화';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('아이디 / 비밀번호 찾기'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black,
          tabs: const [
            Tab(text: '아이디 찾기'),
            Tab(text: '비밀번호 찾기'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 🔹 아이디 찾기 탭
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<String>(
                    title: const Text("휴대전화"),
                    value: "휴대전화",
                    groupValue: idMethod,
                    onChanged: (value) {
                      setState(() {
                        idMethod = value!;
                      });
                    },
                  ),
                  if (idMethod == "휴대전화") ...[
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: '이름',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              hintText: '휴대전화 (-없이)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            print('아이디 인증 요청: ${phoneController.text}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: signatureColor,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("인증 요청"),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 30), // 여기 수정!
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        print('아이디 찾기 버튼 눌림');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.grey,
                      ),
                      child: const Text("아이디 찾기"),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔸 비밀번호 찾기 탭
          Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<String>(
                    title: const Text("휴대전화"),
                    value: "휴대전화",
                    groupValue: pwMethod,
                    onChanged: (value) {
                      setState(() {
                        pwMethod = value!;
                      });
                    },
                  ),
                  if (pwMethod == "휴대전화") ...[
                    TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        hintText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: pwNameController,
                      decoration: const InputDecoration(
                        hintText: '이름',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: pwPhoneController,
                            decoration: const InputDecoration(
                              hintText: '휴대전화 (-없이)',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            print('비밀번호 인증 요청: ${pwPhoneController.text}');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: signatureColor,
                            foregroundColor: Colors.black,
                          ),
                          child: const Text("인증 요청"),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 30), // 여기도 수정!
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        print('비밀번호 찾기 버튼 눌림');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade300,
                        foregroundColor: Colors.grey,
                      ),
                      child: const Text("비밀번호 찾기"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
