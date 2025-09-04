import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final bool soundEnabled;
  final bool showHints;
  final Function(bool) onThemeChanged;
  final Function(bool) onSoundChanged;
  final Function(bool) onHintsChanged;
  final Function(int) onBackgroundColorChanged;
  final Function(int) onBoardThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.soundEnabled,
    required this.showHints,
    required this.onThemeChanged,
    required this.onSoundChanged,
    required this.onHintsChanged,
    required this.onBackgroundColorChanged,
    required this.onBoardThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;
  late bool _soundEnabled;
  late bool _showHints;
  bool _showCoordinates = true;
  bool _highlightMoves = true;
  String _difficulty = 'Medium';
  int _selectedBackgroundColorIndex = 0;
  int _selectedBoardTheme = 0;

  List<Color> backgroundColors = [
    Colors.grey[900]!, // Default dark
    const Color(0xFF2C1810), // Dark wood
    const Color(0xFF1A237E), // Deep blue
    const Color(0xFF4A148C), // Deep purple
    const Color(0xFF1B5E20), // Deep green
    const Color(0xFFBF360C), // Deep orange
    Colors.teal[800]!, // Teal
    Colors.brown[800]!, // Brown
  ];
  List<List<Color>> boardThemes = [
    [Color(0xFFF0D9B5), Color(0xFFB58863)], // Classic
    [Color(0xFFDDB88C), Color(0xFFA55A3E)], // Brown
    [Color(0xFFE8EDF2), Color(0xFF8CA2AD)], // Gray
    [Color(0xFFBEBEBE), Color(0xFF888888)], // Metal
    [Color(0xFFFFCE9E), Color(0xFFD18B47)], // Orange
  ];

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _soundEnabled = widget.soundEnabled;
    _showHints = widget.showHints;
    _loadSettings();
  }

  void _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCoordinates = prefs.getBool('show_coordinates') ?? true;
      _highlightMoves = prefs.getBool('highlight_moves') ?? true;
      _showHints = prefs.getBool('show_hints') ?? true;
      _difficulty = prefs.getString('difficulty') ?? 'Medium';
      _selectedBackgroundColorIndex = prefs.getInt('background_color') ?? 0;
      _selectedBoardTheme = prefs.getInt('board_theme') ?? 0;
    });
  }

  void _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('show_coordinates', _showCoordinates);
    await prefs.setBool('highlight_moves', _highlightMoves);
    await prefs.setString('difficulty', _difficulty);
    await prefs.setBool('dark_mode', _isDarkMode);
    await prefs.setBool('sound_enabled', _soundEnabled);
    await prefs.setBool('show_hints', _showHints);
    await prefs.setInt('background_color', _selectedBackgroundColorIndex);
    await prefs.setInt('board_theme', _selectedBoardTheme);
  }

  Widget _buildThemeSelector(String title, List<Color> colors,
      int selectedIndex, Function(int) onSelect) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 60,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => onSelect(index),
                child: Container(
                  width: 60,
                  height: 60,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: colors[index],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: selectedIndex == index ? Colors.blue : Colors.grey,
                      width: selectedIndex == index ? 3 : 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildBoardThemeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Board Theme',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _isDarkMode ? Colors.grey[300] : Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: boardThemes.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedBoardTheme = index;
                  });
                  widget.onBoardThemeChanged(index);
                  _saveSettings();
                },
                child: Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _selectedBoardTheme == index
                          ? Colors.blue
                          : Colors.grey,
                      width: _selectedBoardTheme == index ? 3 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(color: boardThemes[index][0])),
                            Expanded(
                                child: Container(color: boardThemes[index][1])),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                                child: Container(color: boardThemes[index][1])),
                            Expanded(
                                child: Container(color: boardThemes[index][0])),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
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
              value: _showHints,
              onChanged: (value) {
                setState(() {
                  _showHints = value;
                });
                widget.onHintsChanged(value);
                _saveSettings();
              },
              activeColor: Colors.green,
            ),
          ),

          // Background Color Selector
          _buildThemeSelector(
            'Background Color',
            backgroundColors,
            _selectedBackgroundColorIndex,
                (index) {
              setState(() {
                _selectedBackgroundColorIndex = index;
              });
              widget.onBackgroundColorChanged(index);
              _saveSettings();
            },
          ),

          _buildBoardThemeSelector(),

          // // Sound Section
          // const SizedBox(height: 20),
          // _buildSectionHeader('Appearance'),
          // _buildSettingsTile(
          //   icon: Icons.dark_mode,
          //   title: 'Dark Mode',
          //   subtitle: 'Switch between light and dark themes',
          //   trailing: Switch(
          //     value: _isDarkMode,
          //     onChanged: (value) {
          //       setState(() {
          //         _isDarkMode = value;
          //       });
          //       widget.onThemeChanged(value);
          //       _saveSettings();
          //     },
          //     activeColor: Colors.green,
          //   ),
          // ),


          // _buildBoardThemeSelector(),

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
                            _selectedBackgroundColorIndex = 0;
                            _selectedBoardTheme = 0;
                            _showHints = true;
                          });
                          widget.onThemeChanged(true);
                          widget.onSoundChanged(true);
                          widget.onBackgroundColorChanged(0);
                          widget.onBoardThemeChanged(0);
                          widget.onHintsChanged(true);
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