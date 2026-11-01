import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/calendar_repository.dart';
import '../application/calendar_provider.dart';

class CreateEventSheet extends ConsumerStatefulWidget {
  const CreateEventSheet({super.key});

  @override
  ConsumerState<CreateEventSheet> createState() => _CreateEventSheetState();
}

class _CreateEventSheetState extends ConsumerState<CreateEventSheet> {
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = DateTime(
          picked.year, picked.month, picked.day, 
          _selectedTime.hour, _selectedTime.minute
        );
      });
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
        _selectedDate = DateTime(
          _selectedDate.year, _selectedDate.month, _selectedDate.day, 
          picked.hour, picked.minute
        );
      });
    }
  }

  Future<void> _saveEvent() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a title')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final durationStr = _durationController.text.trim();
      final duration = durationStr.isNotEmpty ? int.tryParse(durationStr) : 60;
      final endAt = _selectedDate.add(Duration(minutes: duration ?? 60));

      final event = {
        'title': _titleController.text.trim(),
        'start': _selectedDate.toIso8601String(),
        'end': endAt.toIso8601String(),
        'type': 'workout',
        'estimated_duration_min': duration ?? 60,
        if (_locationController.text.trim().isNotEmpty) 'location': _locationController.text.trim(),
      };

      await ref.read(calendarRepositoryProvider).createEvent(event);
      ref.invalidate(calendarEventsProvider);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout Scheduled Successfully!'), backgroundColor: Colors.green));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateStr = DateFormat('MMM d, yyyy').format(_selectedDate);
    final timeStr = _selectedTime.format(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16, right: 16, top: 16,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4), borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Text('Schedule Workout', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 24),
            
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Workout Title', hintText: 'e.g. Heavy Chest Day', prefixIcon: Icon(Icons.fitness_center)),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Date', prefixIcon: Icon(Icons.calendar_today)),
                      child: Text(dateStr),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: _pickTime,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Time', prefixIcon: Icon(Icons.access_time)),
                      child: Text(timeStr),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _locationController,
                    decoration: const InputDecoration(labelText: 'Location (Optional)', prefixIcon: Icon(Icons.location_on)),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _durationController,
                    decoration: const InputDecoration(labelText: 'Mins', hintText: '60'),
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isLoading ? null : _saveEvent,
              style: FilledButton.styleFrom(padding: const EdgeInsets.all(16)),
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Schedule Event'),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
