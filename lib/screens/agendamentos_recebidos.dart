import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AgendamentosRecebidosScreen extends StatefulWidget {
  const AgendamentosRecebidosScreen({super.key});

  @override
  State<AgendamentosRecebidosScreen> createState() =>
      _AgendamentosRecebidosScreenState();
}

class _AgendamentosRecebidosScreenState
    extends State<AgendamentosRecebidosScreen> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Agendamentos Recebidos')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('agendamentos')
            .where('profissionalId', isEqualTo: userId)
            .orderBy('data')
            .orderBy('hora')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Nenhum agendamento recebido.'));
          }

          final agendamentos = snapshot.data!.docs;

          return ListView.builder(
            itemCount: agendamentos.length,
            itemBuilder: (context, index) {
              final agendamento = agendamentos[index];
              final cliente = agendamento['clienteNome'] ?? 'Cliente';
              final servico = agendamento['servico'] ?? 'Serviço';
              final data = agendamento['data'] ?? '';
              final hora = agendamento['hora'] ?? '';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text('$servico - $cliente'),
                  subtitle: Text('Dia: $data às $hora'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
