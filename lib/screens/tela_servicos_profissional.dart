import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'tela_adcao_servico.dart'; // ajuste o caminho se for diferente

// Função para buscar os serviços no Firestore (você pode usar se quiser)
Future<List<Map<String, dynamic>>> fetchServices() async {
  try {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('services')
        .get();

    List<Map<String, dynamic>> services = snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList();

    return services;
  } catch (e) {
    print('Erro ao buscar serviços: $e');
    return [];
  }
}

class ListaServicosScreen extends StatefulWidget {
  const ListaServicosScreen({super.key});

  @override
  State<ListaServicosScreen> createState() => _ListaServicosScreenState();
}

class _ListaServicosScreenState extends State<ListaServicosScreen> {
  late Future<List<Map<String, dynamic>>> _futureServices;

  @override
  void initState() {
    super.initState();
    _futureServices = fetchServices(); // Se quiser usar
  }

  @override
  Widget build(BuildContext context) {
    final servicosRef = FirebaseFirestore.instance.collection('services');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Serviços'),
        backgroundColor: const Color.fromARGB(255, 67, 11, 77), // cor roxa
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: servicosRef.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Erro ao carregar serviços.'));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final servicos = snapshot.data!.docs;

          if (servicos.isEmpty) {
            return const Center(child: Text('Nenhum serviço cadastrado.'));
          }

          return ListView.builder(
            itemCount: servicos.length,
            itemBuilder: (context, index) {
              final servico = servicos[index];
              final data = servico.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: data['images'] != null && data['images'].isNotEmpty
                      ? Image.network(
                          data['images'][0],
                          width: 60,
                          fit: BoxFit.cover,
                        )
                      : const Icon(Icons.image),
                  title: Text(data['name'] ?? 'Sem nome'),
                  subtitle: Text(data['description'] ?? ''),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // Navegue para tela de edição aqui
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(255, 67, 11, 77),
                        ),
                        onPressed: () {
                          _confirmarExclusao(context, servico.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.purple,
        tooltip: 'Cadastrar novo serviço',
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ServiceFormScreen()),
          );
        },
      ),
    );
  }

  void _confirmarExclusao(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: const Text('Tem certeza que deseja excluir este serviço?'),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Excluir'),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('servicos')
                  .doc(id)
                  .delete();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
