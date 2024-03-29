import 'package:flutter/material.dart';
import '../../models/WorkoutRecord.dart';

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

  @override
  void initState() {
    super.initState();
    widget.record.workoutTypes.keys.forEach((partName) {
      _selectedExercises[partName] = partName;
    });
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
          initiallyExpanded:true,
          children: widget.record.workoutTypes.entries.map((partEntry) {
            String partName = partEntry.key;
            return ListTile(
              title:  _dropDown(partName),
              subtitle: Column(
                children: partEntry.value.entries.map((exerciseEntry) {
                  String exerciseName = exerciseEntry.key;
                  TextEditingController exerciseNameController = TextEditingController(text: exerciseName);
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        title: Container(
                          width:100,
                            child: TextFormField(
                              controller: exerciseNameController,
                            ),
                          ),
                        subtitle: Column(
                          children: exerciseEntry.value.entries.map((setEntry) {
                            String weight = setEntry.key;
                            List<int> repsList = setEntry.value;
                            TextEditingController weightController = TextEditingController(text: weight);
                            TextEditingController repsController = TextEditingController(text: repsList.join(" "));
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width:40,
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: weightController,
                                      ),
                                    ),
                                    const Text("kg"),
                                  ],
                                ),
                                Row(
                                  children: [
                                    const Text("횟수: "),
                                    Container(
                                      width:150,
                                      child: TextFormField(
                                        keyboardType: TextInputType.number,
                                        controller: repsController,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
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

  Widget _dropDown(String partName) =>
      DropdownButton<String>(
          value: _selectedExercises[partName],  // Use the Map for tracking selected item per partName
          onChanged: (String? newValue) {
            if (newValue != null) {  // Check for null before assigning
              setState(() {
                _selectedExercises[partName] = newValue;
              });
            }
          },
          items: _exercises.map((exercise) =>
              DropdownMenuItem<String>(value: exercise, child: Text(exercise))
          ).toList());

}