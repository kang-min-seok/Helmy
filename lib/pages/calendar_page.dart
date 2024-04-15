import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../models/WorkoutRecord.dart';
import 'package:hive/hive.dart';

import 'package:intl/intl.dart';
import './widgets/workout_record_widget.dart';


class CalendarPage extends StatefulWidget {
  const CalendarPage({Key? key}) : super(key: key);

  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;

  Map<DateTime, List<WorkoutRecord>> _events = {};

  void loadWorkoutRecords() async {
    final box = await Hive.openBox<WorkoutRecord>('workoutRecords');
    List<WorkoutRecord> records = box.values.toList();

    Map<DateTime, List<WorkoutRecord>> tempEvents = {};
    for (WorkoutRecord record in records) {
      DateTime date = DateTime.parse(record.date);
      DateTime dateOnly = DateTime(date.year, date.month, date.day); // 시간을 제거

      if (!tempEvents.containsKey(dateOnly)) {
        tempEvents[dateOnly] = [];
      }
      tempEvents[dateOnly]?.add(record);
    }
    setState(() {
      _events = tempEvents;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    loadWorkoutRecords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        title: Text("캘린더",style: Theme.of(context).textTheme.displayLarge),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko-KR',
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2040, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },
            eventLoader: (date) {
              DateTime dateOnly = DateTime(date.year, date.month, date.day);
              return _events[dateOnly] ?? [];
            },
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              leftChevronIcon: Icon(Icons.chevron_left, color: Theme.of(context).primaryColor),
              rightChevronIcon: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
            ),
            calendarStyle : CalendarStyle(
              outsideDaysVisible: false,
              todayDecoration: const BoxDecoration(),
              todayTextStyle: TextStyle(color: Theme.of(context).primaryColor),
              markersAlignment : Alignment.center,
              markersMaxCount: 1,
              markerDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onBackground,
                shape: BoxShape.circle,
              ),
              tableBorder: TableBorder(
                horizontalInside : BorderSide(
                    color: Theme.of(context).colorScheme.onBackground,
                    width: 0.1,
                ),
                borderRadius : BorderRadius.zero,
              ),
              selectedDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary, // 선택된 날짜의 배경색
                shape: BoxShape.circle,

              ),
              selectedTextStyle : TextStyle(color: Theme.of(context).primaryColor),
              cellMargin: const EdgeInsets.fromLTRB(0, 5, 0, 13),
              cellAlignment : Alignment.topCenter,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Theme.of(context).primaryColor), // 평일 스타일
            ),
            daysOfWeekHeight: 30,
          ),
        ],
      ),
    );
  }
}
