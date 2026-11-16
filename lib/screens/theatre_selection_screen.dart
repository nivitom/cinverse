import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../models/theatre_model.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../services/booking_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import 'showtime_selection_screen.dart';
import 'location_screen.dart';

class TheatreSelectionScreen extends StatefulWidget {
  final MovieModel movie;

  const TheatreSelectionScreen({super.key, required this.movie});

  @override
  State<TheatreSelectionScreen> createState() => _TheatreSelectionScreenState();
}

class _TheatreSelectionScreenState extends State<TheatreSelectionScreen> {
  String _selectedAmenity = 'All';

  final List<String> _amenities = const [
    'All',
    'IMAX',
    'Dolby Atmos',
    'Recliners',
    'Dine-In',
  ];

  void _onSelectTheatre(TheatreModel theatre) {
    BookingService().setTheatre(theatre);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShowtimeSelectionScreen(
          movie: widget.movie,
          theatre: theatre,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locationService = LocationService();
    final allTheatres = DataService().theatres;

    final hasTheatresForCity = allTheatres.any(
      (t) => t.city.toLowerCase() == locationService.selectedCity.toLowerCase(),
    );

    // Filter by city and amenity
    final cityTheatres = allTheatres.where((t) {
      if (hasTheatresForCity) {
        return t.city.toLowerCase() == locationService.selectedCity.toLowerCase();
      }
      return true;
    }).where((t) {
      if (_selectedAmenity == 'All') return true;
      return t.amenities.any((a) => a.toLowerCase().contains(_selectedAmenity.toLowerCase()));
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Cinema'),
            Text(
              widget.movie.title,
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const LocationScreen()),
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.location_on, size: 16, color: AppColors.primary),
            label: Text(
              locationService.selectedCity,
              style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Amenity Filter Chips
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              itemCount: _amenities.length,
              itemBuilder: (context, index) {
                final amenity = _amenities[index];
                final isSelected = amenity == _selectedAmenity;

                return GestureDetector(
                  onTap: () => setState(() => _selectedAmenity = amenity),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        amenity,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? Colors.white : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Theatres List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: cityTheatres.length,
              itemBuilder: (context, index) {
                final theatre = cityTheatres[index];
                return _buildTheatreCard(theatre);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTheatreCard(TheatreModel theatre) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onSelectTheatre(theatre),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: Name & Rating
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            theatre.name,
                            style: AppTextStyles.titleMedium.copyWith(fontSize: 15.5, fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                theatre.chain,
                                style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.confirmation_number_outlined, size: 12, color: AppColors.accentTeal),
                              const SizedBox(width: 3),
                              const Text('M-Ticket', style: TextStyle(fontSize: 10, color: AppColors.accentTeal)),
                              const SizedBox(width: 8),
                              const Icon(Icons.fastfood_outlined, size: 12, color: AppColors.gold),
                              const SizedBox(width: 3),
                              const Text('F&B', style: TextStyle(fontSize: 10, color: AppColors.gold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            theatre.rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Distance & Address
                Row(
                  children: [
                    const Icon(Icons.near_me_outlined, size: 13, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      theatre.distance,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text('•', style: TextStyle(color: AppColors.textMuted)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        theatre.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Amenities Badges
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: theatre.amenities.map((amenity) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        amenity,
                        style: AppTextStyles.caption.copyWith(
                          fontSize: 10,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 10),

                // Available Screens quick preview & action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${theatre.screens.length} Screens Available',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
                    ),
                    Row(
                      children: [
                        Text(
                          'Select Showtimes',
                          style: AppTextStyles.button.copyWith(
                            fontSize: 12.5,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 11,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
