import 'package:uuid/uuid.dart';
import 'micro_action.dart';
import 'itinerary_item.dart';
import 'question.dart';
import 'dream_phase.dart';

class Dream {
  final String id;
  String title;
  String description;
  List<Question> clarifyingQuestions;
  List<String> clarifyingAnswers;
  List<MicroAction> microActions;
  List<ItineraryItem> itineraryItems;
  String? shortDescription;
  String? emoji;
  List<DreamPhase> phases;
  final DateTime createdAt;

  Dream({
    String? id,
    required this.title,
    required this.description,
    List<Question>? clarifyingQuestions,
    List<String>? clarifyingAnswers,
    this.shortDescription,
    this.emoji,
    List<MicroAction>? microActions,
    List<ItineraryItem>? itineraryItems,
    List<DreamPhase>? phases,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        clarifyingQuestions = clarifyingQuestions ?? [],
        clarifyingAnswers = clarifyingAnswers ?? [],
        microActions = microActions ?? [],
        itineraryItems = itineraryItems ?? [],
        phases = phases ?? [],
        createdAt = createdAt ?? DateTime.now();

  bool get isCompleted {
    final totalItems = microActions.length + itineraryItems.length;
    if (totalItems == 0) return false;
    return microActions.every((action) => action.isCompleted) &&
        itineraryItems.every((item) => item.isCompleted);
  }

  double get progress {
    final totalItems = microActions.length + itineraryItems.length;
    if (totalItems == 0) return 0;
    final completedCount = microActions.where((a) => a.isCompleted).length +
        itineraryItems.where((i) => i.isCompleted).length;
    return completedCount / totalItems;
  }

  int get completedActionsCount =>
      microActions.where((a) => a.isCompleted).length;

  int get completedItemsCount =>
      itineraryItems.where((i) => i.isCompleted).length;

  int get totalItemsCount => microActions.length + itineraryItems.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'shortDescription': shortDescription,
      'emoji': emoji,
      'clarifyingQuestions': clarifyingQuestions.map((q) => q.toJson()).toList(),
      'clarifyingAnswers': clarifyingAnswers,
      'microActions': microActions.map((a) => a.toJson()).toList(),
      'itineraryItems': itineraryItems.map((i) => i.toJson()).toList(),
      'phases': phases.map((p) => p.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Dream.fromJson(Map<String, dynamic> json) {
    return Dream(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      shortDescription: json['shortDescription'],
      emoji: json['emoji'],
      clarifyingQuestions: (json['clarifyingQuestions'] as List?)?.map((e) {
        if (e is String) {
          return Question(text: e, type: QuestionType.text);
        }
        return Question.fromJson(e);
      }).toList() ?? [],
      clarifyingAnswers: List<String>.from(json['clarifyingAnswers'] ?? []),
      microActions: (json['microActions'] as List?)
              ?.map((a) => MicroAction.fromJson(a))
              .toList() ??
          [],
      itineraryItems: (json['itineraryItems'] as List?)
              ?.map((i) => ItineraryItem.fromJson(i))
              .toList() ??
          [],
      phases: (json['phases'] as List?)
              ?.map((p) => DreamPhase.fromJson(p))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
