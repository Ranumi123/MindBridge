import 'package:flutter/material.dart';

class PricingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Subscription Plans & Pricing'),
          backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose Your Plan',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),

            // Plan Cards
            _buildPlanCard(
              'Free Plan',
              '\$0/month',
              'Basic AI Chatbot • Limited Community Access • No Therapy Sessions',
              trial: '7-day Free Trial',
            ),
            _buildPlanCard(
              'Basic Plan',
              '\$20/month or \$200/year (Save \$40!)',
              '✔ 2 Therapy Sessions/month • AI Chatbot Access • Community Forum',
            ),
            _buildPlanCard(
              'Premium Plan',
              '\$50/month or \$500/year (Save \$100!)',
              '✔ 5 Therapy Sessions/month • Advanced AI Chatbot • 24/7 Support',
              oneTime: '\$500 One-Time Payment for Lifetime Access',
            ),
            _buildPlanCard(
              'VIP Plan',
              '\$100/month or \$1000/year (Save \$200!)',
              '✔ Unlimited Therapy Sessions • Personalized Mood Tracking • Webinars',
            ),

            SizedBox(height: 20),
            _buildFeatureComparison(),
            SizedBox(height: 20),

            // Payment Options
            _buildPaymentOptions(),

            // FAQ Section
            _buildFAQ(),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Plan Card Widget
  Widget _buildPlanCard(String title, String price, String features,
      {String? trial, String? oneTime}) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(price, style: TextStyle(fontSize: 16, color: Colors.green)),
            if (trial != null)
              Text('🎉 $trial', style: TextStyle(color: Colors.blue)),
            if (oneTime != null)
              Text('💰 $oneTime', style: TextStyle(color: Colors.orange)),
            SizedBox(height: 10),
            Text(features, style: TextStyle(fontSize: 14, color: Colors.grey)),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {},
              child: Text('Subscribe Now'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            ),
          ],
        ),
      ),
    );
  }

  // Features Comparison Table
  Widget _buildFeatureComparison() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Feature Comparison',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Table(
              border: TableBorder.all(color: Colors.grey),
              columnWidths: {0: FractionColumnWidth(0.5)},
              children: [
                _buildTableRow(['Features', 'Free', 'Basic', 'Premium', 'VIP'],
                    isHeader: true),
                _buildTableRow(
                    ['Therapy Sessions', '0', '2/mo', '5/mo', 'Unlimited']),
                _buildTableRow([
                  'AI Chatbot Access',
                  'Basic',
                  'Advanced',
                  'Advanced',
                  'Premium'
                ]),
                _buildTableRow(['24/7 Crisis Support', '❌', '❌', '✔', '✔']),
                _buildTableRow(['Community Access', 'Limited', '✔', '✔', '✔']),
                _buildTableRow(['Mood Tracking', '❌', '❌', '✔', '✔']),
                _buildTableRow(['Exclusive Webinars', '❌', '❌', '❌', '✔']),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Build Table Row
  TableRow _buildTableRow(List<String> cells, {bool isHeader = false}) {
    return TableRow(
      decoration: isHeader ? BoxDecoration(color: Colors.teal[100]) : null,
      children: cells.map((cell) {
        return Padding(
          padding: EdgeInsets.all(8.0),
          child: Text(
            cell,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontWeight: isHeader ? FontWeight.bold : FontWeight.normal),
          ),
        );
      }).toList(),
    );
  }

  // Payment Options Section
  Widget _buildPaymentOptions() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accepted Payment Methods',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.credit_card, size: 40, color: Colors.blue),
                Icon(Icons.paypal, size: 40, color: Colors.blueAccent),
                Icon(Icons.account_balance_wallet,
                    size: 40, color: Colors.green),
                Icon(Icons.phone_android, size: 40, color: Colors.orange),
              ],
            ),
            SizedBox(height: 10),
            Text('💡 Student Discounts & Special Offers Available!',
                style: TextStyle(color: Colors.orange)),
            Text('✅ 30-Day Money-Back Guarantee!',
                style: TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }

  // FAQ Section
  Widget _buildFAQ() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Frequently Asked Questions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildFAQItem('Can I cancel anytime?',
                'Yes! You can cancel your subscription at any time with no extra fees.'),
            _buildFAQItem('Are therapy sessions included in all plans?',
                'No, only Basic, Premium, and VIP plans include therapy sessions.'),
            _buildFAQItem('What happens if I miss a session?',
                'Missed sessions can be rescheduled, but refunds are not provided.'),
          ],
        ),
      ),
    );
  }

  // FAQ Item Widget
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontWeight: FontWeight.bold)),
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Text(answer),
        ),
      ],
    );
  }
}
