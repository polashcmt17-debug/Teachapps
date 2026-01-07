import 'package:flutter/material.dart';
import 'search_teacher_page.dart';

class StudentHomePage extends StatelessWidget {
  const StudentHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF2F4F8),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromARGB(255, 228, 143, 33),
        title: const Text(
          "Student Dashboard 🧑‍🎓",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 🔹 Welcome Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xff5B6CFF), Color(0xff7F8CFF)],
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome ",
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Student 🧑‍🎓",
                  style: TextStyle(
                    color: Color.fromARGB(255, 221, 226, 222),
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  "Choose an option below to continue",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          /// 🔍 Search Teacher
          _smartTile(
            context,
            icon: Icons.search,
            color: Colors.blue,
            title: "Search Teacher",
            subtitle: "Find teacher by name or department",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const SearchTeacherPage(),
                ),
              );
            },
          ),

          /// 📍 Live Location
          _smartTile(
            context,
            icon: Icons.location_on,
            color: Colors.red,
            title: "Teacher Live Location",
            subtitle: "View teacher’s current location",
          ),

          /// 🏫 Current Class
          _smartTile(
            context,
            icon: Icons.class_,
            color: Colors.green,
            title: "Current Class",
            subtitle: "See which class teacher is taking now",
          ),

          /// ⏰ Teacher Status
          _smartTile(
            context,
            icon: Icons.access_time,
            color: Colors.orange,
            title: "Teacher Status",
            subtitle: "Check if teacher is free or busy",
          ),

          /// 📅 Weekly Timetable
          _smartTile(
            context,
            icon: Icons.calendar_month,
            color: Colors.purple,
            title: "Weekly Timetable",
            subtitle: "View teacher’s weekly schedule",
          ),
        ],
      ),
    );
  }

  /// 🔹 Smart ListTile Card
  Widget _smartTile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap ??
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Feature coming soon 🚧")),
              );
            },
      ),
    );
  }
}
