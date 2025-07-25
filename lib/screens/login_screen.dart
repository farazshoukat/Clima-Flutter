import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'loading_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email = '';
  String password = '';
  bool isLogin = true;
  String error = '';
  bool isLoading = false;
  bool isLocked = false;
  int failedAttempts = 0;

  final _formKey = GlobalKey<FormState>();

  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final passwordRegex = RegExp(r'^(?=.*?[!@#\$&*~]).{8,}$');

  void handleAuth() async {
    if (isLocked || !_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      UserCredential userCredential;
      if (isLogin) {
        userCredential = await _auth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set({
          'email': email,
          'createdAt': Timestamp.now(),
        });
      }

      if (userCredential.user != null) {
        setState(() {
          failedAttempts = 0; // Reset on success
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoadingScreen()),
        );
      }
    } catch (e) {
      setState(() {
        error = e.toString().split(']').last.trim();
        failedAttempts++;

        if (failedAttempts >= 3) {
          isLocked = true;
          error = '🚫 Too many failed attempts. Locked for 5 seconds.';
          Future.delayed(Duration(seconds: 5), () {
            if (mounted) {
              setState(() {
                isLocked = false;
                failedAttempts = 0;
                error = '';
              });
            }
          });
        }
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text(
                    isLogin ? 'Welcome Back 👋' : 'Create Account ✨',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isLogin ? 'Login to continue' : 'Sign up to get started',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (value) => email = value.trim(),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Email'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email required';
                      if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    obscureText: true,
                    onChanged: (value) => password = value.trim(),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Password'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Password required';
                      if (!passwordRegex.hasMatch(value)) {
                        return 'Min 8 chars & 1 special char';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),
                  if (error.isNotEmpty)
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 20),
                  isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : ElevatedButton(
                    onPressed: isLocked ? null : handleAuth,
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                      isLocked ? Colors.grey : Colors.blueAccent.shade200,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      isLocked
                          ? 'Locked (5s)'
                          : (isLogin ? 'Login' : 'Signup'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => setState(() => isLogin = !isLogin),
                    child: Text(
                      isLogin
                          ? "Don't have an account? Sign Up"
                          : "Already registered? Log In",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      filled: true,
      fillColor: Colors.white10,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    );
  }
}
