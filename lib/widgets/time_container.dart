import 'package:flutter/material.dart';
import 'package:one_click_memo/models/Time.dart';
import 'package:one_click_memo/models/Time.dart';
import 'package:intl/intl.dart';

class TimeContainer extends StatefulWidget {
  const TimeContainer({super.key, required this.time});
  final Time time;

  @override
  State<TimeContainer> createState() => _TimeContainerState();
}
class _TimeContainerState extends State<TimeContainer> {
  
  @override
  Widget build(BuildContext context) {
    final Time time = widget.time;
    return Container(
      padding: const EdgeInsets.symmetric( // ← 内側の余白を指定
        horizontal: 3,
        vertical: 3,
      ),
      

      decoration: const BoxDecoration(
        color: Colors.white, // ← 背景色を指定
      ),

      child: GestureDetector(
        onTap: () {
            print(DateFormat('yyyy/MM/dd(E) HH:mm:ss.SSS').format(time.date));
        },
        child: Text(
            DateFormat('yyyy/MM/dd(E) HH:mm').format(time.date),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.black,
            ),
        ),
      ),
    );
  }
}