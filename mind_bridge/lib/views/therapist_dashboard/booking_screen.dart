import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import '../therapist_dashboard/appointment_service.dart';

class BookingScreen extends StatefulWidget {
  final String therapistId;
  final String therapistName;
  final String userId;
  final String userEmail;
  final String userName;

  const BookingScreen({
    Key? key,
    required this.therapistId,
    required this.therapistName,
    required this.userId,
    required this.userEmail,
    required this.userName,
  }) : super(key: key);

  @override
  _BookingScreenState createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  List<TimeSlot> _availableSlots = [];
  TimeSlot? _selectedTimeSlot;
  bool _isLoading = false;
  String? _notes;

  @override
  void initState() {
    super.initState();
    _fetchAvailableSlots();
  }

  // Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  // Fetch available time slots
  Future<void> _fetchAvailableSlots() async {
    setState(() {
      _isLoading = true;
      _selectedTimeSlot = null;
    });

    try {
      final slots = await AppointmentService.getAvailableSlots(
        widget.therapistId,
        _formatDate(_selectedDay),
      );

      setState(() {
        _availableSlots = slots;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching available slots: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Book the appointment
  Future<void> _bookAppointment() async {
    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a time slot'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final appointment = await AppointmentService.createAppointment(
        therapistId: widget.therapistId,
        userId: widget.userId,
        startTime: _selectedTimeSlot!.startTime,
        endTime: _selectedTimeSlot!.endTime,
        name: widget.userName,
        email: widget.userEmail,
        notes: _notes,
      );

      setState(() {
        _isLoading = false;
      });

      // Show success message and navigate back
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appointment booked successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to confirmation page or back to previous screen
      Navigator.pop(context, appointment);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error booking appointment: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the gradient colors (matching the main app)
    final primaryColor = const Color(0xFF4B9FE1);
    final accentColor = const Color(0xFF1EBBD7);
    final tertiaryColor = const Color(0xFF20E4B5);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [primaryColor, accentColor, tertiaryColor],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar with back button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Book Appointment with ${widget.therapistName}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Area (White background)
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Select Date',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Calendar Widget
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: TableCalendar(
                              firstDay: DateTime.now(),
                              lastDay:
                                  DateTime.now().add(const Duration(days: 90)),
                              focusedDay: _focusedDay,
                              calendarFormat: _calendarFormat,
                              selectedDayPredicate: (day) {
                                return isSameDay(_selectedDay, day);
                              },
                              onDaySelected: (selectedDay, focusedDay) {
                                if (!isSameDay(_selectedDay, selectedDay)) {
                                  setState(() {
                                    _selectedDay = selectedDay;
                                    _focusedDay = focusedDay;
                                    _availableSlots = [];
                                  });
                                  _fetchAvailableSlots();
                                }
                              },
                              onFormatChanged: (format) {
                                if (_calendarFormat != format) {
                                  setState(() {
                                    _calendarFormat = format;
                                  });
                                }
                              },
                              calendarStyle: CalendarStyle(
                                todayDecoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.3),
                                  shape: BoxShape.circle,
                                ),
                                selectedDecoration: BoxDecoration(
                                  color: primaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              headerStyle: HeaderStyle(
                                titleCentered: true,
                                formatButtonDecoration: BoxDecoration(
                                  color: primaryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                formatButtonTextStyle:
                                    TextStyle(color: primaryColor),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          const Text(
                            'Available Time Slots',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Time Slots Grid
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _availableSlots.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'No available slots for this date',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                        childAspectRatio: 2.0,
                                        crossAxisSpacing: 10,
                                        mainAxisSpacing: 10,
                                      ),
                                      itemCount: _availableSlots.length,
                                      itemBuilder: (context, index) {
                                        final slot = _availableSlots[index];
                                        final isSelected =
                                            _selectedTimeSlot == slot;

                                        // Format time for display
                                        final startTime = DateFormat('h:mm a')
                                            .format(
                                                DateTime.parse(slot.startTime));

                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedTimeSlot = slot;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? primaryColor
                                                  : Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? primaryColor
                                                    : Colors.grey.shade300,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.05),
                                                  blurRadius: 5,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                startTime,
                                                style: TextStyle(
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontWeight: isSelected
                                                      ? FontWeight.bold
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),

                          const SizedBox(height: 24),

                          // Notes TextField
                          const Text(
                            'Notes (Optional)',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: TextField(
                              onChanged: (value) {
                                _notes = value;
                              },
                              maxLines: 3,
                              decoration: const InputDecoration(
                                hintText: 'Add any notes for the therapist...',
                                contentPadding: EdgeInsets.all(16),
                                border: InputBorder.none,
                              ),
                            ),
                          ),

                          const SizedBox(height: 32),

                          // Book Appointment Button
                          GestureDetector(
                            onTap: _isLoading ? null : _bookAppointment,
                            child: Container(
                              height: 60,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    primaryColor,
                                    accentColor,
                                    tertiaryColor
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryColor.withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Book Appointment',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
