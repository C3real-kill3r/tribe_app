import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:tribe/core/theme/theme_provider.dart';

class AppearanceSettingsPage extends StatefulWidget {
  const AppearanceSettingsPage({super.key});

  @override
  State<AppearanceSettingsPage> createState() => _AppearanceSettingsPageState();
}

class _AppearanceSettingsPageState extends State<AppearanceSettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appearance'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Theme Section
            _buildSectionHeader('Theme'),
            _buildSettingsCard(
              child: _buildThemeToggle(),
            ),
            const SizedBox(height: 24),
            // Customization Section
            _buildSectionHeader('Customization'),
            _buildSettingsCard(
              child: _buildAccentColorSelector(),
            ),
            const SizedBox(height: 24),
            // Accessibility Section
            _buildSectionHeader('Accessibility'),
            _buildSettingsCard(
              child: _buildFontSizeSlider(),
            ),
            const SizedBox(height: 24),
            // Live Preview Section
            _buildSectionHeader('Preview'),
            _buildSettingsCard(
              child: _buildPreview(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: child,
    );
  }

  Widget _buildThemeToggle() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: themeProvider.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isDarkMode ? Icons.dark_mode : Icons.light_mode,
              color: themeProvider.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dark Mode',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Reduces eye strain in low-light environments.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey,
                      ),
                ),
              ],
            ),
          ),
          Switch(
            value: isDarkMode,
            onChanged: (value) {
              themeProvider.toggleTheme();
            },
            activeColor: themeProvider.accentColor,
          ),
        ],
      ),
    );
  }

  Widget _buildAccentColorSelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentColor = themeProvider.accentColor;
    
    return InkWell(
      onTap: () => _showColorPicker(context, themeProvider),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: currentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.palette,
                color: currentColor,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                'Accent Color',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: currentColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                  width: 2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFontSizeSlider() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final sliderValue = themeProvider.multiplierToSlider(themeProvider.fontSizeMultiplier);
    final percentage = (themeProvider.fontSizeMultiplier * 100).round();
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: themeProvider.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.format_size,
                  color: themeProvider.accentColor,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Font Size',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    Text(
                      '$percentage%',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.format_size, size: 18, color: Colors.grey),
              Expanded(
                child: Slider(
                  value: sliderValue,
                  min: 0,
                  max: 100,
                  divisions: null, // Remove divisions for smooth sliding
                  activeColor: themeProvider.accentColor,
                  onChanged: (value) {
                    final multiplier = themeProvider.sliderToMultiplier(value);
                    themeProvider.setFontSizeMultiplier(multiplier);
                  },
                ),
              ),
              Icon(Icons.format_size, size: 32, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final accentColor = themeProvider.accentColor;
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: const NetworkImage(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuCDwQ_TFhwoHId57YySrJiF3r4Jm2bwvC7e2oDXDVjfwtBf0So1lAwksEOXhYZJd7sEz1clJ2ucNwMecIy5OB2y5iuESEJcyUxlgzJrAPb48S4IH-U-JQcCMcQxib3apFLj1rb8NBHOtXANQ0gjiPvIiHS6EcfIXrEJP3vgOVrhn3PLDUvSfSdypcNnvtXj7HB-KMUdgbXkXpJdVvjTBVP0ir6yMxyEhduJZ_d-YfLEUH2DK8qBLK4aYj9_FRU5bCf4CkdM7BckwR4',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.2),
                    borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hey! How are you?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'This is a preview of how the app will look with your selected settings.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: Text(
                'Example Button',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showColorPicker(BuildContext context, ThemeProvider themeProvider) {
    showDialog(
      context: context,
      builder: (context) => _ColorPickerDialog(
        initialColor: themeProvider.accentColor,
        onColorChanged: (color) {
          themeProvider.setAccentColor(color);
        },
      ),
    );
  }
}

class _ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerDialog({
    required this.initialColor,
    required this.onColorChanged,
  });

  @override
  State<_ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<_ColorPickerDialog> {
  late Color pickerColor;

  @override
  void initState() {
    super.initState();
    pickerColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Accent Color'),
      content: SingleChildScrollView(
        child: ColorPicker(
          color: pickerColor,
          onColorChanged: (Color color) {
            setState(() {
              pickerColor = color;
            });
            widget.onColorChanged(color);
          },
          width: 40,
          height: 40,
          borderRadius: 4,
          spacing: 5,
          runSpacing: 5,
          wheelDiameter: 200,
          heading: Text(
            'Select color',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          subheading: Text(
            'Select color shade',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          wheelSubheading: Text(
            'Selected color and its shades',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          showMaterialName: true,
          showColorName: true,
          showColorCode: true,
          copyPasteBehavior: const ColorPickerCopyPasteBehavior(
            longPressMenu: true,
          ),
          materialNameTextStyle: Theme.of(context).textTheme.bodySmall,
          colorNameTextStyle: Theme.of(context).textTheme.bodySmall,
          colorCodeTextStyle: Theme.of(context).textTheme.bodySmall,
          pickersEnabled: const <ColorPickerType, bool>{
            ColorPickerType.both: false,
            ColorPickerType.primary: true,
            ColorPickerType.accent: true,
            ColorPickerType.bw: false,
            ColorPickerType.custom: false,
            ColorPickerType.wheel: true,
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

