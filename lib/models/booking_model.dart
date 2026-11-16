class BookingModel {
  final String id;
  final String movieId;
  final String movieTitle;
  final String posterUrl;
  final String backdropUrl;
  final String theatreId;
  final String theatreName;
  final String theatreAddress;
  final String screen;
  final String format;
  final String showDate;
  final String showTime;
  final List<String> seats;
  final String seatTier;
  final int ticketCount;
  final double ticketPrice;
  final double convenienceFee;
  final double tax;
  final double discount;
  final double totalAmount;
  final String paymentMethod;
  final String bookingTimestamp;
  String status; // 'CONFIRMED', 'COMPLETED', 'CANCELLED'
  final String bookingCode;

  BookingModel({
    required this.id,
    required this.movieId,
    required this.movieTitle,
    required this.posterUrl,
    required this.backdropUrl,
    required this.theatreId,
    required this.theatreName,
    required this.theatreAddress,
    required this.screen,
    required this.format,
    required this.showDate,
    required this.showTime,
    required this.seats,
    required this.seatTier,
    required this.ticketCount,
    required this.ticketPrice,
    required this.convenienceFee,
    required this.tax,
    required this.discount,
    required this.totalAmount,
    required this.paymentMethod,
    required this.bookingTimestamp,
    this.status = 'CONFIRMED',
    required this.bookingCode,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String? ?? 'BK-${DateTime.now().millisecondsSinceEpoch}',
      movieId: json['movieId'] as String? ?? '',
      movieTitle: json['movieTitle'] as String? ?? '',
      posterUrl: json['posterUrl'] as String? ?? '',
      backdropUrl: json['backdropUrl'] as String? ?? '',
      theatreId: json['theatreId'] as String? ?? '',
      theatreName: json['theatreName'] as String? ?? '',
      theatreAddress: json['theatreAddress'] as String? ?? '',
      screen: json['screen'] as String? ?? '',
      format: json['format'] as String? ?? '2D',
      showDate: json['showDate'] as String? ?? '',
      showTime: json['showTime'] as String? ?? '',
      seats: (json['seats'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      seatTier: json['seatTier'] as String? ?? 'Standard',
      ticketCount: (json['ticketCount'] as num?)?.toInt() ?? 1,
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? 12.0,
      convenienceFee: (json['convenienceFee'] as num?)?.toDouble() ?? 2.50,
      tax: (json['tax'] as num?)?.toDouble() ?? 1.50,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 16.0,
      paymentMethod: json['paymentMethod'] as String? ?? 'Credit Card',
      bookingTimestamp: json['bookingTimestamp'] as String? ?? DateTime.now().toIso8601String(),
      status: json['status'] as String? ?? 'CONFIRMED',
      bookingCode: json['bookingCode'] as String? ?? 'CNV-${DateTime.now().millisecondsSinceEpoch % 100000}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'posterUrl': posterUrl,
      'backdropUrl': backdropUrl,
      'theatreId': theatreId,
      'theatreName': theatreName,
      'theatreAddress': theatreAddress,
      'screen': screen,
      'format': format,
      'showDate': showDate,
      'showTime': showTime,
      'seats': seats,
      'seatTier': seatTier,
      'ticketCount': ticketCount,
      'ticketPrice': ticketPrice,
      'convenienceFee': convenienceFee,
      'tax': tax,
      'discount': discount,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'bookingTimestamp': bookingTimestamp,
      'status': status,
      'bookingCode': bookingCode,
    };
  }
}

