import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'chat_model.g.dart';

@HiveType(typeId: 0)
class ChatModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  DateTime updatedAt;

  @HiveField(4)
  final List<Message> messages;

  ChatModel({
    String? id,
    required this.title,
    required this.messages,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();
}

@HiveType(typeId: 1)
class Message extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String text;

  @HiveField(2)
  final bool isUser;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  final String? imagePath;

  @HiveField(5)
  final String? audioPath;

  Message({
    String? id,
    required this.text,
    required this.isUser,
    DateTime? timestamp,
    this.imagePath,
    this.audioPath,
  })  : id = id ?? const Uuid().v4(),
        timestamp = timestamp ?? DateTime.now();
}
