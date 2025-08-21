import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:go_router/go_router.dart';

import '../../util/responsive_width.dart';
import '../widget/appbar.dart';
import '../widget/drawer.dart';



class LocalSignupPage extends StatefulWidget {
  const LocalSignupPage({super.key});

  @override
  State<LocalSignupPage> createState() => _LocalSignupPageState();
}

class _LocalSignupPageState extends State<LocalSignupPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _profileImageUrlController = TextEditingController();

  void _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      String username = _usernameController.text;
      String email = _emailController.text;
      String nickname = _nicknameController.text;
      String password = _passwordController.text;
      String profileImageUrl = _profileImageUrlController.text;

      const String url = "https://api.cosmosx.co.kr/api/auth/signup"; // 서버의 API 엔드포인트
      final response = await Dio().post(
        url,
        options: Options(
          headers: {
            'Content-Type': 'application/json; charset=UTF-8',
          },
        ),
        data: {
          'username': username,
          'email': email,
          'nickname': nickname,
          'password': password,
          'roles': ["user"],
          'provider' : 'local'
        },
      );

      if (response.statusCode == 200) {
        // 회원가입 성공
        print('Signup successful');
        if (kIsWeb) {
          context.go('/login', extra: UniqueKey());
        } else {
          context.go('/member',extra: UniqueKey());
        }
      } else {
        // 회원가입 실패
        print('Signup failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BaseAppBar(
        title: "가입페이지",
        appBar: AppBar(),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: ResponsiveWidth.getResponsiveWidth(context),
            child: Column(
              children: [
                const Text(
                  'Welcome 환영합니다',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                Image.network(
                  'https://p1.pxfuel.com/preview/297/88/840/space-shuttle-space-sci-fi-science-fiction.jpg',
                  width: 500,
                  height: 250,
                  fit: BoxFit.fill,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _nicknameController,
                        decoration: const InputDecoration(labelText: 'Nickname'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your nickname';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'Password'),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      // TextFormField(
                      //   controller: _profileImageUrlController,
                      //   decoration: const InputDecoration(labelText: 'Profile Image URL'),
                      //   validator: (value) {
                      //     if (value == null || value.isEmpty) {
                      //       return 'Please enter a valid image URL';
                      //     }
                      //     return null;
                      //   },
                      //   onChanged: (value) {
                      //     setState(() {});
                      //   },
                      // ),
                      // const SizedBox(height: 16),
                      // _profileImageUrlController.text.isNotEmpty
                      //     ? Image.network(
                      //   _profileImageUrlController.text,
                      //   height: 100,
                      //   width: 100,
                      //   errorBuilder: (context, error, stackTrace) {
                      //     return const Text('Invalid image URL');
                      //   },
                      // )
                      //     : Container(),
                      // const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _handleSignup,
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      drawer: const BaseDrawer(),
    );
  }
}
