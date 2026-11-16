import 'dart:async';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/data_service.dart';
import '../services/location_service.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/movie_card.dart';
import '../widgets/app_network_image.dart';
import 'movie_details_screen.dart';
import 'location_screen.dart';
import 'search_screen.dart';
import 'theatre_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _featuredPageController = PageController(viewportFraction: 0.92);
  int _currentFeaturedIndex = 0;
  Timer? _featuredTimer;
  String _selectedGenre = 'All';

  final List<String> _genres = const [
    'All',
    'Action',
    'Biography',
    'Crime',
    'Drama',
    'Sci-Fi',
    'Thriller',
    'Comedy',
  ];

  @override
  void initState() {
    super.initState();
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _featuredTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!mounted) return;
      final featuredCount = DataService().movies.where((m) => m.isFeatured).length;
      if (featuredCount > 1 && _featuredPageController.hasClients) {
        final nextPage = (_currentFeaturedIndex + 1) % featuredCount;
        _featuredPageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _featuredTimer?.cancel();
    _featuredPageController.dispose();
    super.dispose();
  }

  void _openMovieDetails(MovieModel movie) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MovieDetailsScreen(movie: movie),
      ),
    );
  }

  void _openLocationSelector() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LocationScreen()),
    );
  }

  void _quickBook(MovieModel movie) {
    BookingService().setMovie(movie);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TheatreSelectionScreen(movie: movie),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allMovies = DataService().movies;
    final featuredMovies = allMovies.where((m) => m.isFeatured).toList();
    final nowShowing = allMovies.where((m) {
      if (!m.isNowShowing) return false;
      if (_selectedGenre == 'All') return true;
      return m.genre.contains(_selectedGenre);
    }).toList();
    final upcoming = allMovies.where((m) => m.isUpcoming).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () async {
            await DataService().loadAllData();
            setState(() {});
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // BookMyShow Style Top App Bar
                _buildTopBar(),

                // Search Bar Trigger
                _buildSearchBar(),

                const SizedBox(height: 10),

                // BookMyShow Signature Category Icons Row
                _buildCategoryStrip(),

                const SizedBox(height: 14),

                // Featured Movies Carousel Banner
                if (featuredMovies.isNotEmpty) _buildFeaturedCarousel(featuredMovies),

                const SizedBox(height: 20),

                // Genre Filter Chips
                _buildGenreSelector(),

                const SizedBox(height: 20),

                // Recommended Movies Section (BookMyShow Title)
                _buildSectionHeader(
                  title: 'Recommended Movies',
                  subtitle: '${nowShowing.length} movies in Tamil Nadu cinemas',
                  onSeeAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildHorizontalMovieList(nowShowing),

                const SizedBox(height: 24),

                // Promotional BookMyShow Pass Card
                _buildPromoBanner(),

                const SizedBox(height: 24),

                // Upcoming Movies Section
                _buildSectionHeader(
                  title: 'Coming Soon to Theatres',
                  subtitle: 'Advance booking opening soon',
                  onSeeAll: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildUpcomingMovieList(upcoming),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      color: AppColors.backgroundSecondary,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location Selector Chip (BookMyShow Style)
          AnimatedBuilder(
            animation: LocationService(),
            builder: (context, child) {
              return GestureDetector(
                onTap: _openLocationSelector,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: AppColors.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              LocationService().selectedCity,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                        Text(
                          'Tamil Nadu',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),

          // User Profile Quick Avatar & Notifications
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search_rounded, color: AppColors.textPrimary, size: 22),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SearchScreen()),
                  );
                },
              ),
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 22),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notifications: Kollywood first-day-first-show alerts active!')),
                      );
                    },
                  ),
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.textPrimary, size: 21),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cinema Turnstile Scanner: Scan your M-Ticket at cinema entrance.')),
                  );
                },
              ),
              const SizedBox(width: 4),
              AnimatedBuilder(
                animation: AuthService(),
                builder: (context, child) {
                  final user = AuthService().currentUser;
                  return Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 1.5),
                      color: AppColors.surface,
                    ),
                    child: ClipOval(
                      child: user != null && user.avatarUrl.isNotEmpty
                          ? AppNetworkImage(
                              imageUrl: user.avatarUrl,
                              width: 34,
                              height: 34,
                            )
                          : const Center(
                              child: Icon(Icons.person, color: AppColors.textSecondary, size: 18),
                            ),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const SearchScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
          ),
          child: Row(
            children: [
              const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 10),
              Text(
                'Search for Movies, Events, Plays and Activities...',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryStrip() {
    final categories = [
      {'name': 'Movies', 'icon': Icons.local_movies_rounded, 'color': AppColors.primary, 'badge': 'HOT'},
      {'name': 'Stream', 'icon': Icons.play_circle_fill_rounded, 'color': const Color(0xFF6366F1), 'badge': ''},
      {'name': 'Events', 'icon': Icons.celebration_rounded, 'color': const Color(0xFFF59E0B), 'badge': ''},
      {'name': 'Plays', 'icon': Icons.theater_comedy_rounded, 'color': const Color(0xFF10B981), 'badge': ''},
      {'name': 'Sports', 'icon': Icons.sports_cricket_rounded, 'color': const Color(0xFF06B6D4), 'badge': ''},
      {'name': 'Activities', 'icon': Icons.attractions_rounded, 'color': const Color(0xFFEC4899), 'badge': ''},
    ];

    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isMovies = index == 0;
          return GestureDetector(
            onTap: () {
              if (isMovies) {
                setState(() => _selectedGenre = 'All');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${cat['name']}: Experiences in ${LocationService().selectedCity}'),
                    duration: const Duration(milliseconds: 1400),
                  ),
                );
              }
            },
            child: Container(
              width: 66,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: (cat['color'] as Color).withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isMovies ? AppColors.primary : (cat['color'] as Color).withValues(alpha: 0.4),
                            width: isMovies ? 1.5 : 1,
                          ),
                        ),
                        child: Icon(cat['icon'] as IconData, color: cat['color'] as Color, size: 22),
                      ),
                      if ((cat['badge'] as String).isNotEmpty)
                        Positioned(
                          top: -2,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              cat['badge'] as String,
                              style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w900, color: Colors.white),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text(
                    cat['name'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isMovies ? FontWeight.w700 : FontWeight.w500,
                      color: isMovies ? AppColors.primary : AppColors.textSecondary,
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

  Widget _buildFeaturedCarousel(List<MovieModel> featuredMovies) {
    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _featuredPageController,
            itemCount: featuredMovies.length,
            onPageChanged: (index) {
              setState(() => _currentFeaturedIndex = index);
            },
            itemBuilder: (context, index) {
              final movie = featuredMovies[index];
              return GestureDetector(
                onTap: () => _openMovieDetails(movie),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Stack(
                      children: [
                        // Wide Backdrop
                        AppNetworkImage(
                          imageUrl: movie.backdropUrl.isNotEmpty ? movie.backdropUrl : movie.posterUrl,
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                          fallbackTitle: movie.title,
                        ),
                        // Dark Gradient Overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.3),
                                  Colors.black.withValues(alpha: 0.9),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                stops: const [0.2, 0.6, 1.0],
                              ),
                            ),
                          ),
                        ),
                        // Top Badges
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'TRENDING NOW',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 9.5,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                        // Bottom Content
                        Positioned(
                          bottom: 12,
                          left: 14,
                          right: 14,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      movie.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.titleLarge.copyWith(fontSize: 17),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        const Icon(Icons.star_rounded, size: 15, color: AppColors.gold),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${movie.rating}/10 (${movie.votes})',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11.5,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '• Tamil • ${movie.duration}',
                                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => _quickBook(movie),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  'Book',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        // Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(featuredMovies.length, (index) {
            final active = index == _currentFeaturedIndex;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: active ? 16 : 5,
              height: 4,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGenreSelector() {
    return SizedBox(
      height: 36,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _genres.length,
        itemBuilder: (context, index) {
          final genre = _genres[index];
          final isSelected = genre == _selectedGenre;
          return GestureDetector(
            onTap: () => setState(() => _selectedGenre = genre),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  genre,
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
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
    required VoidCallback onSeeAll,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.titleLarge.copyWith(fontSize: 18)),
              const SizedBox(height: 2),
              Text(subtitle, style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary)),
            ],
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: Row(
              children: [
                Text(
                  'See All',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: AppColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalMovieList(List<MovieModel> movies) {
    if (movies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Text(
          'No movies matching "$_selectedGenre"',
          style: AppTextStyles.bodyMedium,
        ),
      );
    }

    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieCard(
            movie: movie,
            width: 148,
            height: 215,
            onTap: () => _openMovieDetails(movie),
          );
        },
      ),
    );
  }

  Widget _buildPromoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            child: const Icon(Icons.local_offer_rounded, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'CINEVERSE CinePass Offer',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '20% OFF',
                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Use code CINEMA20 or THALAIVAR20 on any booking checkout.',
                  style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUpcomingMovieList(List<MovieModel> movies) {
    return SizedBox(
      height: 280,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieCard(
            movie: movie,
            width: 148,
            height: 215,
            showRating: false,
            onTap: () => _openMovieDetails(movie),
          );
        },
      ),
    );
  }
}
