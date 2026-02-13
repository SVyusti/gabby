import 'package:uuid/uuid.dart';

class ItineraryItem {
  final String id;
  String dreamId;
  int day;
  String place;
  String? description;
  String? openingTime;
  String? closingTime;
  bool isCompleted;

  ItineraryItem({
    String? id,
    required this.dreamId,
    required this.day,
    required this.place,
    this.description,
    this.openingTime,
    this.closingTime,
    this.isCompleted = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dreamId': dreamId,
      'day': day,
      'place': place,
      'description': description,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'isCompleted': isCompleted,
    };
  }

  factory ItineraryItem.fromJson(Map<String, dynamic> json) {
    return ItineraryItem(
      id: json['id'],
      dreamId: json['dreamId'],
      day: json['day'],
      place: json['place'],
      description: json['description'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}
