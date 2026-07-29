// Folder: organizational container for HistoryEntries.
class Folder {
  Folder({
    required this.id,
    required this.name,
    this.color = 0xFF0E7C6B,
    this.icon = 'folder',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Folder.fromJson(Map<String, dynamic> json) => Folder(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as int? ?? 0xFF0E7C6B,
        icon: json['icon'] as String? ?? 'folder',
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? ''),
        updatedAt: DateTime.tryParse(json['updatedAt'] as String? ?? ''),
      );

  final String id;
  final String name;
  final int color;
  final String icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  Folder copyWith({
    String? id,
    String? name,
    int? color,
    String? icon,
    DateTime? updatedAt,
  }) {
    return Folder(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Folder && other.id == id);

  @override
  int get hashCode => id.hashCode;
}

class Tag {
  const Tag({
    required this.id,
    required this.name,
    this.color = 0xFF888888,
  });

  factory Tag.fromJson(Map<String, dynamic> json) => Tag(
        id: json['id'] as String,
        name: json['name'] as String,
        color: json['color'] as int? ?? 0xFF888888,
      );

  final String id;
  final String name;
  final int color;

  Tag copyWith({String? name, int? color}) => Tag(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'color': color,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Tag && other.id == id);

  @override
  int get hashCode => id.hashCode;
}
