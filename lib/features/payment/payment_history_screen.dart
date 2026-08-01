import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/colors.dart';

class TransactionItem {
  final String id;
  final String date;
  final String planName;
  final double amount;
  final String status; // 'Success', 'Failed', 'Refunded'
  final String paymentMethod;

  const TransactionItem({
    required this.id,
    required this.date,
    required this.planName,
    required this.amount,
    required this.status,
    required this.paymentMethod,
  });
}

class PaymentHistoryScreen extends StatefulWidget {
  const PaymentHistoryScreen({super.key});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  final Set<int> _expandedIndexes = {};

  final List<TransactionItem> _transactions = const [
    TransactionItem(
      id: 'TXN827394819',
      date: 'Aug 01, 2026',
      planName: 'Quarterly Premium Upgrade',
      amount: 499.0,
      status: 'Success',
      paymentMethod: 'UPI (GPay)',
    ),
    TransactionItem(
      id: 'TXN298472918',
      date: 'May 01, 2026',
      planName: 'Monthly Basic Auto-Renewal',
      amount: 199.0,
      status: 'Success',
      paymentMethod: 'Visa Card (....4819)',
    ),
    TransactionItem(
      id: 'TXN918471029',
      date: 'Apr 01, 2026',
      planName: 'Monthly Basic Renewal',
      amount: 199.0,
      status: 'Failed',
      paymentMethod: 'UPI (PhonePe)',
    ),
    TransactionItem(
      id: 'TXN710398417',
      date: 'Jan 01, 2026',
      planName: 'Annual Ultimate Bundle',
      amount: 1499.0,
      status: 'Refunded',
      paymentMethod: 'Netbanking (HDFC)',
    ),
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Success':
        return const Color(0xFF2E7D32); // Green
      case 'Failed':
        return AppColors.error; // Red
      case 'Refunded':
        return const Color(0xFF1565C0); // Blue
      default:
        return AppColors.muted;
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      if (_expandedIndexes.contains(index)) {
        _expandedIndexes.remove(index);
      } else {
        _expandedIndexes.add(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Payment History',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: _transactions.isEmpty
          ? const Center(
              child: Text(
                'No past transaction receipts found.',
                style: TextStyle(color: AppColors.muted),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _transactions.length,
              itemBuilder: (context, index) {
                final txn = _transactions[index];
                final isExpanded = _expandedIndexes.contains(index);

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F1F1F)),
                  ),
                  child: Column(
                    children: [
                      // Header clickable bar
                      ListTile(
                        onTap: () => _toggleExpand(index),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                txn.planName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '₹${txn.amount.round()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                txn.date,
                                style: const TextStyle(
                                  color: AppColors.muted,
                                  fontSize: 12,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(
                                    txn.status,
                                  ).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  txn.status,
                                  style: TextStyle(
                                    color: _getStatusColor(txn.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        trailing: Icon(
                          isExpanded
                              ? LucideIcons.chevronUp
                              : LucideIcons.chevronDown,
                          color: AppColors.muted,
                        ),
                      ),

                      // Expandable Invoice details block
                      if (isExpanded) ...[
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Divider(color: Colors.white10),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildReceiptRow('Transaction ID', txn.id),
                              const SizedBox(height: 8),
                              _buildReceiptRow(
                                'Payment Method',
                                txn.paymentMethod,
                              ),
                              const SizedBox(height: 8),
                              _buildReceiptRow(
                                'Base Price',
                                '₹${(txn.amount / 1.18).toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 8),
                              _buildReceiptRow(
                                'GST (18%)',
                                '₹${(txn.amount - (txn.amount / 1.18)).toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Net Total Paid',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    '₹${txn.amount.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.muted, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
