import 'dart:async';
import 'package:cuacfm/domain/repository/radiocom_repository_contract.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cuacfm/main.dart';
import 'package:cuacfm/models/episode.dart';
import 'package:cuacfm/models/program.dart';
import 'package:cuacfm/services/favorites_service.dart';
import 'package:cuacfm/services/playlist_service.dart';
import 'package:cuacfm/utils/custom_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:injector/injector.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _yellow = Color(0xFFFCD444);
const _dark = Color(0xFF1A1A1A);

class OnboardingView extends StatefulWidget {
  final VoidCallback onFinished;
  const OnboardingView({Key? key, required this.onFinished}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  // Páxinas: 0=benvida, 1=play, 2=favoritos, 3=playlist, 4=alertas, 5=categorías, 6=idioma
  static const _totalPages = 6;

  // Paso 5: categorías e programas
  final Set<ProgramCategories> _selectedCategories = {};
  static const _maxCategories = 3;
  List<Program> _allPodcasts = [];
  bool _loadingPodcasts = false;
  bool _buildingRecommendations = false;
  List<Program> _recommendedPrograms = [];
  Map<String, List<Episode>> _episodesCache = {};
  late AnimationController _dotsController;
  int _dotsCount = 1;
  int _loadingMsgIndex = 0;
  Timer? _loadingMsgTimer;
  static const _loadingMessages = [
    'Abrindo arquivo de CUAC FM',
    'Buscando programas',
    'Creando recomendación',
  ];
// Estado de accións do usuario
  final Set<String> _favoritedRssUrls = {};
  final Set<String> _playlistedRssUrls = {};

  final FavoritesService _favoritesService = FavoritesService();
  final PlaylistService _playlistService = PlaylistService();

  String? _feedbackMessage;

  // Paso 6: idioma
  String? _selectedLocale; // null = sistema (galego por defecto na app)

  static const _categoryLabels = {
    ProgramCategories.TV: 'Cine e series',
    ProgramCategories.NEWS: 'Novas e política',
    ProgramCategories.SPORTS: 'Deportes',
    ProgramCategories.SOCIETY: 'Magazine',
    ProgramCategories.EDUCATION: 'Educativo',
    ProgramCategories.COMEDY: 'Humor',
    ProgramCategories.MUSIC: 'Música',
    ProgramCategories.SCIENCE: 'Ciencia',
    ProgramCategories.ARTS: 'Arte',
    ProgramCategories.GOVERNMENT: 'Goberno e Org.',
    ProgramCategories.HEALTH: 'Saúde',
    ProgramCategories.TECH: 'Tecnoloxía',
  };

  @override
  void initState() {
    super.initState();
    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addListener(() {
        final next = (_dotsController.value * 3).floor() + 1;
        if (next != _dotsCount && mounted) setState(() => _dotsCount = next);
      })
      ..repeat();
    _loadPodcasts();
  }

  @override
  void dispose() {
    _loadingMsgTimer?.cancel();
    _dotsController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int i) {
    setState(() => _currentPage = i);
  }

  Future<void> _loadPodcasts() async {
    setState(() => _loadingPodcasts = true);
    try {
      final repo = Injector.appInstance.get<CuacRepositoryContract>();
      final result = await repo.getAllPodcasts();
      if (result.data != null) {
        _allPodcasts = result.data!;
      }
    } catch (_) {}
    if (mounted) setState(() => _loadingPodcasts = false);
  }

  void _toggleCategory(ProgramCategories cat) {
    if (_selectedCategories.contains(cat)) {
      setState(() {
        _selectedCategories.remove(cat);
        _recommendedPrograms = [];
      });
    } else if (_selectedCategories.length < _maxCategories) {
      setState(() => _selectedCategories.add(cat));
      if (_selectedCategories.length == _maxCategories) {
        _buildRecommendations();
      }
    }
  }

  Future<void> _buildRecommendations() async {
    if (mounted) setState(() {
      _buildingRecommendations = true;
      _recommendedPrograms = [];
      _loadingMsgIndex = 0;
    });
    _loadingMsgTimer?.cancel();
    _loadingMsgTimer = Timer.periodic(const Duration(milliseconds: 1400), (_) {
      if (mounted) setState(() {
        _loadingMsgIndex = (_loadingMsgIndex + 1) % _loadingMessages.length;
      });
    });
    final repo = Injector.appInstance.get<CuacRepositoryContract>();
    for (final cat in _selectedCategories) {
      final candidates = _allPodcasts
          .where((p) => p.categoryType == cat && p.rssUrl.isNotEmpty)
          .toList()
        ..shuffle();
      final picked = <Program>[];
      for (final p in candidates) {
        if (picked.length >= 2) break;
        if (!_episodesCache.containsKey(p.rssUrl)) {
          try {
            final result = await repo.getEpisodes(p.rssUrl);
            _episodesCache[p.rssUrl] = result.data ?? [];
          } catch (_) {
            _episodesCache[p.rssUrl] = [];
          }
        }
        if (_episodesCache[p.rssUrl]!.isNotEmpty) {
          picked.add(p);
        }
      }
      _recommendedPrograms.addAll(picked);
    }
    // Esperar a que o timer chegue ao último mensaxe antes de saltar
    while (_loadingMsgIndex < _loadingMessages.length - 1) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    // Deixar ver o último mensaxe un momento antes de saltar
    await Future.delayed(const Duration(milliseconds: 1400));

    _loadingMsgTimer?.cancel();
    _loadingMsgTimer = null;
    if (mounted) setState(() { _buildingRecommendations = false; });
  }

void _toggleFavorite(Program program) {
    setState(() {
      if (_favoritedRssUrls.contains(program.rssUrl)) {
        _favoritesService.removeProgram(program.rssUrl);
        _favoritedRssUrls.remove(program.rssUrl);
        _showFeedback("${program.name} eliminado de favoritos");
      } else {
        _favoritesService.addProgram({
          'name': program.name,
          'description': program.description,
          'logoUrl': program.logoUrl,
          'rssUrl': program.rssUrl,
          'duration': program.duration,
          'language': program.language,
          'category': program.category,
        });
        _favoritedRssUrls.add(program.rssUrl);
        _showFeedback("${program.name} engadido a favoritos");
      }
    });
  }

  void _togglePlaylist(Program program) {
    final episodes = _episodesCache[program.rssUrl];
    if (episodes == null || episodes.isEmpty) return;
    final lastEpisode = episodes.first;
    setState(() {
      if (_playlistedRssUrls.contains(program.rssUrl)) {
        _playlistService.removeEpisode(lastEpisode.audio);
        _playlistedRssUrls.remove(program.rssUrl);
        _showFeedback("\"${lastEpisode.title}\" eliminado da playlist");
      } else {
        _playlistService.addEpisode(lastEpisode, program.name, program.logoUrl);
        _playlistedRssUrls.add(program.rssUrl);
        _showFeedback("\"${lastEpisode.title}\" engadido a playlist");
      }
    });
  }

  void _showFeedback(String message) {
    setState(() => _feedbackMessage = message);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _feedbackMessage = null);
    });
  }

  Future<void> _finish() async {
    // Gardar idioma seleccionado
    final prefs = await SharedPreferences.getInstance();
    if (_selectedLocale != null) {
      await prefs.setString('app_locale', _selectedLocale!);
      MyApp.setLocale(MyApp.parseLocale(_selectedLocale));
    }
    await prefs.setBool('onboarding_completed', true);
    try {
      final info = await PackageInfo.fromPlatform();
      await prefs.setInt('onboarding_version', int.tryParse(info.buildNumber) ?? 0);
    } catch (_) {}
    widget.onFinished();
  }

  void _nextPage() {
    if (_currentPage < _totalPages) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _yellow,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _yellow,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: _yellow,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  physics: _currentPage == _totalPages
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  children: [
                    _buildWelcomePage(),
                    _buildInfoPage(
                      icon: Icons.play_circle_filled,
                      text: "Escoita a nosa emisión en directo, sen publicidade e en calquera parte do mundo.",
                    ),
                    _buildInfoPage(
                      icon: Icons.favorite,
                      text: "Sigue os teus programas favoritos.",
                    ),
                    _buildInfoPage(
                      icon: Icons.playlist_play,
                      text: "Crea a túa playlist.",
                      subtitle: "Desliza un episodio cara á dereita para engadilo á playlist.",
                    ),
                    _buildInfoPage(
                      icon: Icons.notifications_active,
                      text: "Activa alertas dos teus programas favoritos e recibe unha notificación cada vez que publiquen un novo episodio.",
                      subtitle: "Podes pausar todas as alertas en calquera momento desde a configuración.",
                    ),
                    _buildCategoryPage(),
                    _buildLocalePage(),
                  ],
                ),
              ),
              _buildBottomControls(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Pantalla 1: Benvida ───────────────────────────────────────────────────

  Widget _buildWelcomePage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              "assets/graphics/cuac-icon-app.png",
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 32),
          const Text(
            "CUAC FM",
            style: TextStyle(
              color: _dark,
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Somos a radio comunitaria da Coruña.\nGrazas por escoitarnos.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dark,
              fontSize: 17,
              fontWeight: FontWeight.w400,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Pantallas 2-4: Información ────────────────────────────────────────────

  Widget _buildInfoPage({required IconData icon, required String text, String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: _dark,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _yellow, size: 48),
          ),
          const SizedBox(height: 40),
          Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _dark,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              height: 1.5,
              letterSpacing: 0,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 16),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _dark.withOpacity(0.55),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 1.5,
                letterSpacing: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Pantalla 5: Categorías e programas ────────────────────────────────────

  Widget _buildCategoryPage() {
    final showRecommendations =
        _selectedCategories.length == _maxCategories &&
            _recommendedPrograms.isNotEmpty;
    return Column(
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              showRecommendations ? "Recomendacións" : "Comecemos",
                style: const TextStyle(
                  color: _dark,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                showRecommendations
                    ? "Engade a favoritos ou á playlist."
                    : "Escolle $_maxCategories temas que che interesen (${_selectedCategories.length}/$_maxCategories).",
                style: const TextStyle(
                  color: _dark,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                switchInCurve: Curves.easeOut,
                switchOutCurve: Curves.easeIn,
                transitionBuilder: (child, animation) =>
                    FadeTransition(opacity: animation, child: child),
                child: _buildingRecommendations
                    ? _buildLoadingRecommendations()
                    : showRecommendations
                        ? _buildProgramsList()
                        : _buildCategoryGrid(),
              ),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: _feedbackMessage != null
                  ? Container(
                      key: ValueKey(_feedbackMessage),
                      margin: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: _dark,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        _feedbackMessage!,
                        style: const TextStyle(
                          color: _yellow,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
    );
  }

  Widget _buildLoadingRecommendations() {
    final msg = _loadingMessages[_loadingMsgIndex];
    return Center(
      key: const ValueKey('loading_recommendations'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 52,
            height: 52,
            child: CircularProgressIndicator(
              color: _dark,
              strokeWidth: 2.5,
            ),
          ),
          const SizedBox(height: 32),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: Text(
              msg,
              key: ValueKey(msg),
              style: const TextStyle(
                color: _dark,
                fontSize: 17,
                fontWeight: FontWeight.w600,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryGrid() {
    if (_loadingPodcasts) {
      return const Center(
        child: CircularProgressIndicator(color: _dark, strokeWidth: 2),
      );
    }
    final categories = ProgramCategories.values;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        physics: const BouncingScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.2,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final cat = categories[i];
          final label = _categoryLabels[cat] ?? Program.getCategory(cat);
          final count = _allPodcasts
              .where((p) => p.categoryType == cat && p.rssUrl.isNotEmpty)
              .length;
          final isSelected = _selectedCategories.contains(cat);
          final canSelect = count > 0 &&
              (_selectedCategories.length < _maxCategories || isSelected);
          return GestureDetector(
            onTap: canSelect ? () => _toggleCategory(cat) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: isSelected
                    ? _dark
                    : count > 0
                        ? _dark.withOpacity(0.15)
                        : _dark.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? Border.all(color: _dark, width: 2)
                    : null,
              ),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isSelected
                                ? _yellow
                                : count > 0
                                    ? _dark
                                    : _dark.withOpacity(0.4),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$count programas",
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white.withOpacity(0.6)
                                : count > 0
                                    ? _dark.withOpacity(0.5)
                                    : _dark.withOpacity(0.3),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: _yellow, size: 22),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgramsList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedCategories.clear();
              _recommendedPrograms = [];
            }),
            child: Row(
              children: [
                Icon(Icons.arrow_back, color: _dark.withOpacity(0.7), size: 18),
                const SizedBox(width: 6),
                Text(
                  "Cambiar categorías",
                  style: TextStyle(
                    color: _dark.withOpacity(0.7),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 14,
                childAspectRatio: 0.62,
              ),
              itemCount: _recommendedPrograms.length,
              itemBuilder: (_, i) {
                final program = _recommendedPrograms[i];
                final isFav = _favoritedRssUrls.contains(program.rssUrl);
                final isPlaylist = _playlistedRssUrls.contains(program.rssUrl);
                final episodes = _episodesCache[program.rssUrl] ?? <Episode>[];
                final hasEpisodes = episodes.isNotEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomImage(
                            resPath: program.logoUrl,
                            fit: BoxFit.cover,
                            radius: 0,
                            background: true,
                            backgroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      program.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: _dark,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _toggleFavorite(program),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isFav ? _dark : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _dark.withOpacity(0.3),
                                width: isFav ? 0 : 1.5,
                              ),
                            ),
                            child: Icon(
                              isFav ? Icons.favorite : Icons.favorite_border,
                              color: isFav ? _yellow : _dark,
                              size: 17,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: hasEpisodes
                              ? () => _togglePlaylist(program)
                              : null,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: isPlaylist ? _dark : Colors.transparent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: hasEpisodes
                                    ? _dark.withOpacity(0.3)
                                    : _dark.withOpacity(0.1),
                                width: isPlaylist ? 0 : 1.5,
                              ),
                            ),
                            child: Icon(
                              isPlaylist
                                  ? Icons.playlist_add_check
                                  : Icons.playlist_add,
                              color: isPlaylist
                                  ? _yellow
                                  : hasEpisodes
                                      ? _dark
                                      : _dark.withOpacity(0.3),
                              size: 17,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // ── Pantalla 6: Idioma ────────────────────────────────────────────────────

  Widget _buildLocaleChip(Map<String, String> l) {
    final isSelected = _selectedLocale == l['code'];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: GestureDetector(
        onTap: () => setState(() => _selectedLocale = l['code']),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 140,
          height: 52,
          decoration: BoxDecoration(
            color: isSelected ? _dark : _dark.withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          alignment: Alignment.center,
          child: Text(
            l['label']!,
            style: TextStyle(
              color: isSelected ? _yellow : _dark,
              fontSize: 17,
              fontWeight: FontWeight.w600,
              letterSpacing: 0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalePage() {
    final locales = [
      {'code': 'gl', 'label': 'Galego'},
      {'code': 'es', 'label': 'Español'},
      {'code': 'en', 'label': 'English'},
      {'code': 'pt', 'label': 'Português'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
              color: _dark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.language, color: _yellow, size: 48),
          ),
          const SizedBox(height: 36),
          const Text(
            "Por último escolle o idioma da app",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dark,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.4,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 32),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: locales.take(2).map((l) => _buildLocaleChip(l)).toList(),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: locales.skip(2).map((l) => _buildLocaleChip(l)).toList(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _selectedLocale == null
                ? "Se non escolles ningún usarase o idioma do sistema"
                : "",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _dark.withOpacity(0.45),
              fontSize: 13,
              fontWeight: FontWeight.w400,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  // ── Controis inferiores ───────────────────────────────────────────────────

  Widget _buildBottomControls() {
    final isLastPage = _currentPage == _totalPages;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          // Puntos indicadores
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalPages + 1, (i) {
              final active = i == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: active ? _dark : _dark.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: isLastPage ? _finish : _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: _dark,
                foregroundColor: _yellow,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: Text(
                isLastPage ? "Comezar" : "Seguinte",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
          if (!isLastPage)
            TextButton(
              onPressed: () {
                _pageController.animateToPage(
                  _totalPages,
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOut,
                );
              },
              child: Text(
                "Saltar",
                style: TextStyle(
                  color: _dark.withOpacity(0.5),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
