import 'package:edu_learn/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'databaseutils/gemini.dart';

class AiSuggestionsPage extends StatefulWidget {
  @override
  _AiSuggestionsPageState createState() => _AiSuggestionsPageState();
}

class _AiSuggestionsPageState extends State<AiSuggestionsPage> {
  final List<Map<String, String>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final String? topic = ModalRoute.of(context)?.settings.arguments as String?;
    if (topic != null && _messages.isEmpty) {
      _messages.add({
        'sender': 'Gemini',
        'text': 'You selected $topic. How can I assist you today?'
      });
    }
  }

  Future<void> _sendMessage(String text) async {
    setState(() {
      _messages.add({'sender': 'User', 'text': text});
      _isLoading = true;
    });

    final responseMessage = await Gemini.fetchAIResponse(text);

    setState(() {
      _messages.add(responseMessage);
      _isLoading = false;
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ask Gemini',
        isBackButtonVisible: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              children: [
                ListView.builder(
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageTile(_messages[index]);
                  },
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: 1, // Ensure it's a single-line input
                    decoration: InputDecoration(
                      hintText:
                          'Gemini is here to help. \nEnter your prompt to learn more \nAsk for assistance.',
                      hintMaxLines: 3, // Allow the hint to wrap to two lines
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 12.0),
                    ),
                  ),
                ),
                IconButton(
                  icon: _isLoading
                      ? const CircularProgressIndicator()
                      : const Icon(Icons.send),
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_controller.text.isNotEmpty) {
                            _sendMessage(_controller.text);
                          }
                        },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageTile(Map<String, String> message) {
    bool isAI = message['sender'] == 'Gemini';
    return ListTile(
      leading: isAI
          ? SizedBox(
              width: 30,
              height: 30,
              child: Image.asset(
                'assets/images/ai_icon.png',
              ),
            )
          : null,
      trailing: !isAI ? const Icon(Icons.person) : null,
      title: Text(message['sender']!),
      subtitle: isAI
          ? _buildFormattedResponse(message['text']!)
          : Text(message['text']!),
      tileColor: isAI ? Colors.blue.shade50 : Colors.green.shade50,
    );
  }

  Widget _buildFormattedResponse(String responseText) {
    final List<TextSpan> spans = [];
    final regex = RegExp(
        r'(\*\*.*?\*\*)|(\*\*.*?\*\*)|(\n\n)'); // Regex for bold headers or newlines
    final matches = regex.allMatches(responseText);

    int start = 0;
    for (var match in matches) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: responseText.substring(start, match.start),
          style: const TextStyle(color: Colors.black),
        ));
      }

      if (match.group(0)!.startsWith('**')) {
        spans.add(TextSpan(
          text: match.group(0)!.replaceAll(RegExp(r'\*\*'), ''),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent,
          ),
        ));
      } else if (match.group(0) == '\n\n') {
        spans.add(const TextSpan(
          text: '\n\n',
          style: TextStyle(color: Colors.black),
        ));
      }

      start = match.end;
    }

    if (start < responseText.length) {
      spans.add(TextSpan(
        text: responseText.substring(start),
        style: const TextStyle(color: Colors.black),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
