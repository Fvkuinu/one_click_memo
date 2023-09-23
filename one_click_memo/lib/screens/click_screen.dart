import 'package:flutter/material.dart';
import 'package:one_click_memo/models/Time.dart';
import 'package:one_click_memo/widgets/time_container.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:one_click_memo/screens/calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

const myKey = 'my_string_list';
bool darkMode = true;
class ClickScreen extends StatefulWidget {
  const ClickScreen({super.key});

  @override
  State<ClickScreen> createState() => _ClickScreenState();
}

class _ClickScreenState extends State<ClickScreen> {
  List<Time> times = []; //時刻を保存する配列

  @override
  void initState() {
    super.initState();
    init();
  }

  // アプリ起動時に保存したデータを読み込む
  void init() async {
    print(222);
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      List<String> timesStringList = prefs.getStringList(myKey) ?? [];
      for(int i = 0; i < timesStringList.length; i++){
        times.add(Time(date: stringToDateTime(timesStringList[i])));
      }
      //timesStringList.map((s) => times.add(Time(date: stringToDateTime(s))));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      backgroundColor: Colors.black,
      appBar: AppBar( //アプリのバー
        centerTitle: true, // 中央寄せを設定
        backgroundColor: Colors.black,
        title: const Text('メモ'),
      ),
      
      body: Center( //中央に揃える
        child: Column( //縦に続けて置くためのもの
            children: [
                // 空白を指定
                Padding(
                    padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    //horizontal: 36,
                ),
                // ボタンを作成
                child: SizedBox(
                  width: 120, //横幅
                  height: 120, //高さ
                child: ElevatedButton(
                        child: const Text(
                            '追加', 
                            style: TextStyle(
                            fontSize: 24 /*サイズ*/,
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
                      onPressed: () async {//ボタンが押された時の処理
                        setState(() {//buildを実行させるための関数
                            times.add(Time(date: DateTime.now()));
                        });
                        final prefs = await SharedPreferences.getInstance();
                        // データを保存する
                        prefs.setStringList(myKey, times.map((t) => DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(t.date)).toList());                       
                        
                        List<String> timesStringList = prefs.getStringList(myKey) ?? [];
                        print(stringToDateTime(timesStringList[0]));
                        print(DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(stringToDateTime(timesStringList[0])));
      //timesStringList.map((s) => times.add(Time(date: stringToDateTime(s))));
                      },
                    ),
                  ),
                ),



                Padding(
                    padding: const EdgeInsets.symmetric(
                    vertical: 30,
                    //horizontal: 36,
                ),
                // ボタンを作成
                child: SizedBox(
                  width: 200, //横幅
                  height: 50, //高さ
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
                      onPressed: ()  {//ボタンが押された時の処理
                        Navigator.of(context).push(
                          MaterialPageRoute( 
                            builder: ((context) => CalendarScreen(times: times)),
                          ),
                        ).then((value) {
                            setState(() {//buildを実行させるための関数
                              //times.add(Time(date: DateTime.now()));
                          });
                        });
                      },
                    ),
                  ),
                ),


              
                //時間のリスト表示を作成
              /*Expanded(
                child: ListView(
                    children: List.from(times.reversed)
                        .map((time) => TimeContainer(time: time))
                        .toList(),
                ),
              ),*/


                //時間のリスト表示を作成
              /*Expanded(
                child: ListView(
                    children: List.from(times.reversed)
                        .map((time) => TimeContainer(time: time))
                        .toList(),
                ),
              ),*/
                
        Expanded(
                 child: ListView(
        children: List.from(times.reversed).map((time) {
          TimeContainer(time: time);
          //String str = DateFormat('yyyy/MM/dd(E) HH:mm').format(time.date);
          return Dismissible(
            key: Key(DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(time.date)),
            
            child: ListTile(
              
              title: Text(getString(time.date),
               style: TextStyle(
                 fontSize: 24,
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
    
          ],
        ),
      ),
      /*floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: FloatingActionButton(  
        onPressed: () {
          setState(() {
                darkMode = (darkMode) ? false : true;
              });
          
        }, // タップ時に実行する処理
        tooltip: 'selectDarkmode',
        child: Icon(Icons.dark_mode),
      ),*/
    );
  }

  String getString(DateTime time){
    locale: const Locale("ja");
    initializeDateFormatting("ja");
    return DateFormat.yMMMd('ja').format(time).toString()+
	    //ここをEEEEからEにしただけ！
        '(${DateFormat.E('ja').format(time)})'+' '+
        time.hour.toString()+'時'+time.minute.toString()+'分';
  }
  DateTime stringToDateTime(String datetimeStr){
    
     var _dateFormatter = DateFormat("yyyy/MM/dd(E) HH:mm:ss.SSS");

  // String→DateTime変換
  
    DateTime result = DateTime(1970,1,1);

    // String→DateTime変換
    try {
      result = _dateFormatter.parseStrict(datetimeStr);
      // (補足)
      // parseStrict()を使うのが大事。
      // parse()だと存在しない日付がいい感じ(?)に計算されて変換された
      // 例)2020/9/32を入れた場合
      // _dateFormatter.parseStrict("2020/9/32"); // 結果→Exception
      // _dateFormatter.parse("2020/9/32"); // 結果→2020/10/2のDateTimeに変換

    } catch(e){
      // 変換に失敗した場合の処理
      
    }
    //print(DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(result));
    return result;
  }
  
  
}


