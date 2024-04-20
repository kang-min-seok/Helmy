import 'package:flutter/material.dart';
import '../../models/WorkoutRecord.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

class WorkoutRecordWidget extends StatefulWidget {
  final WorkoutRecord record;

  WorkoutRecordWidget({Key? key, required this.record}) : super(key: key);

  @override
  _WorkoutRecordWidgetState createState() => _WorkoutRecordWidgetState();
}

class _WorkoutRecordWidgetState extends State<WorkoutRecordWidget>
    with WidgetsBindingObserver {
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

  late Map<int, WorkoutType> tempWorkoutTypes;
  late Map<int, List<Exercise>> tempExercises;
  late Map<int, List<Set>> tempSets;


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        if (widget.record.isEdit) {
          saveTempDataToHive();
        }
        break;
      default:
        break;
    }
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

    tempWorkoutTypes = {};
    for (var id in widget.record.workoutTypeIds) {
      WorkoutType? workoutType = typesBox.get(id);
      if (workoutType != null) {
        tempWorkoutTypes[workoutType.id] = workoutType;
      }
    }

    exercises = {};
    sets = {};

    tempExercises = {};
    tempSets = {};

    for (var type in workoutTypes) {
      exercises[type.id] = type.exerciseIds
          .map((id) => exercisesBox.get(id))
          .where((exercise) => exercise != null)
          .cast<Exercise>()
          .toList();

      tempExercises[type.id] = type.exerciseIds
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
        tempSets[exercise.id] = exercise.setIds
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

    String displayDate = DateFormat('yyyy-MM-dd').format(
      DateFormat('yyyy-MM-dd HH:mm:ss.SSS').parse(widget.record.date),
    );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(2.0),
        child: ExpansionTile(
          title: Text(
            displayDate,
            style: const TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          initiallyExpanded: true,
          children: [
            ...List.generate(
            workoutTypes.length, (typesIndex) {
              WorkoutType type = workoutTypes[typesIndex];
              String partName = type.name;
              return Column(
                children: [
                  ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                    title:
                    isEdit ? Row(
                    children: [
                      _dropDown(partName, type.id),
                      const Spacer(),
                      if(typesIndex != 0)
                        IconButton(
                            onPressed: (){
                              _deleteWorkoutType(type.id);
                            },
                            icon: const Icon(Icons.delete))
                      ]
                    )
                        : Container(
                      margin: const EdgeInsets.fromLTRB(0, 0, 0, 10.0),
                      child: Text(
                          partName,
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ),
                    subtitle: Column(
                      children: List.generate(
                          exercises[type.id]!.length, (exerciseIndex) {
                        Exercise exercise = exercises[type.id]![exerciseIndex];
                        TextEditingController nameController = TextEditingController(
                            text: exercise.name);
                        DismissDirection dismissDirection = exercises[type.id]!.length <= 1
                            ? DismissDirection.none
                            : DismissDirection.endToStart;
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
                          title: isEdit
                              ? Dismissible(
                            key: UniqueKey(),
                            direction: dismissDirection,
                            onDismissed: (direction) {
                              if (direction ==
                                  DismissDirection.endToStart) {
                                _deleteExercise(exercise.id, type.id);
                              }
                            },
                            background: Container(
                              padding: const EdgeInsets.all(5.0),
                              color: Colors.red,
                              alignment: Alignment.centerRight,
                              child: const Icon(
                                Icons.delete,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                            child: TextFormField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '운동 이름',
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 10.0),
                                  ),
                                  controller: nameController,
                                  onChanged: (text) {
                                    tempExercises[type.id]?[exerciseIndex].name =
                                        text;
                                  },
                                  onTapOutside: (event) {
                                    FocusManager.instance.primaryFocus?.unfocus();
                                  },
                                ),
                          )

                              : Container(
                            padding: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                            child: Text(
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                ),
                                exercise.name),
                          ),
                          subtitle: Column(
                            children: [

                              const SizedBox(height: 10),
                              ...List.generate(
                                  sets[exercise.id]!.length, (setsIndex) {
                                Set set = sets[exercise.id]![setsIndex];
                                TextEditingController weightController = TextEditingController(
                                    text: set.weight.toString());
                                Map<int, List<TextEditingController>> repsControllers = {};
                                var controllers = repsControllers.putIfAbsent(
                                  set.id,
                                      () => set.reps.map((rep) => TextEditingController(text: rep)).toList(),
                                );
                                DismissDirection dismissDirection = sets[exercise.id]!.length <= 1
                                    ? DismissDirection.none
                                    : DismissDirection.endToStart;
                                return Dismissible(
                                    key: UniqueKey(),
                                    direction: dismissDirection,
                                    onDismissed: (direction) {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        var controllersToRemove = repsControllers.remove(set.id);
                                        controllersToRemove?.forEach((controller) => controller.dispose());
                                        weightController.dispose();
                                        setState(() {
                                          sets[exercise.id]!.removeAt(setsIndex);
                                        });
                                        _deleteSet(set.id, exercise.id);
                                      }
                                    },
                                    background: Container(
                                      padding: const EdgeInsets.all(5.0),
                                      color: Colors.red,
                                      alignment: Alignment.centerRight,
                                      child: const Icon(
                                        Icons.delete,
                                        size: 36,
                                        color: Colors.white,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment
                                          .start,
                                      children: [
                                        Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              flex: 3,
                                              child: isEdit ? Row(
                                                children: [
                                                  Expanded(
                                                    flex: 1,
                                                    child: TextFormField(
                                                      decoration: const InputDecoration(
                                                        border: OutlineInputBorder(),
                                                        hintText: '무게',
                                                        contentPadding: EdgeInsets
                                                            .symmetric(
                                                            vertical: 10.0,
                                                            horizontal: 10.0),
                                                      ),
                                                      controller: weightController,
                                                      onChanged: (text) {
                                                        tempSets[exercise
                                                            .id]?[setsIndex]
                                                            .weight = text;
                                                      },
                                                      onTapOutside: (event) {
                                                        FocusManager.instance
                                                            .primaryFocus
                                                            ?.unfocus();
                                                      },
                                                      keyboardType: TextInputType
                                                          .number,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Text("kg",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      )
                                                  ),
                                                ],
                                              ) : Row(
                                                children: [
                                                  Text(set.weight.toString(),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                      )
                                                  ),
                                                  const SizedBox(width: 5),
                                                  const Text("kg",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                      )
                                                  ),
                                                ],
                                              ),
                                            ),

                                            const SizedBox(width: 10),
                                            Expanded(
                                              flex: 8,
                                              child: Row(
                                                children: [
                                                  isEdit
                                                      ? const SizedBox()
                                                      : const Expanded(
                                                      child: SizedBox()),
                                                  ...List.generate(
                                                      10, (repIndex) {
                                                    var setsBox = Hive.box<Set>(
                                                        'sets');
                                                    var updatedSet = setsBox.get(
                                                        set.id);

                                                    if (repIndex % 2 == 1) {
                                                      if (isEdit) {
                                                        return const SizedBox(
                                                            width: 2);
                                                      } else {
                                                        return const SizedBox(
                                                            width: 15);
                                                      }
                                                    } else {
                                                      int repEditIndex = repIndex ~/
                                                          2;
                                                      if (isEdit) {
                                                        // TextEditingController setController = TextEditingController(
                                                        //     text: updatedSet!
                                                        //         .reps[repEditIndex]);
                                                        return Expanded(
                                                          child: TextFormField(
                                                            decoration: const InputDecoration(
                                                              border: OutlineInputBorder(),
                                                              contentPadding: EdgeInsets
                                                                  .symmetric(
                                                                  vertical: 10.0,
                                                                  horizontal: 10.0),
                                                            ),
                                                            controller: controllers[repEditIndex],
                                                            onChanged: (text) {
                                                              tempSets[exercise
                                                                  .id]?[setsIndex]
                                                                  .reps[repEditIndex] =
                                                                  text;
                                                            },
                                                            keyboardType: TextInputType
                                                                .number,
                                                            onTapOutside: (
                                                                event) {
                                                              FocusManager
                                                                  .instance
                                                                  .primaryFocus
                                                                  ?.unfocus();
                                                            },
                                                          ),
                                                        );
                                                      } else {
                                                        return Expanded(
                                                          flex: 1,
                                                          child:
                                                            Text(updatedSet!.reps[repEditIndex],
                                                                style: const TextStyle(
                                                                  fontSize: 15,
                                                                )
                                                            ),
                                                        );
                                                      }
                                                    }
                                                  }),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            const Text("회",
                                                style: TextStyle(
                                                  fontSize: 15,
                                                )
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 5),
                                      ],
                                    )
                                );
                              }).toList(),
                              isEdit
                                  ? ListTile(
                                leading: const Icon(Icons.add),
                                title: const Text('무게 추가'),
                                onTap: () => _addNewSet(exercise.id),
                              )
                                  : Container(),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  isEdit
                      ? ListTile(
                    leading: const Icon(Icons.add),
                    title: const Text('운동 추가'),
                    onTap: () => _addNewExercise(type.id),
                  )
                      : Container(),
                ],
              );
            }).toList(),
            isEdit
                ? ListTile(
              leading: const Icon(Icons.add),
              title: const Text('부위 추가'),
              onTap: _addNewType,
            )
                : Container(),
            isEdit
                ? Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    widget.record.isEdit = false;
                  });
                  saveTempDataToHive();
                  widget.record.save();
                },
                child: const Text('작성 완료'),
              ),
            )
                : Container(),
          ],
        ),
      ),
    );
  }

  Future<void> _addNewType() async {
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    // 새 WorkoutType 추가
    var newWorkoutTypeId =
    typesBox.values.isNotEmpty ? typesBox.values.last.id + 1 : 0;
    var newWorkoutType =
    WorkoutType(id: newWorkoutTypeId, name: '', exerciseIds: []);
    await typesBox.put(newWorkoutTypeId, newWorkoutType);
    // 임시 WorkoutType 추가
    tempWorkoutTypes[newWorkoutType.id] = newWorkoutType;

    // 새 Exercise 추가
    var newExerciseId =
    exercisesBox.values.isNotEmpty ? exercisesBox.values.last.id + 1 : 0;
    var newExercise = Exercise(id: newExerciseId, name: '', setIds: []);
    await exercisesBox.put(newExerciseId, newExercise);
    // 임시 Exercise 추가
    if (tempExercises.containsKey(newWorkoutType.id)) {
      tempExercises[newWorkoutType.id]!.add(newExercise);
    } else {
      tempExercises[newWorkoutType.id] = [newExercise];
    }

    // 새 Set 추가
    var newSetId = setsBox.values.isNotEmpty ? setsBox.values.last.id + 1 : 0;
    var newSet = Set(id: newSetId, weight: '', reps: ['', '', '', '', '']);
    await setsBox.put(newSetId, newSet);
    // 임시 Set 추가
    if (tempSets.containsKey(newExercise.id)) {
      tempSets[newExercise.id]!.add(newSet);
    } else {
      tempSets[newExercise.id] = [newSet];
    }

    // 연결된 IDs 업데이트
    newExercise.setIds.add(newSetId);
    await exercisesBox.put(newExerciseId, newExercise);

    newWorkoutType.exerciseIds.add(newExerciseId);
    await typesBox.put(newWorkoutTypeId, newWorkoutType);

    // WorkoutRecord에 WorkoutType ID 추가
    widget.record.workoutTypeIds.add(newWorkoutTypeId);
    await widget.record.save(); // 변경사항 저장

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

    // 임시 Exercise 추가
    if (tempExercises.containsKey(workoutTypeId)) {
      tempExercises[workoutTypeId]!.add(newExercise);
    } else {
      tempExercises[workoutTypeId] = [newExercise];
    }

    // 새 Set 추가
    var newSetId = setsBox.values.isNotEmpty ? setsBox.values.last.id + 1 : 0;
    var newSet = Set(id: newSetId, weight: '', reps: ['', '', '', '', '']);
    await setsBox.put(newSetId, newSet);
    // 임시 Set 추가
    if (tempSets.containsKey(newExercise.id)) {
      tempSets[newExercise.id]!.add(newSet);
    } else {
      tempSets[newExercise.id] = [newSet];
    }


    // 연결된 IDs 업데이트
    newExercise.setIds.add(newSetId);
    await exercisesBox.put(newExerciseId, newExercise); // 업데이트된 Exercise 저장

    workoutType.exerciseIds.add(newExerciseId);
    await typesBox.put(workoutTypeId, workoutType); // 업데이트된 WorkoutType 저장

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
    var newSet = Set(id: newSetId, weight: '', reps: ['', '', '', '', '']);
    await setsBox.put(newSetId, newSet);
    // 임시 Set 추가
    if (tempSets.containsKey(exerciseId)) {
      tempSets[exerciseId]!.add(newSet);
    } else {
      tempSets[exerciseId] = [newSet];
    }

    // 연결된 IDs 업데이트
    exercise.setIds.add(newSetId);
    await exercisesBox.put(exerciseId, exercise); // 업데이트된 Exercise 저장

    _loadData(); // UI 갱신
  }

  Future<void> _deleteSet(int setId, int exerciseId) async {
    var setsBox = Hive.box<Set>('sets');
    var exercisesBox = Hive.box<Exercise>('exercises');

    // Set을 Hive box에서 삭제
    await setsBox.delete(setId);

    // 연결된 Exercise 객체의 setIds 리스트에서 setId 제거
    var exercise = exercisesBox.get(exerciseId);
    if (exercise != null) {
      exercise.setIds.remove(setId);
      await exercisesBox.put(exerciseId, exercise); // 변경사항을 저장합니다.
    }

    // 임시 데이터에서도 setId를 제거
    if (tempSets.containsKey(exerciseId)) {
      tempSets[exerciseId]!.removeWhere((set) => set.id == setId);
    }

  }

  Future<void> _deleteExercise(int exerciseId, int workoutTypeId) async {
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');
    var typesBox = Hive.box<WorkoutType>('workoutTypes');

    var exercise = exercisesBox.get(exerciseId);
    if (exercise == null) {
      print("Exercise with id $exerciseId not found");
      return;
    }

    // 우선 연결된 모든 Set 데이터를 삭제합니다.
    for (var setId in exercise.setIds) {
      await setsBox.delete(setId);
      tempSets.remove(setId); // tempSets에서도 삭제합니다.
    }

    // Exercise 데이터를 Hive box에서 삭제합니다.
    await exercisesBox.delete(exerciseId);
    tempExercises[workoutTypeId]?.removeWhere((ex) => ex.id == exerciseId); // tempExercises에서도 삭제합니다.

    // WorkoutType에서도 연결된 Exercise ID를 제거합니다.
    var workoutType = typesBox.get(workoutTypeId);
    if (workoutType != null) {
      workoutType.exerciseIds.remove(exerciseId);
      await typesBox.put(workoutTypeId, workoutType);
    }

    // UI를 갱신합니다.
    _loadData();
  }

  Future<void> _deleteWorkoutType(int workoutTypeId) async {
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    var workoutType = typesBox.get(workoutTypeId);
    if (workoutType == null) {
      print("WorkoutType with id $workoutTypeId not found");
      return;
    }

    // 우선 해당 WorkoutType에 연결된 모든 Exercise 및 그 Exercise에 연결된 모든 Set 삭제
    for (var exerciseId in workoutType.exerciseIds) {
      var exercise = exercisesBox.get(exerciseId);
      if (exercise != null) {
        // 연결된 모든 Set 삭제
        for (var setId in exercise.setIds) {
          await setsBox.delete(setId);
          tempSets.remove(setId); // tempSets에서도 삭제합니다.
        }

        // Exercise 삭제
        await exercisesBox.delete(exerciseId);
        tempExercises.remove(exerciseId); // tempExercises에서도 삭제합니다.
      }
    }

    // WorkoutType 삭제
    await typesBox.delete(workoutTypeId);
    tempWorkoutTypes.remove(workoutTypeId); // tempWorkoutTypes에서도 삭제합니다.

    widget.record.workoutTypeIds.remove(workoutTypeId);
    await widget.record.save();

    // UI 갱신
    _loadData();
  }


  Future<void> saveTempDataToHive() async {
    var typesBox = Hive.box<WorkoutType>('workoutTypes');
    var exercisesBox = Hive.box<Exercise>('exercises');
    var setsBox = Hive.box<Set>('sets');

    // WorkoutTypes 저장
    for (var workoutType in tempWorkoutTypes.values) {
      if (workoutType.name == "") {
        workoutType.name = "기타";
      }
      await typesBox.put(workoutType.id, workoutType);
    }

    // Exercises 저장
    for (var exerciseList in tempExercises.values) {
      for (var exercise in exerciseList) {
        if (exercise.name == "") {
          exercise.name = "기타";
        }
        await exercisesBox.put(exercise.id, exercise);
      }
    }

    // Sets 저장
    for (var setList in tempSets.values) {
      for (var set in setList) {
        await setsBox.put(set.id, set);
      }
    }
  }


  Widget _dropDown(String partName, int typeID) {
    var workoutTypeBox = Hive.box<WorkoutType>('workoutTypes');
    var workoutType = workoutTypeBox.get(typeID);

    String? dropdownValue =
    workoutType?.name.isNotEmpty ?? false ? workoutType?.name : null;

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
              tempWorkoutTypes[typeID]?.name = newValue;
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
