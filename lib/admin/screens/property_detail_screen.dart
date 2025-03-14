import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_controller.dart'
as custom_carousel_controller;
import 'package:google_maps_flutter/google_maps_flutter.dart';


class PropertyDetailScreen extends StatefulWidget {
  final String propertyId;

  const PropertyDetailScreen({
    Key? key,
    required this.propertyId,
  }) : super(key: key);

  @override
  _PropertyDetailScreenState createState() => _PropertyDetailScreenState();
}

class _PropertyDetailScreenState extends State<PropertyDetailScreen> {
  Map<String, dynamic>? propertyDetails;
  int _currentImageIndex = 0;
  final custom_carousel_controller.CarouselSliderController
  _carouselController =
  custom_carousel_controller.CarouselSliderController();

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
  }

  Future<void> _fetchPropertyDetails() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection('properties')
          .doc(widget.propertyId)
          .get();

      if (snapshot.exists) {
        setState(() {
          propertyDetails = snapshot.data();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Property not found")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load property details: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Property Details"),
      ),
      body: propertyDetails == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (propertyDetails!['images'] != null)
              Stack(
                children: [
                  CarouselSlider(
                    carouselController: _carouselController,
                    items: (propertyDetails!['images'] as List)
                        .map(
                          (imageUrl) => Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                    )
                        .toList(),
                    options: CarouselOptions(
                      height: 300.0,
                      autoPlay: false,
                      enableInfiniteScroll: false,
                      viewportFraction: 1.0,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    left: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios),
                      color: Colors.white,
                      onPressed: () {
                        if (_currentImageIndex > 0) {
                          setState(() {
                            _currentImageIndex--;
                          });
                          _carouselController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_forward_ios),
                      color: Colors.white,
                      onPressed: () {
                        if (_currentImageIndex <
                            (propertyDetails!['images'] as List).length -
                                1) {
                          setState(() {
                            _currentImageIndex++;
                          });
                          _carouselController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Text(
                        "${_currentImageIndex + 1}/${(propertyDetails!['images'] as List).length}",
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            _buildPropertyDetailItem(
                "Address", propertyDetails!['address']),
            _buildPropertyDetailItem("City", propertyDetails!['city']),
            _buildPropertyDetailItem(
                "District", propertyDetails!['district']),
            _buildPropertyDetailItem("State", propertyDetails!['state']),
            _buildPropertyDetailItem(
                "Pincode", propertyDetails!['pincode']),
            _buildPropertyDetailItem(
                "Property Type", propertyDetails!['propertyType']),
            _buildPropertyDetailItem(
                "Land Area", "${propertyDetails!['landArea']} sq ft"),
            _buildPropertyDetailItem(
                "Price Per Unit", "${propertyDetails!['pricePerUnit']}"),
            _buildPropertyDetailItem(
                "Total Price", "${propertyDetails!['totalPrice']}"),
            // _buildPropertyDetailItem(
            //     "Latitude", "${propertyDetails!['latitude']}"),
            // _buildPropertyDetailItem(
            //     "Longitude", "${propertyDetails!['longitude']}"),

            if (propertyDetails!['latitude'] != null &&
                propertyDetails!['longitude'] != null)
              _buildGoogleMapPreview(
                propertyDetails!['latitude'],
                propertyDetails!['longitude'],
              ),

            const SizedBox(height: 16),
            const Text(
              "Agents Assigned",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            propertyDetails!['agents'] != null
                ? Column(
              children: List.generate(
                (propertyDetails!['agents'] as List).length,
                    (index) {
                  final agent = propertyDetails!['agents'][index];
                  return ListTile(
                    title: Text(agent['name'] ?? 'Unknown'),
                    subtitle: Text("ID: ${agent['id']}"),
                  );
                },
              ),
            )
                : const Text("No agents assigned"),
            const SizedBox(height: 16),
            const Text(
              "Videos",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            propertyDetails!['videos'] != null
                ? Column(
              children: List.generate(
                (propertyDetails!['videos'] as List).length,
                    (index) {
                  final videoUrl =
                  propertyDetails!['videos'][index];
                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 8.0),
                    child: TextButton(
                      onPressed: () {
                        // Open video URL
                      },
                      child: Text("Video ${index + 1}"),
                    ),
                  );
                },
              ),
            )
                : const Text("No videos available"),
            const SizedBox(height: 16),
            const Text(
              "Documents",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            propertyDetails!['documents'] != null &&
                propertyDetails!['documents'] is List
                ? Column(
              children: List.generate(
                (propertyDetails!['documents'] as List).length,
                    (index) {
                  final document =
                  propertyDetails!['documents'][index];
                  if (document is Map<String, dynamic> &&
                      document.containsKey('id')) {
                    final documentId = document['id'];
                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Document ID: $documentId"),
                    );
                  } else {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Invalid document format"),
                    );
                  }
                },
              ),
            )
                : const Text("No documents available"),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleMapPreview(double latitude, double longitude) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        height: 400, // Adjust height based on your layout
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(latitude, longitude),
            zoom: 15, // Adjust zoom level as needed
          ),
          markers: {
            Marker(
              markerId: const MarkerId('property_location'),
              position: LatLng(latitude, longitude),
              infoWindow: const InfoWindow(
                title: 'Property Location',
              ),
            ),
          },
        ),
      ),
    );
  }

  Widget _buildPropertyDetailItem(String title, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(
            "$title: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
