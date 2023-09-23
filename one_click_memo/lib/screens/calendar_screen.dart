import 'package:flutter/material.dart';
import 'package:one_click_memo/models/Time.dart';
import 'package:one_click_memo/widgets/time_container.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';
import 'package:fl_chart/fl_chart.dart';
import 'package:one_click_memo/widgets/barChart.dart';
import 'package:expandable/expandable.dart';

const myKey = 'my_string_list';//ローカルに保存するために使うキー

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key, required this.times});
  final List<Time> times;
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  Map<DateTime, List> _eventsList = {};//日ごとに分けられた時間のリストを保存＜日、時間のリスト＞
  List<Time> times = [];//全ての記録された時間
  DateTime _focused = DateTime.now();
  DateTime? _selected;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  
  int getHashCode(DateTime key) {
    return key.day * 1000000 + key.month * 10000 + key.year;
  }

  @override
  void initState() {
    super.initState();
    times = widget.times;
    _selected = _focused;

    //スケジュールの初期化
    eventInit();

  }

  void eventInit() {
    _eventsList.clear();
    List<Time> list = [];
    DateTime pdate = DateTime.now();
    for(int i = 0; i < times.length; i++){
      if(i == 0){
        pdate = times[i].date;
      } else {
        if(!isSameDay(times[i].date, pdate)){
          _eventsList[pdate] = list;
          pdate = times[i].date;
          list = [];
        }
      }
      list.add(times[i]);
    }
    _eventsList[pdate] = list;
    list = [];
  }
  //ボタンを押したときの関数 任意の時間の追加ができる
  Future<void> _selectTime (BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),    // 最初に表示する時刻を設定
    );

    if (picked != null) {
      setState(() {
        times.add(Time(date: DateTime(_focused.year, _focused.month, _focused.day, picked.hour, picked.minute)));
        times.sort((a,b) => a.date.compareTo(b.date));
        

        eventInit();
      });
      final prefs = await SharedPreferences.getInstance();
        prefs.setStringList(myKey, times.map((t) => DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(t.date)).toList());
    }
  }
 //カレンダー改造前の遺物
  /*@override
  Widget build(BuildContext context) {
    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEvent(DateTime day) {
      return _events[day] ?? [];
    }

    return Scaffold(
        appBar: AppBar(
          centerTitle: true, // 中央寄せを設定
          title: Text("Calendar"),
        ),
        body: Column(children: [
          TableCalendar(
            firstDay: DateTime.utc(2022, 4, 1),
            lastDay: DateTime.utc(2025, 12, 31),

            
            eventLoader: getEvent, //追記
            selectedDayPredicate: (day) {
              return isSameDay(_selected, day);
            },
            onDaySelected: (selected, focused) {
              if (!isSameDay(_selected, selected)) {
                setState(() {
                  _selected = selected;
                  _focused = focused;
                });
              }
            },
            focusedDay: _focused,
          ),
          //--追記--------------------------------------------------------------
          ListView(
            shrinkWrap: true,
            children: getEvent(_selected!)
                .map((event) => ListTile(
                      title: Text(event.toString()),
                      textColor: Colors.black,
                    ))
                .toList(),
          )
          //--------------------------------------------------------------------
        ]));
  }*/



 @override
  Widget build(BuildContext context) {
    
    final _events = LinkedHashMap<DateTime, List>(
      equals: isSameDay,
      hashCode: getHashCode,
    )..addAll(_eventsList);

    List getEvent(DateTime day) {
      return _events[day] ?? [];
    }

    Widget _buildEventsMarker(DateTime date, List events) {
  return Positioned(
    right: 5,
    bottom: 5,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red[300],
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    ),
  );
}

    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          centerTitle: true, // 中央寄せを設定
          title: Text("Calendar"),
        ),
        body: Column(children: [
          TableCalendar(
            locale: 'ja_JP',
            firstDay: DateTime.utc(2022, 4, 1),
            lastDay: DateTime.utc(2025, 12, 31),
            calendarFormat: _calendarFormat, 
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            
            eventLoader: getEvent, //追記
            selectedDayPredicate: (day) {
              return isSameDay(_selected, day);
            },
            onDaySelected: (selected, focused) {
              if (!isSameDay(_selected, selected)) {
                setState(() {
                  _selected = selected;
                  _focused = focused;
                });
              }
            },
            focusedDay: _focused,
            calendarBuilders: CalendarBuilders(
        markerBuilder: (context, date, events) {
          if (events.isNotEmpty) {
            return _buildEventsMarker(date, events);
          }
        },
          ),),

ExpandablePanel(
    theme: const ExpandableThemeData(
      headerAlignment: ExpandablePanelHeaderAlignment.center,
      iconColor: Colors.white,
    ),
    header: Padding(
      padding: EdgeInsets.all(10), 
        child: Text('グラフを表示/非表示',
        style: TextStyle(
        fontSize: 12),
        ),
      ),
    collapsed: Container(),
    expanded: BarChartWidget(times: getEvent(_selected!)),
),

        


          //--追記--------------------------------------------------------------
          //予定を表示するやつ
          Expanded(
                 child: ListView(
        children: getEvent(_selected!)
                    .map((time) {
          TimeContainer(time: time);
          //String str = DateFormat('yyyy/MM/dd(E) HH:mm').format(time.date);
          return Dismissible(
            key: Key(DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(time.date)),
            
            child: ListTile(
              title: Text(DateFormat('HH:mm').format(time.date),
              style: TextStyle(
                 fontSize: 30,
                 color: Colors.white),
               ),
              //tileColor: Colors.black,
              //textColor: Colors.white,
            ),
            background: Container(color: Colors.red),
            confirmDismiss: (direction) async {
              // ここで確認を行う
              // Future<bool> で確認結果を返す
              // False の場合削除されない
              return true;
            },
            onDismissed: (direction) async {
              // 削除アニメーションが完了し、リサイズが終了したときに呼ばれる
              setState(() {
                times.removeWhere((t) => t == time);
                eventInit();
                //print(times.length);
              });
              final prefs = await SharedPreferences.getInstance();
                        // データを保存する
                        prefs.setStringList(myKey, times.map((t) => DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(t.date)).toList());
                    },
                  );
                }).toList(),
              ),
            ),
          //--------------------------------------------------------------------
        ],
      ),
      //Text('選択した時刻: ${selectedTime.hour.toString().padLeft(2, "0")}:${selectedTime.minute.toString().padLeft(2, "0")}'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _selectTime(context), // タップ時に実行する処理
        tooltip: 'selectTime',
        child: Icon(Icons.add),
      ),
    );
  }

}


