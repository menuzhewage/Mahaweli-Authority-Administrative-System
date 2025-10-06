import 'dart:html' as html; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../data/models/resource.dart';
import '../data/services/database_service.dart';

class ResourceForm extends StatefulWidget {
  final Function()? onResourceAdded;
  

  const ResourceForm({Key? key, this.onResourceAdded}) : super(key: key);

  @override
  _ResourceFormState createState() => _ResourceFormState();
}

class _ResourceFormState extends State<ResourceForm> {
  
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _ownerController = TextEditingController();
  final _organizationController = TextEditingController();
  
  late MapController _mapController = MapController();
  
  String _selectedCategory = 'Tools';
  bool _isAvailable = true;
  LatLng? _selectedLocation;
  bool _showMap = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'Tools',
    'Seeds',
    'Machinery',
    'Equipment',
    'Other'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _ownerController.dispose();
    _organizationController.dispose();
      _mapController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _mapController = MapController();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 700),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Resource',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Close',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information Section
                      _buildSectionHeader('Basic Information'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Resource Name *',
                                prefixIcon: Icon(Icons.inventory_2_outlined),
                              ),
                              validator: (value) => value?.isEmpty ?? true
                                  ? 'Please enter a name'
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 1,
                            child: DropdownButtonFormField<String>(
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
                                });
                              },
                              decoration: const InputDecoration(
                                labelText: 'Category',
                                prefixIcon: Icon(Icons.category_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          prefixIcon: Icon(Icons.description_outlined),
                        ),
                        maxLines: 3,
                      ),

                      const SizedBox(height: 32),

                      // Location Section
                      _buildSectionHeader('Location'),
                      const SizedBox(height: 16),

                      if (!_showMap)
                        Row(
                          children: [
                            ElevatedButton.icon(
                              icon: const Icon(Icons.map_outlined),
                              label: const Text('Select on Map'),
                              onPressed: () => setState(() => _showMap = true),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.my_location_outlined),
                              label: const Text('Use Current Location'),
                              onPressed: _getCurrentLocation,
                            ),
                          ],
                        ),

                      if (_showMap) _buildMapSection(),

                      if (_selectedLocation != null && !_showMap)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Selected: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                                  '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.edit, size: 16),
                                onPressed: () =>
                                    setState(() => _showMap = true),
                                tooltip: 'Edit location',
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Owner Information Section
                      _buildSectionHeader('Owner Information'),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _ownerController,
                              decoration: const InputDecoration(
                                labelText: 'Owner',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _organizationController,
                              decoration: const InputDecoration(
                                labelText: 'Organization',
                                prefixIcon: Icon(Icons.business_outlined),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Availability Switch
                      SwitchListTile.adaptive(
                        title: const Text('Available for sharing'),
                        subtitle: const Text('Make this resource visible to others'),
                        value: _isAvailable,
                        onChanged: (value) =>
                            setState(() => _isAvailable = value),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  child: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Resource'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
    );
  }

  Widget _buildMapSection() {
    return Column(
      children: [
        Container(
          height: 300,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation ?? const LatLng(7.9625, 80.9844),
                initialZoom: 12.0,
                onTap: (tapPosition, point) {
                  setState(() => _selectedLocation = point);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                  userAgentPackageName: 'com.example.app',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        width: 40,
                        height: 40,
                        child: const Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            if (_selectedLocation != null)
              Expanded(
                child: Text(
                  'Selected: ${_selectedLocation!.latitude.toStringAsFixed(6)}, '
                  '${_selectedLocation!.longitude.toStringAsFixed(6)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            TextButton(
              onPressed: () => setState(() => _showMap = false),
              child: const Text('Hide Map'),
            ),
          ],
        ),
      ],
    );
  }
  Future<void> _getCurrentLocation() async {
  try {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar('Location services are disabled');
      return;
    }

    // Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar('Location permissions are denied');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar('Location permissions are permanently denied');
      return;
    }

    // Get current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _selectedLocation = LatLng(
        position.latitude,
        position.longitude,
      );
      _showMap = true;
    });

    // Center the map on the new location
    _mapController.move(_selectedLocation!, 15.0);
    _showSnackBar('Location set successfully!', isError: false);

  } catch (e) {
    _showSnackBar('Error getting location: ${e.toString()}');
  }
}

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedLocation == null) {
      _showSnackBar('Please select a location');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final newResource = Resource(
        name: _nameController.text,
        category: _selectedCategory,
        description: _descriptionController.text,
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        isAvailable: _isAvailable,
        owner: _ownerController.text,
        organization: _organizationController.text,
        createdAt: DateTime.now(),
      );

      await DatabaseService().addResource(newResource);
      
      if (widget.onResourceAdded != null) {
        widget.onResourceAdded!();
      }
      
      Navigator.of(context).pop();
      _showSnackBar('Resource added successfully!', isError: false);
      
    } catch (e) {
      _showSnackBar('Error saving resource: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}