import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class TopPerformers extends StatelessWidget {

  const TopPerformers({
    required this.hosts, required this.listings, super.key,
    this.onViewAllHosts,
    this.onViewAllListings,
  });
  final List<TopHost> hosts;
  final List<TopListing> listings;
  final VoidCallback? onViewAllHosts;
  final VoidCallback? onViewAllListings;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Performers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 20),
            
            // Top Hosts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mejores Anfitriones',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (onViewAllHosts != null)
                  TextButton(
                    onPressed: onViewAllHosts,
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (hosts.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay datos de anfitriones',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...hosts.take(3).map((host) => TopHostTile(host: host)),
            
            const SizedBox(height: 24),
            
            // Top Listings Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Mejores Listings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (onViewAllListings != null)
                  TextButton(
                    onPressed: onViewAllListings,
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (listings.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No hay datos de listings',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ...listings.take(3).map((listing) => TopListingTile(listing: listing)),
          ],
        ),
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<TopHost>('hosts', hosts));
    properties.add(IterableProperty<TopListing>('listings', listings));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onViewAllHosts', onViewAllHosts));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onViewAllListings', onViewAllListings));
  }
}

class TopHostTile extends StatelessWidget {

  const TopHostTile({
    required this.host, super.key,
    this.onTap,
  });
  final TopHost host;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: Text(
                host.name.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    host.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${host.bookings} reservas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${host.earnings.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${host.rating.toStringAsFixed(1)} ⭐',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TopHost>('host', host));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}

class TopListingTile extends StatelessWidget {

  const TopListingTile({
    required this.listing, super.key,
    this.onTap,
  });
  final TopListing listing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.purple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home,
                color: Colors.purple,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    listing.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${listing.bookings} reservas',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$${listing.revenue.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${listing.occupancyRate.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<TopListing>('listing', listing));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
  }
}

class TopHost {

  const TopHost({
    required this.id,
    required this.name,
    required this.earnings,
    required this.bookings,
    required this.rating,
    this.avatarUrl,
  });

  factory TopHost.fromMap(Map<String, dynamic> map) => TopHost(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      earnings: (map['earnings'] as num? ?? 0).toDouble(),
      bookings: map['bookings'] as int? ?? 0,
      rating: (map['rating'] as num? ?? 0).toDouble(),
      avatarUrl: map['avatarUrl'] as String?,
    );
  final String id;
  final String name;
  final double earnings;
  final int bookings;
  final double rating;
  final String? avatarUrl;

  Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'earnings': earnings,
      'bookings': bookings,
      'rating': rating,
      'avatarUrl': avatarUrl,
    };
}

class TopListing {

  const TopListing({
    required this.id,
    required this.title,
    required this.revenue,
    required this.bookings,
    required this.occupancyRate,
    this.imageUrl,
  });

  factory TopListing.fromMap(Map<String, dynamic> map) => TopListing(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      revenue: (map['revenue'] as num? ?? 0).toDouble(),
      bookings: map['bookings'] as int? ?? 0,
      occupancyRate: (map['occupancyRate'] as num? ?? 0).toDouble(),
      imageUrl: map['imageUrl'] as String?,
    );
  final String id;
  final String title;
  final double revenue;
  final int bookings;
  final double occupancyRate;
  final String? imageUrl;

  Map<String, dynamic> toMap() => {
      'id': id,
      'title': title,
      'revenue': revenue,
      'bookings': bookings,
      'occupancyRate': occupancyRate,
      'imageUrl': imageUrl,
    };
}

class CompactTopPerformers extends StatelessWidget {

  const CompactTopPerformers({
    required this.hosts, required this.listings, super.key,
  });
  final List<TopHost> hosts;
  final List<TopListing> listings;

  @override
  Widget build(BuildContext context) => Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Anfitriones',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...hosts.take(3).map(
                  (host) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          child: Text(
                            host.name.substring(0, 1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            host.name,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${host.earnings.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Listings',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...listings.take(3).map(
                  (listing) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Icon(
                            Icons.home,
                            size: 12,
                            color: Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            listing.title,
                            style: const TextStyle(fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '\$${listing.revenue.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<TopHost>('hosts', hosts));
    properties.add(IterableProperty<TopListing>('listings', listings));
  }
}