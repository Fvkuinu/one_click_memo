import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:one_click_memo/models/Time.dart';
import 'package:flutter/src/widgets/framework.dart';


class BarChartWidget extends StatefulWidget {
  const BarChartWidget({super.key, required this.times});
  final List times;
  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {

  // 棒グラフの棒の横幅
  static const double barWidth = 20.0;

  // グラフタイトルのラベル書式
  final TextStyle _labelStyle = const TextStyle(fontSize: 16, fontWeight: FontWeight.w800);

  // ダミーデータ
  List createTimeLog(List times){
        var timeLog = <double>[0,0,0,0,0,0,0,0,0,0,0,0];
        for(int i = 0; i < times.length; i++){
            timeLog[(times[i].date.hour/2).toInt()] += 1;
        }
        return timeLog;
    }
  final blogLog = <double>[11, 17, 10, 6, 5, 3, 5, 3, 4, 3, 16, 15];
  

  @override
  Widget build(BuildContext context) {
    final timeLog = createTimeLog(widget.times);
    return AspectRatio(
      aspectRatio: 2,
      child: BarChart(
        BarChartData(maxY: 6, //Y軸の最大値を指定

            // 棒グラフの位置
            alignment: BarChartAlignment.spaceEvenly,

            // 棒グラフタッチ時の動作設定
            barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.black,
                )
            ),

            // グラフタイトルのパラメータ
            titlesData: FlTitlesData(
              show: true,
              //右タイトル
              rightTitles:AxisTitles(
                  sideTitles: SideTitles(showTitles: false)
              ),
              //上タイトル
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              //下タイトル
              bottomTitles: AxisTitles(
                //axisNameWidget: Text('ブログ運営年月',style: _labelStyle,),
                axisNameSize: 40,
                sideTitles: SideTitles(
                  showTitles: true,
                ),
              ),
              // 左タイトル
              leftTitles: AxisTitles(
                axisNameWidget: Container(
                    alignment: Alignment.topCenter,
                    //child: Text('記事数',style: _labelStyle,)
                    ),
                axisNameSize: 0,
                sideTitles: SideTitles(
                  showTitles: false,
                ),
              ),
            ),

            // 外枠表の線を表示/非表示
            borderData: FlBorderData(
                border: const Border(
                  top: BorderSide.none,
                  right: BorderSide.none,
                  //left: BorderSide(width: 1),
                  //bottom: BorderSide(width: 1),
                )),


            // barGroups: 棒グラフのグループを表す
            // BarChartGroupData: 棒グラフの1つのグループを表す
            // X : 横軸
            // barRods: 棒グラフのデータを含むBarRodクラスのリスト
            // BarChartRodData
            // toY : 高さ
            // width : 棒の幅
            barGroups: [

              BarChartGroupData(x: 0, barRods: [
                BarChartRodData(toY: timeLog[0], width: barWidth),
              ]),
              BarChartGroupData(x: 2, barRods: [
                BarChartRodData(toY: timeLog[1], width: barWidth),
              ]),
              BarChartGroupData(x: 4, barRods: [
                BarChartRodData(toY: timeLog[2], width: barWidth),
              ]),
              BarChartGroupData(x: 6, barRods: [
                BarChartRodData(toY: timeLog[3], width: barWidth),
              ]),
              BarChartGroupData(x: 8, barRods: [
                BarChartRodData(toY: timeLog[4], width: barWidth),
              ]),
              BarChartGroupData(x: 10, barRods: [
                BarChartRodData(toY: timeLog[5], width: barWidth),
              ]),
              BarChartGroupData(x: 12, barRods: [
                BarChartRodData(toY: timeLog[6], width: barWidth),
              ]),
              BarChartGroupData(x: 14, barRods: [
                BarChartRodData(toY: timeLog[7], width: barWidth),
              ]),
              BarChartGroupData(x: 16, barRods: [
                BarChartRodData(toY: timeLog[8], width: barWidth),
              ]),
              BarChartGroupData(x: 18, barRods: [
                BarChartRodData(toY: timeLog[9], width: barWidth),
              ]),
              BarChartGroupData(x: 20, barRods: [
                BarChartRodData(toY: timeLog[10], width: barWidth),
              ]),
              BarChartGroupData(x: 22, barRods: [
                BarChartRodData(toY: timeLog[11], width: barWidth),
              ]),
              
            ]),
      ),
    );
  }
}