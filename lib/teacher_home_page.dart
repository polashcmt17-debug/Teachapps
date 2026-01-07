import 'package:flutter/material.dart'; 
import 'attendance_page.dart';


class TeacherHomePage extends StatefulWidget {
  const TeacherHomePage({super.key});

  @override
  State<TeacherHomePage> createState() => _TeacherHomePageState();
}

class _TeacherHomePageState extends State<TeacherHomePage> {
  String currentStatus = "Available";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("👨‍🏫 Teacher Dashboard"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          /// 👋 Welcome
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome Teacher 👩‍🏫",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    "Manage your classes and status",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// 🔄 Manual Status
          Card(
            child: ListTile(
              leading: const Icon(Icons.info, color: Colors.blue),
              title: const Text("Current Status"),
              subtitle: Text(currentStatus),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  setState(() => currentStatus = value);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: "In Class", child: Text("In Class")),
                  PopupMenuItem(value: "On Break", child: Text("On Break")),
                  PopupMenuItem(value: "Busy", child: Text("Busy")),
                  PopupMenuItem(value: "Available", child: Text("Available")),
                ],
              ),
            ),
          ),

          /// 👤 Update Profile
          Card(
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.green),
              title: const Text("Update Profile"),
              subtitle: const Text("Edit name, department, info"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showSnackBar(context, "Profile update coming soon 🚧");
              },
            ),
          ),

          /// 📅 Class Schedule
          Card(
            child: ListTile(
              leading: const Icon(Icons.schedule, color: Colors.orange),
              title: const Text("Today's Class Schedule"),
              subtitle: const Text("View today’s classes"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showSnackBar(context, "Class schedule coming soon 🚧");
              },
            ),
          ),

          /// 🗺 Auto Location
          Card(
            child: ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text("Live Location"),
              subtitle: const Text("Auto-update your location"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showSnackBar(context, "Location tracking coming soon 🚧");
              },
            ),
          ),

          /// 📢 Notifications
          Card(
            child: ListTile(
              leading: const Icon(Icons.notifications, color: Colors.purple),
              title: const Text("Class Notifications"),
              subtitle: const Text("Class reminder alerts"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showSnackBar(context, "Notifications coming soon 🚧");
              },
            ),
          ),

          /// 📆 Weekly Timetable
          Card(
            child: ListTile(
              leading: const Icon(Icons.calendar_month, color: Colors.teal),
              title: const Text("Weekly Timetable"),
              subtitle: const Text("View weekly schedule"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showSnackBar(context, "Weekly timetable coming soon 🚧");
              },
            ),
          ),

          /// 📝 Attendance
          /// 📝 Attendance
          Card(
            child: ListTile(
              leading: const Icon(Icons.fact_check, color: Colors.brown),
              title: const Text("Take Attendance"),
              subtitle: const Text("Mark student attendance"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AttendancePage(),
                  ),
                );
              },
            ),
          ),

         /* Card(
            child: ListTile(
              leading: const Icon(Icons.fact_check, color: Colors.brown),
              title: const Text("Take Attendance"),
              subtitle: const Text("Mark student attendance"),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showSnackBar(context, "Attendance system coming soon 🚧");
              },
            ),
          ),*/
        ],
      ),
    );
  }

  void showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }
}
