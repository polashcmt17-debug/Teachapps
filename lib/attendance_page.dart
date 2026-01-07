import 'package:flutter/material.dart';
import 'attendance_service.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final AttendanceService _attendanceService = AttendanceService();

  /// 🔹 Attendance document id
  final String docId = "attendance_today";

  /// 🔹 Controllers
  final TextEditingController courseNameController =
      TextEditingController();
  final TextEditingController courseCodeController =
      TextEditingController();
  final TextEditingController sectionController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Take Attendance"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// HEADER
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Course Information",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: courseNameController,
                      decoration: const InputDecoration(
                        labelText: "Course Name",
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: courseCodeController,
                      decoration: const InputDecoration(
                        labelText: "Course Code",
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: sectionController,
                      decoration: const InputDecoration(
                        labelText: "Section",
                      ),
                    ),

                    const SizedBox(height: 14),

                    ElevatedButton(
                      onPressed: () async {
                        await _attendanceService.createAttendance(
                          docId: docId,
                          courseName: courseNameController.text,
                          courseCode: courseCodeController.text,
                          teacherEmail: "teacher@gmail.com",
                          date: DateTime.now().toString(),
                        );

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text("Attendance session created"),
                          ),
                        );
                      },
                      child: const Text("Start Attendance"),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// STUDENT LIST 
            Expanded(
              child: StreamBuilder(
                stream: _attendanceService.getStudents(docId),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final students = snapshot.data!.docs;

                  if (students.isEmpty) {
                    return const Center(
                      child: Text("No students added"),
                    );
                  }

                  return ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];

                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              student.id.length >= 2
                                  ? student.id.substring(0, 2)
                                  : student.id,
                            ),
                          ),
                          title: Text(student['name']),
                          subtitle: Text("ID: ${student.id}"),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              /// PRESENT / ABSENT
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Switch(
                                    value: student['present'],
                                    onChanged: (value) async {
                                      await _attendanceService
                                          .markStudentAttendance(
                                        docId: docId,
                                        studentId: student.id,
                                        studentName:
                                            student['name'],
                                        present: value,
                                      );
                                    },
                                  ),
                                  Text(
                                    student['present']
                                        ? "Present"
                                        : "Absent",
                                    style: TextStyle(
                                      color: student['present']
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight:
                                          FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(width: 6),

                              /// DELETE BUTTON
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  _confirmDelete(
                                    student.id,
                                    student['name'],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            /// ADD STUDENT
            ElevatedButton.icon(
              onPressed: _showAddStudentDialog,
              icon: const Icon(Icons.person_add),
              label: const Text("Add Student"),
            ),
          ],
        ),
      ),
    );
  }

  ///ADD STUDENT DIALOG
  void _showAddStudentDialog() {
    final TextEditingController idController =
        TextEditingController();
    final TextEditingController nameController =
        TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Student"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: idController,
              decoration: const InputDecoration(
                labelText: "Student ID",
              ),
            ),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Student Name",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await _attendanceService.markStudentAttendance(
                docId: docId,
                studentId: idController.text,
                studentName: nameController.text,
                present: false,
              );
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  /// DELETE CONFIRMATION 
  void _confirmDelete(String studentId, String name) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Student"),
        content: Text(
          "Are you sure you want to delete $name?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              await _attendanceService.deleteStudent(
                docId: docId,
                studentId: studentId,
              );
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
