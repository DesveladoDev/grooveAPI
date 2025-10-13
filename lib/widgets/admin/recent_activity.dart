import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;

class RecentActivity extends StatelessWidget {

  const RecentActivity({
    required this.activities, super.key,
    this.maxItems,
    this.onViewAll,
  });
  final List<ActivityItem> activities;
  final int? maxItems;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final displayActivities = maxItems != null
        ? activities.take(maxItems!).toList()
        : activities;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Actividad Reciente',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                if (onViewAll != null)
                  TextButton(
                    onPressed: onViewAll,
                    child: const Text('Ver todo'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (displayActivities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No hay actividad reciente',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayActivities.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final activity = displayActivities[index];
                  return ActivityTile(
                    activity: activity,
                    isLast: index == displayActivities.length - 1,
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<ActivityItem>('activities', activities));
    properties.add(IntProperty('maxItems', maxItems));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onViewAll', onViewAll));
  }
}

class ActivityTile extends StatelessWidget {

  const ActivityTile({
    required this.activity, super.key,
    this.isLast = false,
  });
  final ActivityItem activity;
  final bool isLast;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getActivityColor(activity.type).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              _getActivityIcon(activity.type),
              color: _getActivityColor(activity.type),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.description,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      timeago.format(activity.timestamp, locale: 'es'),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    if (activity.metadata != null) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          _getMetadataText(activity.metadata!),
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

  Color _getActivityColor(String type) {
    switch (type) {
      case 'booking_created':
        return Colors.blue;
      case 'booking_confirmed':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'payment_completed':
        return Colors.purple;
      case 'host_verified':
        return Colors.orange;
      case 'user_registered':
        return Colors.teal;
      case 'listing_created':
        return Colors.indigo;
      case 'review_posted':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getActivityIcon(String type) {
    switch (type) {
      case 'booking_created':
        return Icons.book_online;
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'payment_completed':
        return Icons.payment;
      case 'host_verified':
        return Icons.verified;
      case 'user_registered':
        return Icons.person_add;
      case 'listing_created':
        return Icons.add_home;
      case 'review_posted':
        return Icons.star;
      default:
        return Icons.info;
    }
  }

  String _getMetadataText(Map<String, dynamic> metadata) {
    if (metadata.containsKey('amount')) {
      return '\$${metadata['amount'].toStringAsFixed(2)}';
    }
    if (metadata.containsKey('bookingId')) {
      return '#${metadata['bookingId'].toString().substring(0, 8)}';
    }
    if (metadata.containsKey('listingId')) {
      return 'Listing #${metadata['listingId'].toString().substring(0, 8)}';
    }
    return '';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<ActivityItem>('activity', activity));
    properties.add(DiagnosticsProperty<bool>('isLast', isLast));
  }
}

class ActivityItem {

  const ActivityItem({
    required this.id,
    required this.type,
    required this.description,
    required this.timestamp,
    this.userId,
    this.metadata,
  });

  factory ActivityItem.fromMap(Map<String, dynamic> map) => ActivityItem(
      id: map['id'] as String? ?? '',
      type: map['type'] as String? ?? '',
      description: map['description'] as String? ?? '',
      timestamp: map['timestamp'] is DateTime
          ? map['timestamp'] as DateTime
          : DateTime.parse(map['timestamp'] as String),
      userId: map['userId'] as String?,
      metadata: map['metadata'] as Map<String, dynamic>?,
    );
  final String id;
  final String type;
  final String description;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toMap() => {
      'id': id,
      'type': type,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'metadata': metadata,
    };
}

class CompactActivityList extends StatelessWidget {

  const CompactActivityList({
    required this.activities, super.key,
    this.maxItems = 5,
  });
  final List<ActivityItem> activities;
  final int maxItems;

  @override
  Widget build(BuildContext context) {
    final displayActivities = activities.take(maxItems).toList();

    return Container(
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
            'Actividad',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...displayActivities.map(
            (activity) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: _getActivityColor(activity.type),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      activity.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    timeago.format(activity.timestamp, locale: 'es'),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String type) {
    switch (type) {
      case 'booking_created':
        return Colors.blue;
      case 'booking_confirmed':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'payment_completed':
        return Colors.purple;
      case 'host_verified':
        return Colors.orange;
      case 'user_registered':
        return Colors.teal;
      case 'listing_created':
        return Colors.indigo;
      case 'review_posted':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<ActivityItem>('activities', activities));
    properties.add(IntProperty('maxItems', maxItems));
  }
}