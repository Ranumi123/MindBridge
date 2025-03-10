import 'package:flutter/material.dart';
import '../models/therapist_model.dart';

class BookingScreen extends StatefulWidget {
  final Therapist therapist;

  BookingScreen({required this.therapist});

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController fullNameController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController contactController = TextEditingController();
  TextEditingController dateController = TextEditingController(); 
  String? selectedGender;
  String? selectedCommunication;
  String? selectedTime;
  String? selectedPlan;

  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> communicationOptions = ['Call', 'Chat', 'Video'];
  final List<String> timeOptions = ['10:00 AM', '02:00 PM', '06:00 PM'];
  final List<String> pricingPlans = [
    "Basic Plan - \$50",
    "Standard Plan - \$80",
    "Premium Plan - \$120"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book ${widget.therapist.name}'), backgroundColor: Colors.teal),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(fullNameController, 'Full Name', true),
              SizedBox(height: 10),

              // Date of Birth (Date Picker)
              TextFormField(
                controller: dobController,
                decoration: InputDecoration(labelText: 'Date of Birth', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDate(context, dobController),
                validator: (value) => value!.isEmpty ? 'Enter your date of birth' : null,
              ),
              SizedBox(height: 10),

              // Gender (Dropdown)
              _buildDropdown('Gender (Optional)', genderOptions, selectedGender, (value) {
                setState(() => selectedGender = value);
              }),
              SizedBox(height: 10),

              // Contact Information
              _buildTextField(contactController, 'Email or Phone Number', true),
              SizedBox(height: 10),

              // Preferred Communication Method
              _buildDropdown('Preferred Communication', communicationOptions, selectedCommunication, (value) {
                setState(() => selectedCommunication = value);
              }),
              SizedBox(height: 10),

              // Preferred Date (Date Picker)
              TextFormField(
                controller: dateController,
                decoration: InputDecoration(labelText: 'Preferred Date', border: OutlineInputBorder()),
                readOnly: true,
                onTap: () => _selectDate(context, dateController),
                validator: (value) => value!.isEmpty ? 'Select a preferred date' : null,
              ),
              SizedBox(height: 10),

              // Preferred Time (Dropdown)
              _buildDropdown('Preferred Time', timeOptions, selectedTime, (value) {
                setState(() => selectedTime = value);
              }),
              SizedBox(height: 10),

              // Pricing Plan
              Text("Select a Pricing Plan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              _buildPricingPlans(),
              SizedBox(height: 20),

              // Confirm Booking Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmBooking,
                  child: Text('Confirm Booking'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 12),
                    textStyle: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Generic Text Field
  Widget _buildTextField(TextEditingController controller, String label, bool isRequired) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      validator: (value) => (isRequired && value!.isEmpty) ? 'Enter your $label' : null,
    );
  }

  // Custom Dropdown Widget
  Widget _buildDropdown(String label, List<String> options, String? selectedValue, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      decoration: InputDecoration(labelText: label, border: OutlineInputBorder()),
      items: options.map((option) {
        return DropdownMenuItem(value: option, child: Text(option));
      }).toList(),
      onChanged: onChanged,
      validator: (value) => value == null ? 'Please select $label' : null,
    );
  }

  // Pricing Plan Radio Buttons
  Widget _buildPricingPlans() {
    return Column(
      children: pricingPlans.map((plan) {
        return RadioListTile<String>(
          title: Text(plan),
          value: plan,
          groupValue: selectedPlan,
          onChanged: (value) {
            setState(() => selectedPlan = value!);
          },
        );
      }).toList(),
    );
  }

  // Show Date Picker
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        controller.text = "${picked.toLocal()}".split(' ')[0];
      });
    }
  }

  // Confirm Booking Action
  void _confirmBooking() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Booking Confirmed for ${widget.therapist.name}!"),
        backgroundColor: Colors.green,
      ));
    }
  }
}
