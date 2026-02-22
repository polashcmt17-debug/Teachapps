import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BatchRoutinePage extends StatefulWidget {
  const BatchRoutinePage({super.key});

  @override
  State<BatchRoutinePage> createState() => _BatchRoutinePageState();
}

class _BatchRoutinePageState extends State<BatchRoutinePage> {
  final TextEditingController batchController = TextEditingController();
  final TextEditingController sectionController = TextEditingController();

  TimeOfDay? selectedTime;
  bool useCurrentTime = true;

  String? resultText;
  bool isLoading = false;

  final Map<String, String> daySheetMap = {
    "saturday": "997090556",
    "sunday": "255270977",
    "monday": "447521283",
    "tuesday": "1496246527",
    "wednesday": "1383433023",
    "thursday": "739024824",
    "friday": "307287901",
  };

  final String baseSheetUrl =
      "https://docs.google.com/spreadsheets/d/1jjOmSUg3U_uyzM0mtaj1FldEOD1nNeMCAhybEiQTW3M/export?format=csv&gid=";

  /// ================= NORMALIZE TABLE =================
  List<List<String>> normalizeTable(List<List<String>> table) {
    int maxLength = 0;
    for (var row in table) {
      if (row.length > maxLength) maxLength = row.length;
    }

    for (var row in table) {
      while (row.length < maxLength) row.add("");
    }
    return table;
  }

  /// ================= CHECK ROUTINE =================
  Future<void> checkBatchRoutine() async {
    if (batchController.text.isEmpty || sectionController.text.isEmpty) return;

    setState(() {
      isLoading = true;
      resultText = null;
    });

    try {
      final now = DateTime.now();
      final currentDay = DateFormat('EEEE').format(now).toLowerCase();
      final gid = daySheetMap[currentDay];

      if (gid == null) {
        setState(() {
          resultText = "No routine found today";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(Uri.parse(baseSheetUrl + gid));
      if (response.statusCode != 200) throw Exception("Failed to load sheet");

      List<List<String>> table = response.body
          .split("\n")
          .map((row) => row.split(","))
          .toList();

      table = normalizeTable(table);

      DateTime checkTime = useCurrentTime
          ? DateTime.now()
          : DateTime(
              now.year,
              now.month,
              now.day,
              selectedTime?.hour ?? 0,
              selectedTime?.minute ?? 0,
            );

      int matchedColumnIndex = -1;
      List<String> header = table[3]; // time header row

      for (int i = 0; i < header.length; i++) {
        if (header[i].contains("-") &&
            isTimeInRange(header[i], checkTime)) {
          matchedColumnIndex = i;
          break;
        }
      }

      if (matchedColumnIndex == -1) {
        setState(() {
          resultText = "No class running";
          isLoading = false;
        });
        return;
      }

      String batch = batchController.text.trim();
      String section = sectionController.text.trim();

      for (int i = 2; i < table.length; i++) {
        // batch = column 2, section = column 3
        if (table[i].length > 2 &&
            table[i][1].trim() == batch &&
            table[i][2].trim() == section) {
          String cell = table[i][matchedColumnIndex];
          setState(() {
            resultText = cell.isEmpty ? "Free" : cell;
            isLoading = false;
          });
          return;
        }
      }

      setState(() {
        resultText = "Batch or Section not found";
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        resultText = "Something went wrong";
        isLoading = false;
      });
    }
  }

  bool isTimeInRange(String range, DateTime checkTime) {
    try {
      final parts = range.split("-");
      if (parts.length != 2) return false;

      DateTime start = parseTime(parts[0]);
      DateTime end = parseTime(parts[1]);

      start = DateTime(checkTime.year, checkTime.month, checkTime.day, start.hour, start.minute);
      end = DateTime(checkTime.year, checkTime.month, checkTime.day, end.hour, end.minute);

      return checkTime.isAfter(start) && checkTime.isBefore(end);
    } catch (e) {
      return false;
    }
  }

  DateTime parseTime(String timeStr) {
    timeStr = timeStr.trim().toUpperCase().replaceAll(".", ":").replaceAll("\"", "");
    if (timeStr.contains("AM") || timeStr.contains("PM")) return DateFormat("h:mm a").parse(timeStr);
    return DateFormat("H:mm").parse(timeStr);
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Batch Routine Checker")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Batch
            TextField(
              controller: batchController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Batch Number",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            /// Section
            TextField(
              controller: sectionController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                labelText: "Section",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 15),

            /// Checkbox
            Row(
              children: [
                Checkbox(
                  value: useCurrentTime,
                  onChanged: (value) {
                    setState(() {
                      useCurrentTime = value!;
                    });
                  },
                ),
                const Text("Use Current Time"),
              ],
            ),

            /// Time Picker
            ElevatedButton(
              onPressed: useCurrentTime
                  ? null
                  : () async {
                      final time = await showTimePicker(
                          context: context, initialTime: TimeOfDay.now());
                      if (time != null) {
                        setState(() {
                          selectedTime = time;
                        });
                      }
                    },
              child: Text(
                  selectedTime == null ? "Select Time" : selectedTime!.format(context)),
            ),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: checkBatchRoutine,
              child: const Text("Check Class"),
            ),
            const SizedBox(height: 20),

            if (isLoading) const CircularProgressIndicator(),

            if (resultText != null)
              Card(
                color: resultText!.toLowerCase().contains("free")
                    ? Colors.blue.shade100
                    : Colors.green.shade100,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    resultText!,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}