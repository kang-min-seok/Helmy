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
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Container(
        padding: EdgeInsets.all(8.0),
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
                    title: _dropDown(partName),
                    subtitle: Column(
                      children: exercises[type.id]!.map((exercise) {
                        TextEditingController exerciseNameController =
                            TextEditingController(text: exercise.name);
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '운동 이름',
                                contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                              ),
                              controller: exerciseNameController,
                              onFieldSubmitted: (newName) {},
                            ),
                            const SizedBox(height: 10),
                            ...sets[exercise.id]!.map((set) {
                              TextEditingController weightController =
                                  TextEditingController(
                                      text: set.weight.toString());
                              TextEditingController repsController =
                                  TextEditingController(
                                      text: set.reps.join(", "));
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: '무게',
                                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: weightController,
                                          onFieldSubmitted: (newWeight) {},
                                        ),
                                      ),
                                      const SizedBox(width: 5),
                                      const Text("kg"),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        flex: 7,
                                        child: TextFormField(
                                          decoration: const InputDecoration(
                                            border: OutlineInputBorder(),
                                            hintText: '띄어쓰기로 구분',
                                            contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0),
                                          ),
                                          keyboardType: TextInputType.number,
                                          controller: repsController,
                                          onFieldSubmitted: (newReps) {},
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
                            ListTile(
                              leading: Icon(Icons.add),
                              title: Text('무게 추가'),
                              onTap: () => _addNewSet(exercise.id),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('운동 추가'),
                    onTap: () => _addNewExercise(type.id),
                  ),
                ],
              );
            }).toList(),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('부위 추가'),
              onTap: _addNewEntry,
            ),
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
    var newSet = Set(id: newSetId, weight: '', reps: []);
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

  Widget _dropDown(String partName) {
    return DropdownButton<String>(
      value: _selectedExercises[partName],
      // Use the Map for tracking selected item per partName
      onChanged: (String? newValue) {
        if (newValue != null) {
          // Check for null before assigning
          setState(() {
            _selectedExercises[partName] = newValue;
          });
          // 이 부분에서도 필요한 경우 변경사항을 저장해야 할 수 있습니다.
        }
      },
      items: _exercises
          .map((exercise) => DropdownMenuItem<String>(
                value: exercise,
                child: Text(exercise),
              ))
          .toList(),
    );
  }
}

