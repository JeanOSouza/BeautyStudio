import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AvailabilityScreen extends StatefulWidget {
  @override
  _AvailabilityScreenState createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen> {
  DateTime _selectedDay = DateTime.now();
  List<TimeOfDay> _selectedTimes = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E152A),
      appBar: AppBar(
        title: const Text("Disponibilidade"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _selectedDay,
              calendarFormat: CalendarFormat.month,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, _) {
                setState(() => _selectedDay = selectedDay);
              },
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
              calendarStyle: const CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: Colors.pink,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.grey),
              ),
              daysOfWeekStyle: const DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: Colors.white),
                weekendStyle: TextStyle(color: Colors.white54),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _adicionarHorario,
                  child: const Text("Adicionar Horário"),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _salvarDisponibilidade,
                  child: const Text("Salvar"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Horários Selecionados:",
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _selectedTimes.map((time) {
                return Chip(
                  label: Text(time.format(context)),
                  backgroundColor: Colors.purple.shade300,
                  deleteIcon: const Icon(Icons.close, color: Colors.white),
                  onDeleted: () {
                    setState(() {
                      _selectedTimes.remove(time);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _adicionarHorario() async {
    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0),
    );

    if (time != null && !_selectedTimes.contains(time)) {
      setState(() => _selectedTimes.add(time));
    }
  }

  Future<void> _salvarDisponibilidade() async {
    if (_selectedTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Adicione ao menos um horário.")),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Usuário não autenticado.")));
      return;
    }

    final dataFormatada =
        "${_selectedDay.year}-${_selectedDay.month.toString().padLeft(2, '0')}-${_selectedDay.day.toString().padLeft(2, '0')}";
    final horarios = _selectedTimes.map((t) => t.format(context)).toList();

    final docId = "$uid-$dataFormatada";

    await FirebaseFirestore.instance
        .collection("disponibilidades")
        .doc(docId)
        .set({
          "profissionalId": uid,
          "data": dataFormatada,
          "horarios": horarios,
          "timestamp": FieldValue.serverTimestamp(),
        });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Disponibilidade salva com sucesso!")),
    );

    setState(() {
      _selectedTimes.clear();
    });
  }
}
