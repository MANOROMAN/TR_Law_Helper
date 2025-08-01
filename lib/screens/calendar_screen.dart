import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<CalendarEvent>> _events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Takvim"),
        backgroundColor: const Color(0xFF2D3E50),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddEventDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          TableCalendar<CalendarEvent>(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            eventLoader: _getEventsForDay,
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              }
            },
            onFormatChanged: (format) {
              if (_calendarFormat != format) {
                setState(() {
                  _calendarFormat = format;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            calendarStyle: const CalendarStyle(
              selectedDecoration: BoxDecoration(
                color: Color(0xFF2D3E50),
                shape: BoxShape.circle,
              ),
              todayDecoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              markerDecoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              formatButtonDecoration: BoxDecoration(
                color: Color(0xFF2D3E50),
                borderRadius: BorderRadius.all(Radius.circular(12.0)),
              ),
              formatButtonTextStyle: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8.0),
          Expanded(
            child: _buildEventsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEventDialog(),
        backgroundColor: const Color(0xFF2D3E50),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEventsList() {
    final events = _getEventsForDay(_selectedDay!);
    
    if (events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              "${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Bu tarih için etkinlik bulunmuyor",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _showAddEventDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Etkinlik Ekle"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3E50),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        return _buildEventCard(event);
      },
    );
  }

  Widget _buildEventCard(CalendarEvent event) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getEventTypeColor(event.type),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getEventTypeIcon(event.type),
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          event.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              event.type,
              style: TextStyle(
                color: _getEventTypeColor(event.type),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (event.time.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                "Saat: ${event.time}",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
            if (event.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                event.description,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 13,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteEvent(event),
        ),
      ),
    );
  }

  Color _getEventTypeColor(String type) {
    switch (type) {
      case 'Duruşma':
        return Colors.red;
      case 'Randevu':
        return Colors.blue;
      case 'Toplantı':
        return Colors.green;
      case 'Müvekkil Görüşmesi':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getEventTypeIcon(String type) {
    switch (type) {
      case 'Duruşma':
        return Icons.gavel;
      case 'Randevu':
        return Icons.schedule;
      case 'Toplantı':
        return Icons.people;
      case 'Müvekkil Görüşmesi':
        return Icons.person;
      default:
        return Icons.event;
    }
  }

  List<CalendarEvent> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  void _showAddEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final timeController = TextEditingController();
    String selectedType = 'Randevu';
    
    final eventTypes = [
      'Randevu',
      'Duruşma',
      'Toplantı',
      'Müvekkil Görüşmesi',
      'Diğer'
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Yeni Etkinlik'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Etkinlik Başlığı *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Etkinlik Türü',
                    border: OutlineInputBorder(),
                  ),
                  items: eventTypes.map((type) => 
                    DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    ),
                  ).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedType = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Saat (ör: 14:30)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Açıklama',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.trim().isNotEmpty) {
                  _addEvent(
                    titleController.text.trim(),
                    selectedType,
                    timeController.text.trim(),
                    descriptionController.text.trim(),
                  );
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2D3E50),
                foregroundColor: Colors.white,
              ),
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }

  void _addEvent(String title, String type, String time, String description) {
    final event = CalendarEvent(
      title: title,
      type: type,
      time: time,
      description: description,
    );

    final day = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    
    setState(() {
      if (_events[day] != null) {
        _events[day]!.add(event);
      } else {
        _events[day] = [event];
      }
    });

    _saveEvents();
  }

  void _deleteEvent(CalendarEvent event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Etkinliği Sil'),
        content: Text('${event.title} etkinliğini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              final day = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
              setState(() {
                _events[day]?.remove(event);
                if (_events[day]?.isEmpty ?? false) {
                  _events.remove(day);
                }
              });
              _saveEvents();
              Navigator.of(context).pop();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getString('calendar_events') ?? '{}';
    final eventsMap = jsonDecode(eventsJson) as Map<String, dynamic>;
    
    setState(() {
      _events = eventsMap.map((key, value) {
        final date = DateTime.parse(key);
        final eventsList = (value as List)
            .map((eventJson) => CalendarEvent.fromJson(eventJson))
            .toList();
        return MapEntry(date, eventsList);
      });
    });
  }

  Future<void> _saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsMap = _events.map((key, value) {
      return MapEntry(
        key.toIso8601String().split('T')[0],
        value.map((event) => event.toJson()).toList(),
      );
    });
    await prefs.setString('calendar_events', jsonEncode(eventsMap));
  }
}

class CalendarEvent {
  final String title;
  final String type;
  final String time;
  final String description;

  CalendarEvent({
    required this.title,
    required this.type,
    required this.time,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'type': type,
      'time': time,
      'description': description,
    };
  }

  factory CalendarEvent.fromJson(Map<String, dynamic> json) {
    return CalendarEvent(
      title: json['title'],
      type: json['type'],
      time: json['time'],
      description: json['description'],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalendarEvent &&
          runtimeType == other.runtimeType &&
          title == other.title &&
          type == other.type &&
          time == other.time &&
          description == other.description;

  @override
  int get hashCode =>
      title.hashCode ^ type.hashCode ^ time.hashCode ^ description.hashCode;
}
