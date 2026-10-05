import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'features/chat/data/datasources/gemini_remote_data_source.dart';

void main() {
  runApp(const GeminiApp());
}

class GeminiApp extends StatelessWidget {
  const GeminiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gemini Assistant',
      theme: ThemeData(colorSchemeSeed: Colors.blue, useMaterial3: true),
      home: const ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();

  late final GeminiRemoteDataSource _dataSource;

  String _answer = '';
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _dataSource = GeminiRemoteDataSource(Dio());
  }

  Future<void> _sendMessage() async {
    final prompt = _controller.text.trim();

    if (prompt.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
      _answer = '';
    });

    try {
      final result = await _dataSource.generateResponse(prompt);

      if (!mounted) return;

      setState(() {
        _answer = result;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Assistant')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Ask Gemini something...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _sendMessage,
                child: const Text('Ask Gemini'),
              ),
            ),
            const SizedBox(height: 20),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_answer.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(child: SelectableText(_answer)),
              ),
          ],
        ),
      ),
    );
  }
}
