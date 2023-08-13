import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'game.dart';
import 'login.dart';
import 'registration.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    AudioPlayer loop_music_background = AudioPlayer();
    loop_music_background
        .setSource(AssetSource('music/loop_music_background.ogg'))
        .then((value) {
      loop_music_background
          .play(AssetSource('music/loop_music_background.ogg'));
      loop_music_background.setReleaseMode(ReleaseMode.loop);
    });

    return MaterialApp(
      title: '2048',
      initialRoute: '/',
      routes: {
        '/': (context) {
          if (_auth.currentUser != null) {
            return GameWidget(arguments: {
              'userEmail': _auth.currentUser!.email ?? '',
            });
          } else {
            return const LoginPage();
          }
        },
        '/registration': (context) => const RegistrationPage(),
        '/game': (context) => GameWidget(
            arguments: ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>),
      },
    );
  }
}
