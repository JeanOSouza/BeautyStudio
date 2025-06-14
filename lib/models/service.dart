import 'package:cloud_firestore/cloud_firestore.dart';

class Service {
  String? id; // O ID é opcional para novos serviços e obrigatório para edição
  String serviceName;
  String description;
  double value;
  String userComment;
  List<String> images; // URLs das imagens

  Service({
    this.id,
    required this.serviceName,
    required this.description,
    required this.value,
    this.userComment = '', // Comentário pode ser opcional
    this.images = const [], // Lista de imagens pode ser opcional
  });

  // Construtor factory para criar um Service a partir de um DocumentSnapshot do Firestore
  factory Service.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Service(
      id: doc.id,
      serviceName: data['serviceName'] ?? '',
      description: data['description'] ?? '',
      value: (data['value'] ?? 0.0).toDouble(),
      userComment: data['userComment'] ?? '',
      images: List<String>.from(data['images'] ?? []),
    );
  }

  // Método para converter Service em Map para salvar/atualizar no Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'serviceName': serviceName,
      'description': description,
      'value': value,
      'userComment': userComment,
      'images': images,
      // 'createdAt' e 'updatedAt' podem ser adicionados no momento da operação no Firestore
    };
  }
}
