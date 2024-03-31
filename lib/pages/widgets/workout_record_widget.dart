import 'package:flutter/material.dart';
import '../../models/WorkoutRecord.dart';
import 'package:hive/hive.dart';

class WorkoutRecordWidget extends StatefulWidget {
  final WorkoutRecord record;

  WorkoutRecordWidget({Key? key, required this.record}) : super(key: key);

  @override
  _WorkoutRecordWidgetState createState() => _WorkoutRecordWidgetState();
}

class _WorkoutRecordWidgetState extends State<WorkoutRecordWidget> {
  Map<String, String> _selectedExercises = {};
  final List<String> _exercises = [
    '하체',
    '가슴',
    '등',
    '어깨',
    '복근',
    '팔',
  ];

  late List<WorkoutType> workoutTypes;
  late Map<int, List<Exercise>> exercises;
  late Map<int, List<Set>> sets;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    workoutTypes = widget.record.workoutTypeIds
        .map((id) => typesBox.get(id))
        .where((type) => type != null)
        .cast<WorkoutType>()
        .toList();

    exercises = {};
    sets = {}; // 'sets' 초기화

    for (var type in workoutTypes) {
      exercises[type.id] = type.exerciseIds
          .map((id) => exercisesBox.get(id))
          .where((exercise) => exercise != null)
          .cast<Exercise>()
          .toList();

      for (var exercise in exercises[type.id]!) {
        sets[exercise.id] = exercise.setIds
            .map((id) => setsBox.get(id))
            .where((set) => set != null)
            .cast<Set>()
            .toList();
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    bool isEdit = widget.record.isEdit;
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: ExpansionTile(
          title: Text(
            widget.record.date,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          initiallyExpanded: true,
          children: [
            ...workoutTypes.map((type) {
              String partName = type.name;
              return Column(
                children: [
                  ListTile(
                    title: isEdit ? _dropDown(partName, type.id) : Text(partName),
                    subtitle: Column(
                      children: exercises[type.id]!.map((exercise) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            isEdit ? TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '운동 이름',
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              ),
                              onFieldSubmitted: (newName) {
                                exercise.name = newName; // Exercise 객체의 name 속성을 새로운 이름으로 업데이트합니다.
                                exercise.save(); // 변경 사항을 Hive 데이터베이스에 저장합니다.
                                print("저장완료: ${exercise.name}");
                              },
                            ) : Text(exercise.name),
                            const SizedBox(height: 10),
                            ...sets[exercise.id]!.map((set) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: isEdit ? TextFormField(
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: '무게',
                                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          ),
                                          keyboardType: TextInputType.number,
                                          onFieldSubmitted: (newWeight) {
                                            var setsBox = Hive.box<Set>('sets');
                                            var updatedSet = setsBox.get(set.id); // 올바른 ID로 Set 객체를 가져옵니다.

                                            if (updatedSet != null && newWeight.isNotEmpty) {
                                              updatedSet.weight = newWeight; // Set 객체의 weight 속성을 새로운 무게로 업데이트합니다.
                                              updatedSet.save(); // 변경 사항을 Hive 데이터베이스에 저장합니다.
                                            }
                                          },
                                        ) : Text(set.weight.toString()),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text("kg"),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 8,
                                        child: Row(
                                          children: List.generate(10, (index) {
                                            var setsBox = Hive.box<Set>('sets');
                                            var updatedSet = setsBox.get(set.id); // 올바른 ID로 Set 객체를 가져옵니다.
                                            if (index % 2 == 1) {
                                              return SizedBox(width: 2);
                                            } else {
                                              int repIndex = index ~/ 2;
                                              return Expanded(
                                                child: isEdit ? TextFormField(
                                                  decoration: const InputDecoration(
                                                    border: OutlineInputBorder(),
                                                    contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                                  ),
                                                  keyboardType: TextInputType.number,
                                                  onFieldSubmitted: (newRep) {
                                                    if (updatedSet != null && newRep.isNotEmpty) {
                                                      // newRep 값이 비어 있지 않을 때만 업데이트
                                                      updatedSet.reps[repIndex] = newRep; // repIndex 위치의 reps 값을 newRep으로 업데이트
                                                      updatedSet.save(); // 변경 사항을 Hive 데이터베이스에 저장합니다.
                                                      print("저장완료: ${updatedSet.reps}");
                                                    }
                                                  },
                                                ) : Text(updatedSet!.reps[repIndex]),
                                              );
                                            }
                                          }),
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text("회"),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                ],
                              );
                            }).toList(),
                            isEdit ? ListTile(
                              leading: Icon(Icons.add),
                              title: Text('무게 추가'),
                              onTap: () => _addNewSet(exercise.id),
                            ) : Container(),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isEdit ? ListTile(
                    leading: Icon(Icons.add),
                    title: Text('운동 추가'),
                    onTap: () => _addNewExercise(type.id),
                  ) : Container(),
                ],
              );
            }).toList(),
            isEdit ? ListTile(
              leading: Icon(Icons.add),
              title: Text('부위 추가'),
              onTap: _addNewEntry,
            ) : Container(),
            isEdit ? Container(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.record.isEdit = false; // isEdit 값을 false로 설정합니다.
                  });
                  widget.record.save();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff0a46ff),
                  foregroundColor: Colors.white,
                ),
                child: Text('작성 완료'),
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewEntry() async {
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    // 새 WorkoutType 추가
    var newWorkoutTypeId =
        typesBox.values.isNotEmpty ? typesBox.values.last.id + 1 : 0;
    var newWorkoutType =
        WorkoutType(id: newWorkoutTypeId, name: '', exerciseIds: []);
    await typesBox.put(newWorkoutTypeId, newWorkoutType);

    // 새 Exercise 추가
    var newExerciseId =
        exercisesBox.values.isNotEmpty ? exercisesBox.values.last.id + 1 : 0;
    var newExercise = Exercise(id: newExerciseId, name: '', setIds: []);
    await exercisesBox.put(newExerciseId, newExercise);

    // 새 Set 추가
    var newSetId = setsBox.values.isNotEmpty ? setsBox.values.last.id + 1 : 0;
    var newSet = Set(id: newSetId, weight: '', reps: ['','','','','']);
    await setsBox.put(newSetId, newSet);

    // 연결된 IDs 업데이트
    newExercise.setIds.add(newSetId);
    await exercisesBox.put(newExerciseId, newExercise); // 업데이트된 Exercise 저장

    newWorkoutType.exerciseIds.add(newExerciseId);
    await typesBox.put(
        newWorkoutTypeId, newWorkoutType); // 업데이트된 WorkoutType 저장

    // WorkoutRecord에 WorkoutType ID 추가
    widget.record.workoutTypeIds.add(newWorkoutTypeId);
    await widget.record.save(); // 변경사항 저장

    print(typesBox.values);
    print(exercisesBox.values);
    print(setsBox.values);

    _loadData(); // UI 갱신
  }

  Future<void> _addNewExercise(int workoutTypeId) async {
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    var workoutType = typesBox.get(workoutTypeId);
    if (workoutType == null) {
      print("WorkoutType with id $workoutTypeId not found");
      return;
    }

    // 새 Exercise 추가
    var newExerciseId =
        exercisesBox.values.isNotEmpty ? exercisesBox.values.last.id + 1 : 0;
    var newExercise = Exercise(id: newExerciseId, name: '', setIds: []);
    await exercisesBox.put(newExerciseId, newExercise);

    // 새 Set 추가
    var newSetId = setsBox.values.isNotEmpty ? setsBox.values.last.id + 1 : 0;
    var newSet = Set(id: newSetId, weight: '', reps: []);
    await setsBox.put(newSetId, newSet);

    // 연결된 IDs 업데이트
    newExercise.setIds.add(newSetId);
    await exercisesBox.put(newExerciseId, newExercise); // 업데이트된 Exercise 저장

    workoutType.exerciseIds.add(newExerciseId);
    await typesBox.put(workoutTypeId, workoutType); // 업데이트된 WorkoutType 저장

    print("Exercise and Set added to WorkoutType with id $workoutTypeId");

    _loadData(); // UI 갱신
  }

  Future<void> _addNewSet(int exerciseId) async {
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    var exercise = exercisesBox.get(exerciseId);
    if (exercise == null) {
      print("Exercise with id $exerciseId not found");
      return;
    }

    // 새 Set 추가
    var newSetId = setsBox.values.isNotEmpty ? setsBox.values.last.id + 1 : 0;
    var newSet = Set(id: newSetId, weight: '', reps: []);
    await setsBox.put(newSetId, newSet);

    // 연결된 IDs 업데이트
    exercise.setIds.add(newSetId);
    await exercisesBox.put(exerciseId, exercise); // 업데이트된 Exercise 저장

    print("Set added to Exercise with id $exerciseId");

    _loadData(); // UI 갱신
  }

  Widget _dropDown(String partName, int typeID) {
    var workoutTypeBox = Hive.box<WorkoutType>('workoutTypes');
    var workoutType = workoutTypeBox.get(typeID);

    String? dropdownValue = workoutType?.name.isNotEmpty ?? false ? workoutType?.name : null;

    List<String> dropdownItems = ['부위 선택'] + _exercises;
    if (!dropdownItems.contains(dropdownValue)) {
      dropdownValue = '부위 선택';
    }

    return DropdownButton<String>(
      value: dropdownValue,
      onChanged: (String? newValue) {
        if (newValue != null && newValue != '부위 선택') {
          setState(() {
            _selectedExercises[partName] = newValue;
            if (workoutType != null) {
              workoutType.name = newValue;
              workoutType.save();
            }
          });
        }
      },
      items: dropdownItems.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }



}

