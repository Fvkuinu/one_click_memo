import 'package:flutter/material.dart';
import 'package:one_click_memo/screens/click_screen.dart';
import 'package:one_click_memo/screens/calendar_screen.dart';
import 'package:intl/date_symbol_data_local.dart';

 void main() {
   initializeDateFormatting('ja').then((_) =>runApp(const MainApp()));
 }

 class MainApp extends StatelessWidget {
   const MainApp({super.key});

   @override
   Widget build(BuildContext context) {
     return MaterialApp(
       title: 'Click to Memo',  // titleを追加
       /*theme: ThemeData(// themeを追加
         primarySwatch: Colors.blue,
         fontFamily: 'Hiragino Sans',
         appBarTheme: const AppBarTheme(
           backgroundColor: Color(0x000000),
           
         ),
         
         textTheme: Theme.of(context).textTheme.apply(
          //subtitle1: TextStyle(fontSize: 18),
          bodyColor: Colors.white,*/
          theme: ThemeData.dark(),
         
       
      home: const ClickScreen(),// SearchScreenを設定
     );
   }
 }
