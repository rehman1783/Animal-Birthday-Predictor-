class Markings {
  final String id;
  final String ownerType; // 'animal', 'foal'
  final String ownerId;
  final String? leftSideImageUrl;
  final String? rightSideImageUrl;
  final String? headViewImageUrl;
  final String? headViewNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Markings({
    required this.id,
    required this.ownerType,
    required this.ownerId,
    this.leftSideImageUrl,
    this.rightSideImageUrl,
    this.headViewImageUrl,
    this.headViewNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_type': ownerType,
      'owner_id': ownerId,
      'left_side_image_url': leftSideImageUrl,
      'right_side_image_url': rightSideImageUrl,
      'head_view_image_url': headViewImageUrl,
      'head_view_notes': headViewNotes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Markings.fromJson(Map<String, dynamic> json) {
    return Markings(
      id: json['id'] as String? ?? '',
      ownerType: json['owner_type'] as String? ?? 'animal',
      ownerId: json['owner_id'] as String? ?? '',
      leftSideImageUrl: json['left_side_image_url'] as String?,
      rightSideImageUrl: json['right_side_image_url'] as String?,
      headViewImageUrl: json['head_view_image_url'] as String?,
      headViewNotes: json['head_view_notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Markings copyWith({
    String? id,
    String? ownerType,
    String? ownerId,
    String? leftSideImageUrl,
    String? rightSideImageUrl,
    String? headViewImageUrl,
    String? headViewNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Markings(
      id: id ?? this.id,
      ownerType: ownerType ?? this.ownerType,
      ownerId: ownerId ?? this.ownerId,
      leftSideImageUrl: leftSideImageUrl ?? this.leftSideImageUrl,
      rightSideImageUrl: rightSideImageUrl ?? this.rightSideImageUrl,
      headViewImageUrl: headViewImageUrl ?? this.headViewImageUrl,
      headViewNotes: headViewNotes ?? this.headViewNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
