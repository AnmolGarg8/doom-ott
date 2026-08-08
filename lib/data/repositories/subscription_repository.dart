import '../../core/network/dio_client.dart';

class SubscriptionPlanModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String interval;
  final int intervalCount;
  final int maxScreens;
  final String maxQuality;

  SubscriptionPlanModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.interval,
    required this.intervalCount,
    required this.maxScreens,
    required this.maxQuality,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      interval: json['interval'] as String? ?? 'monthly',
      intervalCount: json['interval_count'] as int? ?? 1,
      maxScreens: json['max_screens'] as int? ?? 1,
      maxQuality: json['max_quality'] as String? ?? '1080p',
    );
  }
}

class TransactionHistoryModel {
  final String id;
  final double amount;
  final String currency;
  final String status;
  final String providerPaymentId;
  final String createdAt;
  final String planName;

  TransactionHistoryModel({
    required this.id,
    required this.amount,
    required this.currency,
    required this.status,
    required this.providerPaymentId,
    required this.createdAt,
    this.planName = 'DOOM Subscription',
  });

  factory TransactionHistoryModel.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryModel(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'success',
      providerPaymentId: json['provider_payment_id'] as String? ?? '',
      createdAt: json['created_at'] as String? ?? '',
      planName: json['plan_name'] as String? ?? 'DOOM Subscription',
    );
  }
}

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanModel>> getPlans();
  Future<Map<String, dynamic>> checkout(String planId, {String? couponCode});
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  });
  Future<List<TransactionHistoryModel>> getPaymentHistory();
}

class RealSubscriptionRepository implements SubscriptionRepository {
  final DioClient dioClient;

  RealSubscriptionRepository({required this.dioClient});

  @override
  Future<List<SubscriptionPlanModel>> getPlans() async {
    try {
      final response = await dioClient.get('/subscription/plans');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List;
        return list
            .map((e) => SubscriptionPlanModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> checkout(String planId, {String? couponCode}) async {
    final response = await dioClient.post(
      '/payment/checkout',
      data: {
        'plan_id': planId,
        if (couponCode != null && couponCode.isNotEmpty)
          'coupon_code': couponCode,
      },
    );
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<bool> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await dioClient.post(
      '/payment/verify',
      data: {
        'order_id': orderId,
        'payment_id': paymentId,
        'signature': signature,
      },
    );
    return response.statusCode == 200;
  }

  @override
  Future<List<TransactionHistoryModel>> getPaymentHistory() async {
    try {
      final response = await dioClient.get('/payment/history');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List;
        return list
            .map((e) => TransactionHistoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
