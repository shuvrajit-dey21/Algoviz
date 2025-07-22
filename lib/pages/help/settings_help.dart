import 'package:flutter/material.dart';

class SettingsHelpPage extends StatefulWidget {
  const SettingsHelpPage({Key? key}) : super(key: key);

  @override
  State<SettingsHelpPage> createState() => _SettingsHelpPageState();
}

class _SettingsHelpPageState extends State<SettingsHelpPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings Help',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDarkMode 
              ? const Color(0xFF1A237E)
              : const Color(0xFF3F51B5),
          elevation: 4.0,
          shadowColor: isDarkMode 
              ? Colors.black 
              : Colors.black26,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.blue.withOpacity(0.2) 
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: Icon(
                  isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Colors.white,
                  size: 22,
                ),
                tooltip: isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                onPressed: () {
                  setState(() {
                    isDarkMode = !isDarkMode;
                  });
                },
              ),
            ),
          ],
        ),
        body: Container(
          color: isDarkMode 
              ? const Color(0xFF121212)
              : const Color(0xFFF5F5F5),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 16),
              _buildSettingSection(
                'Theme Settings',
                'Customize the app\'s appearance:',
                [
                  'Switch between light and dark themes for comfortable viewing',
                  'Choose from a variety of accent colors to personalize your experience',
                  'Adjust text size and font settings for optimal readability',
                  'Configure contrast and animation settings',
                ],
                Icons.palette_outlined,
              ),
              _buildSettingSection(
                'Account Settings',
                'Manage your account details:',
                [
                  'Update your profile information including name, email, and photo',
                  'Change password and security settings',
                  'Customize notification preferences and alert settings',
                  'Manage connected accounts and third-party integrations',
                ],
                Icons.person_outline,
              ),
              _buildSettingSection(
                'Visualization Settings',
                'Customize data display options:',
                [
                  'Choose from various chart types and visualization styles',
                  'Configure data point display and metric visibility',
                  'Set default time ranges and view periods',
                  'Customize export formats and data presentation',
                ],
                Icons.bar_chart_outlined,
              ),
              _buildSettingSection(
                'Privacy Settings',
                'Control your privacy options:',
                [
                  'Manage data sharing preferences and permissions',
                  'Review and control your activity history',
                  'Set up automatic data backup and recovery options',
                  'Learn about account deletion and data retention policies',
                ],
                Icons.security_outlined,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode 
            ? const Color(0xFF1A237E).withOpacity(0.2)
            : const Color(0xFF3F51B5).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? Colors.blue.withOpacity(0.3) 
              : Colors.blue.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Settings Help',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.blue[300] : Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Find detailed information about each settings category below. Tap on any section to learn more.',
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.black87,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingSection(String title, String subtitle, List<String> details, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2.0,
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        leading: Icon(
          icon, 
          color: isDarkMode ? Colors.blue[300] : Colors.blue,
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 13,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details.map((detail) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: isDarkMode ? Colors.green[300] : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        detail,
                        style: TextStyle(
                          height: 1.5,
                          fontSize: 14,
                          color: isDarkMode ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }
} 