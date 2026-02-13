import 'package:uuid/uuid.dart';

class MicroAction {
  final String id;
  final String dreamId;
  String title;
  String description;
  bool isCompleted;
  int order;
  int phase;
  DateTime? deadline;

  MicroAction({
    String? id,
    required this.dreamId,
    required this.title,
    this.description = '',
    this.isCompleted = false,
    this.order = 0,
    this.phase = 1,
    this.deadline,
  }) : id = id ?? const Uuid().v4();

  MicroAction copyWith({
    String? title,
    String? description,
    bool? isCompleted,
    int? order,
    int? phase,
    DateTime? deadline,
  }) {
    return MicroAction(
      id: id,
      dreamId: dreamId,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      order: order ?? this.order,
      phase: phase ?? this.phase,
      deadline: deadline ?? this.deadline,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dreamId': dreamId,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'isCompleted': isCompleted,
      'order': order,
      'phase': phase,
      'deadline': deadline?.toIso8601String(),
    };
  }

  factory MicroAction.fromJson(Map<String, dynamic> json) {
    return MicroAction(
      id: json['id'],
      dreamId: json['dreamId'],
      title: json['title'],
      description: json['description'] ?? '',
      isCompleted: json['isCompleted'] ?? false,
      order: json['order'] ?? 0,
      phase: json['phase'] ?? 1,
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
    );
  }
}
