import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;
  Position? _position;
  Set<Marker> _markers = {};
  List<dynamic> _nearbyStores = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'Joylashuv xizmati o\'chirilgan';
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _error = 'Joylashuv ruxsati rad etildi';
            _isLoading = false;
          });
          return;
        }
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() => _position = pos);
      await _loadNearbyStores(pos.latitude, pos.longitude);
    } catch (e) {
      setState(() {
        _error = 'Joylashuvni aniqlab bo\'lmadi';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyStores(double lat, double lng) async {
    try {
      final result = await ApiClient.instance.getNearbyStores(lat, lng);
      final stores = result['stores'] as List<dynamic>;
      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('user'),
          position: LatLng(lat, lng),
          infoWindow: const InfoWindow(title: 'Siz bu yerdasiz'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue),
        ),
      };

      for (final store in stores) {
        markers.add(Marker(
          markerId: MarkerId(store['place_id'] ?? store['name']),
          position: LatLng(
            store['latitude'] as double,
            store['longitude'] as double,
          ),
          infoWindow: InfoWindow(
            title: store['name'],
            snippet: store['address'],
          ),
        ));
      }

      setState(() {
        _nearbyStores = stores;
        _markers = markers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Yaqin do\'konlarni yuklab bo\'lmadi';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yaqin do\'konlar')),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Yaqin do\'konlar qidirilmoqda...'),
                ],
              ),
            )
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_off,
                          size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(_error!,
                          style: const TextStyle(
                              color: AppTheme.textSecondary)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _error = null;
                          });
                          _initLocation();
                        },
                        child: const Text('Qayta urinish'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(
                            _position!.latitude,
                            _position!.longitude,
                          ),
                          zoom: 14,
                        ),
                        markers: _markers,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: (c) => _mapController = c,
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: _nearbyStores.isEmpty
                          ? const Center(
                              child: Text(
                                'Yaqin atrofda do\'konlar topilmadi',
                                style: TextStyle(
                                    color: AppTheme.textSecondary),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(12),
                              itemCount: _nearbyStores.length,
                              itemBuilder: (context, i) {
                                final store = _nearbyStores[i];
                                return ListTile(
                                  leading: const CircleAvatar(
                                    backgroundColor: AppTheme.primary,
                                    child: Icon(Icons.store,
                                        color: Colors.white, size: 18),
                                  ),
                                  title: Text(store['name'] ?? ''),
                                  subtitle: Text(store['address'] ?? ''),
                                  trailing: store['rating'] != null
                                      ? Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                color: AppTheme.warning,
                                                size: 14),
                                            Text('${store['rating']}'),
                                          ],
                                        )
                                      : null,
                                  onTap: () {
                                    _mapController?.animateCamera(
                                      CameraUpdate.newLatLng(LatLng(
                                        store['latitude'] as double,
                                        store['longitude'] as double,
                                      )),
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
