import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:timeago/timeago.dart' as timeago;

class UserList extends StatelessWidget {

  const UserList({
    required this.users, super.key,
    this.onUserTap,
    this.onUserEdit,
    this.onUserDelete,
    this.onSearch,
    this.isLoading = false,
    this.searchQuery,
  });
  final List<AdminUser> users;
  final Function(AdminUser)? onUserTap;
  final Function(AdminUser)? onUserEdit;
  final Function(AdminUser)? onUserDelete;
  final Function(String)? onSearch;
  final bool isLoading;
  final String? searchQuery;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Usuarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  '${users.length} usuarios',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Search Bar
            if (onSearch != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: TextField(
                  onChanged: onSearch,
                  decoration: InputDecoration(
                    hintText: 'Buscar usuarios...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.blue),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            
            // Loading State
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              )
            // Empty State
            else if (users.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        searchQuery?.isNotEmpty ?? false
                            ? 'No se encontraron usuarios'
                            : 'No hay usuarios registrados',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              )
            // User List
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: users.length,
                separatorBuilder: (context, index) => const Divider(
                  height: 1,
                  color: Colors.grey,
                ),
                itemBuilder: (context, index) {
                  final user = users[index];
                  return UserTile(
                    user: user,
                    onTap: onUserTap != null ? () => onUserTap!(user) : null,
                    onEdit: onUserEdit != null ? () => onUserEdit!(user) : null,
                    onDelete: onUserDelete != null ? () => onUserDelete!(user) : null,
                  );
                },
              ),
          ],
        ),
      ),
    );

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<AdminUser>('users', users));
    properties.add(ObjectFlagProperty<Function(AdminUser p1)?>.has('onUserTap', onUserTap));
    properties.add(ObjectFlagProperty<Function(AdminUser p1)?>.has('onUserEdit', onUserEdit));
    properties.add(ObjectFlagProperty<Function(AdminUser p1)?>.has('onUserDelete', onUserDelete));
    properties.add(ObjectFlagProperty<Function(String p1)?>.has('onSearch', onSearch));
    properties.add(DiagnosticsProperty<bool>('isLoading', isLoading));
    properties.add(StringProperty('searchQuery', searchQuery));
  }
}

class UserTile extends StatelessWidget {

  const UserTile({
    required this.user, super.key,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });
  final AdminUser user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: _getUserTypeColor(user.type).withOpacity(0.1),
              child: user.avatarUrl?.isNotEmpty ?? false
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        user.avatarUrl!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                            user.name.substring(0, 1).toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getUserTypeColor(user.type),
                            ),
                          ),
                      ),
                    )
                  : Text(
                      user.name.substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _getUserTypeColor(user.type),
                      ),
                    ),
            ),
            const SizedBox(width: 16),
            
            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      UserStatusChip(status: user.status),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      UserTypeChip(type: user.type),
                      const SizedBox(width: 8),
                      Text(
                        'Registrado ${timeago.format(user.createdAt, locale: 'es')}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Actions
            if (onEdit != null || onDelete != null)
              PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      onEdit?.call();
                      break;
                    case 'delete':
                      onDelete?.call();
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (onEdit != null)
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  if (onDelete != null)
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Eliminar', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                ],
                child: const Icon(
                  Icons.more_vert,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );

  Color _getUserTypeColor(UserType type) {
    switch (type) {
      case UserType.admin:
        return Colors.red;
      case UserType.host:
        return Colors.blue;
      case UserType.guest:
        return Colors.green;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<AdminUser>('user', user));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onTap', onTap));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onEdit', onEdit));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onDelete', onDelete));
  }
}

class UserStatusChip extends StatelessWidget {

  const UserStatusChip({required this.status, super.key});
  final UserStatus status;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusColor().withOpacity(0.3),
        ),
      ),
      child: Text(
        _getStatusText(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getStatusColor(),
        ),
      ),
    );

  Color _getStatusColor() {
    switch (status) {
      case UserStatus.active:
        return Colors.green;
      case UserStatus.inactive:
        return Colors.orange;
      case UserStatus.suspended:
        return Colors.red;
    }
  }

  String _getStatusText() {
    switch (status) {
      case UserStatus.active:
        return 'Activo';
      case UserStatus.inactive:
        return 'Inactivo';
      case UserStatus.suspended:
        return 'Suspendido';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<UserStatus>('status', status));
  }
}

class UserTypeChip extends StatelessWidget {

  const UserTypeChip({required this.type, super.key});
  final UserType type;

  @override
  Widget build(BuildContext context) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _getTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        _getTypeText(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: _getTypeColor(),
        ),
      ),
    );

  Color _getTypeColor() {
    switch (type) {
      case UserType.admin:
        return Colors.red;
      case UserType.host:
        return Colors.blue;
      case UserType.guest:
        return Colors.green;
    }
  }

  String _getTypeText() {
    switch (type) {
      case UserType.admin:
        return 'Admin';
      case UserType.host:
        return 'Anfitrión';
      case UserType.guest:
        return 'Huésped';
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(EnumProperty<UserType>('type', type));
  }
}

class AdminUser {

  const AdminUser({
    required this.id,
    required this.name,
    required this.email,
    required this.type,
    required this.status,
    required this.createdAt,
    this.lastLoginAt,
    this.avatarUrl,
    this.bookingsCount = 0,
    this.totalSpent = 0.0,
    this.totalEarned = 0.0,
  });

  factory AdminUser.fromMap(Map<String, dynamic> map) => AdminUser(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      type: UserType.values.firstWhere(
        (e) => e.toString().split('.').last == map['type'] as String?,
        orElse: () => UserType.guest,
      ),
      status: UserStatus.values.firstWhere(
        (e) => e.toString().split('.').last == map['status'] as String?,
        orElse: () => UserStatus.active,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastLoginAt: map['lastLoginAt'] != null
          ? DateTime.parse(map['lastLoginAt'] as String)
          : null,
      avatarUrl: map['avatarUrl'] as String?,
      bookingsCount: map['bookingsCount'] as int? ?? 0,
      totalSpent: (map['totalSpent'] as num? ?? 0).toDouble(),
      totalEarned: (map['totalEarned'] as num? ?? 0).toDouble(),
    );
  final String id;
  final String name;
  final String email;
  final UserType type;
  final UserStatus status;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final String? avatarUrl;
  final int bookingsCount;
  final double totalSpent;
  final double totalEarned;

  Map<String, dynamic> toMap() => {
      'id': id,
      'name': name,
      'email': email,
      'type': type.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
      'avatarUrl': avatarUrl,
      'bookingsCount': bookingsCount,
      'totalSpent': totalSpent,
      'totalEarned': totalEarned,
    };
}

enum UserType { admin, host, guest }

enum UserStatus { active, inactive, suspended }

class CompactUserList extends StatelessWidget {

  const CompactUserList({
    required this.users, super.key,
    this.maxItems = 5,
    this.onViewAll,
  });
  final List<AdminUser> users;
  final int maxItems;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    final displayUsers = users.take(maxItems).toList();

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Usuarios Recientes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  child: const Text('Ver todos'),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (displayUsers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay usuarios',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            ...displayUsers.map(
              (user) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: _getUserTypeColor(user.type).withOpacity(0.1),
                      child: Text(
                        user.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getUserTypeColor(user.type),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    UserTypeChip(type: user.type),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getUserTypeColor(UserType type) {
    switch (type) {
      case UserType.admin:
        return Colors.red;
      case UserType.host:
        return Colors.blue;
      case UserType.guest:
        return Colors.green;
    }
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IterableProperty<AdminUser>('users', users));
    properties.add(IntProperty('maxItems', maxItems));
    properties.add(ObjectFlagProperty<VoidCallback?>.has('onViewAll', onViewAll));
  }
}