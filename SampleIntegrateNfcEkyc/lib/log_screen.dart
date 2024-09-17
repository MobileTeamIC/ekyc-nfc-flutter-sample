import 'package:flutter/material.dart';

class LogScreen extends StatelessWidget {
  final Map<String, dynamic> json;

  const LogScreen({super.key, required this.json});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Hiển thị kết quả',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 8),
          ...json.entries.map(
            (e) => _buildLogItem(
              context,
              title: e.key,
              content: e.value,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLogItem(BuildContext context,
      {required String title, String? content}) {
    return content != null && content.trim().isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(
                      title,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(content),
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}
