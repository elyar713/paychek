import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'admin_demo_data.dart';
import 'admin_theme.dart';

class AdminBillingPage extends StatefulWidget {
  const AdminBillingPage({super.key});

  @override
  State<AdminBillingPage> createState() => _AdminBillingPageState();
}

class _AdminBillingPageState extends State<AdminBillingPage> {
  final _codeCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _pctCtrl = TextEditingController(text: '20');

  @override
  void dispose() {
    _codeCtrl.dispose();
    _descCtrl.dispose();
    _pctCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat.yMMMd('fr_FR');
    final payments = AdminDemoData.payments();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _ChurnCard(pct: AdminDemoData.churnRatePct),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Transactions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AdminTheme.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AdminTheme.border),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Montant')),
                  DataColumn(label: Text('Statut')),
                  DataColumn(label: Text('Utilisateur')),
                  DataColumn(label: Text('Date')),
                ],
                rows: payments
                    .map(
                      (p) => DataRow(
                        cells: [
                          DataCell(Text(p.id)),
                          DataCell(Text('${p.amountUsd.toStringAsFixed(2)} \$')),
                          DataCell(Text(p.status)),
                          DataCell(Text(p.userHandle)),
                          DataCell(Text(df.format(p.date))),
                        ],
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Text(
            'Coupons',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Créer un code promo (Stripe / backend à brancher).',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 140,
                child: TextField(
                  controller: _codeCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Code',
                    hintText: 'TRADER20',
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
              ),
              SizedBox(
                width: 100,
                child: TextField(
                  controller: _pctCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: '% off',
                  ),
                ),
              ),
              FilledButton(
                onPressed: () {
                  final code = _codeCtrl.text.trim().toUpperCase();
                  if (code.isEmpty) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Coupon $code créé (stub — connecter Stripe).',
                      ),
                    ),
                  );
                  _codeCtrl.clear();
                  _descCtrl.clear();
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AdminTheme.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('Créer'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...AdminDemoData.coupons().map(
            (c) {
              final (code, desc, pct) = c;
              return Card(
                color: AdminTheme.bg,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  title: Text(
                    code,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(desc),
                  trailing: Text('-$pct%'),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChurnCard extends StatelessWidget {
  const _ChurnCard({required this.pct});

  final double pct;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AdminTheme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AdminTheme.border),
      ),
      child: Row(
        children: [
          Icon(Icons.trending_down, color: AdminTheme.warning, size: 36),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Churn',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text(
                  '${pct.toStringAsFixed(1)}% annulations ce mois (démo)',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Text(
            '${pct.toStringAsFixed(1)}%',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AdminTheme.warning,
                ),
          ),
        ],
      ),
    );
  }
}
