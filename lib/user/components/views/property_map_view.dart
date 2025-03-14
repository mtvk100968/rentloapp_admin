import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../common/models_user/property_model.dart';
import '../../../utils/format.dart';
import '../../screens/property_details_screen.dart';
import '../maps_related/marker.dart';
import '../property_card2.dart';

class PropertyMapView extends StatefulWidget {
  final List<Property> properties;
  final LatLng? center; // Optional parameter to specify initial center

  const PropertyMapView({
    Key? key,
    required this.properties,
    this.center,
  }) : super(key: key);

  @override
  PropertyMapViewState createState() => PropertyMapViewState();
}

class PropertyMapViewState extends State<PropertyMapView> {
  late GoogleMapController mapController;

  Set<Marker> _markers = {};

  // Create a ClusterManagerId
  final ClusterManagerId _clusterManagerId = const ClusterManagerId('propertyClusterManager');
  late ClusterManager _clusterManager;

  @override
  void initState() {
    super.initState();

    // Initialize ClusterManager
    _clusterManager = ClusterManager(
      clusterManagerId: _clusterManagerId,
      onClusterTap: _onClusterTap,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _addCustomMarkers();
    });
  }

  Future<void> _addCustomMarkers() async {
    Set<Marker> markers = {};
    print("Number of properties: ${widget.properties.length}");

    for (Property property in widget.properties) {
      // Format the price
      final String priceText = formatPrice(property.rentPrice.toDouble());

      // Create custom marker with the formatted price
      final BitmapDescriptor customIcon =
      await CustomMarker.createMarker(priceText);

      // Create marker
      markers.add(
        Marker(
          markerId: MarkerId(property.propertyId),
          position: LatLng(property.latitude, property.longitude),
          icon: customIcon,
          onTap: () => _showPropertyCard(property),
          // Associate marker with ClusterManager
          clusterManagerId: _clusterManagerId,
        ),
      );
    }

    setState(() {
      _markers = markers;
      print("Markers added: ${_markers.length}");
    });
  }

  void _onClusterTap(Cluster cluster) async {
    // Retrieve the current camera position
    final LatLng currentCenter = await mapController.getLatLng(
      ScreenCoordinate(
        x: (MediaQuery.of(context).size.width / 2).round(),
        y: (MediaQuery.of(context).size.height / 2).round(),
      ),
    );

    // Zoom in on the cluster
    final double newZoomLevel = 12.0;
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: cluster.position,
          zoom: newZoomLevel,
        ),
      ),
    );
  }

  void _showPropertyCard(Property property) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return PropertyCard2(
          property: property,
          isFavorited: false,
          onFavoriteToggle: (bool newValue) {},
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PropertyDetailsScreen(property: property),
              ),
            );
          },
        );
      },
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;

    // Add markers once map is created
    _addCustomMarkers();

    // If a center is provided, animate there; otherwise default to India
    if (widget.center != null) {
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: widget.center!,
            zoom: 14, // adjust as you like
          ),
        ),
      );
    } else {
      // Default to India or any fallback
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: LatLng(20.5937, 78.9629),
            zoom: 5,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SizedBox.expand(
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: const CameraPosition(
            target: LatLng(20.5937, 78.9629),
            zoom: 5,
          ),
          onMapCreated: _onMapCreated,
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          clusterManagers: {_clusterManager},
        ),
      ),
    );
  }
}
