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

  final FirestoreService firestoreService = FirestoreService();

  String role = "Student";

  // 👁️ show / hide states
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Email regex
  final RegExp emailRegex =
      RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  // Password regex
  final RegExp passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)[A-Za-z\d]{8,}$');

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
              const Icon(Icons.school, size: 80, color: Colors.blue),
              const SizedBox(height: 20),

              /// ID
              TextFormField(
                controller: idController,
                decoration: inputStyle("ID", Icons.badge),
                validator: (v) =>
                    v == null || v.isEmpty ? "Enter ID" : null,
              ),
              const SizedBox(height: 14),

              /// Name
              TextFormField(
                controller: nameController,
                decoration: inputStyle("Name", Icons.person),
                validator: (v) =>
                    v == null || v.length < 3 ? "Enter valid name" : null,
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

                              /// Department Dropdown
                DropdownButtonFormField<String>(
                  value: "CSE", // Default value
                  decoration: inputStyle("Department", Icons.apartment),
                  items: const [
                    DropdownMenuItem(value: "CSE", child: Text("CSE")),
                    DropdownMenuItem(value: "EEE", child: Text("EEE")),
                    DropdownMenuItem(value: "LAW", child: Text("LAW")),
                    DropdownMenuItem(value: "CIVIL", child: Text("CIVIL")),
                    DropdownMenuItem(value: "ENGLISH", child: Text("ENGLISH")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      deptController.text = value!; // Save selected value
                    });
                  },
                  validator: (v) =>
                      v == null || v.isEmpty ? "Select department" : null,
                ),
                   const SizedBox(height: 14),

              /// Email
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: inputStyle("Email", Icons.email),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter email";
                  }
                  if (!emailRegex.hasMatch(v)) {
                    return "Enter valid email (example@email.com)";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              /// Password 👁️
              TextFormField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: inputStyle("Password", Icons.lock).copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return "Enter password";
                  }
                  if (!passwordRegex.hasMatch(v)) {
                    return "Min 8 chars, upper, lower & number";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              /// Confirm Password 👁️
              TextFormField(
                controller: confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration:
                    inputStyle("Confirm Password", Icons.lock_outline)
                        .copyWith(
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
                validator: (v) {
                  if (v != passwordController.text) {
                    return "Password not match";
                  }
                  return null;
                },
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
                      final String name = nameController.text.trim();
                      final String email = emailController.text.trim();
                      final String password =
                          passwordController.text.trim();
                      final String department =
                          deptController.text.trim();
                      final String userRole =
                          role.toLowerCase();

                      try {
                        await firestoreService.saveUser(
                          email: email,
                          name: name,
                          department: department,
                          password: password,
                          role: userRole,
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Registration Successful"),
                          ),
                        );

                        Navigator.pop(context);
                      } catch (e) {
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
