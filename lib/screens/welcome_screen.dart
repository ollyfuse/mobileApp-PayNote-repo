import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';
import 'main_navigation.dart';

final userNetworkProvider = StateProvider<String?>((ref) => null);

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  Future<void> _selectNetwork(BuildContext context, WidgetRef ref, String network) async {
    await StorageService.saveUserNetwork(network);
    ref.read(userNetworkProvider.notifier).state = network;
    
    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // App Logo with Glow Effect
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00FF88).withOpacity(0.3),
                      const Color(0xFF00CC6A).withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FF88).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.payment,
                  size: 60,
                  color: Color(0xFF00FF88),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Welcome Text
              const Text(
                'Welcome to PayNote',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 16),
              
              const Text(
                'Smart USSD helper and transaction tracker',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 48),
              
              // Network Selection
              const Text(
                'Select your mobile network:',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // MTN Button
              _buildNetworkButton(
                context: context,
                ref: ref,
                network: 'MTN',
                colors: [const Color(0xFFFFC107), const Color(0xFFFFB300)],
                textColor: Colors.black,
              ),
              
              const SizedBox(height: 16),
              
              // Airtel Button
              _buildNetworkButton(
                context: context,
                ref: ref,
                network: 'Airtel',
                colors: [const Color(0xFFFF3B30), const Color(0xFFFF2D92)],
                textColor: Colors.white,
              ),
              
              const SizedBox(height: 48),
              
              // Disclaimer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1A1A1C).withOpacity(0.8),
                      const Color(0xFF2A2A2C).withOpacity(0.6),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
                ),
                child: const Text(
                  'PayNote does not process payments or store PINs. It only helps generate USSD codes and track transactions.',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkButton({
    required BuildContext context,
    required WidgetRef ref,
    required String network,
    required List<Color> colors,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colors[0].withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectNetwork(context, ref, network),
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              network,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
