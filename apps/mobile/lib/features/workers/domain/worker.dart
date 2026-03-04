class Worker {
  const Worker({
    required this.id,
    required this.name,
    required this.primarySkill,
    required this.distanceKm,
    required this.rating,
  });

  final String id;
  final String name;
  final String primarySkill;
  final double distanceKm;
  final double rating;

  factory Worker.fromJson(Map<String, dynamic> json) {
    return Worker(
      id: json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      primarySkill: json["primarySkill"]?.toString() ?? "General",
      distanceKm: (json["distanceKm"] as num?)?.toDouble() ?? 0,
      rating: (json["rating"] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "primarySkill": primarySkill,
      "distanceKm": distanceKm,
      "rating": rating,
    };
  }
}
