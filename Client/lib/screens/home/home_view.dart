import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import 'widgets/welcome_card.dart';
import 'widgets/featured_section.dart';
import 'widgets/quick_actions.dart';
import 'widgets/games_card.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const WelcomeCard(),
                const SizedBox(height: 24),
                const FeaturedSection(),
                const SizedBox(height: 24),
                const QuickActions(),
                const SizedBox(height: 24),
                const GamesCard(),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.onAddPressed,
        backgroundColor: Theme.of(context).primaryColor,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
  
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4B3F72), // Koyu mor
              Color(0xFF3C6997), // Mavi
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        'Mapico',
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      centerTitle: true,
      actions: [
        // Bildirim Butonu
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: Colors.white,
          ),
          onPressed: controller.onNotificationPressed,
        ),
        // Profil Butonu
        IconButton(
          icon: const Icon(
            Icons.person_outline,
            color: Colors.white,
          ),
          onPressed: controller.onProfilePressed,
        ),
      ],
    );
  }
} 