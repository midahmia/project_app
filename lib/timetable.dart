import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  List<Map<String, String>> timetable = [];

  final TextEditingController dayController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTimetable();
  }

  Future<void> _loadTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final String? timetableString = prefs.getString('timetable');
    if (timetableString != null) {
      final List<dynamic> jsonList = json.decode(timetableString);
      timetable = jsonList.map((e) => Map<String, String>.from(e)).toList();
      setState(() {});
    } else {
      // default timetable if nothing saved yet
      timetable = [
        {'day': 'Monday', 'subject': 'Math - 8:00 AM'},
        {'day': 'Tuesday', 'subject': 'English - 10:00 AM'},
        {'day': 'Wednesday', 'subject': 'Science - 9:00 AM'},
        {'day': 'Thursday', 'subject': 'History - 11:00 AM'},
        {'day': 'Friday', 'subject': 'Art - 1:00 PM'},
      ];
    }
  }

  Future<void> _saveTimetable() async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = json.encode(timetable);
    await prefs.setString('timetable', jsonString);
  }

  void _addClass() {
    dayController.clear();
    subjectController.clear();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add New Class', style: TextStyle(color: Colors.indigo)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dayController,
              decoration: InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject and Time',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              if (dayController.text.isNotEmpty && subjectController.text.isNotEmpty) {
                setState(() {
                  timetable.add({
                    'day': dayController.text,
                    'subject': subjectController.text,
                  });
                });
                _saveTimetable();
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void _editClass(int index) {
    final currentClass = timetable[index];
    dayController.text = currentClass['day'] ?? '';
    subjectController.text = currentClass['subject'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit Class', style: TextStyle(color: Colors.indigo)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dayController,
              decoration: InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject and Time',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              dayController.clear();
              subjectController.clear();
              Navigator.pop(context);
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              if (dayController.text.isNotEmpty && subjectController.text.isNotEmpty) {
                setState(() {
                  timetable[index] = {
                    'day': dayController.text,
                    'subject': subjectController.text,
                  };
                });
                _saveTimetable();
                dayController.clear();
                subjectController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Timetable')),
      body: ListView.builder(
        itemCount: timetable.length,
        itemBuilder: (context, index) {
          final item = timetable[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            shadowColor: Colors.indigo.withOpacity(0.3),
            child: ListTile(
              onTap: () => _editClass(index),
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Icon(Icons.class_, color: Colors.indigo),
              ),
              title: Text(item['day'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo.shade900)),
              subtitle: Text(item['subject'] ?? '', style: TextStyle(color: Colors.indigo.shade700)),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    timetable.removeAt(index);
                  });
                  _saveTimetable();
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClass,
        label: Text("Add Class"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}
/*class TimetablePage extends StatefulWidget {
  @override
  _TimetablePageState createState() => _TimetablePageState();
}

class _TimetablePageState extends State<TimetablePage> {
  final List<Map<String, String>> timetable = [
    {'day': 'Monday', 'subject': 'Math - 8:00 AM'},
    {'day': 'Tuesday', 'subject': 'English - 10:00 AM'},
    {'day': 'Wednesday', 'subject': 'Science - 9:00 AM'},
    {'day': 'Thursday', 'subject': 'History - 11:00 AM'},
    {'day': 'Friday', 'subject': 'Art - 1:00 PM'},
  ];

  final TextEditingController dayController = TextEditingController();
  final TextEditingController subjectController = TextEditingController();

  void _addClass() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add New Class', style: TextStyle(color: Colors.indigo)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: dayController,
              decoration: InputDecoration(
                labelText: 'Day',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: subjectController,
              decoration: InputDecoration(
                labelText: 'Subject and Time',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              if (dayController.text.isNotEmpty && subjectController.text.isNotEmpty) {
                setState(() {
                  timetable.add({
                    'day': dayController.text,
                    'subject': subjectController.text,
                  });
                });
                dayController.clear();
                subjectController.clear();
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Weekly Timetable')),
      body: ListView.builder(
        itemCount: timetable.length,
        itemBuilder: (context, index) {
          final item = timetable[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.indigo.shade100,
                child: Icon(Icons.class_, color: Colors.indigo),
              ),
              title: Text(item['day'] ?? '', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['subject'] ?? ''),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.redAccent),
                onPressed: () {
                  setState(() {
                    timetable.removeAt(index);
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addClass,
        label: Text("Add Class"),
        icon: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}*/