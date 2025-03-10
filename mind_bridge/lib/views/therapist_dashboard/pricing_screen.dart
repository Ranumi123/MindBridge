import 'package:flutter/material.dart';

class PricingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pricing Plans')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Your Plan',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 20),
            _buildPlanCard(
              'Basic Plan',
              '\$20/month',
              'Access to basic therapy sessions',
            ),
            _buildPlanCard(
              'Premium Plan',
              '\$50/month',
              'Access to specialists and premium sessions',
            ),
            _buildPlanCard(
              'VIP Plan',
              '\$100/month',
              'Unlimited access to all specialists',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(String title, String price, String description) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(price, style: TextStyle(fontSize: 16, color: Colors.green)),
            SizedBox(height: 10),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 10),
            ElevatedButton(onPressed: () {}, child: Text('Select Plan')),
          ],
        ),
      ),
    );
  }
}
