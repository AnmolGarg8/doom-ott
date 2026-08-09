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
    final features = List<String>.from(json['features'] as List? ?? []);
    String maxQuality = '1080p';
    int maxScreens = 1;
    for (final f in features) {
      if (f.toLowerCase().contains('4k') ||
          f.toLowerCase().contains('ultra hd')) {
        maxQuality = '4K UHD';
      } else if (f.toLowerCase().contains('devices') ||
          f.toLowerCase().contains('screens') ||
          f.toLowerCase().contains('screen')) {
        final match = RegExp(r'\d+').firstMatch(f);
        if (match != null) {
          maxScreens = int.parse(match.group(0)!);
        }
      }
    }

    final durationDays =
        json['duration_days'] as int? ?? json['durationDays'] as int? ?? 30;
    final interval = durationDays >= 365 ? 'yearly' : 'monthly';

    return SubscriptionPlanModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description:
          json['description'] as String? ??
          (features.isNotEmpty ? features.join(', ') : ''),
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      interval: json['interval'] as String? ?? interval,
      intervalCount:
          json['interval_count'] as int? ?? json['intervalCount'] as int? ?? 1,
      maxScreens:
          json['max_screens'] as int? ??
          json['maxScreens'] as int? ??
          maxScreens,
      maxQuality:
          json['max_quality'] as String? ??
          json['maxQuality'] as String? ??
          maxQuality,
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
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
      status: json['status'] as String? ?? 'success',
      providerPaymentId:
          json['provider_payment_id'] as String? ??
          json['providerPaymentId'] as String? ??
          json['gateway_ref'] as String? ??
          '',
      createdAt:
          json['created_at'] as String? ?? json['createdAt'] as String? ?? '',
      planName:
          json['plan_name'] as String? ??
          json['planName'] as String? ??
          'DOOM Subscription',
    );
  }
}

abstract class SubscriptionRepository {
  Future<List<SubscriptionPlanModel>> getPlans();
  Future<Map<String, dynamic>> checkout(String planId, {String? couponCode});
  Future<bool> verifyPayment({
    required String transactionId,
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
      final List<SubscriptionPlanModel> plans = [];
      if (response.statusCode == 200 && response.data != null) {
        final items = response.data as List;
        for (final item in items) {
          plans.add(
            SubscriptionPlanModel.fromJson(Map<String, dynamic>.from(item as Map)),
          );
        }
      }
      return plans;
    } catch (_) {
      return [];
    }
  }

  @override
  Future<Map<String, dynamic>> checkout(
    String planId, {
    String? couponCode,
  }) async {
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
    required String transactionId,
    required String paymentId,
    required String signature,
  }) async {
    final response = await dioClient.post(
      '/payment/verify',
      data: {
        'transaction_id': transactionId,
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
            .map(
              (e) =>
                  TransactionHistoryModel.fromJson(e as Map<String, dynamic>),
            )
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
