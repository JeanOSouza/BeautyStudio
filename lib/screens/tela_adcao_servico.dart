import 'dart:io'; // Para manipular arquivos locais (imagens)
import 'package:image_picker/image_picker.dart'; // Para pegar imagem da galeria/câmera
import 'package:firebase_storage/firebase_storage.dart'; // Para upload no Firebase Storage
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ServiceFormScreen extends StatefulWidget {
  const ServiceFormScreen({super.key});

  @override
  State<ServiceFormScreen> createState() => _ServiceFormScreenState();
}

class _ServiceFormScreenState extends State<ServiceFormScreen> {
  // Variáveis
  File? _selectedImage;
  final TextEditingController _serviceNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();
  final TextEditingController _userCommentController = TextEditingController();
  final List<String> _imagePaths = [];

  @override
  void dispose() {
    // Libera os controladores para evitar vazamento de memória
    _serviceNameController.dispose();
    _descriptionController.dispose();
    _valueController.dispose();
    _userCommentController.dispose();
    super.dispose();
  }

  // Função para abrir a galeria, selecionar imagem e fazer upload para Firebase Storage
  void _addImage() async {
    final ImagePicker picker = ImagePicker();

    // Abre a galeria e espera o usuário escolher uma imagem
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      // Converte XFile em File para manipulação local
      File imageFile = File(pickedFile.path);

      setState(() {
        _selectedImage =
            imageFile; // Guarda temporariamente para exibir, se quiser
      });

      // Cria um nome único para o arquivo usando timestamp
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Referência para o arquivo dentro do Firebase Storage (pasta 'service_images')
      Reference storageRef = FirebaseStorage.instance.ref().child(
        'service_images/$fileName.jpg',
      );

      // Inicia o upload do arquivo
      UploadTask uploadTask = storageRef.putFile(imageFile);

      // Espera o upload finalizar e pega o snapshot
      TaskSnapshot snapshot = await uploadTask;

      // Obtém a URL pública da imagem uploadada para salvar no Firestore
      String downloadUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        _imagePaths.add(
          downloadUrl,
        ); // Adiciona a URL da imagem na lista para mostrar e salvar
      });
    }
  }

  // Função para salvar o serviço no Firestore, incluindo as URLs das imagens
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
        'images': _imagePaths, // Aqui salvamos as URLs das imagens uploadadas
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
        _selectedImage = null;
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
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.asset('lib/img/Logo.png'),
        ),
        title: const Text('Novo Serviço'),
        backgroundColor: Colors.purple,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo: Nome do Serviço
            TextField(
              controller: _serviceNameController,
              decoration: const InputDecoration(
                labelText: 'Nome do Serviço',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.palette),
              ),
            ),
            const SizedBox(height: 15),

            // Campo: Descrição do Serviço
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descrição Detalhada',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 4,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 15),

            // Campo: Valor do Serviço
            TextField(
              controller: _valueController,
              decoration: const InputDecoration(
                labelText: 'Valor (Ex: 150.00)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
              ),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),
            const SizedBox(height: 25),

            // Texto da Galeria de Imagens
            const Text(
              'Galeria de Imagens do Serviço',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Botão para adicionar imagem, chama a função _addImage()
            Align(
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

            // Área para mostrar as imagens selecionadas (exibindo a partir das URLs)
            _imagePaths.isEmpty
                ? const Text(
                    'Nenhuma imagem adicionada ainda.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  )
                : Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: _imagePaths.map((path) {
                      return Stack(
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: path.startsWith('http')
                                ? Image.network(path, fit: BoxFit.cover)
                                : Image.asset(path, fit: BoxFit.cover),
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  _imagePaths.remove(path);
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

            // Campo: Comentário para o Usuário
            TextField(
              controller: _userCommentController,
              decoration: const InputDecoration(
                labelText:
                    'Observações para o Usuário (Ex: Preparo necessário)',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
                prefixIcon: Icon(Icons.comment),
              ),
              maxLines: 3,
              keyboardType: TextInputType.multiline,
            ),
            const SizedBox(height: 30),

            // Botão para salvar serviço
            ElevatedButton.icon(
              onPressed: _saveService,
              icon: const Icon(Icons.save),
              label: const Text(
                'Salvar Serviço',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
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
