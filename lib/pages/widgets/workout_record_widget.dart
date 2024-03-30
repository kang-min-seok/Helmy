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
  late Map<String, TextEditingController> exerciseNameControllers;
  late Map<String, TextEditingController> weightControllers;
  late Map<String, TextEditingController> repsControllers;

  @override
  void initState() {
    super.initState();
    exerciseNameControllers = {};
    weightControllers = {};
    repsControllers = {};

    widget.record.workoutTypes.forEach((partName, exercises) {
      _selectedExercises[partName] = partName;
      exercises.forEach((exerciseName, sets) {
        exerciseNameControllers[exerciseName] =
            TextEditingController(text: exerciseName);
        sets.forEach((weight, reps) {
          String key = '$exerciseName-$weight';
          weightControllers[key] = TextEditingController(text: weight);
          repsControllers[key] = TextEditingController(text: reps.join(" "));
        });
      });
    });
  }

  @override
  void dispose() {
    exerciseNameControllers.forEach((key, controller) => controller.dispose());
    weightControllers.forEach((key, controller) => controller.dispose());
    repsControllers.forEach((key, controller) => controller.dispose());
    super.dispose();
  }

  void _saveChanges() async {
    var box = Hive.box<WorkoutRecord>('workoutRecords');
    print(widget.record.workoutTypes);
    box.put(widget.record.id, widget.record);
  }

  void _updateExerciseName(
      String partName, String oldExerciseName, String newExerciseName) {
    print("newExerciseName");
    var exercises = widget.record.workoutTypes[partName];
    if (exercises != null && exercises.containsKey(oldExerciseName)) {
      print("되냐1");
      var sets = exercises.remove(oldExerciseName);
      if (sets != null) {
        print("되냐?");
        exercises[newExerciseName] = sets;
        _saveChanges();
      }
    }
  }

  void _updateSetData(
      String partName, String exerciseName, String weight, String reps) {
    var exercises = widget.record.workoutTypes[partName];
    if (exercises != null) {
      var exercise = exercises[exerciseName];
      if (exercise != null) {
        exercise[weight] = reps.split(" ").map(int.parse).toList();
        _saveChanges();
      }
    }
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
          children: widget.record.workoutTypes.entries.map((partEntry) {
            String partName = partEntry.key;
            return ListTile(
              title:  _dropDown(partName),
              subtitle: Column(
                children: partEntry.value.entries.map((exerciseEntry) {
                  String exerciseName = exerciseEntry.key;
                  TextEditingController exerciseNameController =
                      exerciseNameControllers[exerciseName]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: exerciseNameController,
                        onChanged: (text){
                          exerciseName = text;
                          print(exerciseName);
                        },
                        onFieldSubmitted: (newName) {
                          _updateExerciseName(partName, exerciseName, newName);
                          exerciseNameControllers[newName] =
                              exerciseNameController; // Update controller with new exercise name
                        },
                      ),
                      ...exerciseEntry.value.entries.map((setEntry) {
                        String weight = setEntry.key;
                        List<int> reps = setEntry.value;
                        String weightRepsKey = '$exerciseName-$weight';
                        TextEditingController weightController =
                            weightControllers[weightRepsKey]!;
                        TextEditingController repsController =
                            repsControllers[weightRepsKey]!;

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 40,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: weightController,
                                onFieldSubmitted: (newWeight) {
                                  _updateSetData(partName, exerciseName,
                                      newWeight, reps.join(", "));
                                },
                              ),
                            ),
                            const Text("kg"),
                            Container(
                              width: 150,
                              child: TextFormField(
                                keyboardType: TextInputType.number,
                                controller: repsController,
                                onFieldSubmitted: (newReps) {
                                  _updateSetData(
                                      partName, exerciseName, weight, newReps);
                                },
                              ),
                            ),
                            const Text("회"),
                          ],
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
  Widget _dropDown(String partName) {
    return DropdownButton<String>(
      value: _selectedExercises[partName], // Use the Map for tracking selected item per partName
      onChanged: (String? newValue) {
        if (newValue != null) { // Check for null before assigning
          setState(() {
            _selectedExercises[partName] = newValue;
          });
          // 이 부분에서도 필요한 경우 변경사항을 저장해야 할 수 있습니다.
        }
      },
      items: _exercises.map((exercise) => DropdownMenuItem<String>(
        value: exercise,
        child: Text(exercise),
      )).toList(),
    );
  }
}
