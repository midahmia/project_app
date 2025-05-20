import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeworkPage extends StatefulWidget {
  @override
  _HomeworkPageState createState() => _HomeworkPageState();
}

class _HomeworkPageState extends State<HomeworkPage> {
  List<Map<String, dynamic>> homeworkList = [];
  final TextEditingController titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadHomework();
  }

  Future<void> loadHomework() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('homework');
    if (data != null) {
      setState(() {
        homeworkList = List<Map<String, dynamic>>.from(json.decode(data));
      });
    }
  }

  Future<void> saveHomework() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('homework', json.encode(homeworkList));
  }

  void addHomework() {
    titleController.clear();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New Homework'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: 'Homework Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  homeworkList.add({
                    'title': titleController.text,
                    'done': false,
                  });
                });
                saveHomework();
                Navigator.pop(context);
              }
            },
            child: Text('Add'),
          ),
        ],
      ),
    );
  }

  void editHomework(int index) {
    titleController.text = homeworkList[index]['title'];
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Edit Homework'),
        content: TextField(
          controller: titleController,
          decoration: InputDecoration(labelText: 'Homework Title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                homeworkList[index]['title'] = titleController.text;
              });
              saveHomework();
              Navigator.pop(context);
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
  }

  void deleteHomework(int index) {
    setState(() {
      homeworkList.removeAt(index);
    });
    saveHomework();
  }

  void toggleDone(int index, bool? value) {
    setState(() {
      homeworkList[index]['done'] = value ?? false;
    });
    saveHomework();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Homework')),
      body: ListView.builder(
        itemCount: homeworkList.length,
        itemBuilder: (context, index) {
          final item = homeworkList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Checkbox(
                value: item['done'],
                onChanged: (value) => toggleDone(index, value),
              ),
              title: Text(
                item['title'],
                style: TextStyle(
                  decoration: item['done'] ? TextDecoration.lineThrough : null,
                ),
              ),
              onTap: () => editHomework(index),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red),
                onPressed: () => deleteHomework(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: addHomework,
        label: Text('Add Homework'),
        icon: Icon(Icons.add),
        backgroundColor: Colors.indigo,
      ),
    );
  }
}