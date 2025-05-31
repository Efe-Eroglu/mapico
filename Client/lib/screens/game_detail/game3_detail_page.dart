import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:mapico/models/game_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mapico/services/auth_service.dart';
import 'package:confetti/confetti.dart';

class Game3DetailPage extends StatefulWidget {
  @override
  _Game3DetailPageState createState() => _Game3DetailPageState();
}

class _Game3DetailPageState extends State<Game3DetailPage>
    with SingleTickerProviderStateMixin {
  // Oyun değişkenleri
  bool isGameStarted = false;
  bool isCountrySelected = false;
  String? selectedCountry;
  int score = 0;
  int timeLeft = 60;
  bool gameOver = false;
  DateTime? _gameStartTime;
  Timer? _gameTimer;
  Timer? _itemSpawnTimer;
  Timer? _animationTimer;
  double _currentTime = 0.0;

  // Ses oynatıcı
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioCache _audioCache = AudioCache(prefix: 'assets/araçlar/');

  // Karakter pozisyonu ve hızı
  double _characterX = 0.0;
  double _characterY = 0.0;
  double _characterSpeed = 12.0;
  final double _characterSize = 120.0;
  final double _itemSize = 60.0;
  final double _collectionDistance = 70.0;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;

  // Toplanabilir nesneler
  List<CollectibleItem> items = [];
  final Random random = Random();

  // Ülke bilgileri
  final Map<String, Map<String, dynamic>> countries = {
    'turkiye': {
      'name': 'Türkiye',
      'background': 'assets/araçlar/plane_interior_turkey.png',
      'items': [
        {
          'name': 'Nazar Boncuğu',
          'image': 'assets/araçlar/nazar.png',
          'points': 10,
          'description':
              'Nazar boncuğu, Türk kültüründe kötü gözden korunmak için kullanılan geleneksel bir semboldür.',
        },
        {
          'name': 'Türk Kahvesi',
          'image': 'assets/araçlar/kahve.png',
          'points': 15,
          'description':
              'Türk kahvesi, dünya mirası listesinde yer alan geleneksel bir içecektir.',
        },
      ],
    },
    'usa': {
      'name': 'Amerika',
      'background': 'assets/araçlar/plane_interior_usa.png',
      'items': [
        {
          'name': 'Hot Dog',
          'image': 'assets/araçlar/hotdog.png',
          'points': 10,
          'description':
              'Hot dog, Amerikan fast food kültürünün vazgeçilmez bir parçasıdır.',
        },
        {
          'name': 'Beyzbol Topu',
          'image': 'assets/araçlar/baseball.png',
          'points': 15,
          'description':
              'Beyzbol, Amerika\'nın en popüler sporlarından biridir.',
        },
        {
          'name': 'Elmalı Turta',
          'image': 'assets/araçlar/applepie.png',
          'points': 20,
          'description':
              'Elmalı turta, Amerikan mutfağının klasik tatlılarından biridir.',
        },
      ],
    },
  };

  // Animasyon kontrolcüsü
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _initializeGame();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _confettiController = ConfettiController(duration: Duration(seconds: 3));
  }

  Future<void> _initializeGame() async {
    try {
      await Future.wait([
        _audioCache.load('collect.mp3'),
        _audioCache.load('win.mp3'),
        _audioCache.load('lose.mp3'),
      ]);
    } catch (e) {
      print('Ses dosyaları yüklenirken hata: $e');
    }
  }

  void _startGame() {
    setState(() {
      isGameStarted = true;
      score = 0;
      timeLeft = 60;
      gameOver = false;
      items.clear();
      _characterX = MediaQuery.of(context).size.width / 2;
      _characterY = MediaQuery.of(context).size.height / 2;
    });

    _gameStartTime = DateTime.now();
    _startTimers();
    _startAccelerometer();
  }

  void _startTimers() {
    _gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeLeft > 0 && !gameOver) {
        setState(() {
          timeLeft--;
        });
        if (timeLeft == 0) {
          _endGame();
        }
      }
    });

    _itemSpawnTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!gameOver) _spawnItem();
    });

    _animationTimer = Timer.periodic(Duration(milliseconds: 16), (timer) {
      if (!gameOver) _updateItems();
    });
  }

  void _startAccelerometer() {
    _accelerometerSubscription =
        accelerometerEvents.listen((AccelerometerEvent event) {
      if (!mounted || gameOver) return;

      setState(() {
        // Telefon eğimine göre karakteri hareket ettir
        _characterX += (event.x * 0.8) * _characterSpeed;
        _characterY += (event.y * 0.8) * _characterSpeed;

        // Ekran sınırlarını kontrol et
        final screenWidth = MediaQuery.of(context).size.width;
        final screenHeight = MediaQuery.of(context).size.height;
        _characterX = _characterX.clamp(0.0, screenWidth - _characterSize);
        _characterY = _characterY.clamp(0.0, screenHeight - _characterSize);
      });
    });
  }

  void _spawnItem() {
    if (selectedCountry == null) return;

    final countryItems = countries[selectedCountry]!['items'] as List;
    final randomItem = countryItems[random.nextInt(countryItems.length)];

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Ekranda aynı anda en fazla 6 nesne olacak şekilde kontrol
    if (items.length >= 6) {
      items.removeAt(0); // En eski nesneyi kaldır
    }

    final item = CollectibleItem(
      id: DateTime.now().millisecondsSinceEpoch,
      x: random.nextDouble() * (screenWidth - _itemSize),
      y: screenHeight,
      image: randomItem['image'],
      points: randomItem['points'],
      name: randomItem['name'],
      description: randomItem['description'],
    );

    setState(() {
      items.add(item);
    });
  }

  void _updateItems() {
    List<CollectibleItem> toCollect = [];
    setState(() {
      // Nesnelerin hareket hızını karakter hızına yakın ayarladık (12.0 * 0.3 = 3.6)
      for (var item in items) {
        item.y -= 3.6;
        // Karakter ile nesne arasındaki mesafeyi kontrol et
        final distance =
            sqrt(pow(_characterX - item.x, 2) + pow(_characterY - item.y, 2));
        // Eğer karakter nesneye yeterince yakınsa, nesneyi topla
        if (distance < _collectionDistance) {
          toCollect.add(item);
        }
      }
      // Ekrandan çıkan nesneleri kaldır
      items.removeWhere((item) => item.y < -_itemSize);
      // Döngü dışında toplama işlemi
      for (var item in toCollect) {
        _collectItem(item);
      }
    });
  }

  void _collectItem(CollectibleItem item) {
    _audioCache.load('collect.mp3').then((audioSource) {
      _audioPlayer.play(DeviceFileSource(audioSource.path));
    });

    // Toplama animasyonu
    _animationController.forward().then((_) => _animationController.reverse());

    setState(() {
      score += item.points;
      items.removeWhere((i) => i.id == item.id);
    });
  }

  void _endGame() {
    setState(() {
      gameOver = true;
      isGameStarted = false;
    });
    _gameTimer?.cancel();
    _itemSpawnTimer?.cancel();
    _animationTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _audioCache.load('lose.mp3').then((audioSource) {
      _audioPlayer.play(DeviceFileSource(audioSource.path));
    });
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _itemSpawnTimer?.cancel();
    _animationTimer?.cancel();
    _accelerometerSubscription?.cancel();
    _audioPlayer.dispose();
    _animationController.dispose();
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isCountrySelected) {
      return _buildCountrySelection();
    }

    if (!isGameStarted) {
      return _buildGameStart();
    }

    if (gameOver) {
      return _buildGameOver();
    }

    return _buildGameScreen();
  }

  Widget _buildCountrySelection() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/araçlar/plane_background.png'),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Gökyüzü Kaşifi',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Ülke Seçin',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 10.0,
                                color: Colors.black,
                                offset: Offset(2.0, 2.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),
                        ...countries.entries
                            .map((country) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  child: _buildCountryButton(country),
                                ))
                            .toList(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountryButton(MapEntry<String, Map<String, dynamic>> country) {
    return Container(
      width: 250,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.withOpacity(0.8),
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
        onPressed: () {
          setState(() {
            selectedCountry = country.key;
            isCountrySelected = true;
          });
        },
        child: Column(
          children: [
            Text(
              country.value['name'],
              style: TextStyle(
                fontSize: 28,
                color: Colors.white,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    blurRadius: 3.0,
                    color: Colors.black,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              '${(country.value['items'] as List).length} Nesne',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameStart() {
    final country = countries[selectedCountry]!;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(country['background']),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.black.withOpacity(0.5),
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${country['name']} - Gökyüzü Kaşifi',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          blurRadius: 10.0,
                          color: Colors.black,
                          offset: Offset(2.0, 2.0),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Hazır mısın?',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 5.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(
                          'Telefonu eğerek karakteri yönlendir\nve nesneleri topla!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 3.0,
                                color: Colors.black,
                                offset: Offset(1.0, 1.0),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 15,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding:
                            EdgeInsets.symmetric(horizontal: 50, vertical: 25),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _startGame,
                      child: Text(
                        'Oyunu Başlat',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameScreen() {
    final country = countries[selectedCountry]!;
    return Scaffold(
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(country['background']),
                fit: BoxFit.cover,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
          // Toplanabilir nesneler
          ...items
              .map((item) => Positioned(
                    left: item.x,
                    top: item.y,
                    child: AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) => Transform.scale(
                        scale: 1.0,
                        child: Image.asset(
                          item.image,
                          width: _itemSize,
                          height: _itemSize,
                        ),
                      ),
                    ),
                  ))
              .toList(),
          // Karakter
          Positioned(
            left: _characterX,
            top: _characterY,
            child: Image.asset(
              'assets/araçlar/character.png',
              width: _characterSize,
              height: _characterSize,
            ),
          ),
          // Skor ve süre göstergesi
          Positioned(
            top: 40,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.yellow,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        'Skor: $score',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.timer,
                        color: Colors.white,
                        size: 30,
                      ),
                      SizedBox(width: 10),
                      Text(
                        '$timeLeft sn',
                        style: TextStyle(
                          fontSize: 28,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 3.0,
                              color: Colors.black,
                              offset: Offset(1.0, 1.0),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameOver() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage(countries[selectedCountry]!['background']),
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
          ),
        ),
        child: Center(
          child: Container(
            margin: EdgeInsets.all(30),
            padding: EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_off,
                  size: 100,
                  color: Colors.red,
                ),
                SizedBox(height: 20),
                Text(
                  'Süre Doldu!',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 5.0,
                        color: Colors.black,
                        offset: Offset(2.0, 2.0),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Skor: $score',
                    style: TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 3.0,
                          color: Colors.black,
                          offset: Offset(1.0, 1.0),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        selectedCountry = null;
                        isCountrySelected = false;
                        gameOver = false;
                      });
                    },
                    child: Text(
                      'Ana Menüye Dön',
                      style: TextStyle(
                        fontSize: 24,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 3.0,
                            color: Colors.black,
                            offset: Offset(1.0, 1.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CollectibleItem {
  final int id;
  double x;
  double y;
  final String image;
  final int points;
  final String name;
  final String description;

  CollectibleItem({
    required this.id,
    required this.x,
    required this.y,
    required this.image,
    required this.points,
    required this.name,
    required this.description,
  });
}
