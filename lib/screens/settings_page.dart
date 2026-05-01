import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _usernameController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AppState>();
    _usernameController = TextEditingController(text: state.username == 'Learner' ? '' : state.username);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _saveUsername() {
    final name = _usernameController.text.trim();
    if (name.isNotEmpty) {
      context.read<AppState>().setUsername(name);
      context.pop();
    }
  }

  void _resetOnboarding() {
    final loc = AppLocalizations.of(context)!;
    context.read<AppState>().resetOnboarding();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(loc.resetSuccess)),
    );
  }

  void _resetLearningData() {
    final loc = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(loc.resetLearningRecord),
        content: Text(loc.resetLearningRecordDesc),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(loc.back),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AppState>().resetLearningData();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(loc.resetLearningRecordSuccess)),
              );
            },
            child: Text(loc.confirm),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            child: SafeArea(
              bottom: false,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0)))),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.pop(),
                      icon: const Icon(Icons.arrow_back, color: Color(0xFF333333)),
                    ),
                    Text(loc.settings,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 修改用户名
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            loc.editUsername,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TextField(
                            controller: _usernameController,
                            decoration: InputDecoration(
                              hintText: loc.enterNewUsername,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFF4285F4), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saveUsername,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4285F4),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                loc.save,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 中文语音识别引擎选择
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            loc.chineseAsrEngineLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        RadioListTile<AsrEngine>(
                          title: Text(loc.asrEngineQwen),
                          subtitle: Text(
                            loc.asrEngineQwenDesc,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                          ),
                          value: AsrEngine.qwen,
                          groupValue: state.chineseAsrEngine,
                          onChanged: (v) => state.setChineseAsrEngine(v!),
                          activeColor: const Color(0xFF4285F4),
                        ),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        RadioListTile<AsrEngine>(
                          title: Text(loc.asrEngineWhisper),
                          subtitle: Text(
                            loc.asrEngineWhisperDesc,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                          ),
                          value: AsrEngine.whisper,
                          groupValue: state.chineseAsrEngine,
                          onChanged: (v) => state.setChineseAsrEngine(v!),
                          activeColor: const Color(0xFF4285F4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 母语语音识别引擎选择（第二步语义评分）
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            loc.nativeAsrEngineLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF333333),
                            ),
                          ),
                        ),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        RadioListTile<AsrEngine>(
                          title: Text(loc.asrEngineAuto),
                          subtitle: Text(
                            loc.asrEngineAutoDesc,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                          ),
                          value: AsrEngine.auto,
                          groupValue: state.asrEngine,
                          onChanged: (v) => state.setAsrEngine(v!),
                          activeColor: const Color(0xFF4285F4),
                        ),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        RadioListTile<AsrEngine>(
                          title: Text(loc.asrEngineQwen),
                          subtitle: Text(
                            loc.asrEngineQwenDesc,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                          ),
                          value: AsrEngine.qwen,
                          groupValue: state.asrEngine,
                          onChanged: (v) => state.setAsrEngine(v!),
                          activeColor: const Color(0xFF4285F4),
                        ),
                        const Divider(height: 1, color: Color(0xFFE0E0E0)),
                        RadioListTile<AsrEngine>(
                          title: Text(loc.asrEngineWhisper),
                          subtitle: Text(
                            loc.asrEngineWhisperDesc,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                          ),
                          value: AsrEngine.whisper,
                          groupValue: state.asrEngine,
                          onChanged: (v) => state.setAsrEngine(v!),
                          activeColor: const Color(0xFF4285F4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 重置引导流程
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        loc.resetOnboarding,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      subtitle: Text(
                        loc.resetOnboardingDesc,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                      ),
                      trailing: ElevatedButton(
                        onPressed: _resetOnboarding,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(loc.reset),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 重置学习记录
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      title: Text(
                        loc.resetLearningRecord,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      subtitle: Text(
                        loc.resetLearningRecordDesc,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF666666)),
                      ),
                      trailing: ElevatedButton(
                        onPressed: _resetLearningData,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(loc.reset),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
