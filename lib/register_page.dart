import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import './firestore_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final idController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final deptController = TextEditingController();
  final db = FirebaseFirestore.instance;
  final FirestoreService firestoreService = FirestoreService();


  String role = "Student";

  InputDecoration inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.grey.shade100,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Account"),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// Top Icon
              const Icon(
                Icons.school,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),

              /// ID
              TextFormField(
                controller: idController,
                decoration: inputStyle("ID", Icons.badge),
                validator: (v) => v!.isEmpty ? "Enter ID" : null,
              ),
              const SizedBox(height: 14),

              /// Name
              TextFormField(
                controller: nameController,
                decoration: inputStyle("Name", Icons.person),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 14),

              /// Role
              DropdownButtonFormField<String>(
                value: role,
                decoration: inputStyle("Role", Icons.person_outline),
                items: const [
                  DropdownMenuItem(value: "Student", child: Text("Student")),
                  DropdownMenuItem(value: "Teacher", child: Text("Teacher")),
                ],
                onChanged: (value) => setState(() => role = value!),
              ),
              const SizedBox(height: 14),

              /// Department
              TextFormField(
                controller: deptController,
                decoration: inputStyle("Department", Icons.apartment),
                validator: (v) => v!.isEmpty ? "Enter department" : null,
              ),
              const SizedBox(height: 14),

              /// Email
              TextFormField(
                controller: emailController,
                decoration: inputStyle("Email", Icons.email),
                validator: (v) => v!.isEmpty ? "Enter email" : null,
              ),
              const SizedBox(height: 14),

              /// Password
              TextFormField(
                controller: passwordController,
                decoration: inputStyle("Password", Icons.lock),
                obscureText: true,
                validator: (v) =>
                    v!.length < 6 ? "Min 6 characters" : null,
              ),
              const SizedBox(height: 14),

              /// Confirm Password
              TextFormField(
                controller: confirmPasswordController,
                decoration:
                    inputStyle("Confirm Password", Icons.lock_outline),
                obscureText: true,
                validator: (v) =>
                    v != passwordController.text ? "Password not match" : null,
              ),
              const SizedBox(height: 30),

              /// Register Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {

                      // 🔹 Collect all form data
                      final String id = idController.text.trim(); // optional (not stored now)
                      final String name = nameController.text.trim();
                      final String email = emailController.text.trim();
                      final String password = passwordController.text.trim();
                      final String department = deptController.text.trim();
                      final String userRole = role.toLowerCase(); // student / teacher

                      try {
                        // 🔥 Save to Firestore via service
                        await firestoreService.saveUser(
                          email: email,
                          name: name,
                          department: department,
                          password: password,
                          role: userRole,
                        );

                        // 🔍 Confirm data stored
                        final userData = await firestoreService.getUser(email);
                        print("✅ Firestore user data: $userData");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registration Successful"),
                          ),
                        );
                      } catch (e) {
                        print("❌ Firestore error: $e");

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registration Failed"),
                          ),
                        );
                      }
                    }
                  },



                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
