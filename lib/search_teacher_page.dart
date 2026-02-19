import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class SearchTeacherPage extends StatefulWidget {
  const SearchTeacherPage({super.key});

  @override
  State<SearchTeacherPage> createState() => _SearchTeacherPageState();
}

class _SearchTeacherPageState extends State<SearchTeacherPage> {
  final TextEditingController searchController = TextEditingController();

  List<Map<String, String>> allTeachers = [];
  List<Map<String, String>> filteredTeachers = [];

  String? selectedAcronym;
  String? resultText;

  // Sheet IDs
  final String teacherSheet =
      "https://docs.google.com/spreadsheets/d/1jjOmSUg3U_uyzM0mtaj1FldEOD1nNeMCAhybEiQTW3M/export?format=csv&gid=2120560749";

  final Map<String, String> daySheetMap = {
    "saturday": "997090556",
    "sunday": "255270977",
    "monday": "255270977",
    "tuesday": "1496246527",
    "wednesday": "1383433023",
    "thursday": "739024824",
    "friday": "307287901",
  };
//   sunday: 255270977
// monday: 255270977
// tuesday: 1496246527
// wednessday: 1383433023
// thursday: 1383433023
// friday: 1383433023
// saturday: 

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  Future<void> fetchTeachers() async {
    final response = await http.get(Uri.parse(teacherSheet));
    if (response.statusCode == 200) {
      List<String> rows = response.body.split("\n");

      for (int i = 1; i < rows.length; i++) {
        final columns = rows[i].split(",");
        if (columns.length > 2) {
          allTeachers.add({
            "acronym": columns[2].trim(),
            "fullName": columns[3].trim(),
          });
        }
      }
      setState(() {});
    }
  }

  void searchTeacher(String query) {
    if (query.isEmpty) {
      setState(() => filteredTeachers = []);
      return;
    }

    final results = allTeachers.where((teacher) {
      final name = teacher["fullName"]!.toLowerCase();
      final acronym = teacher["acronym"]!.toLowerCase();
      // print("Hare krishna answer: ${acronym} ");
      final input = query.toLowerCase();
      return name.contains(input) || acronym.contains(input);
    }).toList();

    setState(() {
      filteredTeachers = results;
    });
  }

  Future<void> checkCurrentClass() async {
    if (selectedAcronym == null) return;

    final now = DateTime.now();
    final currentDay = DateFormat('EEEE').format(now).toLowerCase();
    // final currentTime = DateFormat('HH:mm').format(now);

    final gid = daySheetMap[currentDay];
    if (gid == null) {
      print("No sheet for $currentDay");
      setState(() => resultText = "No routine for today");
      return;
    }

    final routineUrl =
        "https://docs.google.com/spreadsheets/d/1jjOmSUg3U_uyzM0mtaj1FldEOD1nNeMCAhybEiQTW3M/export?format=csv&gid=$gid";

    final response = await http.get(Uri.parse(routineUrl));
    if (response.statusCode != 200) return;

    List<List<String>> table = response.body
        .split("\n")
        .map((row) => row.split(","))
        .toList();

    if (table.isEmpty) return;

    List<String> header = table[3]; // time header row

    int matchedColumnIndex = -1;

    for (int i = 0; i < header.length; i++) {
      if (header[i].contains("-")) { 
        print("Checking time range: ${header[i]} against current time: ");
        if (isTimeInRange(header[i])) {
          matchedColumnIndex = i;
          print("Matched column: $i with time range ${header[i]}");
          break;
        }
      }
    }

    if (matchedColumnIndex == -1) {
      setState(() => resultText = "No class at this time");
      return;
    }

    for (int i = 2; i < table.length; i++) {
      if (table[i].length > matchedColumnIndex) {
        String cell = table[i][matchedColumnIndex];
        print("HK: Checking cell '$cell' for acronym '$selectedAcronym'");
        if (cell.contains(selectedAcronym!)) {
          setState(() => resultText = cell);
          return;
        }
      }
    }

    setState(() => resultText = "No class right now");
  }

bool isTimeInRange(String range) {
  try {
    // final now = DateTime.now();
    DateTime now = parseSheetTime("11:00 AM");

    final parts = range.split("-");
    if (parts.length != 2) return false; 

    print("HK: Parsing time range '$range' into start '${parts[0]}' and end '${parts[1]}'");
    DateTime start = parseSheetTime(parts[0]); 
    print('HK: Parsed start time: $start');
    DateTime end = parseSheetTime(parts[1]);
    print('HK: Parsed end time: $end');

    // Make start & end same date as today
    start = DateTime(now.year, now.month, now.day, start.hour, start.minute);
    end = DateTime(now.year, now.month, now.day, end.hour, end.minute);
    
    print("HK: Checking if now ($now) is between $start and $end");
    return now.isAfter(start) && now.isBefore(end);
  } catch (e) {
    print("Error parsing time range '$range': $e");
    return false;
  }
}


DateTime parseSheetTime(String timeStr) {
  timeStr = timeStr
      .trim()
      .toUpperCase()
      .replaceAll(".", ":")      // convert 1.25 → 1:25
      .replaceAll("OL Class ", "")
      .replaceAll(RegExp(r'\s+'), " "); // normalize spaces

  // If already contains AM/PM → parse normally
  if (timeStr.contains("AM") || timeStr.contains("PM")) {
    return DateFormat("h:mm a").parse(timeStr);
  }

  // Parse as 12-hour WITHOUT AM/PM
  DateTime temp = DateFormat("h:mm").parse(timeStr);

  int hour = temp.hour;

  String period;

  if (hour >= 9 && hour <= 11) {
    period = " AM";
  } else {
    period = " PM";
  }

  String formatted = timeStr + period;

  return DateFormat("h:mm a").parse(formatted);
}


  DateTime parseTime(String timeStr) {
    timeStr = timeStr.replaceAll("AM", "").replaceAll("PM", "").trim();
    return DateFormat("HH:mm").parse(
        DateFormat("HH:mm").format(DateFormat("HH:mm").parse(timeStr)));
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Teacher")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Search teacher",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: searchTeacher,
            ),

            const SizedBox(height: 10),

            if (filteredTeachers.isNotEmpty)
              Container(
                height: 200,
                child: ListView.builder(
                  itemCount: filteredTeachers.length,
                  itemBuilder: (context, index) {
                    final teacher = filteredTeachers[index];
                    return ListTile(
                      title: Text(
                          "${teacher['fullName']} (${teacher['acronym']})"),
                      onTap: () {
                        selectedAcronym = teacher['acronym'];
                        searchController.text = teacher['fullName']!;
                        filteredTeachers = [];
                        setState(() {});
                        checkCurrentClass();
                      },
                    );
                  },
                ),
              ),

            const SizedBox(height: 20),

            if (resultText != null)
              Card(
                color: Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    resultText!,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
