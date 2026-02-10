import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
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
  List<Contact> _contacts = [];
  bool _isLoadingContacts = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoadingContacts = true);
    
    try {
      if (await Permission.contacts.request().isGranted) {
        final contacts = await FlutterContacts.getContacts(
          withProperties: true,
          withPhoto: false,
        );
        setState(() {
          _contacts = contacts.where((contact) => 
            contact.phones.isNotEmpty
          ).take(10).toList(); // Limit to 10 contacts
        });
      }
    } catch (e) {
      // If contacts fail, continue with empty list
      print('Contacts loading failed: $e');
    }
    
    setState(() => _isLoadingContacts = false);
  }

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
        title: const Text('Transaction Status'),
        content: Text('Was the payment of ${widget.amount} successful?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Failed'),
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
                
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Transaction saved! ${PlatformHelper.isWeb ? "(Web storage)" : "(Mobile database)"}')),
                );
              } catch (e) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Transaction noted!')),
                );
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
      appBar: AppBar(
        title: const Text('Select Contact'),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Text('Amount: ${widget.amount}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('Category: ${widget.category}', style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Enter phone number or merchant code',
                hintText: '0781234567 or 12345',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: () {
                    if (_phoneController.text.isNotEmpty) {
                      _makePayment(_phoneController.text, null);
                    }
                  },
                  icon: const Icon(Icons.send),
                ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ),

          const Divider(),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('Recent Contacts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                const Spacer(),
                if (_isLoadingContacts)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),

          Expanded(
            child: _contacts.isEmpty && !_isLoadingContacts
                ? const Center(
                    child: Text(
                      'No contacts available\nUse manual entry above',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (context, index) {
                      final contact = _contacts[index];
                      final phone = contact.phones.isNotEmpty ? contact.phones.first.number : '';
                      final network = _detectNetwork(phone);
                      
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(contact.displayName.isNotEmpty ? contact.displayName[0] : '?'),
                        ),
                        title: Text(contact.displayName),
                        subtitle: Row(
                          children: [
                            Text(phone),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: network == 'MTN' ? Colors.yellow.shade100 : Colors.red.shade100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                network,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: network == 'MTN' ? Colors.orange.shade800 : Colors.red.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _makePayment(phone, contact.displayName),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
