import 'package:flutter/material.dart';
import 'package:one_click_memo/models/Time.dart';
import 'package:one_click_memo/widgets/time_container.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_click_memo/screens/calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:csv/csv.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

const myKey = 'my_string_list';
bool darkMode = true;

class ClickScreen extends StatefulWidget {
  const ClickScreen({super.key});

  @override
  State<ClickScreen> createState() => _ClickScreenState();
}

class _ClickScreenState extends State<ClickScreen> {
  List<Time> times = []; // List to store times

  @override
  void initState() {
    super.initState();
    // Ensure initialization after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      init();
    });
  }

  // Initialize and load saved data
  void init() async {
    print(222);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String> timesStringList = prefs.getStringList(myKey) ?? [];
      for (int i = 0; i < timesStringList.length; i++) {
        times.add(Time(date: stringToDateTime(timesStringList[i])));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar( // App bar
        centerTitle: true,
        backgroundColor: Colors.black,
        title: const Text('メモ'),
      ),
      body: Center( // Center alignment
        child: Column(
          children: [
            // Add Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                width: 120,
                height: 120,
                child: ElevatedButton(
                  child: const Text(
                    '追加', 
                    style: TextStyle(
                      fontSize: 24,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey[850],
                    onPrimary: Colors.white,
                    shape: const CircleBorder(
                      side: BorderSide(
                        color: Colors.black,
                        width: 1,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  onPressed: () async { // On button press
                    setState(() {
                      times.add(Time(date: DateTime.now()));
                    });
                    final prefs = await SharedPreferences.getInstance();
                    // Save data
                    prefs.setStringList(myKey, times.map((t) => DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(t.date)).toList());
                  },
                ),
              ),
            ),

            // Calendar Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                  ),
                  label: const Text('カレンダーを表示'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.blue,
                    onPrimary: Colors.white,
                  ),
                  onPressed: ()  { // On button press
                    Navigator.of(context).push(
                      MaterialPageRoute( 
                        builder: ((context) => CalendarScreen(times: times)),
                      ),
                    ).then((value) {
                      setState(() {
                        // Optional: Update state if needed
                      });
                    });
                  },
                ),
              ),
            ),

            // Export to CSV Button
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(
                    Icons.download,
                    color: Colors.white,
                  ),
                  label: const Text('CSVをエクスポート'),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.green,
                    onPrimary: Colors.white,
                  ),
                  onPressed: exportToCSV, // New method
                ),
              ),
            ),

            // List of Times
            Expanded(
              child: ListView(
                children: List.from(times.reversed).map((time) {
                  return Dismissible(
                    key: Key(DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(time.date)),
                    child: ListTile(
                      title: Text(
                        getString(time.date),
                        style: const TextStyle(
                          fontSize: 24,
                          color: Colors.white
                        ),
                      ),
                    ),
                    background: Container(color: Colors.red),
                    confirmDismiss: (direction) async {
                      // Confirmation dialog can be added here
                      return true;
                    },
                    onDismissed: (direction) async {
                      setState(() {
                        times.removeWhere((t) => t == time);
                      });
                      final prefs = await SharedPreferences.getInstance();
                      // Save updated data
                      prefs.setStringList(myKey, times.map((t) => DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(t.date)).toList());
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CSV Export Method
  Future<void> exportToCSV() async {
    if (times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('エクスポートするデータがありません。')),
      );
      return;
    }

    try {
      // 1. Convert times to a List<List<String>> for CSV
      List<List<String>> csvData = [
        ['Date', 'Time'], // Header
        ...times.map((time) => [
              DateFormat('yyyy/MM/dd(E)').format(time.date),
              DateFormat('HH:mm:ss.SSS').format(time.date),
            ]),
      ];

      // 2. Convert the List<List<String>> to a CSV string
      String csv = const ListToCsvConverter().convert(csvData);

      // 3. Get the temporary directory
      final directory = await getTemporaryDirectory();
      final path = '${directory.path}/times_${DateTime.now().millisecondsSinceEpoch}.csv';

      // 4. Write the CSV string to the file
      final file = File(path);
      await file.writeAsString(csv);

      // 5. Share the CSV file
      await Share.shareFiles([path], text: 'エクスポートされたタイムデータです。');
    } catch (e) {
      
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('エクスポート中にエラーが発生しました: $e')),
        
      );
    }
  }

  // Helper method to format DateTime
  String getString(DateTime time){
    initializeDateFormatting("ja", null);
    return DateFormat.yMMMd('ja').format(time) +
        '(${DateFormat.E('ja').format(time)})' +
        ' ' +
        time.hour.toString() + '時' +
        time.minute.toString() + '分';
  }

  // Helper method to convert string to DateTime
  DateTime stringToDateTime(String datetimeStr){
    var _dateFormatter = DateFormat("yyyy/MM/dd(E) HH:mm:ss.SSS");
    DateTime result = DateTime(1970,1,1);

    try {
      result = _dateFormatter.parseStrict(datetimeStr);
    } catch(e){
      // Handle parsing error
      print('Error parsing date string: $e');
    }
    return result;
  }
}
