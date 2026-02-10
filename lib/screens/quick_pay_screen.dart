import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category.dart';
import 'contact_selection_screen.dart';
import '../services/storage_service.dart';
import 'welcome_screen.dart';

final amountProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => 'Other');

class QuickPayScreen extends ConsumerWidget {
  const QuickPayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final amount = ref.watch(amountProvider);
    final selectedCategory = ref.watch(selectedCategoryProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        title: const Text('PayNote'),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () => _showNetworkSettings(context, ref),
            icon: const Icon(Icons.settings, color: Colors.white),
          ),
        ],
      ),
      body: Column(
        children: [
          // Amount Display with Glow Effect
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1A1A1C).withOpacity(0.8),
                    const Color(0xFF2A2A2C).withOpacity(0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00FF88).withOpacity(0.1),
                    blurRadius: 20,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Amount',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 8),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      style: Theme.of(context).textTheme.displayLarge!.copyWith(
                        color: amount.isEmpty ? Colors.grey.shade600 : Colors.white,
                      ),
                      child: Text(amount.isEmpty ? '0' : amount),
                    ),
                    Text(
                      'RWF',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Categories with Smooth Selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Category',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: PaymentCategory.defaultCategories.length,
                    itemBuilder: (context, index) {
                      final category = PaymentCategory.defaultCategories[index];
                      final isSelected = selectedCategory == category.name;
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(category.icon),
                                const SizedBox(width: 6),
                                Text(category.name),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (_) {
                              ref.read(selectedCategoryProvider.notifier).state = category.name;
                            },
                            backgroundColor: const Color(0xFF1A1A1C),
                            selectedColor: const Color(0xFF00FF88).withOpacity(0.2),
                            checkmarkColor: const Color(0xFF00FF88),
                            labelStyle: TextStyle(
                              color: isSelected ? const Color(0xFF00FF88) : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Keypad with Liquid Feel
          Expanded(
            flex: 3,
            child: _buildKeypad(ref),
          ),

          // Action Buttons Row
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Check Balance Button
                Expanded(
                  flex: 1,
                  child: _buildGlassButton(
                    onPressed: () => _checkBalance(context, ref),
                    child: const Icon(Icons.account_balance_wallet, color: Color(0xFF00FF88)),
                  ),
                ),
                const SizedBox(width: 16),
                // Pay Button
                Expanded(
                  flex: 3,
                  child: _buildPayButton(context, ref, amount, selectedCategory),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad(WidgetRef ref) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
        children: [
            // Row 1: 1, 2, 3
            Row(
            children: [
                Expanded(child: _buildKeypadButton('1', ref)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('2', ref)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('3', ref)),
            ],
            ),
            const SizedBox(height: 12),
            
            // Row 2: 4, 5, 6
            Row(
            children: [
                Expanded(child: _buildKeypadButton('4', ref)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('5', ref)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('6', ref)),
            ],
            ),
            const SizedBox(height: 12),
            
            // Row 3: 7, 8, 9
            Row(
            children: [
                Expanded(child: _buildKeypadButton('7', ref)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('8', ref)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('9', ref)),
            ],
            ),
            const SizedBox(height: 12),
            
            // Row 4: Clear, 0, Backspace
            Row(
            children: [
                Expanded(child: _buildKeypadButton('C', ref, isClear: true)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('0', ref)),
                const SizedBox(width: 12),
                Expanded(child: _buildKeypadButton('⌫', ref, isBackspace: true)),
            ],
            ),
        ],
        ),
    );
    }

  Widget _buildKeypadButton(String text, WidgetRef ref, {bool isBackspace = false, bool isClear = false}) {
    return Container(
        height: 60, // Fixed height for consistency
        child: Material(
        color: Colors.transparent,
        child: InkWell(
            onTap: () {
            final currentAmount = ref.read(amountProvider);
            
            if (isBackspace) {
                if (currentAmount.isNotEmpty) {
                ref.read(amountProvider.notifier).state = 
                    currentAmount.substring(0, currentAmount.length - 1);
                }
            } else if (isClear) {
                ref.read(amountProvider.notifier).state = '';
            } else {
                ref.read(amountProvider.notifier).state = currentAmount + text;
            }
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                    const Color(0xFF1A1A1C).withOpacity(0.8),
                    const Color(0xFF2A2A2C).withOpacity(0.6),
                ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 0.5,
                ),
            ),
            child: Center(
                child: Text(
                text,
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: (isBackspace || isClear) ? const Color(0xFF00FF88) : Colors.white,
                ),
                ),
            ),
            ),
        ),
        ),
    );
    }

  Widget _buildGlassButton({required VoidCallback onPressed, required Widget child}) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A1C).withOpacity(0.8),
            const Color(0xFF2A2A2C).withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 0.5,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          child: Center(child: child),
        ),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context, WidgetRef ref, String amount, String category) {
    final isEnabled = amount.isNotEmpty;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isEnabled ? [
            const Color(0xFF00FF88),
            const Color(0xFF00CC6A),
          ] : [
            Colors.grey.shade800,
            Colors.grey.shade700,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: isEnabled ? [
          BoxShadow(
            color: const Color(0xFF00FF88).withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ContactSelectionScreen(
                  amount: double.parse(amount),
                  category: category,
                ),
              ),
            );
          } : null,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              'Pay',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isEnabled ? Colors.black : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _checkBalance(BuildContext context, WidgetRef ref) async {
    final ussdCode = '*182*6*1#';
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Balance USSD: $ussdCode'),
        backgroundColor: const Color(0xFF1A1A1C),
      ),
    );
  }


  void _showNetworkSettings(BuildContext context, WidgetRef ref) {
    final currentNetwork = ref.read(userNetworkProvider);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1C),
        title: const Text('Network Settings', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Current Network: $currentNetwork', style: const TextStyle(color: Colors.white)),
            const SizedBox(height: 16),
            const Text('Change your network?', style: TextStyle(color: Colors.grey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              await StorageService.clearUserData();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('Change Network'),
          ),
        ],
      ),
    );
  }
}
