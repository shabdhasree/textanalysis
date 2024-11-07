import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TextAnalysisApp());
}

class TextAnalysisApp extends StatelessWidget {
  const TextAnalysisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TextAnalysisScreen(),
    );
  }
}

class TextAnalysisScreen extends StatefulWidget {
  @override
  _TextAnalysisScreenState createState() => _TextAnalysisScreenState();
}

class _TextAnalysisScreenState extends State<TextAnalysisScreen> {
  final TextEditingController _controller = TextEditingController();
  String _analysisResult = '';
  bool _isThreatDetected = false;

  // Function to analyze the paragraph using TextRazor API
  // Updated function to analyze text and detect threats by scanning the paragraph directly
Future<void> analyzeText(String paragraph) async {
  const apiKey = "";
  final url = Uri.parse("https://api.textrazor.com/");

  final headers = {
    "x-textrazor-key": apiKey,
    "Content-Type": "application/x-www-form-urlencoded"
  };

  // Threat keywords to detect
  List<String> threatKeywords = ["dead", "danger", "kill","help","died","hazard","risk","trouble","force","blackmail"];

  // Check for threat keywords directly in the paragraph text
  bool threatFound = threatKeywords.any((keyword) => paragraph.toLowerCase().contains(keyword));

  // Send request to TextRazor API for any additional processing (if needed)
  final body = {
    "text": paragraph,
    "extractors": "entities",
  };

  try {
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // You can add extra checks based on TextRazor's response, if necessary
      if (jsonResponse['response']['entities'] != null) {
        for (var entity in jsonResponse['response']['entities']) {
          String entityText = entity['entityId'].toLowerCase();
          if (threatKeywords.any((keyword) => entityText.contains(keyword))) {
            threatFound = true;
            break;
          }
        }
      }

      // Update the UI based on threat detection
      setState(() {
        _isThreatDetected = threatFound;
        _analysisResult = threatFound ? "Threat Detected!" : "No threat detected.";
      });
    } else {
      setState(() {
        _analysisResult = "Error: Unable to analyze text.";
        _isThreatDetected = false;
      });
    }
  } catch (e) {
    setState(() {
      _analysisResult = "Error: ${e.toString()}";
      _isThreatDetected = false;
    });
  }
}


  // Function to clear the text input and reset the analysis results
  void clearText() {
    setState(() {
      _controller.clear();
      _analysisResult = '';
      _isThreatDetected = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Analysis')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _controller,
              maxLines: 6,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter a paragraph',
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    analyzeText(_controller.text);
                  },
                  child: const Text('Analyze'),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: clearText,
                  child: const Text('Delete',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  ),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Display the analysis result
            if (_analysisResult.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: _isThreatDetected ? Colors.red[100] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isThreatDetected ? Colors.red : Colors.grey,
                    width: 2,
                  ),
                ),
                child: Text(
                  _analysisResult,
                  style: TextStyle(
                    color: _isThreatDetected ? Colors.red : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
