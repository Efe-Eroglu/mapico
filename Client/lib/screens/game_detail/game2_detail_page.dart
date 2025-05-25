import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import '../../services/auth_service.dart';
import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:camera/camera.dart';

class Game2DetailPage extends StatefulWidget {
  const Game2DetailPage({super.key});

  @override
  State<Game2DetailPage> createState() => _CookingGameState();
}

class _CookingGameState extends State<Game2DetailPage>
    with SingleTickerProviderStateMixin {
  final Map<String, Map<String, dynamic>> countries = {
    'turkiye': {
      'name': 'Türkiye',
      'flag': 'assets/balonPatlatmaFlags/turkiye.png',
      'meal': 'Mantı',
      'description':
          'Mantı, Türk mutfağının en sevilen hamur işlerinden biridir. Küçük hamur parçalarının içine kıyma konularak hazırlanır ve yoğurt ile servis edilir.',
      'origin': 'Orta Asya',
      'history':
          'Mantı, Orta Asya Türkleri tarafından Anadolu\'ya getirilmiş ve zamanla Türk mutfağının vazgeçilmezlerinden olmuştur.',
      'funFact':
          'Kayseri mantısı, bir kaşığa 40 adet sığacak kadar küçük yapılırsa makbul sayılır!',
      'ingredients': ['Un', 'Kıyma', 'Soğan', 'Sarımsak', 'Yoğurt'],
      'images': {
        'Un': 'assets/cooking/un.svg',
        'Kıyma': 'assets/cooking/kiyma.png',
        'Soğan': 'assets/cooking/sogan.png',
        'Sarımsak': 'assets/cooking/sarimsak.png',
        'Yoğurt': 'assets/cooking/yogurt.png',
      },
    },
    'usa': {
      'name': 'Amerika',
      'flag': 'assets/balonPatlatmaFlags/usa.png',
      'meal': 'Hamburger',
      'description':
          'Hamburger, Amerika mutfağının simgesi haline gelmiş bir yemektir. Izgara köfte, taze sebzeler ve ekmekle hazırlanır.',
      'origin': 'Almanya (Hamburg)',
      'history':
          'Hamburger, adını Almanya\'nın Hamburg kentinden alır. Amerika\'da popülerleşerek fast food kültürünün simgesi olmuştur.',
      'funFact':
          'Dünyanın en büyük hamburgeri 2012\'de ABD\'de yapıldı ve 913 kg ağırlığındaydı!',
      'ingredients': ['Dana Eti', 'Marul', 'Domates', 'Soğan', 'Ekmek'],
      'images': {
        'Dana Eti': 'assets/cooking/et.png',
        'Marul': 'assets/cooking/marul.png',
        'Domates': 'assets/cooking/domates.png',
        'Soğan': 'assets/cooking/sogan.png',
        'Ekmek': 'assets/cooking/ekmek.png',
      },
    },
    'germany': {
      'name': 'Almanya',
      'flag': 'assets/balonPatlatmaFlags/germany.png',
      'meal': 'Schnitzel',
      'description':
          'Schnitzel, Almanya ve Avusturya mutfağının ünlü yemeklerinden biridir. İnce et dilimleri pane harcına bulanıp kızartılır.',
      'origin': 'Avusturya',
      'history':
          'Schnitzel, ilk olarak Avusturya\'da ortaya çıkmış, Almanya ve çevre ülkelerde de çok sevilmiştir.',
      'funFact':
          'Viyana\'da geleneksel schnitzel dana etinden yapılır, tavuk veya domuz etiyle de hazırlanabilir.',
      'ingredients': ['Tavuk Göğsü', 'Un', 'Yumurta', 'Galeta Unu', 'Limon'],
      'images': {
        'Tavuk Göğsü': 'assets/cooking/tavuk-gogsu.png',
        'Un': 'assets/cooking/un.svg',
        'Yumurta': 'assets/cooking/yumurta.png',
        'Galeta Unu': 'assets/cooking/galeta-un.png',
        'Limon': 'assets/cooking/limon.png',
      },
    },
    'holland': {
      'name': 'Hollanda',
      'flag': 'assets/balonPatlatmaFlags/holland.png',
      'meal': 'Stroopwafel',
      'description':
          'Stroopwafel, Hollanda mutfağına özgü, iki ince waffle arasında karamel şurubu bulunan tatlı bir atıştırmalıktır.',
      'origin': 'Gouda, Hollanda',
      'history':
          'Stroopwafel, 18. yüzyılda Hollanda\'nın Gouda kentinde fırıncılar tarafından icat edilmiştir.',
      'funFact':
          'Stroopwafel, sıcak bir içeceğin üzerine konularak karamelinin yumuşaması sağlanır!',
      'ingredients': ['Un', 'Şeker', 'Tereyağı', 'Yumurta', 'Tarçın'],
      'images': {
        'Un': 'assets/cooking/un.svg',
        'Şeker': 'assets/cooking/seker.svg',
        'Tereyağı': 'assets/cooking/tereyag.png',
        'Yumurta': 'assets/cooking/yumurta.png',
        'Tarçın': 'assets/cooking/tarcin.png',
      },
    },
  };

  String? selectedCountry;
  List<String> collected = [];
  final int gridRows = 4;
  final int gridColumns = 3;
  late List<List<bool>> gridOccupancy;
  List<Offset> ingredientPositions = [];
  int currentIndex = 0;
  late ConfettiController _confettiController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _titleController;
  late Animation<double> _titleRotation;
  late Animation<double> _titleScale;

  // Bilgilendirme ekranı için
  bool showInfo = false;
  String? infoCountryKey;

  // Puan ve can
  int score = 0;
  int lives = 3;
  bool gameOver = false;
  DateTime? _gameStartTime;
  Timer? _gameTimer;
  Duration _gameDuration = Duration.zero;

  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  // Sanal oyun alanı boyutları
  late double _worldWidth;
  late double _worldHeight;
  double _viewportX = 0.0; // Görünen alanın sol üst köşesi (x)
  double _viewportY = 0.0; // Görünen alanın sol üst köşesi (y)
  final double _viewportMoveSensitivity =
      14.0; // Telefon hareketine göre viewport kayma hızı (daha az hassas)

  CameraController? _cameraController;
  Future<void>? _initializeCameraFuture;

  bool showSuccessDialog = false;

  DateTime _lastSensorUpdate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 2));
    _titleController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    // Initialize title animations
    _titleRotation = Tween<double>(
      begin: -0.1,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeInOut,
    ));

    _titleScale = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _titleController,
      curve: Curves.easeInOut,
    ));
  }

  void _startWorldSensors() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (!mounted) return;
      final now = DateTime.now();
      if (now.difference(_lastSensorUpdate).inMilliseconds < 40)
        return; // 25 FPS throttle
      _lastSensorUpdate = now;
      setState(() {
        // Telefonun eğimine göre viewport'u kaydır
        _viewportX -= event.x * _viewportMoveSensitivity;
        _viewportY += event.y * _viewportMoveSensitivity;

        // Sınırları kontrol et (viewport, world sınırları dışına çıkmasın)
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        final minX = 0.0;
        final maxX = _worldWidth - screenWidth;
        final minY = 0.0;
        final maxY = _worldHeight - screenHeight;
        _viewportX = _viewportX.clamp(minX, maxX > 0 ? maxX : 0.0);
        _viewportY = _viewportY.clamp(minY, maxY > 0 ? maxY : 0.0);
      });
    });
  }

  void _generatePositions(int count) {
    final random = Random();
    gridOccupancy =
        List.generate(gridRows, (_) => List.filled(gridColumns, false));
    ingredientPositions = [];

    // Sanal oyun alanı boyutunu belirle (ekranın 2.2 katı genişliğinde, 1.15 katı yüksekliğinde)
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    _worldWidth = screenWidth * 2.2;
    _worldHeight = screenHeight * 1.07;
    final bottomPadding = 45.0;

    // İlk malzemeyi viewport'un ortasına yakın bir yere yerleştir
    final centerX = (_worldWidth - screenWidth) / 2 + screenWidth / 2 - 32;
    final centerY = (_worldHeight - screenHeight) / 2 + screenHeight / 2 - 32;
    // Alt padding'i de hesaba kat
    final safeCenterY = centerY.clamp(0.0, _worldHeight - 64 - bottomPadding);
    ingredientPositions.add(Offset(centerX, safeCenterY));

    // Kalan malzemeleri world alanında rastgele ve çakışmayacak şekilde yerleştir
    for (int i = 1; i < count; i++) {
      bool positionFound = false;
      int attempts = 0;
      while (!positionFound && attempts < 100) {
        double x = random.nextDouble() * (_worldWidth - 64);
        double y = random.nextDouble() * (_worldHeight - 64 - bottomPadding);
        // Çakışma kontrolü
        bool hasCollision = false;
        for (final pos in ingredientPositions) {
          final rect1 = Rect.fromLTWH(pos.dx, pos.dy, 64, 64);
          final rect2 = Rect.fromLTWH(x, y, 64, 64);
          if (rect1.overlaps(rect2)) {
            hasCollision = true;
            break;
          }
        }
        if (!hasCollision) {
          ingredientPositions.add(Offset(x, y));
          positionFound = true;
        }
        attempts++;
      }
    }
    // Viewport'u world'un ortasına başlat
    _viewportX = (_worldWidth - screenWidth) / 2;
    _viewportY = (_worldHeight - screenHeight) / 2;
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _accelerometerSubscription?.cancel();
    _gameTimer?.cancel();
    _titleController.dispose();
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> playSound(String file) async {
    await _audioPlayer.stop();
    await _audioPlayer.setVolume(1.0);
    await _audioPlayer.play(AssetSource('cookingsound/$file'));
  }

  void onIngredientTap(int idx, List<String> ingredients) async {
    if (gameOver) return;
    if (idx == currentIndex) {
      setState(() {
        collected.add(ingredients[idx]);
        currentIndex++;
        score += 5;
      });
      await playSound('tiklama.mp3');
      if (collected.length == ingredients.length) {
        _gameTimer?.cancel();
        await playSound('tamamlandi.mp3');
        _confettiController.play();
        _confettiController.addListener(_onConfettiComplete);
      }
    } else {
      setState(() {
        lives--;
        if (lives <= 0) {
          gameOver = true;
        }
      });
      await playSound('fail.mp3');
    }
  }

  void _onConfettiComplete() {
    if (_confettiController.state == ConfettiControllerState.stopped) {
      _confettiController.removeListener(_onConfettiComplete);
      setState(() {
        showSuccessDialog = true;
      });
    }
  }

  void startGameTimer() {
    _gameTimer?.cancel();
    _gameDuration = Duration.zero;
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _gameDuration += const Duration(seconds: 1);
      });
    });
  }

  void selectCountry(String key) {
    setState(() {
      selectedCountry = null;
      showInfo = true;
      infoCountryKey = key;
      collected = [];
      currentIndex = 0;
      score = 0;
      lives = 3;
      gameOver = false;
      _gameStartTime = DateTime.now();
    });
    Future.delayed(const Duration(seconds: 7), () {
      if (mounted && showInfo && infoCountryKey == key) {
        setState(() {
          selectedCountry = key;
          showInfo = false;
          _generatePositions(countries[key]!['ingredients'].length);
          _startWorldSensors();
          startGameTimer();
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  Future<void> sendGameSessionToServer({
    required int gameId,
    required int userId,
    required int score,
    required bool success,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    final url = Uri.parse('${dotenv.env['API_BASE_URL']}/game_sessions');
    final body = {
      "game_id": gameId,
      "user_id": userId,
      "score": score,
      "success": success,
      "started_at": startedAt.toIso8601String(),
      "ended_at": endedAt.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        print("Oyun oturumu başarıyla kaydedildi!");
      } else {
        print("Hata oluştu: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("İstek gönderilemedi: $e");
    }
  }

  Future<void> _endGame() async {
    _gameTimer?.cancel();
    // Dinamik userId çek
    int? userId;
    try {
      const storage = FlutterSecureStorage();
      final token = await storage.read(key: 'jwt_token');
      if (token != null) {
        final authService = AuthService();
        final (user, _) = await authService.getCurrentUser(token);
        userId = user?.id;
      }
    } catch (e) {
      print('Kullanıcı id alınamadı: $e');
    }

    // Oyun ID'sini al (örnek olarak 1 kullanıyoruz, gerçek uygulamada doğru ID'yi kullanın)
    const gameId = 1; // Bu değeri gerçek oyun ID'si ile değiştirin

    if (userId != null && _gameStartTime != null) {
      await sendGameSessionToServer(
        gameId: gameId,
        userId: userId,
        score: score,
        success: collected.length ==
            countries[selectedCountry]!['ingredients'].length,
        startedAt: _gameStartTime!,
        endedAt: DateTime.now(),
      );
    } else {
      print(
          'Kullanıcı id veya oyun başlangıç zamanı bulunamadı, skor gönderilemedi.');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Eğer oyun ekranı aktifse ve malzemeler varsa, pozisyonları yeniden oluştur
    if (selectedCountry != null && ingredientPositions.isNotEmpty) {
      final data = countries[selectedCountry]!;
      final ingredients = data['ingredients'] as List<String>;
      _generatePositions(ingredients.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showInfo && infoCountryKey != null) {
      final data = countries[infoCountryKey]!;
      return Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.shade100,
                Colors.orange.shade50,
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 420),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.18),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(color: Colors.orange.shade100, width: 2),
                ),
                padding: const EdgeInsets.all(32),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade50,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.12),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(12),
                        child: Image.asset(
                          data['flag'],
                          width: 72,
                          height: 72,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        data['name'],
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        data['meal'],
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.orange.shade700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 22),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Text(
                          data['description'],
                          style: const TextStyle(
                            fontSize: 17,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 22),
                      _InfoRow(
                        icon: Icons.public,
                        title: 'Kökeni',
                        text: data['origin'],
                        color: Colors.orange.shade300,
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(
                        icon: Icons.history_edu,
                        title: 'Tarihçe',
                        text: data['history'],
                        color: Colors.orange.shade400,
                      ),
                      const SizedBox(height: 14),
                      _InfoRow(
                        icon: Icons.emoji_emotions,
                        title: 'Eğlenceli Bilgi',
                        text: '😋 ${data['funFact']}',
                        color: Colors.orange.shade600,
                      ),
                      const SizedBox(height: 32),
                      const CircularProgressIndicator(color: Colors.deepOrange),
                      const SizedBox(height: 10),
                      const Text(
                        'Oyun başlatılıyor...',
                        style: TextStyle(fontSize: 16, color: Colors.orange),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (selectedCountry == null) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.orange.shade400,
                Colors.orange.shade200,
                Colors.orange.shade100,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 16),
                // Başlık ve ikon
                Center(
                  child: Column(
                    children: [
                      // İkon animasyonu
                      AnimatedBuilder(
                        animation: _titleController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle: _titleRotation.value,
                            child: Transform.scale(
                              scale: _titleScale.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.orange.withOpacity(0.3),
                                      blurRadius: 32,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                padding: const EdgeInsets.all(20),
                                child: const Icon(
                                  Icons.restaurant_menu,
                                  size: 50,
                                  color: Colors.deepOrange,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      // Başlık animasyonu
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.orange.shade700,
                            Colors.deepOrange,
                            Colors.orange.shade700,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: const Text(
                          'Dünya Mutfağı',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                            shadows: [
                              Shadow(
                                color: Colors.orange,
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Alt başlık animasyonu
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 1500),
                        curve: Curves.easeOut,
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, (1 - value) * 20),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 2,
                                  ),
                                ),
                                child: const Text(
                                  'Bir ülke seç ve o ülkenin meşhur yemeğini keşfet!',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    shadows: [
                                      Shadow(
                                        color: Colors.orange,
                                        blurRadius: 8,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Kartlar
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 24,
                      right: 24,
                      top: 0,
                      bottom: 60,
                    ),
                    itemCount: countries.length,
                    itemBuilder: (context, i) {
                      final entry = countries.entries.elementAt(i);
                      final key = entry.key;
                      final data = entry.value;
                      return _StaggeredCountryCard(
                        index: i,
                        onTap: () => selectCountry(key),
                        flag: data['flag'],
                        country: data['name'],
                        meal: data['meal'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Oyun ekranı
    final data = countries[selectedCountry]!;
    final ingredients = data['ingredients'] as List<String>;
    final images = data['images'] as Map<String, String>;
    return Scaffold(
      appBar: AppBar(
        title: Text('${data['name']} - ${data['meal']}'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => setState(() => selectedCountry = null),
        ),
      ),
      body: Stack(
        children: [
          // Kamera arka planı (tam ekran)
          if (_cameraController != null &&
              _cameraController!.value.isInitialized)
            FutureBuilder(
              future: _initializeCameraFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return SizedBox.expand(
                    child: CameraPreview(_cameraController!),
                  );
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          // Confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [Colors.red, Colors.green, Colors.yellow, Colors.blue],
            ),
          ),
          // PUAN ve CAN
          Positioned(
            top: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Can göstergesi
                Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.favorite,
                        color: i < lives ? Colors.red : Colors.grey.shade400,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                // Timer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.orange, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        _formatDuration(_gameDuration),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 24),
                // Skor göstergesi
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.13),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange, size: 22),
                      const SizedBox(width: 6),
                      Text(
                        '$score',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Toplama sırası
          Positioned(
            top: 64,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Text('Toplama Sırası:',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900)),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  children: ingredients.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final name = entry.value;
                    final isCollected = collected.contains(name);
                    final isCurrent = idx == currentIndex && !isCollected;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCollected
                            ? Colors.grey.shade400
                            : isCurrent
                                ? Colors.orange
                                : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color:
                              isCurrent ? Colors.orange : Colors.grey.shade300,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        name,
                        style: TextStyle(
                          color: isCollected
                              ? Colors.white
                              : isCurrent
                                  ? Colors.white
                                  : Colors.black54,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          // Oyun bitti ekranı
          if (gameOver)
            Center(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.sentiment_very_dissatisfied,
                        color: Colors.red, size: 54),
                    const SizedBox(height: 16),
                    const Text(
                      'Oyun Bitti!',
                      style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    Text('Puan: $score',
                        style: const TextStyle(
                            fontSize: 22,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                          3,
                          (i) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 2),
                                child: Icon(
                                  Icons.favorite,
                                  color: i < lives
                                      ? Colors.red
                                      : Colors.grey.shade400,
                                  size: 28,
                                ),
                              )),
                    ),
                    const SizedBox(height: 18),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18)),
                      ),
                      onPressed: () {
                        _endGame(); // Oyun bittiğinde puanları kaydet
                        setState(() => selectedCountry = null);
                      },
                      icon: const Icon(Icons.replay),
                      label: const Text('Tekrar Oyna'),
                    ),
                  ],
                ),
              ),
            ),
          // Malzemeler (sanal dünya viewport'unda)
          if (!gameOver)
            ...ingredients.asMap().entries.map((entry) {
              final idx = entry.key;
              final name = entry.value;
              if (collected.contains(name)) return const SizedBox.shrink();
              final pos = ingredientPositions[idx];
              // Malzeme viewport içinde mi?
              final screenWidth = MediaQuery.of(context).size.width;
              final screenHeight = MediaQuery.of(context).size.height;
              final visibleX = pos.dx - _viewportX;
              final visibleY = pos.dy - _viewportY;
              if (visibleX < 0 ||
                  visibleX > screenWidth - 64 ||
                  visibleY < 0 ||
                  visibleY > screenHeight - 64) {
                return const SizedBox.shrink();
              }
              return Positioned(
                left: visibleX,
                top: visibleY,
                child: GestureDetector(
                  onTap: () => onIngredientTap(idx, ingredients),
                  child: _buildIngredient(
                    name,
                    images[name]!,
                    pos,
                    false,
                  ),
                ),
              );
            }).toList(),
          // Başarı bilgilendirme kutusu
          if (showSuccessDialog)
            Center(
              child: Container(
                width: 320,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.13),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: Colors.orange.shade100, width: 2),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.orange, size: 48),
                    const SizedBox(height: 12),
                    const Text(
                      'Tebrikler!',
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange),
                    ),
                    const SizedBox(height: 10),
                    Text('Süre: ${_formatDuration(_gameDuration)}',
                        style: const TextStyle(
                            fontSize: 18, color: Colors.black87)),
                    const SizedBox(height: 6),
                    Text('Puan: $score',
                        style: const TextStyle(
                            fontSize: 18,
                            color: Colors.orange,
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            setState(() {
                              showSuccessDialog = false;
                              selectedCountry = null;
                            });
                          },
                          icon: const Icon(Icons.home),
                          label: const Text('Ana Menü'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () {
                            setState(() {
                              showSuccessDialog = false;
                              // Aynı ülkeyi tekrar başlat
                              if (selectedCountry != null) {
                                selectCountry(selectedCountry!);
                              }
                            });
                          },
                          icon: const Icon(Icons.replay),
                          label: const Text('Tekrar Oyna'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIngredient(
      String name, String imagePath, Offset position, bool isCurrent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (imagePath.endsWith('.svg'))
          SizedBox(
            width: 64,
            height: 64,
            child: SvgPicture.asset(imagePath),
          )
        else
          SizedBox(
            width: 64,
            height: 64,
            child: Image.asset(imagePath),
          ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  void _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _cameraController = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
      );
      _initializeCameraFuture = _cameraController!.initialize();
      setState(() {});
    }
  }
}

class _StaggeredCountryCard extends StatefulWidget {
  final int index;
  final VoidCallback onTap;
  final String flag;
  final String country;
  final String meal;

  const _StaggeredCountryCard({
    required this.index,
    required this.onTap,
    required this.flag,
    required this.country,
    required this.meal,
  });

  @override
  State<_StaggeredCountryCard> createState() => _StaggeredCountryCardState();
}

class _StaggeredCountryCardState extends State<_StaggeredCountryCard>
    with SingleTickerProviderStateMixin {
  double opacity = 0;
  bool isHovered = false;
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _bounceController,
        curve: Curves.elasticOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));
    Future.delayed(Duration(milliseconds: 150 * widget.index), () {
      if (mounted) setState(() => opacity = 1);
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _bounceController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _bounceController.reverse();
  }

  void _onTapCancel() {
    _bounceController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      child: SlideTransition(
        position: _slideAnimation,
        child: MouseRegion(
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false),
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(
                bottom: 16,
              ),
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.withOpacity(isHovered ? 0.25 : 0.13),
                    blurRadius: isHovered ? 24 : 18,
                    offset: Offset(0, isHovered ? 12 : 8),
                  ),
                ],
                gradient: isHovered
                    ? LinearGradient(
                        colors: [
                          Colors.orange.shade50,
                          Colors.white,
                          Colors.orange.shade50,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: ScaleTransition(
                scale: _bounceAnimation,
                child: Row(
                  children: [
                    // Bayrak
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange.shade50,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange.withOpacity(0.15),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(10),
                      child: Image.asset(
                        widget.flag,
                        width: 52,
                        height: 52,
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Ülke ve yemek adı
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.country,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrange,
                              shadows: [
                                Shadow(
                                  color: Colors.orange,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.orange.shade100,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              widget.meal,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.deepOrange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Ok ikonu
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isHovered
                            ? Colors.orange.shade200
                            : Colors.orange.shade100,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.orange
                                .withOpacity(isHovered ? 0.3 : 0.2),
                            blurRadius: isHovered ? 12 : 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Colors.deepOrange,
                        size: isHovered ? 24 : 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Bilgi satırı widget'ı
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;
  final Color color;
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.text,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.13),
        borderRadius: BorderRadius.circular(14),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: color.withOpacity(0.25),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(8),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  text,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
