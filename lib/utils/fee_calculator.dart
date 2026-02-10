class FeeCalculator {
  static double calculateMTNFee(double amount) {
    if (amount >= 1 && amount <= 1000) {
      return 20;
    } else if (amount >= 1001 && amount <= 10000) {
      return 100;
    } else if (amount >= 10001 && amount <= 150000) {
      return 250;
    } else if (amount >= 150001 && amount <= 2000000) {
      return 1500;
    } else if (amount >= 2000001 && amount <= 5000000) {
      return 3000;
    } else if (amount >= 5000001 && amount <= 10000000) {
      return 5000;
    }
    return 0;
  }

  static double calculateAirtelFee(double amount) {
    return calculateMTNFee(amount);
  }

  static bool isMerchantCode(String number) {
    final cleanNumber = number.trim();
    return cleanNumber.length >= 5 && cleanNumber.length <= 6 && RegExp(r'^\d+$').hasMatch(cleanNumber);
  }

  static double calculateFee(double amount, String network) {
    switch (network.toUpperCase()) {
      case 'MTN':
        return calculateMTNFee(amount);
      case 'AIRTEL':
        return calculateAirtelFee(amount);
      default:
        return 0;
    }
  }

  static double calculateFeeWithNumber(double amount, String number, String network) {
    if (isMerchantCode(number)) {
      return 0;
    }
    return calculateFee(amount, network);
  }

  static String generateUSSD(String number, double amount, String userNetwork) {
    if (isMerchantCode(number)) {
      return '*182*8*1*$number*${amount.toInt()}#';
    }
    
    final receiverNetwork = _detectNetwork(number);
    
    if (userNetwork == 'MTN') {
      if (receiverNetwork == 'MTN') {
        return '*182*1*1*$number*${amount.toInt()}#';
      } else {
        return '*182*1*2*$number*${amount.toInt()}#';
      }
    } else if (userNetwork == 'Airtel') {
      if (receiverNetwork == 'Airtel') {
        return '*182*1*$number*${amount.toInt()}#';
      } else {
        return '*182*1*2*$number*${amount.toInt()}#';
      }
    }
    
    return '*000#';
  }

  static String _detectNetwork(String phoneNumber) {
    if (phoneNumber.startsWith('078') || phoneNumber.startsWith('079')) {
      return 'MTN';
    } else if (phoneNumber.startsWith('073') || phoneNumber.startsWith('072')) {
      return 'Airtel';
    }
    return 'Unknown';
  }
}
