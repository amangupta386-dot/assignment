import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0D8), Color(0xFFF5F2EA)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(18),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => context.go("/jobs/track"),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text("Payment", style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: const [
                      _LineItem(label: "Service fee", amount: "INR 540"),
                      SizedBox(height: 8),
                      _LineItem(label: "Platform fee", amount: "INR 40"),
                      Divider(height: 20),
                      _LineItem(label: "Total", amount: "INR 580", bold: true),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.go("/rating"),
                child: const Text("Pay Securely"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineItem extends StatelessWidget {
  const _LineItem({
    required this.label,
    required this.amount,
    this.bold = false,
  });

  final String label;
  final String amount;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 16,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
    );

    return Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(amount, style: style),
      ],
    );
  }
}
