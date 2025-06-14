import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Adicione este import para Firebase Storage
import 'tela_adcao_servico.dart'; // Provavelmente sua ServiceFormScreen
import 'package:beautystudio/cores/cores.dart'; // cores
import 'disponibilidade_servico.dart';
import 'perfil.dart';
import 'package:beautystudio/models/service.dart'; // <--- IMPORTE SEU MODELO DE SERVIÇO AQUI

class ListaServicosScreen extends StatefulWidget {
  const ListaServicosScreen({super.key});

  @override
  State<ListaServicosScreen> createState() => _ListaServicosScreenState();
}

class _ListaServicosScreenState extends State<ListaServicosScreen> {
  @override
  Widget build(BuildContext context) {
    final servicosRef = FirebaseFirestore.instance.collection('services');

    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu, color: Colors.white),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: const Text(
          'Meus Serviços',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.roxoEscuro,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            tooltip: 'Definir Disponibilidade',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AvailabilityScreen()),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(color: AppColors.roxoEscuro),
              child: const Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: const Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.add_business),
              title: const Text('Cadastro de Serviço'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ServiceFormScreen(), // Para adicionar um novo serviço
                  ),
                );
              },
            ),
          ],
        ),
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
              final servicoDoc = servicos[index]; // DocumentSnapshot
              // Converta o DocumentSnapshot para o seu modelo Service
              final service = Service.fromFirestore(
                servicoDoc,
              ); // <--- Use o construtor factory

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  leading: service.images.isNotEmpty
                      ? Image.network(
                          service.images[0],
                          width: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.broken_image,
                              ), // Fallback para erro
                        )
                      : const Icon(Icons.image),
                  title: Text(service.serviceName),
                  subtitle: Text(
                    'R\$ ${service.value.toStringAsFixed(2)}\n${service.description}',
                  ), // Exibe o valor e a descrição
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          // <--- LÓGICA DE NAVEGAÇÃO PARA EDIÇÃO
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ServiceFormScreen(
                                service: service,
                              ), // PASSA O OBJETO SERVICE
                            ),
                          ).then((_) {
                            // Opcional: Atualiza a tela após voltar da edição, se necessário
                            // (StreamBuilder já lida com a maioria das atualizações)
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.delete,
                          color: Color.fromARGB(
                            255,
                            67,
                            11,
                            77,
                          ), // A cor original era roxa escura, não vermelha
                        ),
                        onPressed: () {
                          _confirmarExclusao(
                            context,
                            service,
                          ); // Passa o objeto Service completo
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
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  const ServiceFormScreen(), // Para adicionar um novo serviço
            ),
          );
        },
        backgroundColor: Colors.purple,
        tooltip: 'Cadastrar novo serviço',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Modificada para receber o objeto Service completo
  void _confirmarExclusao(BuildContext context, Service service) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Excluir Serviço'),
        content: Text(
          'Tem certeza que deseja excluir "${service.serviceName}"?',
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text('Excluir'),
            onPressed: () async {
              Navigator.pop(context); // Fecha o diálogo primeiro

              try {
                // 1. Excluir o documento do Firestore
                await FirebaseFirestore.instance
                    .collection('services')
                    .doc(service.id) // Usa o ID do serviço
                    .delete();

                // 2. Excluir as imagens associadas do Firebase Storage (melhor prática)
                if (service.images.isNotEmpty) {
                  for (String imageUrl in service.images) {
                    try {
                      await FirebaseStorage.instance
                          .refFromURL(imageUrl)
                          .delete();
                      print('Imagem $imageUrl excluída do Storage.');
                    } catch (e) {
                      print('Erro ao excluir imagem $imageUrl do Storage: $e');
                      // Continua mesmo se uma imagem falhar, para tentar excluir as outras
                    }
                  }
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Serviço "${service.serviceName}" e imagens associadas excluídos com sucesso!',
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao excluir serviço: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
