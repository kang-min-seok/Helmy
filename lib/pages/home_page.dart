import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import '../models/WorkoutRecord.dart';
import './widgets/workout_record_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  List<WorkoutRecord> workoutRecords = [];
  int _selectedIndex = 0;
  List<String> tabs = ['전체','하체', '가슴', '등', '어깨', '복근', '팔'];
  bool dataLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!dataLoaded) {
      _loadData();
      dataLoaded = true;
    }
  }

  Future<void> _loadData() async {
    var recordsBox = Hive.box<WorkoutRecord>('workoutRecords');
    var typesBox = Hive.box<WorkoutType>('workoutTypes');

    List<WorkoutRecord> allRecords = recordsBox.values.toList();
    List<WorkoutType> allTypes = typesBox.values.toList();

    allRecords.sort((a, b) {
      DateTime dateA = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(a.date);
      DateTime dateB = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(b.date);
      return dateB.compareTo(dateA);
    });

    List<int> selectedTypeIds = []; // 유형의 ID를 저장할 리스트
    if (_selectedIndex != 0) {
      String selectedTypeName = tabs[_selectedIndex];
      // 선택된 탭에 해당하는 모든 유형을 찾아 selectedTypeIds에 추가
      selectedTypeIds = allTypes.where((type) => type.name == selectedTypeName).map((type) => type.id).toList();

      // 선택된 유형 ID에 해당하는 모든 운동 기록을 필터링
      workoutRecords = allRecords.where((record) {
        return record.isEdit || (selectedTypeIds.isNotEmpty && record.workoutTypeIds.any((id) => selectedTypeIds.contains(id)));
      }).toList();
    } else {
      workoutRecords = allRecords;
    }



    setState(() {});
  }

  Future<void> _addNewData() async {
    var recordsBox = Hive.box<WorkoutRecord>('workoutRecords');
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    final newId =
        recordsBox.values.isNotEmpty ? recordsBox.values.last.id + 1 : 1;
    final todayDate = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(DateTime.now());

    // 새로운 WorkoutType, Exercise, Set 생성
    final newWorkoutTypeId =
        typesBox.values.isNotEmpty ? typesBox.values.last.id + 1 : 0;
    final newExerciseId =
        exercisesBox.values.isNotEmpty ? exercisesBox.values.last.id + 1 : 0;
    final newSetId = setsBox.values.isNotEmpty ? setsBox.values.last.id + 1 : 0;

    final newSet = Set(id: newSetId, weight: '', reps: ['', '', '', '', '']);
    final newExercise =
        Exercise(id: newExerciseId, name: '', setIds: [newSetId]);
    final newWorkoutType = WorkoutType(
        id: newWorkoutTypeId, name: '', exerciseIds: [newExerciseId]);

    // 각 객체를 Hive에 저장
    await setsBox.put(newSetId, newSet);
    await exercisesBox.put(newExerciseId, newExercise);
    await typesBox.put(newWorkoutTypeId, newWorkoutType);

    // WorkoutRecord 생성 및 저장
    final newRecord = WorkoutRecord(
      id: newId,
      date: todayDate,
      workoutTypeIds: [newWorkoutTypeId],
      isEdit: true,
    );
    await recordsBox.add(newRecord);

    _loadData();
  }

  Future<void> deleteWorkoutRecord(WorkoutRecord record) async {
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    // 각 WorkoutType에 대해 연관된 Exercise들을 삭제합니다.
    for (var typeId in record.workoutTypeIds) {
      var workoutType = typesBox.get(typeId);
      if (workoutType != null) {
        for (var exerciseId in workoutType.exerciseIds) {
          var exercise = exercisesBox.get(exerciseId);
          if (exercise != null) {
            // 각 Exercise에 대해 연관된 Set들을 삭제합니다.
            for (var setId in exercise.setIds) {
              setsBox.delete(setId);
            }
            // Exercise 객체를 삭제합니다.
            exercisesBox.delete(exerciseId);
          }
        }
        // WorkoutType 객체를 삭제합니다.
        typesBox.delete(typeId);
      }
    }

    await record.delete();
    setState(() {
      workoutRecords.removeWhere((item) => item.id == record.id);
    });
    await Hive.box<WorkoutRecord>('workoutRecords').compact();
  }

  Future<void> _selectDate(BuildContext context, WorkoutRecord record) async {
    DateTime initialDate = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(record.date);

    // Use showDatePicker to pick a new date.
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light(), // Customize the theme as needed.
          child: child!,
        );
      },
    );

    // If the user has picked a date, update the record's date.
    if (pickedDate != null && pickedDate != initialDate) {
      // Keep the current time parts (hours, minutes, seconds, and milliseconds).
      DateTime now = DateTime.now();
      DateTime updatedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        now.hour,
        now.minute,
        now.second,
        now.millisecond,
      );

      setState(() {
        // Format the updated date-time and update the record.
        record.date = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(updatedDateTime);
        record.save();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: true,
                scrolledUnderElevation: 0,
                collapsedHeight: 115,
                flexibleSpace: FlexibleSpaceBar(
                    centerTitle: true,
                    collapseMode: CollapseMode.pin,
                    titlePadding: EdgeInsets.zero,
                    title: Container(
                        height: 115,
                        padding: EdgeInsets.only(top: 15),
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text("운동기록",style: Theme.of(context).textTheme.displayLarge),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: List.generate(tabs.length, (index) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                        foregroundColor: _selectedIndex == index ? Colors.white : Theme.of(context).primaryColor,
                                        backgroundColor: _selectedIndex == index ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        elevation: 0,
                                      ),
                                      child: Text(tabs[index]),
                                      onPressed: () {
                                        setState(() {
                                          _selectedIndex = index;
                                          _loadData();
                                        });
                                      },
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ],
                        ),
                      ),


                ),
                backgroundColor: Theme.of(context).colorScheme.background,
              ),
              workoutRecords.isEmpty
                  ? SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center, size: 70, color: Colors.grey),
                      SizedBox(height: 20,),
                      Text('추가된 운동 기록이 없습니다.', style: TextStyle(fontSize: 20, color: Colors.grey)),
                    ],
                  ),
                ),
              )
                  : SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    if (index >= workoutRecords.length) return const SizedBox.shrink();
                    final record = workoutRecords[index];
                    return GestureDetector(
                      onLongPress: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            List<Widget> menuItems = record.isEdit
                                ? [
                              ListTile(
                                leading: const Icon(Icons.date_range),
                                title: const Text('날짜 변경하기'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  _selectDate(context, record);
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('삭제하기'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  deleteWorkoutRecord(record);
                                },
                              ),
                            ]
                                : [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('수정하기'),
                                onTap: () {
                                  setState(() {
                                    record.isEdit = true;
                                    record.save();
                                  });
                                  Navigator.of(context).pop();
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.delete),
                                title: const Text('삭제하기'),
                                onTap: () {
                                  Navigator.of(context).pop();
                                  deleteWorkoutRecord(record);
                                },
                              ),
                            ];
                            return SafeArea(
                              child: Wrap(
                                children: menuItems,
                              ),
                            );
                          },
                        );
                      },
                      child: WorkoutRecordWidget(
                        key: ValueKey(record.id),
                        record: record,
                      ),
                    );
                  },
                  childCount: workoutRecords.isEmpty ? 1 : workoutRecords.length,
                ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _addNewData,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        ),
    );
  }
}
