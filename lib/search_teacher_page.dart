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
  String? errorMessage;

  bool isCheckingRoutine = false;
  List<List<String>> todayRoutine = [];

  final String teacherSheet =
      "https://docs.google.com/spreadsheets/d/1jjOmSUg3U_uyzM0mtaj1FldEOD1nNeMCAhybEiQTW3M/export?format=csv&gid=2120560749";

  final String teacherSheetGED =
      "https://docs.google.com/spreadsheets/d/1jjOmSUg3U_uyzM0mtaj1FldEOD1nNeMCAhybEiQTW3M/export?format=csv&gid=639086230";

  final Map<String, String> daySheetMap = {
    "saturday": "997090556",
    "sunday": "255270977",
    "monday": "447521283",
    "tuesday": "1496246527",
    "wednesday": "1383433023",
    "thursday": "739024824",
    "friday": "307287901",
  };

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  /// ================= NORMALIZE TABLE =================
  List<List<String>> normalizeTable(List<List<String>> table) {
    int maxLength = 0;

    for (var row in table) {
      if (row.length > maxLength) {
        maxLength = row.length;
      }
    }

    for (var row in table) {
      while (row.length < maxLength) {
        row.add("");
      }
    }

    return table;
  }

  /// ================= FETCH TEACHERS =================
  Future<void> fetchTeachers() async {
    allTeachers.clear();
    final response = await http.get(Uri.parse(teacherSheet));
    final responseGED = await http.get(Uri.parse(teacherSheetGED));

    if (response.statusCode == 200) {
      List<String> rows = response.body.split("\n");
      for (int i = 1; i < rows.length; i++) {
        final columns = rows[i].split(",");
        if (columns.length > 3) {
          allTeachers.add({
            "acronym": columns[2].trim(),
            "fullName": columns[3].trim(),
          });
        }
      }

      List<String> rowsGED = responseGED.body.split("\n");
      for (int i = 1; i < rowsGED.length; i++) {
        final columns = rowsGED[i].split(",");
        if (columns.length > 4) {
          allTeachers.add({
            "acronym": columns[3].trim(),
            "fullName": columns[4].trim(),
          });
        }
      }

      setState(() {});
    }
  }

  /// ================= SEARCH =================
  void searchTeacher(String query) {
    if (query.isEmpty) {
      setState(() => filteredTeachers = []);
      return;
    }

    final results = allTeachers.where((teacher) {
      final name = teacher["fullName"]!.toLowerCase();
      final acronym = teacher["acronym"]!.toLowerCase();
      final input = query.toLowerCase();
      return name.contains(input) || acronym.contains(input);
    }).toList();

    setState(() {
      filteredTeachers = results;
    });
  }

  /// ================= CHECK CURRENT CLASS =================
  Future<void> checkCurrentClass() async {
    if (selectedAcronym == null) return;

    setState(() {
      isCheckingRoutine = true;
      resultText = null;
      errorMessage = null;
    });

    try {
      final now = DateTime.now();
      final currentDay =
          DateFormat('EEEE').format(now).toLowerCase();

      final gid = daySheetMap[currentDay];
      if (gid == null) {
        setState(() {
          resultText = "No routine for today";
          isCheckingRoutine = false;
        });
        return;
      }

      final routineUrl =
          "https://docs.google.com/spreadsheets/d/1jjOmSUg3U_uyzM0mtaj1FldEOD1nNeMCAhybEiQTW3M/export?format=csv&gid=$gid";

      final response = await http.get(Uri.parse(routineUrl));
      if (response.statusCode != 200) {
        throw Exception("Failed to load routine");
      }

      List<List<String>> table = response.body
          .split("\n")
          .map((row) => row.split(","))
          .toList();

      todayRoutine = normalizeTable(table);

      List<String> header = todayRoutine[3];
      int matchedColumnIndex = -1;

      for (int i = 0; i < header.length; i++) {
        if (header[i].contains("-") &&
            isTimeInRange(header[i])) {
          matchedColumnIndex = i;
          break;
        }
      }

      if (matchedColumnIndex == -1) {
        setState(() {
          resultText = "Free right now";
          isCheckingRoutine = false;
        });
        return;
      }

      for (int i = 2; i < todayRoutine.length; i++) {
        if (todayRoutine[i].length >
            matchedColumnIndex) {
          String cell =
              todayRoutine[i][matchedColumnIndex];
          if (cell.contains(selectedAcronym!)) {
            setState(() {
              resultText = cell;
              isCheckingRoutine = false;
            });
            return;
          }
        }
      }

      setState(() {
        resultText = "Free right now";
        isCheckingRoutine = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Something went wrong";
        isCheckingRoutine = false;
      });
    }
  }

  bool isTimeInRange(String range) {
    try {
      final now = DateTime.now();
      final parts = range.split("-");
      if (parts.length != 2) return false;

      DateTime start = parseSheetTime(parts[0]);
      DateTime end = parseSheetTime(parts[1]);

      start = DateTime(now.year, now.month, now.day,
          start.hour, start.minute);
      end = DateTime(now.year, now.month, now.day,
          end.hour, end.minute);

      return now.isAfter(start) && now.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  DateTime parseSheetTime(String timeStr) {
    timeStr = timeStr
        .trim()
        .toUpperCase()
        .replaceAll(".", ":")
        .replaceAll("\"", "")
        .replaceAll(RegExp(r'\s+'), " ");

    if (timeStr.contains("AM") ||
        timeStr.contains("PM")) {
      return DateFormat("h:mm a").parse(timeStr);
    }

    DateTime temp =
        DateFormat("h:mm").parse(timeStr);
    String period =
        (temp.hour >= 9 && temp.hour <= 11)
            ? " AM"
            : " PM";
    return DateFormat("h:mm a")
        .parse(timeStr + period);
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Teacher"),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: fetchTeachers,
        child: SingleChildScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search teacher",
                  prefixIcon:
                      const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: searchTeacher,
              ),
              const SizedBox(height: 15),

              if (filteredTeachers.isNotEmpty)
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    itemCount:
                        filteredTeachers.length,
                    itemBuilder: (context, index) {
                      final teacher =
                          filteredTeachers[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                                teacher['acronym']![0]),
                          ),
                          title:
                              Text(teacher['fullName']!),
                          subtitle: Text(
                              "(${teacher['acronym']})"),
                          onTap: () {
                            selectedAcronym =
                                teacher['acronym'];
                            searchController.text =
                                teacher['fullName']!;
                            filteredTeachers = [];
                            setState(() {});
                            checkCurrentClass();
                          },
                        ),
                      );
                    },
                  ),
                ),

              const SizedBox(height: 20),

              if (isCheckingRoutine)
                const CircularProgressIndicator(),

              if (resultText != null)
                Card(
                  color: resultText!
                          .toLowerCase()
                          .contains("free")
                      ? Colors.blue.shade100
                      : Colors.green.shade100,
                  child: Padding(
                    padding:
                        const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        Text(
                          resultText!,
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          resultText!
                                  .toLowerCase()
                                  .contains("free")
                              ? "Status: Free"
                              : "Status: In Class",
                        ),
                      ],
                    ),
                  ),
                ),

              /// ================= FULL DAY ROUTINE TABLE =================
              if (todayRoutine.isNotEmpty)
                ExpansionTile(
                  title: const Text(
                    "View Full Day Routine",
                    style: TextStyle(
                        fontWeight:
                            FontWeight.bold),
                  ),
                  children: [
                    SingleChildScrollView(
                      scrollDirection:
                          Axis.horizontal,
                      child:
                          SingleChildScrollView(
                        scrollDirection:
                            Axis.vertical,
                        child: DataTable(
                          border: TableBorder.all(
                            color: Colors
                                .grey.shade300,
                          ),
                          headingRowColor:
                              MaterialStateProperty
                                  .all(Colors
                                      .blue
                                      .shade100),
                          columns: todayRoutine[0]
                              .map(
                                (header) =>
                                    DataColumn(
                                  label: Text(
                                    header,
                                    style:
                                        const TextStyle(
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                          rows: todayRoutine
                              .sublist(1)
                              .map(
                                (row) =>
                                    DataRow(
                                  cells: row
                                      .map(
                                        (cell) =>
                                            DataCell(
                                          Text(cell),
                                        ),
                                      )
                                      .toList(),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}