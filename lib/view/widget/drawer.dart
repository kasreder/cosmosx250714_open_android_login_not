
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../provider/user_provider.dart';
import 'loginout_widget.dart';


class BaseDrawer extends StatefulWidget {
  const BaseDrawer({
    super.key,
    // required this.drawer,
    // required this.title1,
    // required this.onItemTapped,
  });

  @override
  State<BaseDrawer> createState() => _BaseDrawerState();
}

class _BaseDrawerState extends State<BaseDrawer> {
  // final Widget drawer;
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final isLoggedIn = userProvider.username.isNotEmpty;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              // color: Colors.deepPurpleAccent,
              color: Color(0xffce93d8),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('COSMOSX',style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [

                    LoginStyle2(),
                  ],
                ),
                // GestureDetector(
                //   onTap: () {
                //     context.go('/login');
                //     Navigator.pop(context);
                //   },
                //   child: const Row(
                //     mainAxisAlignment: MainAxisAlignment.end,
                //     children: [
                //       Icon(Icons.door_front_door_outlined),
                //       SizedBox(width: 8), // 아이콘과 텍스트 사이에 여백 추가
                //       Text(
                //         'Login',
                //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                //       ),
                //     ],
                // ),),
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     Icon(Icons.door_front_door_outlined),
                //     Text('Login',style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),),
                //
                //   ],
                // ),
              ],
            ),
          ),
          ExpansionTile(
            title: const Text('새소식'),
            children: <Widget>[
              ListTile(
                  title: const Text('-  뉴스'),
                  onTap: () {
                    context.go('/nwn/news');
                    Navigator.pop(context);
                  }),
              ListTile(
                  title: const Text('-  공지'),
                  onTap: () {
                    context.go('/nwn1/notice');
                    Navigator.pop(context);
                  }),
            ],
          ),
          ExpansionTile(
            title: const Text('커뮤니티'),
            children: <Widget>[
              ListTile(
                title: const Text('-  자유게시판'),
                onTap: () {
                  context.go('/comm/free', extra: UniqueKey());
                  // Navigator.pop(context);
                }),
              ListTile(
                  title: const Text('-  기록/실험'),
                  onTap: () {
                    context.go('/comm1/record', extra: UniqueKey());
                    Navigator.pop(context);
                  }),
            ],
          ),
          ListTile(
              title: const Text('설정'),
              onTap: () {
                context.go('/set');
                Navigator.pop(context);
              }),
          ListTile(
            title: Text(isLoggedIn ? '회원정보' : 'LOGIN'),
            onTap: () {
              if (isLoggedIn) {
                context.go('/member'); // 회원정보 페이지로 이동
              } else {
                context.go('/login'); // 로그인 페이지로 이동
              }
              Navigator.pop(context); // Drawer 닫기
            },
          ),
        ],
      ),
    );
  }
}
