import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker_screen.dart';

class EventFormScreen extends StatefulWidget {
  final DateTime selectedDate;
  final Function(LatLng, String, TimeOfDay) onEventAdded;

  EventFormScreen({
    required this.selectedDate,
    required this.onEventAdded,
  });

  @override
  _EventFormScreenState createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final _titleController = TextEditingController();
  TimeOfDay? _selectedTime;
  LatLng? _selectedLocation;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          //title
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Event Title'),
          ),
          const SizedBox(height: 10),

          // time
          ElevatedButton(
            onPressed: () async {
              final pickedTime = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (pickedTime != null) {
                setState(() {
                  _selectedTime = pickedTime;
                });
              }
            },
            child: Text(
              _selectedTime == null
                  ? 'Select Time'
                  : 'Selected Time: ${_selectedTime!.format(context)}',
            ),
          ),
          const SizedBox(height: 10),

          // location
          ElevatedButton(
            onPressed: () async {
              final pickedLocation = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => LocationPickerScreen()),
              );
              if (pickedLocation != null && pickedLocation is LatLng) {
                setState(() {
                  _selectedLocation = pickedLocation;
                });
              }
            },
            child: Text(
              _selectedLocation == null
                  ? 'Select Location'
                  : 'Location Selected: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}',
            ),
          ),
          const SizedBox(height: 20),

          // save button
          ElevatedButton(
            onPressed: () {
              if (_titleController.text.isNotEmpty &&
                  _selectedTime != null &&
                  _selectedLocation != null) {
                widget.onEventAdded(
                  _selectedLocation!,
                  _titleController.text,
                  _selectedTime!,
                );
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please complete all fields.')),
                );
              }
            },
            child: Text('Save Event'),
          ),
        ],
      ),
    );
  }
}