import 'package:flutter/material.dart';
import 'package:project_app/homework.dart';
import 'package:project_app/motivation.dart';
import 'package:project_app/notes.dart';
import 'package:project_app/reminder.dart';
import 'package:project_app/timetable.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, dynamic>> features = [
    {'icon': Icons.schedule, 'label': 'Timetable', 'color': Colors.blueAccent},
    {'icon': Icons.book, 'label': 'Homework', 'color': Colors.orangeAccent},
    {'icon': Icons.notifications, 'label': 'Reminders', 'color': Colors.pinkAccent},
    {'icon': Icons.note, 'label': 'Notes', 'color': Colors.greenAccent},
    {'icon': Icons.mood, 'label': 'Motivation', 'color': Colors.purpleAccent},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('StudyMate'),
          centerTitle: true,
        ),
        body: GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return GestureDetector(
              onTap: () {
                if (feature['label'] == 'Timetable') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => TimetablePage()));
                } else if (feature['label'] == 'Homework') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => HomeworkPage()));
                } else if (feature['label'] == 'Reminders') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => ReminderPage()));
                } else if (feature['label'] == 'Notes') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => NotesPage()));
                } else if (feature['label'] == 'Motivation') {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => MotivationPage()));
                }
              },
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: feature['color'], width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: feature['color'].withOpacity(0.3),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      backgroundColor: feature['color'].withOpacity(0.2),
                      child: Icon(feature['icon'], size: 32, color: feature['color']),
                    ),
                    SizedBox(height: 12),
                    Text(
                      feature['label'],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}