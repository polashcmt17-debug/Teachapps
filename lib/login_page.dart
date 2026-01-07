import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_page.dart';
import 'student_home_page.dart';
import 'teacher_home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // 1️⃣ Validate input
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    try {
      // 2️⃣ Get user document (email = document ID)
      final doc =
          await _firestore.collection('users').doc(email).get();

      if (!doc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not found")),
        );
        return;
      }

      final data = doc.data()!;
      final storedPassword = data['password'];
      final role = data['role'];

      // 3️⃣ Password check
      if (storedPassword != password) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Incorrect password")),
        );
        return;
      }

      // 4️⃣ Login success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Login successful")),
      );

      // 5️⃣ Role-based navigation
      if (role == 'student') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const StudentHomePage()),
        );
      } else if (role == 'teacher') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TeacherHomePage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid role")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.school, size: 90, color: Colors.blue),
            const SizedBox(height: 20),

            const Text(
              "TeachMap",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 45,
              child: ElevatedButton(
                onPressed: login,
                child: const Text("Login"),
              ),
            ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPage(),
                  ),
                );
              },
              child: const Text("Create new account"),
            ),
          ],
        ),
      ),
    );
  }
}
