class DreamPhase {
  final int phaseNumber;
  final String title;
  final String icon; // Emoji

  DreamPhase({
    required this.phaseNumber,
    required this.title,
    required this.icon,
  });

  Map<String, dynamic> toJson() {
    return {
      'phaseNumber': phaseNumber,
      'title': title,
      'icon': icon,
    };
  }

  factory DreamPhase.fromJson(Map<String, dynamic> json) {
    return DreamPhase(
      phaseNumber: json['phaseNumber'] as int,
      title: json['title'] as String,
      icon: json['icon'] as String,
    );
  }
}
