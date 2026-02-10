import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'welcome_screen.dart';
import '../utils/platform_helper.dart';
import '../utils/fee_calculator.dart';
import '../models/transaction.dart' as models;
import '../services/database_service.dart';

class ContactSelectionScreen extends ConsumerStatefulWidget {
  final double amount;
  final String category;

  const ContactSelectionScreen({
    super.key,
    required this.amount,
    required this.category,
  });

  @override
  ConsumerState<ContactSelectionScreen> createState() => _ContactSelectionScreenState();
}

class _ContactSelectionScreenState extends ConsumerState<ContactSelectionScreen> {
  final TextEditingController _phoneController = TextEditingController();

  String _detectNetwork(String number) {
    if (FeeCalculator.isMerchantCode(number)) {
      return 'MTN';
    }
    
    if (number.startsWith('078') || number.startsWith('079')) {
      return 'MTN';
    } else if (number.startsWith('073') || number.startsWith('072')) {
      return 'Airtel';
    }
    return 'Unknown';
  }

  String _generateUSSD(String phoneNumber, double amount, String userNetwork) {
    return FeeCalculator.generateUSSD(phoneNumber, amount, userNetwork);
  }

  Future<void> _makePayment(String phoneNumber, String? contactName) async {
    final userNetwork = ref.read(userNetworkProvider);
    if (userNetwork == null) return;
    
    final ussdCode = _generateUSSD(phoneNumber, widget.amount, userNetwork);
    final uri = Uri(scheme: 'tel', path: ussdCode);
    
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      
      if (mounted) {
        _showConfirmationDialog(phoneNumber, contactName);
      }
    }
  }

  void _showConfirmationDialog(String phoneNumber, String? contactName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1C),
        title: const Text('Transaction Status', style: TextStyle(color: Colors.white)),
        content: Text('Was the payment of ${widget.amount} RWF successful?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Failed', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final fee = FeeCalculator.calculateFeeWithNumber(
                  widget.amount, 
                  phoneNumber, 
                  _detectNetwork(phoneNumber)
                );
                
                final transaction = models.Transaction(
                  amount: widget.amount,
                  phoneNumber: phoneNumber,
                  contactName: contactName ?? (FeeCalculator.isMerchantCode(phoneNumber) ? 'Merchant $phoneNumber' : null),
                  network: _detectNetwork(phoneNumber),
                  category: widget.category,
                  isSuccessful: true,
                  createdAt: DateTime.now(),
                  fee: fee,
                );
                
                await DatabaseService.insertTransaction(transaction);
                
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Transaction saved! ${PlatformHelper.isWeb ? "(Web storage)" : "(Mobile database)"}'),
                      backgroundColor: const Color(0xFF1A1A1C),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Transaction noted!'),
                      backgroundColor: Color(0xFF1A1A1C),
                    ),
                  );
                }
              }
            },
            child: const Text('Success'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0B),
      appBar: AppBar(
        title: const Text('Enter Phone Number'),
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          // Amount Display
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
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
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 0.5),
            ),
            child: Column(
              children: [
                Text('Amount: ${widget.amount.toInt()} RWF', 
                     style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 4),
                Text('Category: ${widget.category}', 
                     style: const TextStyle(fontSize: 14, color: Colors.grey)),
              ],
            ),
          ),

          // Phone Input
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter phone number or merchant code',
                labelStyle: const TextStyle(color: Colors.grey),
                hintText: '0781234567 or 12345',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF00FF88)),
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_phoneController.text.isNotEmpty) {
                      _makePayment(_phoneController.text, null);
                    }
                  },
                  icon: const Icon(Icons.send, color: Color(0xFF00FF88)),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),

          const Spacer(),

          // Info Card
          Container(
            margin: const EdgeInsets.all(16),
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
            child: const Column(
              children: [
                Text(
                  'Manual Entry Only',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                SizedBox(height: 8),
                Text(
                  'Enter phone numbers manually for payments.\nMerchant codes (5-6 digits) have no fees.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
