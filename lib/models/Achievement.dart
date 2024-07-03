class Achievement {
  final String title;
  final String description;
  final int currentProgress;
  final int totalSteps;
  final String image;

  Achievement({
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.totalSteps,
    required this.image,
  });

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      title: json['title'],
      description: json['description'],
      currentProgress: json['currentProgress'],
      totalSteps: json['totalSteps'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'currentProgress': currentProgress,
      'totalSteps': totalSteps,
      'image': image,
    };
  }
}
