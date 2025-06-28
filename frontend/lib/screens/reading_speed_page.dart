import 'package:flutter/material.dart';

class ReadingSpeedPage extends StatefulWidget {
  final String participantName;
  final int participantAge;

  const ReadingSpeedPage({
    Key? key,
    required this.participantName,
    required this.participantAge,
  }) : super(key: key);

  @override
  State<ReadingSpeedPage> createState() => _ReadingSpeedPageState();
}

class _ReadingSpeedPageState extends State<ReadingSpeedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.participantName} — Age ${widget.participantAge}'),),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1) Passage display
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const SingleChildScrollView(
                  child: Text(
                    'Insert your test passage here. '
                    'This is where users will read aloud.',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 2) Placeholder for buttons
            Row(
              children: [
                Expanded(child: ElevatedButton(onPressed: null, child: const Text('Start'))),
                const SizedBox(width: 16),
                Expanded(child: ElevatedButton(onPressed: null, child: const Text('Stop'))),
              ],
            ),

            const SizedBox(height: 16),

            // 3) Placeholder for WPM display
            const Text(
              'WPM: --',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
