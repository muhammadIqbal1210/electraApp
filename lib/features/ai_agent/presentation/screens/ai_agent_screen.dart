import 'package:flutter/material.dart';
import 'package:electra_app/core/constants/app_colors.dart';
import 'package:electra_app/features/ai_agent/data/services/ai_agent_api_service.dart';

class AiAgentScreen extends StatefulWidget {
  const AiAgentScreen({super.key});

  @override
  State<AiAgentScreen> createState() => _AiAgentScreenState();
}

class _AiAgentScreenState extends State<AiAgentScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _chatController = TextEditingController();
  bool _isSending = false;

  final List<Map<String, dynamic>> _chatMessages = [
    {
      'isUser': false,
      'text': 'Halo! Saya Electra AI Agent. Terhubung ke data PostgreSQL & telemetry sensor IoT backend Anda. Ada yang ingin Anda tanyakan?',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _chatController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final query = _chatController.text.trim();
    if (query.isEmpty || _isSending) return;

    setState(() {
      _chatMessages.add({
        'isUser': true,
        'text': query,
      });
      _isSending = true;
      _chatController.clear();
    });

    final res = await AiAgentApiService.sendChatMessage(query);

    if (mounted) {
      setState(() {
        _isSending = false;
        if (res['success'] == true) {
          _chatMessages.add({
            'isUser': false,
            'text': res['reply'],
          });
        } else {
          _chatMessages.add({
            'isUser': false,
            'text': 'Mohon maaf: ${res['message']}',
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electra AI Agent (Backend RAG)'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.secondary,
          labelColor: AppColors.secondary,
          unselectedLabelColor: AppColors.textMuted,
          tabs: const [
            Tab(icon: Icon(Icons.chat_bubble_outline), text: 'AI Chat'),
            Tab(icon: Icon(Icons.center_focus_weak), text: 'Scan Penyakit'),
            Tab(icon: Icon(Icons.menu_book), text: 'Storyteller'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(),
          _buildDiagnosisTab(),
          _buildStorytellerTab(),
        ],
      ),
    );
  }

  // AI Chat Tab (Terhubung ke POST /api/agent/chat)
  Widget _buildChatTab() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _chatMessages.length,
            itemBuilder: (context, index) {
              final msg = _chatMessages[index];
              final isUser = msg['isUser'] as bool;
              return Align(
                alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
                  decoration: BoxDecoration(
                    color: isUser ? AppColors.secondary : AppColors.cardDark,
                    borderRadius: BorderRadius.circular(16),
                    border: isUser ? null : Border.all(color: AppColors.borderDark),
                  ),
                  child: Text(
                    msg['text'],
                    style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.4),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isSending)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                SizedBox(width: 8),
                Text('AI Agent sedang berpikir & membaca database...', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            border: Border(top: BorderSide(color: AppColors.borderDark)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Tanyakan data batch, tanah, atau cuaca backend...',
                    hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
                    filled: true,
                    fillColor: AppColors.cardDark,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: AppColors.secondary,
                child: IconButton(
                  icon: const Icon(Icons.send, color: Colors.white, size: 18),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosisTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.secondary, width: 2),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_a_photo_outlined, color: AppColors.secondary, size: 44),
                SizedBox(height: 10),
                Text('Unggah Citra Daun Tanaman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                SizedBox(height: 4),
                Text('Deteksi penyakit terhubung ke model AI Backend Gemini', style: TextStyle(color: AppColors.textMuted, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStorytellerTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_stories, color: Colors.black, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Penceritaan Traceability Berbasis Data PostgreSQL & Ledger',
                    style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
