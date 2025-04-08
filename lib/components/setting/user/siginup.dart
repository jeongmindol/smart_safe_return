// lib/components/setting/user/signup.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smart_safe_return/components/setting/user/user.dart';
import 'package:smart_safe_return/provider/setting/user/signup_provider.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _handleSignup() async {
    final id = idController.text.trim();
    final pw = passwordController.text.trim();
    final phone = phoneController.text.trim();

    if (id.isEmpty || pw.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('모든 필드를 입력해주세요')),
      );
      return;
    }

    final success = await signupUser(
      id: id,
      password: pw,
      phone: phone,
      imageFile: _selectedImage,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const UserPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('회원가입에 실패했습니다')),
      );
    }
  }

  Future<void> _checkId() async {
    final id = idController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디를 입력해주세요')),
      );
      return;
    }
    final isAvailable = await checkIdDuplicate(id);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAvailable ? '✅ 사용 가능한 아이디입니다' : '❌ 이미 사용 중인 아이디입니다'),
      ),
    );
  }

  Future<void> _checkPhone() async {
    final phone = phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('연락처를 입력해주세요')),
      );
      return;
    }
    final isAvailable = await checkPhoneDuplicate(phone);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isAvailable ? '✅ 사용 가능한 연락처입니다' : '❌ 이미 등록된 연락처입니다'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const signatureColor = Color.fromARGB(255, 102, 247, 255);

    return Scaffold(
      appBar: AppBar(title: const Text('회원가입'), centerTitle: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: idController,
                      decoration: const InputDecoration(
                        labelText: '아이디',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _checkId,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signatureColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('중복확인'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: '연락처(-없이 입력)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _checkPhone,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: signatureColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('중복확인'),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: '비밀번호',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              const Text('프로필 이미지', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: _selectedImage == null
                      ? const Text('이미지를 선택하세요')
                      : Image.file(_selectedImage!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 50,
                child: ElevatedButton(
                  onPressed: _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: signatureColor,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('등록', style: TextStyle(fontSize: 18)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
