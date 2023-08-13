import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  String _errorMessage = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = _auth.currentUser;
      if (user != null) {
        setState(() {
          _userEmail = user.email ?? '';
        });
      }
      AudioPlayer button_01 = AudioPlayer();
      button_01.setSource(AssetSource('music/button_01.ogg')).then((value) {
        button_01.play(AssetSource('music/button_01.ogg'));
      });
      Navigator.pushReplacementNamed(context, '/game', arguments: {
        'userEmail': _userEmail,
      });
    } catch (e) {
      setState(() {
        AudioPlayer button_02 = AudioPlayer();
        button_02.setSource(AssetSource('music/button_02.ogg')).then((value) {
          button_02.play(AssetSource('music/button_02.ogg'));
        });
        _errorMessage = 'Đăng nhập không thành công.';
      });
    }
  }

  Future<void> _loginWithGoogle() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();

      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);

        User? user = _auth.currentUser;
        if (user != null) {
          final email = user.email ?? '';

          // Kiểm tra tài khoản trong Firestore
          final isAccountExists = await _isAccountExists(email);

          if (isAccountExists) {
            AudioPlayer button_01 = AudioPlayer();
            button_01
                .setSource(AssetSource('music/button_01.ogg'))
                .then((value) {
              button_01.play(AssetSource('music/button_01.ogg'));
            });
            Navigator.pushReplacementNamed(context, '/game', arguments: {
              'userEmail': email,
            });
          } else {
            setState(() {
              AudioPlayer button_02 = AudioPlayer();
              button_02
                  .setSource(AssetSource('music/button_02.ogg'))
                  .then((value) {
                button_02.play(AssetSource('music/button_02.ogg'));
              });
              _errorMessage = 'Tài khoản không tồn tại.';
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        AudioPlayer button_02 = AudioPlayer();
        button_02.setSource(AssetSource('music/button_02.ogg')).then((value) {
          button_02.play(AssetSource('music/button_02.ogg'));
        });
        _errorMessage = 'Đăng nhập bằng Google không thành công.';
      });
    }
  }

  Future<bool> _isAccountExists(String email) async {
    final userCollection = FirebaseFirestore.instance.collection('users');
    final querySnapshot =
        await userCollection.where('email', isEqualTo: email).get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50],
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 128),
                const Text('2048',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                      fontSize: 64,
                    )),
                const SizedBox(height: 48),
                SizedBox(
                  width: 400.0,
                  height: 50.0,
                  child: Theme(
                    data: ThemeData(hintColor: Colors.white),
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontFamily: 'Nunito',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 16),
                      cursorColor: Colors.pinkAccent,
                      decoration: InputDecoration(
                        hintText: 'Tài khoản',
                        hintStyle: const TextStyle(
                          color: Colors.pinkAccent,
                          fontFamily: 'Nunito',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.pink[50],
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.pinkAccent),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 3, color: Colors.pinkAccent),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 400.0,
                  height: 50.0,
                  child: Theme(
                    data: ThemeData(hintColor: Colors.white),
                    child: TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      enableSuggestions: false,
                      autocorrect: false,
                      style: const TextStyle(
                          color: Colors.pinkAccent,
                          fontFamily: 'Nunito',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 16),
                      cursorColor: Colors.pinkAccent,
                      decoration: InputDecoration(
                        hintText: 'Mật khẩu',
                        hintStyle: const TextStyle(
                          color: Colors.pinkAccent,
                          fontFamily: 'Nunito',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.normal,
                          fontSize: 16,
                        ),
                        filled: true,
                        fillColor: Colors.pink[50],
                        enabledBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 2, color: Colors.pinkAccent),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide:
                              BorderSide(width: 3, color: Colors.pinkAccent),
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.pinkAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontFamily: 'Nunito',
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: 400.0,
                  height: 50.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        _errorMessage = '';
                      });
                      _login();
                    },
                    child: const Text('ĐĂNG NHẬP',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                          color: Colors.pinkAccent,
                          fontSize: 16,
                        )),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: 400.0,
                  height: 50.0,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: _loginWithGoogle,
                    icon: Image.asset(
                      'assets/images/google.png',
                      height: 32.0,
                      width: 32.0,
                    ),
                    label: const Text(
                      'ĐĂNG NHẬP BẰNG GOOGLE',
                      style: TextStyle(
                        color: Colors.pinkAccent,
                        fontFamily: 'Nunito',
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 48),
                SizedBox(
                  width: 250.0,
                  height: 40.0,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.pinkAccent,
                      backgroundColor: Colors.pink[200],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onPressed: () {
                      AudioPlayer button_01 = AudioPlayer();
                      button_01
                          .setSource(AssetSource('music/button_01.ogg'))
                          .then((value) {
                        button_01.play(AssetSource('music/button_01.ogg'));
                      });
                      Navigator.pushReplacementNamed(context, '/registration');
                    },
                    child: const Text('ĐĂNG KÝ',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontStyle: FontStyle.normal,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 14,
                        )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
