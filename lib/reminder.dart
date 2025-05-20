import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List<Map<String, dynamic>> reminders = [];

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  TextEditingController reminderController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadReminders();
  }

  Future<void> _initNotifications() async {
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedReminders = prefs.getString('reminders');
    if (storedReminders != null) {
      setState(() {
        reminders = List<Map<String, dynamic>>.from(
          json.decode(storedReminders).map((item) => Map<String, dynamic>.from(item)),
        );
      });
    }
  }

  Future<void> _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('reminders', json.encode(reminders));
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  DateTime? get scheduledDateTime {
    if (selectedDate == null || selectedTime == null) return null;

    return DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );
  }

  Future<void> _scheduleNotification(int id, String title, DateTime scheduledTime) async {
    final androidDetails = AndroidNotificationDetails(
      'reminder_channel',
      'Reminders',
      channelDescription: 'Reminder notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    final platformDetails = NotificationDetails(android: androidDetails);

    final tz.TZDateTime tzScheduledDate = tz.TZDateTime.from(scheduledTime, tz.local);

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      'Reminder',
      title,
      tzScheduledDate,
      platformDetails,
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  void _addReminder() {
    final dateTime = scheduledDateTime;
    if (reminderController.text.isEmpty || dateTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter reminder text and pick date & time')),
      );
      return;
    }

    if (dateTime.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Selected time is in the past! Please choose a future time.')),
      );
      return;
    }

    int id = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    Map<String, dynamic> newReminder = {
      'id': id,
      'text': reminderController.text,
      'datetime': dateTime.toIso8601String(),
    };

    setState(() {
      reminders.add(newReminder);
      reminderController.clear();
      selectedDate = null;
      selectedTime = null;
    });

    _saveReminders();
    _scheduleNotification(id, newReminder['text'], dateTime);
  }

  void _confirmDelete(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete reminder?'),
        content: Text('Are you sure you want to delete this reminder?'),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              _deleteReminder(index);
            },
          ),
        ],
      ),
    );
  }

  void _deleteReminder(int index) async {
    int id = reminders[index]['id'];
    await flutterLocalNotificationsPlugin.cancel(id);

    setState(() {
      reminders.removeAt(index);
    });

    _saveReminders();
  }

  @override
  Widget build(BuildContext context) {
    final isAddEnabled = reminderController.text.isNotEmpty && scheduledDateTime != null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Reminders'),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: reminderController,
              decoration: InputDecoration(
                labelText: 'Reminder text',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onChanged: (_) {
                setState(() {}); // update Add button enabled state
              },
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.calendar_today),
                  label: Text(selectedDate == null
                      ? 'Pick Date'
                      : '${selectedDate!.toLocal().toString().split(' ')[0]}'),
                  onPressed: _pickDate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.access_time),
                  label: Text(selectedTime == null
                      ? 'Pick Time'
                      : selectedTime!.format(context)),
                  onPressed: _pickTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isAddEnabled ? _addReminder : null,
              child: Text('Add Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: isAddEnabled ? Colors.pinkAccent : Colors.grey,
                minimumSize: Size(double.infinity, 45),
              ),
            ),
            SizedBox(height: 20),
            Expanded(
              child: reminders.isEmpty
                  ? Center(child: Text('No Reminders yet'))
                  : ListView.builder(
                      itemCount: reminders.length,
                      itemBuilder: (context, index) {
                        final reminder = reminders[index];
                        DateTime dt = DateTime.parse(reminder['datetime']);
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          elevation: 3,
                          margin: EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(reminder['text']),
                            subtitle: Text('${dt.toLocal().toString().substring(0, 16)}'),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () => _confirmDelete(index),
                            ),
                          ),
                        );
                      },
                    ),
            )
          ],
        ),
      ),
    );
  }
}
