import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/booking_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/app_network_image.dart';
import '../widgets/custom_button.dart';
import 'theatre_selection_screen.dart';

class MovieDetailsScreen extends StatefulWidget {
  final MovieModel movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  bool _isBookmarked = false;
  bool _isSynopsisExpanded = false;
  String _selectedFormat = '';

  @override
  void initState() {
    super.initState();
    if (widget.movie.formats.isNotEmpty) {
      _selectedFormat = widget.movie.formats.first;
    }
  }

  void _onBookTickets() {
    BookingService().setMovie(widget.movie);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TheatreSelectionScreen(movie: widget.movie),
      ),
    );
  }

  void _showTrailerModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surfaceBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${widget.movie.title} – Official Tamil Trailer',
                      style: AppTextStyles.titleMedium.copyWith(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  color: Colors.black,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AppNetworkImage(
                        imageUrl: widget.movie.backdropUrl,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        fallbackTitle: widget.movie.title,
                      ),
                      Container(color: Colors.black.withValues(alpha: 0.45)),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: const Icon(Icons.play_arrow_rounded, size: 36, color: Colors.white),
                      ),
                      Positioned(
                        bottom: 10,
                        left: 14,
                        child: Text(
                          'Tamil • 4K UHD • Dolby Atmos Audio',
                          style: AppTextStyles.caption.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Official Kollywood Teaser & Trailer Feed.',
                style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Scrollable Content
          SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Backdrop Header
                _buildBackdropHeader(movie),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Movie Title & Details
                      _buildTitleSection(movie),

                      const SizedBox(height: 16),

                      // BookMyShow Style Rating Card
                      _buildBmsRatingCard(movie),

                      const SizedBox(height: 16),

                      // Format Chips
                      _buildFormatSelector(movie),

                      const SizedBox(height: 18),

                      // Storyline / Synopsis
                      _buildSynopsis(movie),

                      const SizedBox(height: 20),

                      // Cast & Crew List
                      _buildCastSection(movie),

                      const SizedBox(height: 20),

                      // Cinema Specifications
                      _buildSpecsCard(movie),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Floating Top Navigation Icons (Back & Share/Bookmark)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        child: IconButton(
                          icon: const Icon(Icons.share_outlined, size: 18, color: Colors.white),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Movie link copied: ${movie.title}'),
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        child: IconButton(
                          icon: Icon(
                            _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            color: _isBookmarked ? AppColors.primary : Colors.white,
                          ),
                          onPressed: () {
                            setState(() => _isBookmarked = !_isBookmarked);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  _isBookmarked ? 'Added to Watchlist' : 'Removed from Watchlist',
                                ),
                                duration: const Duration(milliseconds: 1500),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Sticky Bottom Booking Bar (BookMyShow Style Red Button)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomBookingBar(movie),
          ),
        ],
      ),
    );
  }

  Widget _buildBackdropHeader(MovieModel movie) {
    return SizedBox(
      height: 340,
      child: Stack(
        children: [
          // Backdrop Image
          AppNetworkImage(
            imageUrl: movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl,
            width: double.infinity,
            height: 340,
            fit: BoxFit.cover,
            fallbackTitle: movie.title,
          ),
          // Gradient Fade
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.5),
                    AppColors.background,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.3, 0.7, 1.0],
                ),
              ),
            ),
          ),
          // Play Trailer Button in Center
          Center(
            child: GestureDetector(
              onTap: _showTrailerModal,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 24),
                    SizedBox(width: 6),
                    Text(
                      'Trailer',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection(MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          movie.title,
          style: AppTextStyles.displayMedium.copyWith(fontSize: 24, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),

        // Language & Certificate & Duration
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                movie.certificate,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${movie.language} • ${movie.duration}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '${movie.genre.join(', ')} • Released: ${movie.releaseDate}',
          style: AppTextStyles.caption.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildBmsRatingCard(MovieModel movie) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, color: AppColors.gold, size: 26),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${movie.rating}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const TextSpan(
                          text: '/10',
                          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '(${movie.votes} Votes)',
                    style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Thank you! You rated 10/10.')),
              );
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              side: const BorderSide(color: AppColors.primary, width: 1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Rate now', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildFormatSelector(MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Format',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: movie.formats.map((fmt) {
              final isSel = fmt == _selectedFormat;
              return GestureDetector(
                onTap: () => setState(() => _selectedFormat = fmt),
                child: Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSel ? AppColors.primary : AppColors.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.surfaceBorder,
                      width: 1.0,
                    ),
                  ),
                  child: Text(
                    fmt,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                      color: isSel ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSynopsis(MovieModel movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the movie',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          movie.synopsis,
          maxLines: _isSynopsisExpanded ? null : 3,
          overflow: _isSynopsisExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          style: AppTextStyles.bodyMedium.copyWith(height: 1.5),
        ),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () => setState(() => _isSynopsisExpanded = !_isSynopsisExpanded),
          child: Text(
            _isSynopsisExpanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCastSection(MovieModel movie) {
    if (movie.cast.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Cast & Crew',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            Text(
              'Director: ${movie.director}',
              style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: movie.cast.length,
            itemBuilder: (context, index) {
              final actor = movie.cast[index];
              return Container(
                width: 78,
                margin: const EdgeInsets.only(right: 12),
                child: Column(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                      ),
                      child: ClipOval(
                        child: AppNetworkImage(
                          imageUrl: actor.imageUrl,
                          width: 58,
                          height: 58,
                          fit: BoxFit.cover,
                          fallbackTitle: actor.name,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      actor.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      actor.role,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsCard(MovieModel movie) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSpecItem(Icons.closed_caption_rounded, 'Subtitles', 'English, Tamil'),
          _buildSpecItem(Icons.spatial_audio_rounded, 'Audio', 'Dolby Atmos 7.1'),
          _buildSpecItem(Icons.hd_rounded, 'Projection', '4K Laser HDR'),
        ],
      ),
    );
  }

  Widget _buildSpecItem(IconData icon, String title, String value) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 10)),
        const SizedBox(height: 1),
        Text(value, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 11)),
      ],
    );
  }

  Widget _buildBottomBookingBar(MovieModel movie) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 10,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Starting from', style: AppTextStyles.caption.copyWith(fontSize: 10.5)),
              const SizedBox(height: 1),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '₹${movie.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: ' /seat',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textMuted, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: CustomButton(
              text: 'Book tickets',
              icon: Icons.confirmation_number_rounded,
              onPressed: _onBookTickets,
            ),
          ),
        ],
      ),
    );
  }
}
