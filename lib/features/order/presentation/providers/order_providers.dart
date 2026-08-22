import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../data/order_repository.dart';
import '../../domain/order_model.dart';

/// StateNotifier managing executed order history.
///
/// Records every buy/sell trade and persists history to [OrderRepository].
class OrdersNotifier extends StateNotifier<List<Order>> {
  OrdersNotifier(this._repository) : super([]) {
    _loadOrders();
  }

  final OrderRepository _repository;

  /// Loads saved order history from persistent storage on startup.
  void _loadOrders() {
    state = _repository.getOrders();
  }

  /// Records a newly executed order (prepends to top of history list) and persists.
  Future<void> recordOrder(Order order) async {
    final updated = [order, ...state];
    state = updated;
    await _repository.recordOrder(order);
  }
}

/// Provider for user executed order history.
final ordersProvider =
    StateNotifierProvider<OrdersNotifier, List<Order>>((ref) {
  final repository = ref.watch(orderRepositoryProvider);
  return OrdersNotifier(repository);
});
