import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  // Controladores para os campos de texto
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _userCommentController = TextEditingController();

  // Lista para armazenar os caminhos das imagens selecionadas
  // Em um app real, aqui seriam objetos de imagem ou URLs
  final List<String> _imagePaths = [];

  @override
  void dispose() {
    // É importante liberar os controladores quando o widget for descartado
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _userCommentController.dispose();
    super.dispose();
  }

  // --- Lógica de Adicionar Imagem (Exemplo - precisaria de um pacote como image_picker) ---
  void _addImage() {
    // Implementar a lógica para abrir a galeria/câmera e selecionar uma imagem.
    // Ex: usando o pacote image_picker
    // ImagePicker().pickImage(source: ImageSource.gallery).then((file) {
    //   if (file != null) {
    //     setState(() {
    //       _imagePaths.add(file.path); // Adiciona o caminho da imagem
    //     });
    //   }
    // });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Lógica para adicionar imagem aqui (ex: image_picker)'),
      ),
    );
    // Adicionando um placeholder para demonstração
    setState(() {
      _imagePaths.add(
        'assets/placeholder_image.png',
      ); // Adicione uma imagem de placeholder em assets/
    });
  }

  // --- Lógica de Salvar o Serviço ---
  void _saveService() async {
    final serviceName = _serviceNameController.text.trim();
    final description = _descriptionController.text.trim();
    final value = _valueController.text.trim();
    final userComment = _userCommentController.text.trim();

    if (serviceName.isEmpty || description.isEmpty || value.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Por favor, preencha nome, descrição e valor do serviço.',
          ),
        ),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('services').add({
        'serviceName': serviceName,
        'description': description,
        'value': double.tryParse(value) ?? 0.0,
        'userComment': userComment,
        'images': _imagePaths, // Se for URL das imagens, envie aqui
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Serviço "$serviceName" salvo com sucesso!')),
      );

      // Limpa os campos e imagens após salvar
      _serviceNameController.clear();
      _descriptionController.clear();
      _valueController.clear();
      _userCommentController.clear();
      setState(() {
        _imagePaths.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao salvar serviço: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adicionar Serviço'),
        backgroundColor:
            Colors.pinkAccent, // Cor da AppBar para o tema do salão
      ),
      // Adicionamos um SingleChildScrollView para garantir que o teclado não cubra os campos
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0), // Padding em todos os lados
        child: Column(
          crossAxisAlignment: CrossAxisAlignment
              .stretch, // Estica os elementos para a largura total
          children: [
            // --- Campo: Nome do Serviço ---
            TextField(
              controller: _serviceNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Serviço',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.palette), // Ícone sugestivo
              ),
            ),
            const SizedBox(height: 15),

            // --- Campo: Descrição do Serviço ---
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição Detalhada',
                border: OutlineInputBorder(),
                alignLabelWithHint:
                    true, // Alinha o label no topo para múltiplos TextFields
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4, // Permite múltiplas linhas
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 15),

            // --- Campo: Valor do Serviço ---
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valor (Ex: 150.00)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money), // Ícone de dinheiro
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ), // Teclado numérico
            ),
            const SizedBox(height: 25),

            // --- Galeria de Imagens ---
            const Text(
              'Galeria de Imagens do Serviço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Linha para o botão "Adicionar Imagem"
            Align(
              // Centraliza o botão
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: _addImage,
                icon: const Icon(Icons.add_a_photo),
                label: const Text('Adicionar Imagem'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            // Grade/Wrap para exibir as imagens selecionadas
            _imagePaths.isEmpty
                ? const Text(
                    'Nenhuma imagem adicionada ainda.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                : Wrap(
                    spacing: 8.0, // Espaçamento horizontal entre as imagens
                    runSpacing:
                        8.0, // Espaçamento vertical entre as linhas de imagens
                    children: _imagePaths.map((path) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: AssetImage(
                                  path,
                                ), // Use NetworkImage para URLs reais
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imagePaths.remove(
                                    path,
                                  ); // Remove a imagem da lista
                                });
                              },
                              child: const CircleAvatar(
                                radius: 12,
                                backgroundColor: Colors.purple,
                                child: Icon(
                                  Icons.close,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
            const SizedBox(height: 25),

            // --- Campo: Comentário para o Usuário ---
            TextField(
              controller: _userCommentController,
              decoration: const InputDecoration(
                labelText:
                    'Observações para o Usuário (Ex: Preparo necessário)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 3, // Permite múltiplas linhas para o comentário
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 30),

            // --- Botão Salvar Serviço ---
            ElevatedButton.icon(
              onPressed: _saveService,
              icon: const Icon(Icons.save),
              label: const Text(
                'Salvar Serviço',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent, // Cor do botão
                foregroundColor: Colors.white, // Cor do texto/ícone
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
