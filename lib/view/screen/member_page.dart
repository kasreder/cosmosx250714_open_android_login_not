import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../provider/user_provider.dart';
import '../../util/responsive_width.dart';
import '../widget/appbar.dart';
import '../widget/drawer.dart';

class MemberPage extends StatefulWidget {
  const MemberPage({super.key});

  @override
  State<MemberPage> createState() => _MemberPageState();
}

class _MemberPageState extends State<MemberPage> {
  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        return Scaffold(
          appBar: BaseAppBar(title: "멤버정보 페이지", appBar: AppBar()),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(width: ResponsiveWidth_Info.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.1)),
                SizedBox(width: ResponsiveWidth_Info.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 20, 0, 20),
                  child: Column(
                    children: [
                      SelectableText('이름: ${userProvider.username}', style: const TextStyle(fontSize: 20)),
                      SelectableText('닉네임: ${userProvider.nickname}', style: const TextStyle(fontSize: 20)),
                      SelectableText('이메일: ${userProvider.email}', style: const TextStyle(fontSize: 20)),
                      SelectableText('등급: ${userProvider.grade}', style: const TextStyle(fontSize: 20)),
                      SelectableText('포인트: ${userProvider.points}', style: const TextStyle(fontSize: 20)),
                      SelectableText('가입경로: ${userProvider.provider}', style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    userProvider.clearUser();
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      context.go('/login', extra: UniqueKey());
                    });
                  },
                  child: const Text('로그아웃'),
                ),
                SizedBox(width: ResponsiveWidth_Info.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.3)),
                SizedBox(width: ResponsiveWidth_Info.getResponsiveWidth(context), child: const Divider(color: Colors.black54, thickness: 0.1)),
              ],
            ),
          ),
          drawer: const BaseDrawer(),
        );
      },
    );
  }

// @override
  // Widget build(BuildContext context) {
  //   final userProvider = Provider.of<UserProvider>(context);
  //   final username = userProvider.username;
  //   final nickname = userProvider.nickname;
  //   final email = userProvider.email;
  //   final grade = userProvider.grade;
  //   // final grade = userProvider.grade;
  //   final points = userProvider.points;
  //   final provider = userProvider.provider;
  //
  //   return Scaffold(
  //     appBar: BaseAppBar(
  //       title: "멤버정보 페이지",
  //       appBar: AppBar(),
  //     ),
  //     body: Center(
  //       child: Column(
  //         mainAxisSize: MainAxisSize.min,
  //         children: <Widget>[
  //
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               '이름: $username',
  //               style: const TextStyle(fontSize: 20),
  //             ),
  //           ),
  //           // SizedBox(height: 10),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               '닉네임: $nickname',
  //               style: const TextStyle(fontSize: 20),
  //             ),
  //           ),
  //           // SizedBox(height: 10),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               'Email: $email',
  //               style: const TextStyle(fontSize: 20),
  //             ),
  //           ),
  //           // SizedBox(height: 10),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               '직업: $grade',
  //               style: const TextStyle(fontSize: 20),
  //             ),
  //           ),
  //           // Padding(
  //           //   padding: const EdgeInsets.all(8.0),
  //           //   child: Text(
  //           //     '등급: $grade',
  //           //     style: const TextStyle(fontSize: 20),
  //           //   ),
  //           // ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               '포인트: $points',
  //               style: const TextStyle(fontSize: 20),
  //             ),
  //           ),
  //           Padding(
  //             padding: const EdgeInsets.all(8.0),
  //             child: Text(
  //               '가입경로: $provider',
  //               style: const TextStyle(fontSize: 20),
  //             ),
  //           ),
  //           // SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: () {
  //               userProvider.clearUser();
  //               WidgetsBinding.instance.addPostFrameCallback((_) {
  //                 context.go('/login');
  //               });
  //             },
  //             child: const Text('로그아웃'),
  //           ),
  //         ],
  //       ),
  //     ),
  //     drawer: const BaseDrawer(),
  //   );
  // }
}
