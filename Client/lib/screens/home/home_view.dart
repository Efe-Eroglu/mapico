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
      appBar: AppBar(
        title: const Text('Mapico'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: controller.onNotificationPressed,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: controller.onProfilePressed,
          ),
        ],
      ),
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
        child: const Icon(Icons.add),
      ),
    );
  }
} 