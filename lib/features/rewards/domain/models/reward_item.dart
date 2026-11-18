class RewardItem {
  final String id;
  final String title;
  final String description;
  final int costStars;
  final String icon;
  final int timesRedeemed;

  const RewardItem({
    required this.id,
    required this.title,
    this.description = '',
    required this.costStars,
    this.icon = '🎁',
    this.timesRedeemed = 0,
  });

  RewardItem copyWith({
    String? id,
    String? title,
    String? description,
    int? costStars,
    String? icon,
    int? timesRedeemed,
  }) {
    return RewardItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      costStars: costStars ?? this.costStars,
      icon: icon ?? this.icon,
      timesRedeemed: timesRedeemed ?? this.timesRedeemed,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'costStars': costStars,
      'icon': icon,
      'timesRedeemed': timesRedeemed,
    };
  }

  factory RewardItem.fromMap(Map<String, dynamic> map) {
    return RewardItem(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      costStars: map['costStars'] as int? ?? 10,
      icon: map['icon'] as String? ?? '🎁',
      timesRedeemed: map['timesRedeemed'] as int? ?? 0,
    );
  }
}
