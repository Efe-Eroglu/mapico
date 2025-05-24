import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mapico/services/auth_service.dart';
import 'package:mapico/models/game_model.dart';

class Game1DetailPage extends StatefulWidget {
  @override
  _Game1DetailPageState createState() => _Game1DetailPageState();
}

class _Game1DetailPageState extends State<Game1DetailPage> {
  final AudioPlayer audioPlayer = AudioPlayer();
  final AudioCache effectAudioCache =
      AudioCache(prefix: 'assets/balonPatlatmaSound/');

  bool isGameStarted = false;
  bool isCountrySelected = false;
  String? selectedCountry;
  int score = 0;
  int lives = 3;
  int balloonsPopped = 0;
  int totalBalloons = 0;
  double _currentTime = 0.0;
  Timer? _gameTimer;
  Timer? _balloonTimer;
  Timer? _animationTimer;
  Timer? _speedEffectTimer;
  DateTime? _gameStartTime;
  List<String> currentGameWrongAnswers = [];
  bool isSpeedReduced = false;
  double _originalSpeed = 1.0;
  bool isPopupOpen = false;
  int yellowBalloonIndex = 0; // 0,1,2
  Set<int> yellowBalloonScoresAsked = {};
  Question? currentQuestion;
  bool? lastAnswerCorrect;

  // Balon özellikleri
  List<Balloon> balloons = [];
  final Random random = Random();
  final List<Color> balloonColors = [
    Colors.black, // Siyah
    Colors.red, // Kırmızı
    Colors.yellow // Sarı
  ];
  final Color forbiddenColor = Colors.red;
  final Color yellowColor = Colors.yellow;
  final Color blackColor = Colors.black;

  final List<Map<String, String>> countries = [
    {"name": "Türkiye", "flag": "assets/balonPatlatmaFlags/turkiye.png"},
    {"name": "Amerika", "flag": "assets/balonPatlatmaFlags/usa.png"},
    {"name": "Hollanda", "flag": "assets/balonPatlatmaFlags/holland.png"},
    {"name": "Almanya", "flag": "assets/balonPatlatmaFlags/germany.png"},
  ];

  // Türkiye için örnek sorular
  final List<Question> turkiyeQuestions = [
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/galata.jpeg',
      questionText: 'Bu yapı hangi şehre aittir?',
      options: ['İstanbul', 'Madrid'],
      correctIndex: 0,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/kizKulesi.jpeg',
      questionText: 'Bu kule hangi şehirde bulunur?',
      options: ['İstanbul', 'Ankara'],
      correctIndex: 0,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/anitkabir.jpeg',
      questionText: 'Bu anıt hangi şehirde bulunur?',
      options: ['Ankara', 'İzmir'],
      correctIndex: 0,
    ),
  ];

  // Amerika için örnek sorular
  final List<Question> amerikaQuestions = [
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/statue_of_liberty.jpeg',
      questionText: 'Özgürlük Heykeli hangi ülkededir?',
      options: ['Türkiye', 'ABD'],
      correctIndex: 1,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/white_house.jpeg',
      questionText: 'Beyaz Saray hangi ülkededir?',
      options: ['ABD', 'Azerbaycan'],
      correctIndex: 0,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/golden_gate.jpeg',
      questionText: 'Golden Gate Köprüsü hangi ülkededir?',
      options: ['Brezilya', 'ABD'],
      correctIndex: 1,
    ),
  ];

  // Hollanda için sorular eklendi
  final List<Question> hollandaQuestions = [
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/amsterdam_canal.jpeg',
      questionText: 'Bu kanallar hangi ülkededir?',
      options: ['Almanya', 'Hollanda'],
      correctIndex: 1,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/keukenhof.jpeg',
      questionText: 'Dünyaca ünlü bu lale bahçesi hangi ülkededir?',
      options: ['Hollanda', 'Fransa'],
      correctIndex: 0,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/windmill.jpeg',
      questionText: 'Bu geleneksel yel değirmenleri hangi ülkededir?',
      options: ['Şili', 'Hollanda'],
      correctIndex: 1,
    ),
  ];

  // Almanya için sorular eklendi
  final List<Question> almanyaQuestions = [
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/brandenburg_gate.jpeg',
      questionText: 'Brandenburg Kapısı hangi ülkededir?',
      options: ['Rusya', 'Almanya'],
      correctIndex: 1,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/neuschwanstein.jpeg',
      questionText: 'Bu ünlü kale hangi ülkededir?',
      options: ['Almanya', 'Bolivya'],
      correctIndex: 0,
    ),
    Question(
      imageAsset: 'assets/balonPatlatmaLokasyon/cologne_cathedral.jpeg',
      questionText: 'Köln Katedrali hangi ülkededir?',
      options: ['Portekiz', 'Almanya'],
      correctIndex: 1,
    ),
  ];

  GameModel? currentGame;

  @override
  void initState() {
    super.initState();
    if (Get.arguments != null && Get.arguments is GameModel) {
      currentGame = Get.arguments as GameModel;
    }
    _initializeGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _balloonTimer?.cancel();
    _animationTimer?.cancel();
    _speedEffectTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _initializeGame() async {
    try {
      await Future.wait([
        effectAudioCache.load('pop.mp3'),
        effectAudioCache.load('wrong.mp3'),
        effectAudioCache.load('success.mp3'),
      ]);
    } catch (e) {
      print('Initialization error: $e');
    }
  }

  void _startGame() {
    setState(() {
      isGameStarted = true;
      score = 0;
      lives = 3;
      balloonsPopped = 0;
      totalBalloons = 0;
      balloons.clear();
      currentGameWrongAnswers.clear();
      _currentTime = 0.0;
      isSpeedReduced = false;
      isPopupOpen = false;
      yellowBalloonIndex = 0;
      yellowBalloonScoresAsked = {};
      currentQuestion = null;
      lastAnswerCorrect = null;
    });
    _gameStartTime = DateTime.now();
    _startTimers();
  }

  void _startTimers() {
    _gameTimer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (_gameStartTime != null) {
        setState(() {
          _currentTime =
              DateTime.now().difference(_gameStartTime!).inMilliseconds / 1000;
        });
      }
    });
    _balloonTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      _addBalloon();
    });
    _animationTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (!isPopupOpen) {
        _updateBalloons();
      }
    });
  }

  void _addBalloon() {
    if (!isGameStarted || isPopupOpen) return;
    final screenWidth = MediaQuery.of(context).size.width;
    final yellowScores = [30, 60, 90];
    int? yellowToDrop;
    for (final s in yellowScores) {
      if (score == s && !yellowBalloonScoresAsked.contains(s)) {
        yellowToDrop = s;
        break;
      }
    }
    bool yellowOnScreen = balloons.any((b) => b.type == 'yellow');

    // Eğer ekranda sarı balon varsa başka balon eklenmesin
    if (yellowOnScreen) return;

    // Sarı balon eklenmesi gereken durumda sadece sarı balon ekle ve diğerlerini temizle
    if (yellowToDrop != null && yellowBalloonIndex < 3 && !yellowOnScreen) {
      final x = random.nextDouble() * (screenWidth - 100);
      final balloon = Balloon(
        id: DateTime.now().millisecondsSinceEpoch,
        x: x,
        y: 0,
        color: yellowColor,
        speed: 0.8,
        isForbidden: false,
        type: 'yellow',
      );
      setState(() {
        balloons.clear();
        balloons.add(balloon);
      });
      return;
    }

    // Sadece sarı balon henüz patlatılmamışken, ilgili aralıkta siyah balon düşmesin
    bool yellowNeeded =
        (score == 30 && !yellowBalloonScoresAsked.contains(30)) ||
            (score == 60 && !yellowBalloonScoresAsked.contains(60)) ||
            (score == 90 && !yellowBalloonScoresAsked.contains(90));
    bool onlyYellowOrRed = yellowNeeded && !yellowOnScreen;

    String type;
    Color color;
    double speed;
    if (onlyYellowOrRed) {
      // Sadece kırmızı balon düşebilir
      type = 'red';
      color = forbiddenColor;
      speed = 1.0 + random.nextDouble() * 2.0;
    } else {
      final r = random.nextDouble();
      if (r < 0.4) {
        type = 'red';
        color = forbiddenColor;
        speed = 1.0 + random.nextDouble() * 2.0;
      } else {
        type = 'black';
        color = blackColor;
        speed = 1.0 + random.nextDouble() * 2.0;
      }
    }
    final x = random.nextDouble() * (screenWidth - 60);
    final balloon = Balloon(
      id: DateTime.now().millisecondsSinceEpoch,
      x: x,
      y: 0,
      color: color,
      speed: speed,
      isForbidden: type == 'red',
      type: type,
    );
    setState(() {
      balloons.add(balloon);
    });
  }

  void _updateBalloons() {
    if (!isGameStarted) return;
    final screenHeight = MediaQuery.of(context).size.height;
    bool shouldUpdate = false;
    setState(() {
      for (var balloon in balloons) {
        balloon.y += balloon.speed;
        if (balloon.y > screenHeight) {
          if (!balloon.isForbidden) {
            // Can kaybı yok, sadece balon kaybolur
          }
          shouldUpdate = true;
        }
      }
      if (shouldUpdate) {
        balloons.removeWhere((balloon) => balloon.y > screenHeight);
      }
    });
  }

  Future<void> _popBalloon(Balloon balloon) async {
    if (!isGameStarted || isPopupOpen) return;
    if (balloon.type == 'red') {
      setState(() {
        lives--;
        score = (score - 5).clamp(0, 100);
        currentGameWrongAnswers.add("Kırmızı Balon");
        balloonsPopped++;
        balloons.removeWhere((b) => b.id == balloon.id);
      });
      if (lives <= 0) {
        _endGame();
        return;
      }
    } else if (balloon.type == 'black') {
      await _playPopSound();
      setState(() {
        score = (score + 10).clamp(0, 100);
        balloonsPopped++;
        balloons.removeWhere((b) => b.id == balloon.id);
      });
    } else if (balloon.type == 'yellow') {
      // Sarı balon: pop-up aç, oyun duraklat
      final yellowScores = [30, 60, 90];
      int yellowIndex = yellowBalloonIndex;
      final Set<int> newAsked = {...yellowBalloonScoresAsked};
      newAsked.add(yellowScores[yellowIndex]);
      Question question;
      if (selectedCountry == "Türkiye") {
        question = turkiyeQuestions[yellowIndex];
      } else if (selectedCountry == "Amerika") {
        question = amerikaQuestions[yellowIndex];
      } else if (selectedCountry == "Hollanda") {
        question = hollandaQuestions[yellowIndex];
      } else if (selectedCountry == "Almanya") {
        question = almanyaQuestions[yellowIndex];
      } else {
        // Diğer ülkeler için örnek soru
        question = Question(
          imageAsset: '',
          questionText: 'Bu ülkeye özel soru hazırlanmadı.',
          options: ['Seçenek 1', 'Seçenek 2'],
          correctIndex: 0,
        );
      }
      setState(() {
        isPopupOpen = true;
        currentQuestion = question;
        yellowBalloonIndex = yellowIndex + 1;
        yellowBalloonScoresAsked = newAsked;
        balloons.removeWhere((b) => b.id == balloon.id);
      });
    }
    // Oyun bitti mi?
    if (score >= 100) {
      _endGame();
    }
  }

  Future<void> _answerQuestion(int selectedIndex) async {
    if (currentQuestion == null) return;
    final correct = selectedIndex == currentQuestion!.correctIndex;
    setState(() {
      lastAnswerCorrect = correct;
    });
    if (correct) {
      await audioPlayer.play(AssetSource('balonPatlatmaSound/success.mp3'));
      await Future.delayed(const Duration(milliseconds: 1200));
    } else {
      await audioPlayer.play(AssetSource('balonPatlatmaSound/wrong.mp3'));
      await Future.delayed(const Duration(milliseconds: 1200));
    }
    setState(() {
      isPopupOpen = false;
      currentQuestion = null;
      lastAnswerCorrect = null;
    });
  }

  Future<void> _playPopSound() async {
    try {
      await audioPlayer.play(AssetSource('balonPatlatmaSound/pop.mp3'));
    } catch (e) {
      print('Pop sound error: $e');
    }
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
    _balloonTimer?.cancel();
    _animationTimer?.cancel();
    _speedEffectTimer?.cancel();
    setState(() {
      isGameStarted = false;
    });
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
    final gameId = currentGame?.id;
    if (userId != null && gameId != null) {
      await sendGameSessionToServer(
        gameId: gameId,
        userId: userId,
        score: score,
        success: score >= 100,
        startedAt: _gameStartTime!,
        endedAt: DateTime.now(),
      );
    } else {
      print('Kullanıcı id veya gameId bulunamadı, skor gönderilemedi.');
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events, color: Colors.amber, size: 32),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                score >= 100 ? "Tebrikler! Oyun Tamamlandı!" : "Oyun Bitti!",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(),
            _scoreBarContent(),
            Divider(),
            if (currentGameWrongAnswers.isNotEmpty) ...[
              SizedBox(height: 10),
              Text(
                "Yanlış Patlatmalar: \\${currentGameWrongAnswers.length} kırmızı balon",
                style: TextStyle(
                    color: Colors.red[700], fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                elevation: 6,
                shadowColor: Colors.deepOrangeAccent,
                textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              icon: Icon(Icons.check_circle_outline),
              label: Text("Tamam"),
              onPressed: () {
                Navigator.of(context).pop();
                Future.delayed(const Duration(milliseconds: 100), () {
                  Get.offAllNamed('/home');
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreBarContent() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _scoreBox(Icons.flag, selectedCountry ?? '', Colors.blue[700]!),
        _scoreBox(Icons.emoji_events, '$score', Colors.amber[800]!),
        _scoreBox(Icons.bubble_chart, '$balloonsPopped', Colors.purple[400]!),
        _scoreBox(Icons.favorite, '$lives', Colors.red[400]!),
        _scoreBox(Icons.timer, '${_currentTime.toStringAsFixed(1)}s',
            Colors.green[400]!),
      ],
    );
  }

  Widget _scoreBox(IconData icon, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 6,
            offset: Offset(1, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: color, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildCountrySelectScreen(Size size, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "Bir ülke seçiniz",
            style: TextStyle(
                fontSize: isTablet ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900]),
          ),
          SizedBox(height: 10),
          Text(
            "Oynamak istediğiniz ülkeyi seçin ve maceraya başlayın!",
            style: TextStyle(
                fontSize: isTablet ? 18 : 14, color: Colors.grey[700]),
          ),
          SizedBox(height: 32),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 32,
            runSpacing: 32,
            children: countries.map((country) {
              return InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  setState(() {
                    selectedCountry = country["name"];
                    isCountrySelected = true;
                  });
                  _startGame();
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 200),
                  width: isTablet ? 120 : 90,
                  height: isTablet ? 150 : 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blueAccent.withOpacity(0.13),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: selectedCountry == country["name"]
                          ? Colors.blue
                          : Colors.transparent,
                      width: 2.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ClipOval(
                        child: Image.asset(
                          country["flag"]!,
                          width: isTablet ? 60 : 44,
                          height: isTablet ? 60 : 44,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        country["name"]!,
                        style: TextStyle(
                            fontSize: isTablet ? 20 : 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900]),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGameScreen(Size size, bool isPortrait, bool isTablet) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF87CEEB),
                Color(0xFF1E90FF),
              ],
            ),
          ),
        ),
        for (var balloon in balloons)
          Positioned(
            left: balloon.x,
            top: balloon.y,
            child: GestureDetector(
              onTap: () => _popBalloon(balloon),
              child: Container(
                width: balloon.type == 'yellow' ? 100 : 60,
                height: balloon.type == 'yellow' ? 140 : 80,
                child: CustomPaint(
                  painter: BalloonPainter(
                    color: balloon.color,
                    isForbidden: balloon.isForbidden,
                    type: balloon.type,
                  ),
                ),
              ),
            ),
          ),
        Positioned(
          top: 20,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: _scoreBarContent(),
          ),
        ),
        if (isSpeedReduced)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.yellow.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.yellow.withOpacity(0.2),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.slow_motion_video,
                        color: Colors.orange[900], size: 26),
                    SizedBox(width: 10),
                    Text(
                      'Hız Azaltıldı!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (isPopupOpen && currentQuestion != null)
          _QuestionPopup(
            question: currentQuestion!,
            lastAnswerCorrect: lastAnswerCorrect,
            onAnswer: (i) => _answerQuestion(i),
          ),
      ],
    );
  }

  Widget _buildResponsiveLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = size.height > size.width;
    final isTablet = size.shortestSide >= 600;
    if (!isCountrySelected) {
      return _buildCountrySelectScreen(size, isTablet);
    } else {
      return _buildGameScreen(size, isPortrait, isTablet);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Balon Macerası")),
      body: _buildResponsiveLayout(context),
    );
  }
}

class Balloon {
  final int id;
  double x;
  double y;
  final Color color;
  double speed;
  final bool isForbidden;
  final String type; // 'black', 'red', 'yellow'
  Balloon({
    required this.id,
    required this.x,
    required this.y,
    required this.color,
    required this.speed,
    required this.isForbidden,
    required this.type,
  });
}

class BalloonPainter extends CustomPainter {
  final Color color;
  final bool isForbidden;
  final String type;
  BalloonPainter(
      {required this.color, required this.isForbidden, required this.type});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.18)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 6);
    final path = Path();
    final centerX = size.width / 2;
    final topY = size.height * 0.18;
    final bottomY = size.height * 0.88;
    path.moveTo(centerX, topY);
    path.cubicTo(
      size.width * 0.95,
      size.height * 0.25,
      size.width * 0.95,
      size.height * 0.75,
      centerX,
      bottomY,
    );
    path.cubicTo(
      size.width * 0.05,
      size.height * 0.75,
      size.width * 0.05,
      size.height * 0.25,
      centerX,
      topY,
    );
    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.22)
      ..style = PaintingStyle.fill;
    final highlightRect = Rect.fromCenter(
      center: Offset(size.width * 0.38, size.height * 0.32),
      width: size.width * 0.22,
      height: size.height * 0.18,
    );
    canvas.save();
    canvas.rotate(-0.12);
    canvas.drawOval(highlightRect, highlightPaint);
    canvas.restore();
    final mouthPath = Path();
    mouthPath.moveTo(centerX - size.width * 0.06, size.height * 0.89);
    mouthPath.lineTo(centerX + size.width * 0.06, size.height * 0.89);
    mouthPath.lineTo(centerX, size.height * 0.97);
    mouthPath.close();
    final mouthPaint = Paint()
      ..color = Colors.grey[500]!
      ..style = PaintingStyle.fill;
    canvas.drawPath(mouthPath, mouthPaint);
    final stringPaint = Paint()
      ..color = Colors.grey[700]!
      ..strokeWidth = 2;
    final stringStart = Offset(centerX, size.height * 0.97);
    final stringEnd = Offset(centerX, size.height * 1.13);
    final control1 = Offset(centerX - 10, size.height * 1.03);
    final control2 = Offset(centerX + 12, size.height * 1.08);
    final stringPath = Path()
      ..moveTo(stringStart.dx, stringStart.dy)
      ..cubicTo(control1.dx, control1.dy, control2.dx, control2.dy,
          stringEnd.dx, stringEnd.dy);
    canvas.drawPath(stringPath, stringPaint);
    // Kırmızı balon için X işareti
    if (type == 'red') {
      final xPaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      canvas.drawLine(
        Offset(size.width * 0.22, size.height * 0.28),
        Offset(size.width * 0.78, size.height * 0.78),
        xPaint,
      );
      canvas.drawLine(
        Offset(size.width * 0.78, size.height * 0.28),
        Offset(size.width * 0.22, size.height * 0.78),
        xPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class Question {
  final String imageAsset;
  final String questionText;
  final List<String> options;
  final int correctIndex;
  Question({
    required this.imageAsset,
    required this.questionText,
    required this.options,
    required this.correctIndex,
  });
}

class _QuestionPopup extends StatefulWidget {
  final Question question;
  final bool? lastAnswerCorrect;
  final void Function(int selectedIndex) onAnswer;
  const _QuestionPopup(
      {required this.question, required this.onAnswer, this.lastAnswerCorrect});
  @override
  State<_QuestionPopup> createState() => _QuestionPopupState();
}

class _QuestionPopupState extends State<_QuestionPopup> {
  int? selectedIndex;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.black54,
        child: Container(
          width: 370,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.question_mark_rounded,
                  color: Colors.amber[800], size: 38),
              const SizedBox(height: 10),
              if (widget.question.imageAsset.isNotEmpty)
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(widget.question.imageAsset, height: 100),
                  ),
                ),
              const SizedBox(height: 18),
              Text(
                widget.question.questionText,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              ...List.generate(widget.question.options.length, (i) {
                Color? color;
                if (selectedIndex != null) {
                  if (i == selectedIndex && widget.lastAnswerCorrect == true)
                    color = Colors.green;
                  else if (i == selectedIndex &&
                      widget.lastAnswerCorrect == false)
                    color = Colors.red;
                  else if (i == widget.question.correctIndex &&
                      widget.lastAnswerCorrect == true) color = Colors.green;
                }
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color ?? Colors.blue[50],
                      foregroundColor:
                          color != null ? Colors.white : Colors.blue[900],
                      elevation: color != null ? 6 : 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 16),
                      textStyle:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    onPressed: selectedIndex == null
                        ? () async {
                            setState(() {
                              selectedIndex = i;
                            });
                            await Future.delayed(
                                const Duration(milliseconds: 200));
                            widget.onAnswer(i);
                          }
                        : null,
                    child: Text(widget.question.options[i]),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
