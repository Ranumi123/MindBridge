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
            // _buildFeatureComparison(),
            // SizedBox(height: 20),

            // // Payment Options
            // _buildPaymentOptions(),

            // // FAQ Section
            // _buildFAQ(),

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
}
