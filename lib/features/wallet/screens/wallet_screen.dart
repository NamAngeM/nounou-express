import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildSectionTitle("Options de retrait"),
                  const SizedBox(height: AppSpacing.lg),
                  _buildWithdrawMethods(),
                  const SizedBox(height: AppSpacing.xxxl),
                  _buildSectionTitle("Historique des transactions"),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
          _buildTransactionList(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.primary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      title: Text(
        "Mon Portefeuille",
        style: AppTypography.h4.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            "Solde total disponible",
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "45 250 FCFA",
            style: AppTypography.h1.copyWith(
              color: Colors.white,
              fontSize: 40,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _BalanceInfoItem(
                  label: "Gains du mois",
                  value: "128 000 F",
                  icon: Icons.trending_up_rounded,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: _BalanceInfoItem(
                  label: "Missions",
                  value: "14",
                  icon: Icons.task_alt_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn().scale(delay: 100.ms);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTypography.h4.copyWith(fontWeight: FontWeight.w900),
    );
  }

  Widget _buildWithdrawMethods() {
    final methods = [
      {
        "name": "Airtel Money",
        "icon": Icons.phone_android_rounded,
        "color": Colors.red,
      },
      {
        "name": "Moov Money",
        "icon": Icons.account_balance_wallet_rounded,
        "color": Colors.blue,
      },
      {
        "name": "Virement Bancaire",
        "icon": Icons.account_balance_rounded,
        "color": Colors.green,
      },
    ];

    return Column(
      children: methods
          .map(
            (m) => _WithdrawMethodTile(
              name: m["name"] as String,
              icon: m["icon"] as IconData,
              color: m["color"] as Color,
              onTap: () => _showWithdrawDialog(m["name"] as String),
            ),
          )
          .toList(),
    );
  }

  Widget _buildTransactionList() {
    final transactions = [
      {
        "title": "Gains Mission Akanda",
        "amount": "+ 15 000 F",
        "date": "Aujourd'hui, 14:20",
        "type": "credit",
      },
      {
        "title": "Retrait Airtel Money",
        "amount": "- 20 000 F",
        "date": "Hier, 09:15",
        "type": "debit",
      },
      {
        "title": "Gains Mission Owendo",
        "amount": "+ 8 500 F",
        "date": "12 Mars, 18:45",
        "type": "credit",
      },
      {
        "title": "Gains Mission Angondjé",
        "amount": "+ 12 000 F",
        "date": "10 Mars, 11:30",
        "type": "credit",
      },
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final tx = transactions[index];
        final isCredit = tx["type"] == "credit";
        return Container(
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: 8,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isCredit
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.danger.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCredit ? Icons.add_rounded : Icons.call_made_rounded,
                  color: isCredit ? AppColors.success : AppColors.danger,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx["title"]!,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      tx["date"]!,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                tx["amount"]!,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isCredit ? AppColors.success : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (index * 50).ms).slideX(begin: 0.05, end: 0);
      }, childCount: transactions.length),
    );
  }

  void _showWithdrawDialog(String method) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WithdrawBottomSheet(method: method),
    );
  }
}

class _BalanceInfoItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _BalanceInfoItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: AppTypography.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: AppTypography.small.copyWith(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _WithdrawMethodTile extends StatelessWidget {
  final String name;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _WithdrawMethodTile({
    required this.name,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                name,
                style: AppTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

class _WithdrawBottomSheet extends StatefulWidget {
  final String method;
  const _WithdrawBottomSheet({required this.method});

  @override
  State<_WithdrawBottomSheet> createState() => _WithdrawBottomSheetState();
}

class _WithdrawBottomSheetState extends State<_WithdrawBottomSheet> {
  final _amountController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 40,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            "Retrait via ${widget.method}",
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            "Solde disponible : 45 250 FCFA",
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const SizedBox(height: 32),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: AppTypography.h1.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w900,
            ),
            decoration: InputDecoration(
              hintText: "Montant",
              hintStyle: AppTypography.h1.copyWith(
                color: AppColors.border,
                fontWeight: FontWeight.w900,
              ),
              border: InputBorder.none,
              suffixText: "FCFA",
              suffixStyle: AppTypography.h4.copyWith(
                color: AppColors.textTertiary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 40),
          AppButton(
            label: "Confirmer le retrait",
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Demande de retrait envoyée !"),
                  backgroundColor: AppColors.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
