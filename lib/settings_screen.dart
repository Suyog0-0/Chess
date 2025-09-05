import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* ===========================================================================
   1.  ENTRY POINT – SETTINGS SCREEN
   =========================================================================== */
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

/* ===========================================================================
   2.  STATE – THEME, SOUND, BOARD COLOURS …
   =========================================================================== */
class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode;
  late bool _soundEnabled;
  late bool _showHints;
  bool _showCoordinates = true;
  bool _highlightMoves = true;
  String _difficulty = 'Medium';
  int _selectedBackgroundColorIndex = 0;
  int _selectedBoardTheme = 0;

  final List<Color> _backgroundColors = [
    Colors.grey[900]!,
    const Color(0xFF2C1810),
    const Color(0xFF1A237E),
    const Color(0xFF4A148C),
    const Color(0xFF1B5E20),
    const Color(0xFFBF360C),
    Colors.teal[800]!,
    Colors.brown[800]!,
  ];

  final List<List<Color>> _boardThemes = [
    [const Color(0xFFF0D9B5), const Color(0xFFB58863)],
    [const Color(0xFFDDB88C), const Color(0xFFA55A3E)],
    [const Color(0xFFE8EDF2), const Color(0xFF8CA2AD)],
    [const Color(0xFFBEBEBE), const Color(0xFF888888)],
    [const Color(0xFFFFCE9E), const Color(0xFFD18B47)],
  ];

  /* ------------------------------------------
     2.1  LIFE-CYCLE
     ------------------------------------------ */
  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode;
    _soundEnabled = widget.soundEnabled;
    _showHints = widget.showHints;
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showCoordinates = prefs.getBool('show_coordinates') ?? true;
      _highlightMoves = prefs.getBool('highlight_moves') ?? true;
      _difficulty = prefs.getString('difficulty') ?? 'Medium';
      _selectedBackgroundColorIndex = prefs.getInt('background_color') ?? 0;
      _selectedBoardTheme = prefs.getInt('board_theme') ?? 0;
    });
  }

  Future<void> _saveSettings() async {
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

  /* ===========================================================================
     3.  HELPERS – RESPONSIVE & THEME
     =========================================================================== */
  Color get _cardColor => _isDarkMode ? Colors.grey[850]! : Colors.white;

  Color get _textColor => _isDarkMode ? Colors.white : Colors.black87;

  Color get _subtitleColor => _isDarkMode ? Colors.grey[400]! : Colors.grey[600]!;

  bool get _isDesktop => MediaQuery.of(context).size.width > 800;

  /* ===========================================================================
     4.  WIDGET – MAIN BUILD
     =========================================================================== */
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.grey[900] : Colors.grey[50],
      body: Row(
        children: [
          /* ----------------------------------------------------------
             4.1  SIDE NAV (only desktop)
             ---------------------------------------------------------- */
          if (_isDesktop) _sideNav(),
          /* ----------------------------------------------------------
             4.2  CONTENT AREA
             ---------------------------------------------------------- */
          Expanded(
            child: LayoutBuilder(
              builder: (_, constraints) {
                final horizontalPadding = constraints.maxWidth > 600 ? 40.0 : 24.0;
                return CustomScrollView(
                  slivers: [
                    _appBar(horizontalPadding),
                    _content(horizontalPadding),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /* --------------------------------------------------------------------------
     4.3  SIDE NAV – DESKTOP
     -------------------------------------------------------------------------- */
  Widget _sideNav() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 220,
      color: _cardColor,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _navItem(Icons.palette_outlined, 'Appearance', 0),
          _navItem(Icons.audiotrack_outlined, 'Audio', 1),
          _navItem(Icons.videogame_asset_outlined, 'Game', 2),
          _navItem(Icons.info_outline, 'About', 3),
          const Spacer(),
          _resetTile(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    return ListTile(
      leading: Icon(icon, color: _subtitleColor),
      title: Text(label, style: TextStyle(color: _textColor)),
      onTap: () => Scrollable.ensureVisible(
        _sectionKeys[index].currentContext!,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      ),
    );
  }

  /* --------------------------------------------------------------------------
     4.4  APP-BAR – UNIFIED FOR MOBILE & DESKTOP
     -------------------------------------------------------------------------- */
  Widget _appBar(double horizontalPadding) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
        child: Row(
          children: [
            if (!_isDesktop)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new),
                onPressed: () => Navigator.pop(context),
              ),
            const Spacer(),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Text(
                'Settings',
                key: ValueKey(_isDarkMode),
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: _textColor,
                ),
              ),
            ),
            const Spacer(),
            IconButton(
              icon: const Icon(Icons.check_rounded),
              tooltip: 'Save',
              onPressed: () {
                _saveSettings();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  /* --------------------------------------------------------------------------
     4.5  CONTENT – SECTIONS
     -------------------------------------------------------------------------- */
  final List<GlobalKey> _sectionKeys = List.generate(4, (_) => GlobalKey());

  Widget _content(double horizontalPadding) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate(
          [
            _section('Appearance', _appearanceSection(), 0),
            const SizedBox(height: 32),
            _section('Audio', _audioSection(), 1),
            const SizedBox(height: 32),
            _section('Game Settings', _gameSection(), 2),
            const SizedBox(height: 32),
            _section('About', _aboutSection(), 3),
            const SizedBox(height: 48),
            if (!_isDesktop) _resetTile(),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, Widget child, int index) {
    return Column(
      key: _sectionKeys[index],
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedOpacity(
          duration: const Duration(milliseconds: 400),
          opacity: 1,
          child: Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: _textColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  /* --------------------------------------------------------------------------
     5.  SECTION WIDGETS
     -------------------------------------------------------------------------- */
  Widget _appearanceSection() {
    return _card(
      children: [
        _toggle('Dark Mode', _isDarkMode, (v) {
          setState(() => _isDarkMode = v);
          widget.onThemeChanged(v);
          _saveSettings();
        }),
        _divider(),
        _toggle('Show Hints', _showHints, (v) {
          setState(() => _showHints = v);
          widget.onHintsChanged(v);
          _saveSettings();
        }),
        _divider(),
        const SizedBox(height: 12),
        _colorSelector('Background Colour', _backgroundColors,
            _selectedBackgroundColorIndex, (i) {
              setState(() => _selectedBackgroundColorIndex = i);
              widget.onBackgroundColorChanged(i);
              _saveSettings();
            }),
        const SizedBox(height: 12),
        _boardSelector(),
      ],
    );
  }

  Widget _audioSection() {
    return _card(
      children: [
        _toggle('Sound Effects', _soundEnabled, (v) {
          setState(() => _soundEnabled = v);
          widget.onSoundChanged(v);
          _saveSettings();
        }),
      ],
    );
  }

  Widget _gameSection() {
    return _card(
      children: [
        _toggle('Show Coordinates', _showCoordinates, (v) {
          setState(() => _showCoordinates = v);
          _saveSettings();
        }),
        _divider(),
        _toggle('Highlight Valid Moves', _highlightMoves, (v) {
          setState(() => _highlightMoves = v);
          _saveSettings();
        }),
        _divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('AI Difficulty', style: TextStyle(color: _textColor)),
          trailing: DropdownButton<String>(
            value: _difficulty,
            dropdownColor: _cardColor,
            style: TextStyle(color: _textColor),
            items: const [
              DropdownMenuItem(value: 'Easy', child: Text('Easy')),
              DropdownMenuItem(value: 'Medium', child: Text('Medium')),
              DropdownMenuItem(value: 'Hard', child: Text('Hard')),
            ],
            onChanged: (v) {
              setState(() => _difficulty = v!);
              _saveSettings();
            },
          ),
        ),
      ],
    );
  }

  Widget _aboutSection() {
    return _card(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.info_outline, color: _subtitleColor),
          title: Text('Version', style: TextStyle(color: _textColor)),
          subtitle: Text('1.0.0', style: TextStyle(color: _subtitleColor)),
        ),
        _divider(),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.star_outline, color: _subtitleColor),
          title: Text('Rate This App', style: TextStyle(color: _textColor)),
          subtitle:
          Text('Enjoying the game? Leave a review!', style: TextStyle(color: _subtitleColor)),
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon!')),
          ),
        ),
      ],
    );
  }

  /* --------------------------------------------------------------------------
     6.  RE-USABLE UI FRAGMENTS
     -------------------------------------------------------------------------- */
  Widget _card({required List<Widget> children}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _toggle(String title, bool value, ValueChanged<bool> onTap) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: TextStyle(color: _textColor)),
      trailing: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: Switch(
          key: ValueKey(value),
          value: value,
          onChanged: onTap,
          activeColor: Colors.greenAccent,
        ),
      ),
    );
  }

  Widget _divider() => Divider(height: 1, color: _subtitleColor.withOpacity(.2));

  Widget _colorSelector(String title, List<Color> colors, int selected,
      ValueChanged<int> onTap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: _subtitleColor, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 50,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: colors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              return GestureDetector(
                onTap: () => onTap(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colors[i],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected == i
                          ? (_isDarkMode ? Colors.white : Colors.black)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _boardSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Board Theme', style: TextStyle(color: _subtitleColor, fontSize: 14)),
        const SizedBox(height: 8),
        SizedBox(
          height: 70,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _boardThemes.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final theme = _boardThemes[i];
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedBoardTheme = i);
                  widget.onBoardThemeChanged(i);
                  _saveSettings();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedBoardTheme == i
                          ? (_isDarkMode ? Colors.white : Colors.black)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9), // Slightly smaller than container radius
                    child: GridView.count(
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      padding: EdgeInsets.zero,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      childAspectRatio: 1,
                      children: List.generate(4, (j) {
                        final color = theme[(j + j ~/ 2) % 2];
                        return Container(color: color);
                      }),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _resetTile() {
    return ListTile(
      leading: const Icon(Icons.restore, color: Colors.redAccent),
      title: const Text('Reset All Settings',
          style: TextStyle(color: Colors.redAccent)),
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Reset Settings?'),
          content: const Text('Restore everything to default values?'),
          actions: [
            TextButton(onPressed: Navigator.of(context).pop, child: const Text('Cancel')),
            TextButton(
              onPressed: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                setState(() {
                  _isDarkMode = true;
                  _soundEnabled = true;
                  _showHints = true;
                  _showCoordinates = true;
                  _highlightMoves = true;
                  _difficulty = 'Medium';
                  _selectedBackgroundColorIndex = 0;
                  _selectedBoardTheme = 0;
                });
                widget.onThemeChanged(true);
                widget.onSoundChanged(true);
                widget.onHintsChanged(true);
                widget.onBackgroundColorChanged(0);
                widget.onBoardThemeChanged(0);
                if (mounted) Navigator.of(context).pop();
              },
              child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
            ),
          ],
        ),
      ),
    );
  }
}