enum SeatStatus {
  available,
  selected,
  booked,
}

enum SeatTier {
  standard,
  premium,
  vip,
}

class SeatModel {
  final String id; // e.g. "E5"
  final String row; // e.g. "E"
  final int number; // e.g. 5
  final SeatTier tier;
  final double price;
  SeatStatus status;

  SeatModel({
    required this.id,
    required this.row,
    required this.number,
    required this.tier,
    required this.price,
    this.status = SeatStatus.available,
  });

  String get tierName {
    switch (tier) {
      case SeatTier.vip:
        return 'VIP Recliner';
      case SeatTier.premium:
        return 'Premium';
      case SeatTier.standard:
        return 'Standard';
    }
  }

  SeatModel copyWith({
    SeatStatus? status,
  }) {
    return SeatModel(
      id: id,
      row: row,
      number: number,
      tier: tier,
      price: price,
      status: status ?? this.status,
    );
  }
}
