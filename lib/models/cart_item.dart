import 'service.dart';

class CartItem {
  final ServiceType service;
  double quantity;
  CartItem({required this.service, this.quantity = 1});
  double get subtotal => service.price * quantity;
}
