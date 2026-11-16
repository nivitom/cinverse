import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../services/data_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';
import '../widgets/movie_card.dart';
import 'movie_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedGenre = 'All';
  String _selectedFormat = 'All';

  final List<String> _genres = const [
    'All',
    'Action',
    'Drama',
    'Biographical',
    'Thriller',
    'Gangster',
    'Crime',
    'Sci-Fi',
    'Comedy',
  ];

  final List<String> _formats = const [
    'All',
    '2D',
    '3D',
    'IMAX 2D',
    'IMAX 3D',
    'Dolby Atmos',
    'EPIQ',
    '4DX',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MovieModel> _filterMovies(List<MovieModel> allMovies) {
    return allMovies.where((movie) {
      // Query filter
      if (_query.isNotEmpty) {
        final queryLower = _query.toLowerCase();
        final matchesTitle = movie.title.toLowerCase().contains(queryLower);
        final matchesDirector = movie.director.toLowerCase().contains(queryLower);
        final matchesCast = movie.cast.any((c) => c.name.toLowerCase().contains(queryLower));
        final matchesLang = movie.language.toLowerCase().contains(queryLower);
        if (!matchesTitle && !matchesDirector && !matchesCast && !matchesLang) return false;
      }

      // Genre filter
      if (_selectedGenre != 'All') {
        if (!movie.genre.any((g) => g.toLowerCase() == _selectedGenre.toLowerCase())) return false;
      }

      // Format filter
      if (_selectedFormat != 'All') {
        if (!movie.formats.any((f) => f.toLowerCase().contains(_selectedFormat.toLowerCase()))) return false;
      }

      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final allMovies = DataService().movies;
    final filtered = _filterMovies(allMovies);
    final hasActiveFilter = _query.isNotEmpty || _selectedGenre != 'All' || _selectedFormat != 'All';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search & Explore'),
        centerTitle: false,
        actions: [
          if (hasActiveFilter)
            TextButton(
              onPressed: () {
                setState(() {
                  _searchController.clear();
                  _query = '';
                  _selectedGenre = 'All';
                  _selectedFormat = 'All';
                });
              },
              child: Text(
                'Clear All',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // BookMyShow Style Search Input Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder, width: 0.8),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _query = val.trim()),
                style: AppTextStyles.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Search for Movies, Actors, Directors...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textMuted),
                  prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                ),
              ),
            ),
          ),

          // Genre Filter Chips with BookMyShow Red Highlight
          SizedBox(
            height: 38,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = genre == _selectedGenre;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(genre),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() => _selectedGenre = selected ? genre : 'All');
                    },
                    selectedColor: AppColors.primary,
                    backgroundColor: AppColors.surface,
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    showCheckmark: false,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // Format Filter Row (IMAX, Dolby Atmos, 2D, etc.)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text('Format:', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _formats.map((fmt) {
                        final isSel = fmt == _selectedFormat;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedFormat = fmt),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSel ? AppColors.primary.withValues(alpha: 0.15) : AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSel ? AppColors.primary : AppColors.surfaceBorder,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              fmt,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                color: isSel ? AppColors.primary : AppColors.textMuted,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Results Count Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tamil Nadu Releases (${filtered.length})',
                  style: AppTextStyles.titleMedium.copyWith(fontSize: 13, color: AppColors.textSecondary),
                ),
                Text(
                  'Kollywood & More',
                  style: AppTextStyles.caption.copyWith(color: AppColors.accentTeal),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Results Grid
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.movie_filter_outlined,
                          size: 64,
                          color: AppColors.textMuted.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No movies found matching criteria',
                          style: AppTextStyles.titleMedium.copyWith(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Try searching for another Kollywood title or reset filters',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.58,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final movie = filtered[index];
                      return MovieCard(
                        movie: movie,
                        width: double.infinity,
                        height: 220,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MovieDetailsScreen(movie: movie),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
