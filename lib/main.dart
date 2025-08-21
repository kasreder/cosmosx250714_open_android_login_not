import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as quill;
import 'package:provider/provider.dart';
import 'package:kakao_flutter_sdk/kakao_flutter_sdk.dart';
import 'package:url_strategy/url_strategy.dart';
import 'provider/noticeModel.dart';
import 'provider/post_provider.dart';
import 'provider/user_provider.dart';
import 'provider/list_provider.dart';
import 'routes/app_router.dart';
import 'package:flutter_quill/flutter_quill.dart';

void main() async {
  // turn off the # in the URLs on the web111
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
      nativeAppKey: 'ddcbf01fdd26bb7b767ca2a47a1dffac',
      javaScriptAppKey: '38ecd3c1f415e1f7850b443e0a6b59e5',
  );
  // usePathUrlStrategy();
  // print('userProvider = UserProvider();');
  // final userProvider = UserProvider();
  // print('userProvider = UserProvider()끝');dsd
  // debugPaintSizeEnabled = true;


  setPathUrlStrategy();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => NoticeProvider()),
        ChangeNotifierProvider(create: (context) => ItemIndexProvider()),
        ChangeNotifierProvider(create: (context) => ViewCountProvider()),
        ChangeNotifierProvider(create: (context) => UserProvider()),
        ChangeNotifierProvider(create: (context) => QuillEditorController()),

      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      localizationsDelegates: FlutterQuillLocalizations.localizationsDelegates,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch:
        // Colors.red,
        ColorService.createMaterialColor(const Color(0xffD8BFD8)),
        fontFamily: "Nanum",
        // fontFamily: "Blackader ITC",
        // fontFamily: "Arial Rounded MT Bold",
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 15),
          bodyMedium: TextStyle(color: Colors.black, fontSize: 20),
          bodySmall: TextStyle(color: Colors.black, fontSize: 10),
          //title 본문
          titleLarge: TextStyle(
            color: Colors.black,
            fontSize: 16,
          ),
          titleMedium: TextStyle(
            color: Colors.black,
            fontSize: 13,
          ),
          titleSmall: TextStyle(
            color: Colors.black,
            fontSize: 10,
          ),
          //label 메뉴
          labelLarge: TextStyle(
              color: Colors.green, fontSize: 27, fontWeight: FontWeight.w500),
          labelMedium: TextStyle(
              color: Colors.green, fontSize: 22, fontWeight: FontWeight.w500),
          labelSmall: TextStyle(
              color: Colors.green, fontSize: 17, fontWeight: FontWeight.w500),
          headlineLarge: TextStyle(
              color: Colors.blue, fontSize: 40, fontWeight: FontWeight.w500),
          headlineMedium: TextStyle(
              color: Colors.blue, fontSize: 30, fontWeight: FontWeight.w500),
          headlineSmall: TextStyle(
              color: Colors.blue, fontSize: 20, fontWeight: FontWeight.w500),
          displayLarge: TextStyle(
              color: Colors.black, fontSize: 40, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(
              color: Colors.black, fontSize: 25, fontWeight: FontWeight.w700),
          displaySmall: TextStyle(
              color: Colors.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class ColorService {
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
class QuillEditorController with ChangeNotifier {
  final quill.QuillController controller = quill.QuillController.basic();
}
///Thema.of
///1.notosans
///2.에스코어드림
///3.AND가지런한 (유료 ㅜㅜ)
///4.휘갈귀는 폰트(장문X)
///5.길쭉동글 스웨거(영어가능) 두께조절 안됨
///6.옴니고딕 (1:1비율)
///
///      테마 재정의
///     theme: ThemeData(
///     	...
///         textTheme: const TextTheme(
///             headline3: TextStyle(
///                 fontSize: 20,
///                 fontWeight: FontWeight.w500,
///                 fontStyle: FontStyle.italic))),}
///
///    기존 형식은 그대로 copywith만 적용
///Text(
///   "헤드라인3이 적용된 텍스트입니다.",
///   style: Theme.of(context)
///       .textTheme
///       .headline3!
///       .copyWith(color: Theme.of(context).colorScheme.primary),
/// )
///
///  일반사용법
/// Text("헤드라인3이 적용된 텍스트입니다.",
///      style: Theme.of(context).textTheme.headline3,),
///
///  Theme.of(context).copyWith(accentColor: Colors.yellow)
///
///  Text(style: Theme.of(context).textTheme.title,),
/// 배달의민족 을지로체, 삼립호빵체
///
///  Lavender Science Palette
// (라벤더 색상을 중심으로, 블록체인·실험·과학·우주 느낌을 살린 색상 패밀리)
//
// 기본색 (Base): 🌸 라벤더 #D8BFD8
//
// 전체적인 부드러움과 신비로운 분위기 유지.
// 딥 셰이드 (Deep Shade): 🔮 미드나잇 퍼플 #8A2BE2
//
// 기본 라벤더에서 조금 더 딥하고 미래적인 느낌.
// 라이트 셰이드 (Light Shade): 🌫️ 소프트 라벤더 미스트 #E6D5EA
//
// 더 밝고 깨끗한 느낌으로 배경색으로 적합.
// 보색 포인트 (Contrasting Accent): 💙 코발트 블루 #4C6EF5
//
// 과학과 블록체인의 기술적 느낌을 강조할 수 있는 포인트 컬러.
// 뉴트럴 (Neutral): 🌑 차콜 그레이 #2E2E3A
//
// 가독성을 위한 텍스트 및 UI 요소로 활용할 수 있는 색상.