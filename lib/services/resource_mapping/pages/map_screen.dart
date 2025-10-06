// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../data/models/resource.dart';
import '../data/services/database_service.dart';
import '../data/services/distance_service.dart';
import '../utils/export_utils.dart';
import '../widgets/cluster_indicator.dart';
import '../widgets/resource_card.dart';
import '../widgets/resource_form.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Resource> _resources = [];
  Resource? _selectedResource;
  bool _showResourcesList = false;
  String _selectedCategory = 'All';
  LatLng? _startLocation;
  List<Resource> _pathResources = [];
  bool _showPath = false;

  final List<String> _categories = [
    'All',
    'Tools',
    'Seeds',
    'Machinery',
    'Equipment',
    'Other'
  ];

  void _handleMapTap(TapPosition tapPosition, LatLng position) {
    setState(() {
      _startLocation = position;
      _showPath = false;
      _pathResources.clear();
    });
  }

  void _calculatePathToResource(Resource resource) {
    if (_startLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on the map to set a starting location first')),
      );
      return;
    }

    setState(() {
      _pathResources = DistanceService.findShortestPathFromLocation(
        _resources,
        _startLocation!,
        resource.id,
      );
      _showPath = true;
      _selectedResource = resource;
    });
  }

  void _findNearestResource() {
    if (_startLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please tap on the map to set a starting location first')),
      );
      return;
    }

    setState(() {
      _pathResources = DistanceService.findNearestResourcePath(
        _resources,
        _startLocation!,
        _selectedCategory,
      );
      _showPath = true;
      if (_pathResources.isNotEmpty) {
        _selectedResource = _pathResources.last;
        _mapController.move(
          LatLng(_selectedResource!.latitude, _selectedResource!.longitude),
          15.0,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No resources found in this category')),
        );
      }
    });
  }

  double _calculateTotalDistance() {
    if (_startLocation == null || _pathResources.isEmpty) return 0;

    double totalDistance = DistanceService.calculateDistance(
      _startLocation!,
      LatLng(_pathResources.first.latitude, _pathResources.first.longitude),
    );

    for (int i = 0; i < _pathResources.length - 1; i++) {
      totalDistance += DistanceService.calculateDistance(
        LatLng(_pathResources[i].latitude, _pathResources[i].longitude),
        LatLng(_pathResources[i + 1].latitude, _pathResources[i + 1].longitude),
      );
    }

    return totalDistance;
  }

  void _clearPath() {
    setState(() {
      _startLocation = null;
      _showPath = false;
      _pathResources.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final databaseService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Community Resource Map'),
        actions: [
          DropdownButton<String>(
            value: _selectedCategory,
            items: _categories.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
                _showPath = false;
                _pathResources.clear();
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () {
              setState(() {
                _showResourcesList = !_showResourcesList;
              });
            },
          ),
          if (_startLocation != null)
            IconButton(
              icon: const Icon(Icons.near_me),
              onPressed: _findNearestResource,
              tooltip: 'Find nearest resource',
            ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              List<Resource> resources = await databaseService.getAllResources();
              ExportUtils.exportToCSV(resources);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Data exported successfully')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: _clearPath,
            tooltip: 'Clear path',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // await authService.signOut();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('resources').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          _resources = snapshot.data!.docs.map((doc) {
            return Resource.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          if (_selectedCategory != 'All') {
            _resources = _resources
                .where((resource) => resource.category == _selectedCategory)
                .toList();
          }

          Map<LatLng, List<Resource>> clusters =
              DistanceService.detectClusters(_resources, 10.0);

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(7.9625, 80.9844),
                  initialZoom: 10.0,
                  onTap: _handleMapTap,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: _resources.map((resource) {
                      return Marker(
                        point: LatLng(resource.latitude, resource.longitude),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedResource = resource;
                            });
                          },
                          child: Icon(
                            Icons.location_pin,
                            color: resource.isAvailable ? Colors.green : Colors.red,
                            size: 30,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  MarkerLayer(
                    markers: clusters.entries.map((entry) {
                      return Marker(
                        point: entry.key,
                        child: ClusterIndicator(
                          count: entry.value.length,
                        ),
                      );
                    }).toList(),
                  ),
                  // Add marker for start location
                  if (_startLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _startLocation!,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  // Add polyline layer for path
                  if (_showPath && _pathResources.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [
                            _startLocation!,
                            ..._pathResources.map((resource) => 
                              LatLng(resource.latitude, resource.longitude)),
                          ],
                          color: Colors.blue,
                          strokeWidth: 4,
                        ),
                      ],
                    ),
                ],
              ),
              if (_selectedResource != null)
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: ResourceCard(
                    resource: _selectedResource!,
                    onClose: () {
                      setState(() {
                        _selectedResource = null;
                      });
                    },
                    onShowPath: () => _calculatePathToResource(_selectedResource!),
                  ),
                ),
              if (_showResourcesList)
                Positioned(
                  top: 80,
                  right: 20,
                  width: 300,
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                            'Resources List',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _resources.length,
                            itemBuilder: (context, index) {
                              Resource resource = _resources[index];
                              return ListTile(
                                title: Text(resource.name),
                                subtitle: Text(resource.category),
                                trailing: Icon(
                                  Icons.circle,
                                  color: resource.isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  size: 12,
                                ),
                                onTap: () {
                                  setState(() {
                                    _selectedResource = resource;
                                    _mapController.move(
                                        LatLng(
                                            resource.latitude,
                                            resource.longitude),
                                        15.0);
                                  });
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              // Add path information panel
              if (_showPath && _pathResources.isNotEmpty)
                Positioned(
                  top: 80,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Path to ${_selectedResource?.name}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text('Distance: ${_calculateTotalDistance().toStringAsFixed(2)} km'),
                        Text('Steps: ${_pathResources.length} resources'),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const ResourceForm(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}