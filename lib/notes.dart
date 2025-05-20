import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, String>> notes = [];
  final titleController = TextEditingController();
  final contentController = TextEditingController();

  String selectedCategory = 'General';
  final List<String> categories = ['General', 'Study', 'Personal', 'Ideas'];

  String searchQuery = '';

  // Map each category to a distinct color
  final Map<String, Color> categoryColors = {
    'General': Colors.grey,
    'Study': Colors.indigo,
    'Personal': Colors.teal,
    'Ideas': Colors.deepOrange,
  };

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  Future<void> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString('notes');
    if (notesString != null) {
      final List decoded = jsonDecode(notesString);
      setState(() {
        notes = decoded.cast<Map<String, String>>();
      });
    }
  }

  Future<void> saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('notes', jsonEncode(notes));
  }

  List<Map<String, String>> getFilteredNotes() {
    if (searchQuery.isEmpty) return notes;
    return notes.where((note) {
      final title = note['title']!.toLowerCase();
      final content = note['content']!.toLowerCase();
      final category = note['category']!.toLowerCase();
      return title.contains(searchQuery) ||
          content.contains(searchQuery) ||
          category.contains(searchQuery);
    }).toList();
  }

  void addOrEditNote({Map<String, String>? existingNote, int? index}) {
    if (existingNote != null) {
      titleController.text = existingNote['title']!;
      contentController.text = existingNote['content']!;
      selectedCategory = existingNote['category']!;
    } else {
      titleController.clear();
      contentController.clear();
      selectedCategory = 'General';
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          existingNote == null ? 'Add Note' : 'Edit Note',
          style: TextStyle(color: Colors.indigo),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: contentController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Content',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                items: categories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedCategory = value;
                    });
                  }
                },
                decoration: InputDecoration(
                  labelText: 'Category',
                  border:
                      OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              titleController.clear();
              contentController.clear();
              selectedCategory = 'General';
            },
            child: Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  contentController.text.isNotEmpty) {
                setState(() {
                  if (existingNote != null && index != null) {
                    notes[index] = {
                      'title': titleController.text,
                      'content': contentController.text,
                      'category': selectedCategory,
                    };
                  } else {
                    notes.add({
                      'title': titleController.text,
                      'content': contentController.text,
                      'category': selectedCategory,
                    });
                  }
                });
                saveNotes();
                Navigator.pop(context);
                titleController.clear();
                contentController.clear();
                selectedCategory = 'General';
              }
            },
            child: Text(existingNote == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void deleteNote(int index) {
    setState(() {
      notes.removeAt(index);
      saveNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = getFilteredNotes();

    return Scaffold(
      appBar: AppBar(title: Text('My Notes')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: filteredNotes.isEmpty
                ? Center(
                    child: Text(
                      'No notes found. Tap + to add one!',
                      style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = filteredNotes[index];
                      final catColor =
                          categoryColors[note['category']] ?? Colors.grey;
                      return Card(
                        margin:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 3,
                        color: Theme.of(context).cardColor,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: catColor,
                            child: Text(
                              note['category']![0],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            note['title']!,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          subtitle: Text(
                            '${note['content']!}\nCategory: ${note['category']!}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Theme.of(context).textTheme.bodyMedium?.color,
                            ),
                          ),
                          onTap: () => addOrEditNote(
                            existingNote: note,
                            index: notes.indexOf(note),
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.redAccent),
                            onPressed: () {
                              deleteNote(notes.indexOf(note));
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo,
        child: Icon(Icons.add),
        onPressed: () => addOrEditNote(),
      ),
    );
  }
}