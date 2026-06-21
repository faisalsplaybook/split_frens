import 'package:flutter/material.dart';
import '../../data/models/hangout_model.dart';
import '../../../../core/utils/money_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import 'package:go_router/go_router.dart';

/// A custom widget to display the summary of a Hangout.
class HangoutCard extends StatelessWidget {
  // We pass the HangoutModel into this widget so it knows what to display.
  final HangoutModel hangout;

  const HangoutCard({super.key, required this.hangout});

  @override
  Widget build(BuildContext context) {
    // We use our new DateFormatter to format the model's start date
    final String dateStr = DateFormatter.format(hangout.startDate);

    // For now, we still hardcode the total to 1380, but we use MoneyFormatter
    // to give it the proper currency symbol and formatting.
    final String totalAmountStr = MoneyFormatter.format(1380.0);

    const String settlementStatusStr = 'Unsettled';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      // InkWell gives us that nice Material ripple effect when the card is tapped!
      child: InkWell(
        onTap: () {
          // Navigate to this specific hangout's detail screen
          // We use string interpolation to pass the hangout's unique ID into the URL
          context.push('/hangout/${hangout.id}');
        },
        borderRadius: BorderRadius.circular(
          16,
        ), // Match the card's border radius
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // Top Row: Title and Date
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hangout.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    dateStr,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ==========================================
              // Middle Row: Total Amount and Status Badge
              // ==========================================
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        totalAmountStr,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary, // Use primary color
                        ),
                      ),
                    ],
                  ),
                  // A small custom "Badge" for the settlement status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100, // Light orange background
                      borderRadius: BorderRadius.circular(20), // Pill shape
                    ),
                    child: Text(
                      settlementStatusStr,
                      style: TextStyle(
                        color: Colors.orange.shade800, // Dark orange text
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ==========================================
              // Bottom Row: People and Expenses count
              // ==========================================
              Row(
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${hangout.participantIds.length} people',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(width: 16), // Spacing between the two stats
                  const Icon(
                    Icons.receipt_long_outlined,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${hangout.expenseIds.length} expenses',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
