import 'package:flutter/material.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  final AppState state;

  const SettingsScreen({super.key, required this.state});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String get _language => switch (widget.state.languageCode) {
    'km' => 'ខ្មែរ',
    'vi' => 'Tiếng Việt',
    _ => 'English',
  };

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.state.text('settings'),
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _sectionTitle(widget.state.text('display')),
          const SizedBox(height: 10),
          _settingsCard(
            isDark: isDark,
            child: ListTile(
              leading: _icon(Icons.dark_mode_rounded),
              title: Text(
                widget.state.text('darkMode'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                widget.state.isDarkMode
                    ? widget.state.text('darkOn')
                    : widget.state.text('lightOn'),
              ),
              trailing: Switch(
                value: widget.state.isDarkMode,
                activeThumbColor: Colors.white,
                activeTrackColor: const Color(0xFF6C5CE7),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: const Color(0xFFE2E8F0),
                trackOutlineColor: const WidgetStatePropertyAll(
                  Colors.transparent,
                ),
                onChanged: (_) => widget.state.toggleTheme(),
              ),
            ),
          ),
          const SizedBox(height: 28),
          _sectionTitle(widget.state.text('language')),
          const SizedBox(height: 10),
          _settingsCard(
            isDark: isDark,
            child: ListTile(
              onTap: _chooseLanguage,
              leading: _icon(Icons.language_rounded),
              title: Text(
                widget.state.text('appLanguage'),
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(_language),
              trailing: const Icon(
                Icons.chevron_right_rounded,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: Color(0xFF6C5CE7),
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _settingsCard({required bool isDark, required Widget child}) {
    return Material(
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      clipBehavior: Clip.antiAlias,
      child: child,
    );
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(9),
      decoration: BoxDecoration(
        color: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF6C5CE7)),
    );
  }

  Future<void> _chooseLanguage() async {
    var pendingLanguage = widget.state.languageCode;
    final selected = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheetState) => RadioGroup<String>(
          groupValue: pendingLanguage,
          onChanged: (value) {
            if (value != null) {
              setSheetState(() => pendingLanguage = value);
            }
          },
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.state.text('chooseLanguage'),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...const {
                    'en': 'English',
                    'km': 'ខ្មែរ',
                    'vi': 'Tiếng Việt',
                  }.entries.map(
                    (language) => RadioListTile<String>(
                      contentPadding: EdgeInsets.zero,
                      value: language.key,
                      activeColor: const Color(0xFF6C5CE7),
                      title: Text(language.value),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(sheetContext),
                          child: Text(widget.state.text('cancel')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(sheetContext, pendingLanguage),
                          child: Text(widget.state.text('apply')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      widget.state.setLanguage(selected);
      setState(() {});
    }
  }
}
