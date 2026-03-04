import "../../../core/api_client.dart";
import "../domain/worker.dart";

class WorkersRepository {
  Future<List<Worker>> fetchNearbyWorkers(double lat, double lng) async {
    final response = await ApiClient.dio.get("/geo/geo/nearby", queryParameters: {
      "latitude": lat,
      "longitude": lng,
      "radiusKm": 5
    });

    final list = (response.data as List<dynamic>)
        .map((item) => Worker(
              id: item["workerId"].toString(),
              name: "Worker ${item["workerId"].toString().substring(0, 6)}",
              primarySkill: "General",
              distanceKm: (item["distanceKm"] as num).toDouble(),
              rating: 4.5,
            ))
        .toList();
    return list;
  }
}
