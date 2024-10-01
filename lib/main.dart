import 'package:capstoneapp/firebase_options.dart';
import 'package:capstoneapp/services/auth/authservice.dart';
import 'package:capstoneapp/services/auth/loginornot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

void main()async {
    WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
 );
  runApp(
    ChangeNotifierProvider(
    create: (context) => AuthService(),
    child: const MyApp(),)
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690), 
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey, 
          title: 'Responsive App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const LoginNaba(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
