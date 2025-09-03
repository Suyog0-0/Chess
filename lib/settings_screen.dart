import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool soundEnabled;
  final Function(bool) onThemeChanged;
  final Function(bool) onSoundChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.soundEnabled,
    required this.onThemeChanged,
    required this.onSoundChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;
  late bool _soundEnabled;
  bool _showCoordinates = true;
  bool _highlightMoves = true;
  String _difficulty = 'Medium';

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _soundEnabled = widget.soundEnabled;
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCoordinates = prefs.getBool('show_coordinates') ?? true;
      _highlightMoves = prefs.getBool('highlight_moves') ?? true;
      _difficulty = prefs.getString('difficulty') ?? 'Medium';
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_coordinates', _showCoordinates);
    await prefs.setBool('highlight_moves', _highlightMoves);
    await prefs.setString('difficulty', _difficulty);
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('sound_enabled', _soundEnabled);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: _isDarkMode ? Colors.grey[800] : Colors.white,
        foregroundColor: _isDarkMode ? Colors.white : Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              _saveSettings();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader('Appearance'),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            trailing: Switch(
              value: _isDarkMode,
              onChanged: (value) {
                setState(() {
                  _isDarkMode = value;
                });
                widget.onThemeChanged(value);
                _saveSettings();
              },
              activeColor: Colors.green,
            ),
          ),

          // Sound Section
          const SizedBox(height: 20),
          _buildSectionHeader('Audio'),
          _buildSettingsTile(
            icon: Icons.volume_up,
            title: 'Sound Effects',
            subtitle: 'Enable game sounds and music',
            trailing: Switch(
              value: _soundEnabled,
              onChanged: (value) {
                setState(() {
                  _soundEnabled = value;
                });
                widget.onSoundChanged(value);
                _saveSettings();
              },
              activeColor: Colors.green,
            ),
          ),

          // Game Settings Section
          const SizedBox(height: 20),
          _buildSectionHeader('Game Settings'),
          _buildSettingsTile(
            icon: Icons.grid_on,
            title: 'Show Coordinates',
            subtitle: 'Display board coordinates (a-h, 1-8)',
            trailing: Switch(
              value: _showCoordinates,
              onChanged: (value) {
                setState(() {
                  _showCoordinates = value;
                });
                _saveSettings();
              },
              activeColor: Colors.green,
            ),
          ),

          _buildSettingsTile(
            icon: Icons.highlight,
            title: 'Highlight Valid Moves',
            subtitle: 'Show possible moves for selected piece',
            trailing: Switch(
              value: _highlightMoves,
              onChanged: (value) {
                setState(() {
                  _highlightMoves = value;
                });
                _saveSettings();
              },
              activeColor: Colors.green,
            ),
          ),

          _buildSettingsTile(
            icon: Icons.speed,
            title: 'AI Difficulty',
            subtitle: 'Set computer opponent strength',
            trailing: DropdownButton<String>(
              value: _difficulty,
              dropdownColor: _isDarkMode ? Colors.grey[800] : Colors.white,
              style: TextStyle(
                color: _isDarkMode ? Colors.white : Colors.black,
              ),
              items: const [
                DropdownMenuItem(value: 'Easy', child: Text('Easy')),
                DropdownMenuItem(value: 'Medium', child: Text('Medium')),
                DropdownMenuItem(value: 'Hard', child: Text('Hard')),
              ],
              onChanged: (value) {
                setState(() {
                  _difficulty = value!;
                });
                _saveSettings();
              },
            ),
          ),

          // About Section
          const SizedBox(height: 20),
          _buildSectionHeader('About'),
          _buildSettingsTile(
            icon: Icons.info,
            title: 'Version',
            subtitle: '1.0.0',
            onTap: () {},
          ),

          _buildSettingsTile(
            icon: Icons.star,
            title: 'Rate This App',
            subtitle: 'Enjoying the game? Leave a review!',
            onTap: () {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Thank you for your interest! Rating feature coming soon.'),
                  ),
                );
              }
            },
          ),

          // Reset Section
          const SizedBox(height: 20),
          _buildSectionHeader('Data'),
          _buildSettingsTile(
            icon: Icons.restore,
            title: 'Reset All Settings',
            subtitle: 'Restore default settings',
            textColor: Colors.red,
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Reset Settings'),
                  content: const Text(
                      'Are you sure you want to reset all settings to default?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        if (mounted) {
                          setState(() {
                            _showCoordinates = true;
                            _highlightMoves = true;
                            _difficulty = 'Medium';
                            _isDarkMode = true;
                            _soundEnabled = true;
                          });
                          widget.onThemeChanged(true);
                          widget.onSoundChanged(true);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Settings reset to default')),
                          );
                        }
                      },
                      child: const Text('Reset',
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: _isDarkMode ? Colors.grey[800] : Colors.white,
      child: ListTile(
        leading: Icon(
          icon,
          color:
              textColor ?? (_isDarkMode ? Colors.grey[300] : Colors.grey[700]),
        ),
        title: Text(
          title,
          style: TextStyle(
            color: textColor ?? (_isDarkMode ? Colors.white : Colors.black),
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: _isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
