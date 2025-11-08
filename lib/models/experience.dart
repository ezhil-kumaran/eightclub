class Experience {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String imageUrl;
  final String iconUrl;

  Experience({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.imageUrl,
    required this.iconUrl,
  });

  factory Experience.fromJson(Map<String, dynamic> json) {
    return Experience(
      id: json['id'] as int,
      name: json['name'] as String,
      tagline: json['tagline'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      iconUrl: json['icon_url'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'image_url': imageUrl,
      'icon_url': iconUrl,
    };
  }
}

class ExperienceResponse {
  final String message;
  final List<Experience> experiences;

  ExperienceResponse({required this.message, required this.experiences});

  factory ExperienceResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final experiencesList = data['experiences'] as List<dynamic>;

    return ExperienceResponse(
      message: json['message'] as String,
      experiences: experiencesList
          .map((e) => Experience.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
