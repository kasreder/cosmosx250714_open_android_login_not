import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NaviFloatingAction extends StatelessWidget {
  const NaviFloatingAction({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 40.0,
      height: 40.0,
      child: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: const Column(
                  mainAxisSize: MainAxisSize.min, // Dialog 크기를 내용에 맞게 조절
                  crossAxisAlignment: CrossAxisAlignment.center, // 가로로 중간 정렬
                  children: [
                    Text(
                      '글 작성하실 건가요? 좋아요!',
                      textAlign: TextAlign.center, // 텍스트를 중앙 정렬
                      style: TextStyle(fontSize: 18), // 텍스트 크기 조정
                    ),
                  ],
                ),
                actions: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '아니요',
                          style: TextStyle(fontSize: 15),
                        ),
                      ),
                      const SizedBox(width: 25), // 버튼 간격
                      ElevatedButton(
                        onPressed: () {
                          final currentUrl = Uri.base.toString();
                          final segments = currentUrl.split('/'); // URL을 '/' 기준으로 분리
                          final lastParamValue = currentUrl.split('/').last; // URL의 마지막 파라미터 가져오기
                          String? lastParam;

                          // 마지막 파라미터가 숫자인 경우, 바로 이전 경로와 함께 저장
                          if (int.tryParse(lastParamValue) != null && segments.length >= 2) {
                            lastParam = segments[segments.length - 2];
                          } else {
                            // 숫자가 아니면 그냥 마지막 파라미터 저장
                            lastParam = lastParamValue;
                          }

                          context.go('/PostWrite', extra: {'lastParam': lastParam});
                          print('제작페이지로 넘겨주는 값: $lastParam');
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          '네, 할 거에요',
                          // '네',
                          style: TextStyle(fontSize: 15),
                        ),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     final currentUrl = Uri.base.toString();
                      //     final segments = currentUrl.split('/'); // URL을 '/' 기준으로 분리
                      //     final lastParamValue = currentUrl.split('/').last; // URL의 마지막 파라미터 가져오기
                      //     String? lastParam;
                      //
                      //     // 마지막 파라미터가 숫자인 경우, 바로 이전 경로와 함께 저장
                      //     if (int.tryParse(lastParamValue) != null && segments.length >= 2) {
                      //       lastParam = segments[segments.length - 2];
                      //     } else {
                      //       // 숫자가 아니면 그냥 마지막 파라미터 저장
                      //       lastParam = lastParamValue;
                      //     }
                      //
                      //     context.go('/PostWriteScreen2', extra: {'lastParam': lastParam});
                      //     print('제작페이지로 넘겨주는 값: $lastParam');
                      //     Navigator.of(context).pop();
                      //   },
                      //   child: const Text(
                      //     '네2',
                      //     style: TextStyle(fontSize: 15),
                      //   ),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     final currentUrl = Uri.base.toString();
                      //     final segments = currentUrl.split('/'); // URL을 '/' 기준으로 분리
                      //     final lastParamValue = currentUrl.split('/').last; // URL의 마지막 파라미터 가져오기
                      //     String? lastParam;
                      //
                      //     // 마지막 파라미터가 숫자인 경우, 바로 이전 경로와 함께 저장
                      //     if (int.tryParse(lastParamValue) != null && segments.length >= 2) {
                      //       lastParam = segments[segments.length - 2];
                      //     } else {
                      //       // 숫자가 아니면 그냥 마지막 파라미터 저장
                      //       lastParam = lastParamValue;
                      //     }
                      //
                      //     context.go('/PostWriteScreen3', extra: {'lastParam': lastParam});
                      //     print('제작페이지로 넘겨주는 값: $lastParam');
                      //     Navigator.of(context).pop();
                      //   },
                      //   child: const Text(
                      //     '네3',
                      //     style: TextStyle(fontSize: 15),
                      //   ),
                      // ),
                      // ElevatedButton(
                      //   onPressed: () {
                      //     final currentUrl = Uri.base.toString();
                      //     final segments = currentUrl.split('/'); // URL을 '/' 기준으로 분리
                      //     final lastParamValue = currentUrl.split('/').last; // URL의 마지막 파라미터 가져오기
                      //     String? lastParam;
                      //
                      //     // 마지막 파라미터가 숫자인 경우, 바로 이전 경로와 함께 저장
                      //     if (int.tryParse(lastParamValue) != null && segments.length >= 2) {
                      //       lastParam = segments[segments.length - 2];
                      //     } else {
                      //       // 숫자가 아니면 그냥 마지막 파라미터 저장
                      //       lastParam = lastParamValue;
                      //     }
                      //
                      //     context.go('/PostWriteScreen4', extra: {'lastParam': lastParam});
                      //     print('제작페이지로 넘겨주는 값: $lastParam');
                      //     Navigator.of(context).pop();
                      //   },
                      //   child: const Text(
                      //     '네4',
                      //     style: TextStyle(fontSize: 15),
                      //   ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.border_color),
      ),
    );
  }
}
