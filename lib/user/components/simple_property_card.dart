// lib/components/simple_property_card.dart

import 'package:flutter/material.dart';

import '../../common/models_user/property_model.dart';
import '../../utils/format.dart';

class SimplePropertyCard extends StatelessWidget {
  final Property property;

  const SimplePropertyCard({Key? key, required this.property}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Build a formatted address by joining the available address fields.
    final address = [
      property.houseNo,
      property.colonyName,
      property.city,
      property.taluqMandal,
      property.district,
      property.pincode,
    ].where((element) => element.isNotEmpty).join(', ');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Property type at top
            Text(
              property.propertyType,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Address
            Text(
              address,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            // Area in sqft and Rent Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${property.areaInSqft} sqft',
                  style: const TextStyle(fontSize: 14),
                ),
                Text(
                  '\$${formatPrice(property.rentPrice)}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
