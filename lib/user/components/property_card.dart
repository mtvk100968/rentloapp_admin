// lib/components/property_card.dart

import 'package:flutter/material.dart';
import '../../common/models_user/property_model.dart';
import '../../utils/format.dart';

class PropertyCard extends StatefulWidget {
  final Property property;
  final bool isFavorited;
  final ValueChanged<bool> onFavoriteToggle;
  final VoidCallback onTap; // Callback for taps

  const PropertyCard({
    Key? key,
    required this.property,
    required this.isFavorited,
    required this.onFavoriteToggle,
    required this.onTap,
  }) : super(key: key);

  @override
  _PropertyCardState createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  late bool isFavorited;
  int currentPage = 0; // For Carousel Dots

  @override
  void initState() {
    super.initState();
    isFavorited = widget.isFavorited;
  }

  void _toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });
    widget.onFavoriteToggle(isFavorited);
  }

  @override
  void didUpdateWidget(covariant PropertyCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorited != widget.isFavorited) {
      setState(() {
        isFavorited = widget.isFavorited;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return InkWell(
      onTap: widget.onTap, // Navigate to property details
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            Center(
              child: SizedBox(
                width: screenWidth * 0.95,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    children: [
                      AspectRatio(
                        aspectRatio: 16 / 10,
                        child: PageView.builder(
                          itemCount: widget.property.images.length,
                          onPageChanged: (index) {
                            setState(() {
                              currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return Image.network(
                              widget.property.images[index],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              loadingBuilder: (context, child, progress) {
                                if (progress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                        (progress.expectedTotalBytes ?? 1)
                                        : null,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset(
                                  'assets/images/no_image_available.png',
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                );
                              },
                            );
                          },
                        ),
                      ),
                      // Heart Icon
                      Positioned(
                        top: 10,
                        right: 10,
                        child: GestureDetector(
                          onTap: _toggleFavorite,
                          child: Icon(
                            isFavorited ? Icons.favorite : Icons.favorite_border,
                            size: 30,
                            color: Colors.pink,
                            shadows: isFavorited
                                ? [Shadow(offset: Offset(0, 0), blurRadius: 2, color: Colors.white)]
                                : null,
                          ),
                        ),
                      ),
                      // Carousel Dots
                      Positioned(
                        bottom: 8,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            widget.property.images.length,
                                (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index == currentPage
                                    ? Colors.white
                                    : Colors.white.withOpacity(0.5),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Property Type Badge
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.property.propertyType,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            // Property Details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Address Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property.colonyName,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.property.taluqMandal,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey),
                        ),
                        Text(
                          widget.property.district,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  // Price and Area Details
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Rent Price (already a double)
                      Text(
                        '${formatPrice(widget.property.rentPrice)}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 4),
                      // Area: Convert the int to double using toDouble()
                      Text(
                        '${formatValue(widget.property.areaInSqft.toDouble())} sft',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
