import 'package:flutter/material.dart';
import 'package:makan_mate/features/home/domain/entities/restaurant_entity.dart';

class RestaurantDetailScreen extends StatelessWidget {
  const RestaurantDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RestaurantEntity r =
        ModalRoute.of(context)!.settings.arguments as RestaurantEntity;

    final vendor = r.vendor;

    final imageUrl = vendor.bannerImageUrl ??
        vendor.businessLogoUrl ??
        'assets/images/logos/image-not-found.jpg';

    final rating = vendor.ratingAverage?.toStringAsFixed(1) ?? '-';

    final hasHalal = vendor.certifications
        .any((cert) => cert.type.toLowerCase() == "halal");

    return Scaffold(
      appBar: AppBar(
        title: Text(vendor.businessName),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.network(
              imageUrl,
              height: 230,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.businessName,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    vendor.businessAddress,
                    style: const TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 12),

                  Text("Cuisine: ${vendor.cuisineType ?? '-'}"),
                  Text("Price Range: ${vendor.priceRange ?? '-'}"),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(rating),
                      if (hasHalal)
                        const Padding(
                          padding: EdgeInsets.only(left: 8),
                          child: Text(
                            "Halal",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Text(
                    vendor.shortDescription,
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    "Menu Items",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Column(
                    children: r.menuItems.map((m) {
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(m.imageUrl),
                        ),
                        title: Text(m.name),
                        subtitle: Text(m.description),
                        trailing: Text("RM ${m.price.toStringAsFixed(2)}"),
                      );
                    }).toList(),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
