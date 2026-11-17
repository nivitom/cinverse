import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movie_model.dart';
import '../models/theatre_model.dart';
import '../services/booking_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/custom_button.dart';
import 'seat_selection_screen.dart';

class ShowtimeSelectionScreen extends StatefulWidget {
  final MovieModel movie;
  final TheatreModel theatre;

  const ShowtimeSelectionScreen({
    super.key,
    required this.movie,
    required this.theatre,
  });

  @override
  State<ShowtimeSelectionScreen> createState() => _ShowtimeSelectionScreenState();
}

class _ShowtimeSelectionScreenState extends State<ShowtimeSelectionScreen> {
  int _selectedDateIndex = 0;
  late List<DateTime> _dates;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(8, (i) => now.add(Duration(days: i)));
    BookingService().setDate(_formatSelectedDate(_dates[0], 0));
  }

  String _formatSelectedDate(DateTime date, int index) {
    if (index == 0) return 'Today, ${DateFormat('dd MMM').format(date)}';
    if (index == 1) return 'Tomorrow, ${DateFormat('dd MMM').format(date)}';
    return DateFormat('EEE, dd MMM').format(date);
  }

  void _onShowtimeSelected(ScreenModel screen, ShowtimeModel showtime) {
    _showSeatQuantityModal(screen, showtime);
  }

  void _showSeatQuantityModal(ScreenModel screen, ShowtimeModel showtime) {
    int selectedSeats = BookingService().requestedSeatCount;
    final vehicles = [
      {'count': 1, 'icon': '🚴', 'label': 'Cycle'},
      {'count': 2, 'icon': '🛵', 'label': 'Scooter'},
      {'count': 3, 'icon': '🛺', 'label': 'Auto'},
      {'count': 4, 'icon': '🚗', 'label': 'Mini Car'},
      {'count': 5, 'icon': '🚙', 'label': 'Sedan'},
      {'count': 6, 'icon': '🚐', 'label': 'SUV'},
      {'count': 7, 'icon': '🚐', 'label': 'Van'},
      {'count': 8, 'icon': '🚌', 'label': 'Minibus'},
      {'count': 9, 'icon': '🚍', 'label': 'Bus'},
      {'count': 10, 'icon': '✈️', 'label': 'Jumbo'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final activeVehicle = vehicles[selectedSeats - 1];

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 14,
                bottom: MediaQuery.of(modalContext).padding.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 38,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Text(
                    'How Many Seats?',
                    style: AppTextStyles.titleLarge.copyWith(fontSize: 18),
                  ),
                  const SizedBox(height: 12),

                  // Vehicle Icon & Name Representation (BookMyShow Signature)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activeVehicle['icon'] as String,
                          style: const TextStyle(fontSize: 30),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$selectedSeats ${selectedSeats == 1 ? 'Seat' : 'Seats'} (${activeVehicle['label']})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 1 to 10 Numbers Row
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 10,
                      itemBuilder: (context, index) {
                        final count = index + 1;
                        final isSel = count == selectedSeats;

                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              selectedSeats = count;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 38,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary : AppColors.surfaceLight,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.surfaceBorder,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: isSel ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 18),

                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  const SizedBox(height: 14),

                  // Seat Tier Pricing Preview
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildTierPricePreview(
                        'RECLINER',
                        '₹${(screen.basePrice + 60).toStringAsFixed(0)}',
                        AppColors.gold,
                      ),
                      _buildTierPricePreview(
                        'PRIME',
                        '₹${(screen.basePrice + 30).toStringAsFixed(0)}',
                        AppColors.accentTeal,
                      ),
                      _buildTierPricePreview(
                        'CLASSIC',
                        '₹${screen.basePrice.toStringAsFixed(0)}',
                        AppColors.textSecondary,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // "Select Seats" Button
                  CustomButton(
                    text: 'Select Seats',
                    icon: Icons.chair_rounded,
                    onPressed: () {
                      Navigator.pop(modalContext);

                      final bookingService = BookingService();
                      bookingService.setMovie(widget.movie);
                      bookingService.setTheatre(widget.theatre);
                      bookingService.setScreen(screen);
                      bookingService.setShowtime(showtime.time);
                      bookingService.setDate(_formatSelectedDate(_dates[_selectedDateIndex], _selectedDateIndex));
                      bookingService.setRequestedSeatCount(selectedSeats);
                      bookingService.clearSeats();

                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SeatSelectionScreen(
                            movie: widget.movie,
                            theatre: widget.theatre,
                            screen: screen,
                            showtime: showtime.time,
                            date: _formatSelectedDate(_dates[_selectedDateIndex], _selectedDateIndex),
                            requestedSeatCount: selectedSeats,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTierPricePreview(String tier, String price, Color color) {
    return Column(
      children: [
        Text(
          tier,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          price,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 1),
        const Text(
          'Available',
          style: TextStyle(
            fontSize: 9.5,
            color: AppColors.accentGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.movie.title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            Text(
              '${widget.theatre.name} • ${widget.theatre.city}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Horizontal Date Picker Strip (BookMyShow Style)
          _buildDateStrip(),

          const SizedBox(height: 10),

          // Availability Legend
          _buildStatusLegend(),

          const SizedBox(height: 10),

          // Screens & Showtime Groups
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: widget.theatre.screens.length,
              itemBuilder: (context, index) {
                final screen = widget.theatre.screens[index];
                return _buildScreenShowtimes(screen);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStrip() {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.backgroundSecondary,
        border: Border(
          bottom: BorderSide(color: AppColors.surfaceBorder, width: 0.8),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _dates.length,
        itemBuilder: (context, index) {
          final date = _dates[index];
          final isSelected = index == _selectedDateIndex;
          final dayName = index == 0
              ? 'TODAY'
              : index == 1
                  ? 'TOM'
                  : DateFormat('EEE').format(date).toUpperCase();
          final dayNum = DateFormat('dd').format(date);
          final month = DateFormat('MMM').format(date);

          return GestureDetector(
            onTap: () {
              setState(() => _selectedDateIndex = index);
              BookingService().setDate(_formatSelectedDate(date, index));
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 58,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                  width: 1.0,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayName,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dayNum,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    month,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white70 : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildLegendItem(AppColors.accentGreen, 'Available'),
          const SizedBox(width: 18),
          _buildLegendItem(AppColors.warning, 'Filling Fast'),
          const SizedBox(width: 18),
          _buildLegendItem(AppColors.error, 'Almost Full'),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildScreenShowtimes(ScreenModel screen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Screen Name & Format Badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                screen.name,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  screen.format,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            'Starting from ₹${screen.basePrice.toStringAsFixed(0)}',
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          // Showtime Pills (BookMyShow Style with Green/Orange outline)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: screen.showtimes.map((st) {
              Color statusColor = AppColors.accentGreen;
              if (st.status == 'Filling Fast') statusColor = AppColors.warning;
              if (st.status == 'Almost Full') statusColor = AppColors.error;

              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _onShowtimeSelected(screen, st),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: statusColor, width: 1.0),
                    ),
                    child: Column(
                      children: [
                        Text(
                          st.time,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          screen.format.split(' ').first,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
