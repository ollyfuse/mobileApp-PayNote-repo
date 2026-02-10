class PaymentCategory {
  final String name;
  final String icon;

  const PaymentCategory({
    required this.name,
    required this.icon,
  });

  static const List<PaymentCategory> defaultCategories = [
    PaymentCategory(name: 'Transport', icon: '🚗'),
    PaymentCategory(name: 'Food', icon: '🍽️'),
    PaymentCategory(name: 'Rent', icon: '🏠'),
    PaymentCategory(name: 'Family', icon: '👨‍👩‍👧‍👦'),
    PaymentCategory(name: 'Business', icon: '💼'),
    PaymentCategory(name: 'Entertainment', icon: '🍻'),
    PaymentCategory(name: 'Health', icon: '⚕️'),
    PaymentCategory(name: 'Shopping', icon: '🛍️'),
    PaymentCategory(name: 'Other', icon: '💰'),
  ];
}
