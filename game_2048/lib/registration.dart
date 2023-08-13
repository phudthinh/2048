import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _errorMessage = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  Future<void> _register() async {
    try {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() {
          _errorMessage = 'Mật khẩu không trùng khớp.';
        });
        return;
      }

      await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final userId = _auth.currentUser!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'email': _emailController.text,
        'score': 0,
      });

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
        _errorMessage = 'Đã có lỗi xảy ra trong quá trình đăng ký.';
      });
    }
  }

  Future<void> _registerWithGoogle() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        await _auth.signInWithCredential(credential);

        final user = _auth.currentUser;
        if (user != null) {
          final userId = user.uid;
          await FirebaseFirestore.instance.collection('users').doc(userId).set({
            'email': user.email,
            'score': 0,
          });
          AudioPlayer button_01 = AudioPlayer();
          button_01.setSource(AssetSource('music/button_01.ogg')).then((value) {
            button_01.play(AssetSource('music/button_01.ogg'));
          });
          Navigator.pushReplacementNamed(context, '/game', arguments: {
            'userEmail': user.email,
          });
        }
      }
    } catch (e) {
      setState(() {
        AudioPlayer button_02 = AudioPlayer();
        button_02.setSource(AssetSource('music/button_02.ogg')).then((value) {
          button_02.play(AssetSource('music/button_02.ogg'));
        });
        _errorMessage = 'Đã có lỗi xảy ra trong quá trình đăng ký bằng Google.';
      });
    }
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
                const SizedBox(height: 64),
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
                SizedBox(
                  width: 400.0,
                  height: 50.0,
                  child: Theme(
                    data: ThemeData(hintColor: Colors.white),
                    child: TextField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
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
                        hintText: 'Nhập lại mật khẩu',
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
                              _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                            });
                          },
                          icon: Icon(
                            _obscureConfirmPassword
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
                      _register();
                    },
                    child: const Text('ĐĂNG KÝ',
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
                    onPressed: _registerWithGoogle,
                    icon: Image.asset(
                      'assets/images/google.png',
                      height: 32.0,
                      width: 32.0,
                    ),
                    label: const Text(
                      'ĐĂNG KÝ BẰNG GOOGLE',
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
                      Navigator.pushReplacementNamed(context, '/');
                    },
                    child: const Text('ĐĂNG NHẬP',
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
