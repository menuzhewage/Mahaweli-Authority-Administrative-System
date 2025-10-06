// lib/data/services/distance_service.dart
import 'dart:math';
import 'package:latlong2/latlong.dart';
import '../models/resource.dart';


class DistanceService {
  // Calculate distance between two coordinates using Haversine formula
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    double lat1 = point1.latitude * pi / 180;
    double lon1 = point1.longitude * pi / 180;
    double lat2 = point2.latitude * pi / 180;
    double lon2 = point2.longitude * pi / 180;

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static List<String> findShortestPath(
      List<Resource> resources, String startId, String endId) {
    if (resources.isEmpty) return [];

    // Create a graph with distances between all resources
    Map<String, Map<String, double>> graph = {};

    for (var resource in resources) {
      graph[resource.id] = {};
    }

    for (int i = 0; i < resources.length; i++) {
      for (int j = i + 1; j < resources.length; j++) {
        Resource r1 = resources[i];
        Resource r2 = resources[j];

        double distance = calculateDistance(
          LatLng(r1.latitude, r1.longitude),
          LatLng(r2.latitude, r2.longitude),
        );

        graph[r1.id]![r2.id] = distance;
        graph[r2.id]![r1.id] = distance;
      }
    }

    // Dijkstra's algorithm implementation
    Map<String, double> distances = {};
    Map<String, String> previous = {};
    List<String> unvisited = [];

    for (String node in graph.keys) {
      distances[node] = double.infinity;
      previous[node] = '';
      unvisited.add(node);
    }

    distances[startId] = 0;

    while (unvisited.isNotEmpty) {
      unvisited.sort((a, b) => distances[a]!.compareTo(distances[b]!));
      String closest = unvisited.removeAt(0);

      if (closest == endId) {
        // Reconstruct path
        List<String> path = [];
        String current = endId;

        while (current != '') {
          path.insert(0, current);
          current = previous[current]!;
        }

        return path;
      }

      if (distances[closest] == double.infinity) {
        break;
      }

      for (String neighbor in graph[closest]!.keys) {
        if (!unvisited.contains(neighbor)) continue;

        double alt = distances[closest]! + graph[closest]![neighbor]!;
        if (alt < distances[neighbor]!) {
          distances[neighbor] = alt;
          previous[neighbor] = closest;
        }
      }
    }

    return []; // No path found
  }

  // Find shortest path from any location to any resource
  static List<Resource> findShortestPathFromLocation(
    List<Resource> resources,
    LatLng startLocation,
    String endResourceId,
  ) {
    if (resources.isEmpty) return [];

    // Create a temporary "virtual resource" for the start location
    Resource startVirtualResource = Resource(
      id: 'start_location',
      name: 'Start Location',
      description: 'Your current location',
      category: 'Location',
      latitude: startLocation.latitude,
      longitude: startLocation.longitude,
      isAvailable: true,
      owner: '',
      organization: '',
      createdAt: DateTime.now(),
    );

    // Add the virtual resource to the list temporarily
    List<Resource> allResources = [startVirtualResource] + resources;

    // Find the shortest path
    List<String> pathIds = findShortestPath(
      allResources,
      'start_location',
      endResourceId,
    );

    // Remove the virtual start location from the result
    List<Resource> pathResources = pathIds
        .where((id) => id != 'start_location')
        .map((id) => resources.firstWhere((r) => r.id == id))
        .toList();

    return pathResources;
  }

  // Find shortest path to the nearest resource of a specific category
  static List<Resource> findNearestResourcePath(
    List<Resource> resources,
    LatLng startLocation,
    String category,
  ) {
    if (resources.isEmpty) return [];

    // Filter resources by category if specified
    List<Resource> filteredResources = category == 'All'
        ? resources
        : resources.where((r) => r.category == category).toList();

    if (filteredResources.isEmpty) return [];

    // Find the nearest resource
    Resource nearestResource = filteredResources.reduce((a, b) {
      double distA = calculateDistance(
        startLocation,
        LatLng(a.latitude, a.longitude),
      );
      double distB = calculateDistance(
        startLocation,
        LatLng(b.latitude, b.longitude),
      );
      return distA < distB ? a : b;
    });


    return findShortestPathFromLocation(
      resources,
      startLocation,
      nearestResource.id,
    );
  }

  // Detect clusters of resources
  static Map<LatLng, List<Resource>> detectClusters(
      List<Resource> resources, double clusterRadius) {
    Map<LatLng, List<Resource>> clusters = {};

    for (Resource resource in resources) {
      bool addedToCluster = false;
      LatLng resourceLocation = LatLng(resource.latitude, resource.longitude);

      for (LatLng clusterCenter in clusters.keys) {
        double distance = calculateDistance(resourceLocation, clusterCenter);
        if (distance <= clusterRadius) {
          clusters[clusterCenter]!.add(resource);
          addedToCluster = true;
          break;
        }
      }

      if (!addedToCluster) {
        clusters[resourceLocation] = [resource];
      }
    }
    return clusters;
  }
}
