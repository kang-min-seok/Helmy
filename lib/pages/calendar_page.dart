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
  final ScrollController _scrollController = ScrollController();
  double _lastScrollOffset = 0;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime nowTime = DateTime.now();

  void loadWorkoutRecords() async {
    final box = await Hive.openBox<WorkoutRecord>('workoutRecords');
    List<WorkoutRecord> records = box.values.toList();
    DateTime today = DateTime(nowTime.year, nowTime.month, nowTime.day);

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
      _selectedDay = today;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = DateTime.now();
    loadWorkoutRecords();
    _scrollController.addListener(_scrollListener);
  }

  // void _scrollListener() {
  //   double currentOffset = _scrollController.offset;
  //   if (currentOffset > _lastScrollOffset + 30 && _calendarFormat != CalendarFormat.twoWeeks) {
  //     // Scroll down
  //     setState(() {
  //       _calendarFormat = CalendarFormat.twoWeeks;
  //     });
  //   } else if (currentOffset < _lastScrollOffset - 30 && _calendarFormat != CalendarFormat.month) {
  //     // Scroll up
  //     setState(() {
  //       _calendarFormat = CalendarFormat.month;
  //     });
  //   }
  //   _lastScrollOffset = currentOffset;
  // }

  void _scrollListener() {
    double currentOffset = _scrollController.offset;

    // Calculate scroll direction and magnitude
    double delta = currentOffset - _lastScrollOffset;
    bool isScrollingDown = delta - 20 > 0 && currentOffset > 100; // Only consider changing format if scrolled significantly down
    bool isScrollingUp = delta + 20 < 0 && currentOffset < _scrollController.position.maxScrollExtent - 100; // Only consider changing format if scrolled significantly up

    if (isScrollingDown && _calendarFormat != CalendarFormat.twoWeeks) {
      // Scroll down - change to two weeks format if not already
      setState(() {
        _calendarFormat = CalendarFormat.twoWeeks;
      });
    } else if (isScrollingUp && _calendarFormat != CalendarFormat.month) {
      // Scroll up - change to month format if not already
      setState(() {
        _calendarFormat = CalendarFormat.month;
      });
    }

    // Update last scroll position
    _lastScrollOffset = currentOffset;
  }
  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    List<WorkoutRecord> selectedRecords = _events[_selectedDay] ?? [];
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.background,
        scrolledUnderElevation: 0,
        title: Text("캘린더",style: Theme.of(context).textTheme.displayLarge),
      ),
      body: Column(
        children: [
          TableCalendar(
            locale: 'ko-KR',
            firstDay: DateTime.utc(2010, 1, 1),
            lastDay: DateTime.utc(2040, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              DateTime selectDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
              setState(() {
                _selectedDay = selectDay;
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
              isTodayHighlighted: false,
              todayTextStyle: TextStyle(color: Theme.of(context).primaryColor),
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
              selectedTextStyle : const TextStyle(color: Colors.white),
              cellMargin: const EdgeInsets.fromLTRB(0, 5, 0, 25),
              cellPadding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
              cellAlignment : Alignment.topCenter,
              markerMargin: const EdgeInsets.only(top: 5),
              markersAlignment : Alignment.bottomCenter,
              markersMaxCount: 1,
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(color: Theme.of(context).primaryColor), // 평일 스타일
            ),
            daysOfWeekHeight: 30,
            rowHeight: 60,
          ),
          Expanded(
              child: selectedRecords.isNotEmpty ? ListView.builder(
                controller: _scrollController,
                itemCount: selectedRecords.length,
                itemBuilder: (context, index) {
                  return WorkoutRecordWidget(
                    key: ValueKey(selectedRecords[index].id),
                    record: selectedRecords[index],
                  );
                },
              ) : Center(
                child: Column(
                  children: [
                    Icon(Icons.hotel, color: Colors.grey ,size: 100),
                    Text(
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 20
                        ),
                        "휴식 데이"
                    )
                  ],
                ),
              )
          ),
        ],
      ),
    );
  }
}
