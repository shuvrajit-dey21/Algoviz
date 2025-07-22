import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with SingleTickerProviderStateMixin {
  // Settings state
  bool isDarkMode = false;
  String selectedLanguage = 'English';
  bool notificationsEnabled = true;
  double textScale = 1.0;
  bool isDataSyncEnabled = true;
  String? userEmail;
  String currentVersion = '';
  final storage = const FlutterSecureStorage();
  
  // Animation controller for background
  late AnimationController _backgroundAnimationController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAppVersion();
    
    // Initialize animation controller
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat(reverse: true);
    
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_backgroundAnimationController);
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
      selectedLanguage = prefs.getString('language') ?? 'English';
      notificationsEnabled = prefs.getBool('notifications') ?? true;
      textScale = prefs.getDouble('textScale') ?? 1.0;
      isDataSyncEnabled = prefs.getBool('dataSync') ?? true;
      userEmail = prefs.getString('userEmail');
    });
  }

  Future<void> _loadAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
    await prefs.setString('language', selectedLanguage);
    await prefs.setBool('notifications', notificationsEnabled);
    await prefs.setDouble('textScale', textScale);
    await prefs.setBool('dataSync', isDataSyncEnabled);
  }

  @override
  Widget build(BuildContext context) {
    // Get the current theme brightness
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: isDarkMode ? Color.fromRGBO(40, 40, 70, 1.0) : Colors.white,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 4.0,
        shadowColor: isDarkMode ? Colors.black : Colors.grey[300],
        actions: [
          IconButton(
            icon: Icon(Icons.restore, color: isDarkMode ? Colors.white : Colors.black87),
            onPressed: _resetSettings,
            tooltip: 'Reset Settings',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimation,
            builder: (context, child) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDarkMode
                        ? [
                            Color.fromRGBO(30, 30, 60, 1.0),
                            Color.fromRGBO(15, 15, 35, 1.0),
                          ]
                        : [
                            Color.fromRGBO(230, 240, 255, 1.0),
                            Color.fromRGBO(210, 220, 235, 1.0),
                          ],
                    stops: [
                      _backgroundAnimation.value,
                      _backgroundAnimation.value + 0.5,
                    ],
                  ),
                ),
              );
            },
          ),
          
          // Subtle pattern overlay with adaptive color
          Opacity(
            opacity: isDarkMode ? 0.1 : 0.05,
            child: CustomPaint(
              painter: BackgroundPatternPainter(
                animation: _backgroundAnimation,
                isDarkMode: isDarkMode,
              ),
              child: Container(),
            ),
          ),
          
          // Content with transparency
          ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
              _buildSectionHeader('Appearance', textColor),
              _buildCard([
                ListTile(
                  leading: const Icon(Icons.dark_mode),
                  title: const Text('Dark Mode'),
                  trailing: Switch(
                    value: isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        isDarkMode = value;
                        _saveSettings();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.text_fields),
                  title: const Text('Text Size'),
                  subtitle: Slider(
                    value: textScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: '${(textScale * 100).round()}%',
                    onChanged: (value) {
                      setState(() {
                        textScale = value;
                        _saveSettings();
                      });
                    },
                  ),
                ),
              ]),

          const SizedBox(height: 16),

          // Language Settings
              _buildSectionHeader('Language', textColor),
              _buildCard([
                ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Language'),
              trailing: DropdownButton<String>(
                value: selectedLanguage,
                items: ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese']
                    .map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedLanguage = newValue;
                      _saveSettings();
                    });
                  }
                },
              ),
            ),
              ]),

          const SizedBox(height: 16),

          // Notifications Section
              _buildSectionHeader('Notifications', textColor),
              _buildCard([
                ListTile(
                  leading: const Icon(Icons.notifications),
                  title: const Text('Push Notifications'),
                  trailing: Switch(
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setState(() {
                        notificationsEnabled = value;
                        _saveSettings();
                      });
                    },
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.sync),
                  title: const Text('Background Sync'),
                  trailing: Switch(
                    value: isDataSyncEnabled,
                    onChanged: (value) {
                      setState(() {
                        isDataSyncEnabled = value;
                        _saveSettings();
                      });
                    },
                  ),
                ),
              ]),

          const SizedBox(height: 16),

          // Account Section
              _buildSectionHeader('Account', textColor),
              _buildCard([
                ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(userEmail ?? 'Not signed in'),
                  trailing: TextButton(
                    onPressed: _handleAccountAction,
                    child: Text(userEmail != null ? 'Sign Out' : 'Sign In'),
                  ),
                ),
                if (userEmail != null)
                  ListTile(
                    leading: const Icon(Icons.security),
                    title: const Text('Change Password'),
                    onTap: _showChangePasswordDialog,
                  ),
              ]),

          const SizedBox(height: 16),

          // Support Section
              _buildSectionHeader('Support', textColor),
              _buildCard([
                ListTile(
                  leading: const Icon(Icons.help),
                  title: const Text('Help Center'),
                  onTap: _openHelpCenter,
                ),
                ListTile(
                  leading: const Icon(Icons.bug_report),
                  title: const Text('Report a Bug'),
                  onTap: _reportBug,
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('About'),
                  subtitle: Text('Version $currentVersion'),
                  onTap: _showAboutDialog,
                ),
              ]),
              ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.lightBlue[100] : Colors.grey[700],
          shadows: isDarkMode ? [
            Shadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(1, 1),
            )
          ] : null,
        ),
      ),
    );
  }

  Future<void> _resetSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDarkMode ? Color.fromRGBO(50, 50, 80, 1.0) : Colors.white,
        title: Text(
          'Reset Settings',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to reset all settings to default?',
          style: TextStyle(
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        actions: [
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
            onPressed: () => Navigator.pop(context, false),
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.red.withOpacity(0.2) : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextButton(
            onPressed: () => Navigator.pop(context, true),
              child: Text(
                'RESET',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      setState(() {
        isDarkMode = false;
        selectedLanguage = 'English';
        notificationsEnabled = true;
        textScale = 1.0;
        isDataSyncEnabled = true;
      });
      await _saveSettings();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings reset to default')),
        );
      }
    }
  }

  void _handleAccountAction() {
    if (userEmail != null) {
      _signOut();
    } else {
      _signIn();
    }
  }

  Future<void> _signIn() async {
    // Implement your sign-in logic here
    // This is just a placeholder implementation
    setState(() {
      userEmail = 'user@example.com';
    });
  }

  Future<void> _signOut() async {
    // Implement your sign-out logic here
    setState(() {
      userEmail = null;
    });
  }

  Future<void> _showChangePasswordDialog() async {
    final TextEditingController currentPassword = TextEditingController();
    final TextEditingController newPassword = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDarkMode ? Color.fromRGBO(50, 50, 80, 1.0) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dialog title
              Text(
                'Change Password',
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              // Input fields
              TextField(
                controller: currentPassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  labelStyle: TextStyle(
                    color: isDarkMode ? Colors.lightBlue[100] : Colors.blue[700],
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[400]! : Colors.grey[400]!,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.lightBlue : Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  hintText: 'Enter your current password',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87, 
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: newPassword,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  labelStyle: TextStyle(
                    color: isDarkMode ? Colors.lightBlue[100] : Colors.blue[700],
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.grey[400]! : Colors.grey[400]!,
                    ),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: isDarkMode ? Colors.lightBlue : Colors.blue,
                      width: 2.0,
                    ),
                  ),
                  hintText: 'Enter your new password',
                  hintStyle: TextStyle(
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 24),
              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blue.withOpacity(0.2) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'CANCEL',
                        style: TextStyle(
                          color: isDarkMode ? Colors.lightBlue[200] : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isDarkMode ? Colors.blue[300]! : Colors.blue,
                        width: 1.0,
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        // Implement password change logic here
                        Navigator.pop(context);
                      },
                      child: Text(
                        'CHANGE',
                        style: TextStyle(
                          color: isDarkMode ? Colors.lightBlue[200] : Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openHelpCenter() async {
    const url = 'https://your-help-center-url.com';
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch help center')),
        );
      }
    }
  }

  Future<void> _reportBug() async {
    const email = 'support@your-app.com';
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Bug Report - AlgoViz&body=Please describe the issue:',
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch email client')),
        );
      }
    }
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) {
        // Create a custom about dialog instead of using the built-in AboutDialog
        return Dialog(
          backgroundColor: isDarkMode ? Color.fromRGBO(50, 50, 80, 1.0) : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App icon and name
                Row(
                  children: [
                    // App icon
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.auto_graph,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    // App name and version
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AlgoViz',
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          currentVersion,
                          style: TextStyle(
                            color: isDarkMode ? Colors.white70 : Colors.black54,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Description
                Text(
                  'AlgoViz is an educational platform for learning algorithms and data structures through visualization.',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 16),
                // Copyright
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.copyright, 
                      size: 16, 
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                    ),
                    SizedBox(width: 4),
                    Text(
                      '2023 AlgoViz Team',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white70 : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Color.fromRGBO(70, 90, 150, 1.0) : Colors.blue[100],
                        foregroundColor: isDarkMode ? Colors.white : Colors.blue[800],
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onPressed: () {
                        // View licenses functionality
                        showLicensePage(
                          context: context,
        applicationName: 'AlgoViz',
        applicationVersion: currentVersion,
                          applicationIcon: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Icon(
                                Icons.auto_graph,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Text(
                        'View licenses',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDarkMode ? Color.fromRGBO(60, 60, 100, 1.0) : Colors.grey[100],
                        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Close',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method to create cards with a consistent style
  Widget _buildCard(List<Widget> children) {
    final cardColor = isDarkMode 
        ? Color.fromRGBO(45, 45, 75, 0.85)
        : Colors.white.withOpacity(0.9);
        
    final iconColor = isDarkMode ? Colors.lightBlue[100] : Colors.blue;
    
    // Add theming to the children
    final themedChildren = children.map((child) {
      if (child is ListTile) {
        Widget? trailingWidget = child.trailing;
        
        // Style the "Sign In" or "Sign Out" button specifically
        if (trailingWidget is TextButton) {
          final buttonText = (trailingWidget.child as Text).data ?? '';
          trailingWidget = Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.blue.withOpacity(0.3) : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDarkMode ? Colors.blue[300]! : Colors.blue[700]!,
                width: 1.0,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: TextButton(
              onPressed: trailingWidget.onPressed,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                buttonText,
                style: TextStyle(
                  color: isDarkMode ? Colors.blue[200] : Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }
        
        return ListTile(
          leading: child.leading != null ? 
            IconTheme(
              data: IconThemeData(color: iconColor),
              child: child.leading!,
            ) : null,
          title: DefaultTextStyle(
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            child: child.title!,
          ),
          subtitle: child.subtitle != null ? 
            DefaultTextStyle(
              style: TextStyle(
                color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
              ),
              child: child.subtitle is Slider ? 
                child.subtitle! : 
                DefaultTextStyle(
                  style: TextStyle(
                    color: isDarkMode ? Colors.grey[300] : Colors.grey[700],
                  ),
                  child: child.subtitle!,
                ),
            ) : null,
          trailing: trailingWidget,
          onTap: child.onTap,
        );
      }
      return child;
    }).toList();
    
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 4),
      shadowColor: isDarkMode ? Colors.black87 : Colors.black45,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(12),
          border: isDarkMode ? 
            Border.all(color: Colors.lightBlue.withOpacity(0.3), width: 0.5) : null,
        ),
        child: Theme(
          data: Theme.of(context).copyWith(
            switchTheme: SwitchThemeData(
              thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return isDarkMode ? Colors.lightBlue : Colors.blue;
                }
                return isDarkMode ? Colors.grey[400]! : Colors.grey[50]!;
              }),
              trackColor: MaterialStateProperty.resolveWith<Color>((states) {
                if (states.contains(MaterialState.selected)) {
                  return isDarkMode ? Colors.lightBlue.withOpacity(0.5) : Colors.blue.withOpacity(0.5);
                }
                return isDarkMode ? Colors.grey[700]! : Colors.grey[300]!;
              }),
            ),
            sliderTheme: SliderThemeData(
              activeTrackColor: isDarkMode ? Colors.lightBlue : null,
              thumbColor: isDarkMode ? Colors.lightBlue : null,
            ),
          ),
          child: Column(children: themedChildren),
        ),
      ),
    );
  }
}

// Custom painter for background pattern
class BackgroundPatternPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isDarkMode;
  
  BackgroundPatternPainter({required this.animation, required this.isDarkMode}) : super(repaint: animation);
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDarkMode ? Colors.lightBlue.withOpacity(0.3) : Colors.white
      ..strokeWidth = isDarkMode ? 1.2 : 1.0
      ..style = PaintingStyle.stroke;
    
    final double offset = animation.value * 20;
    
    // Draw a grid of subtle circles
    for (double x = -50; x < size.width + 50; x += 50) {
      for (double y = -50; y < size.height + 50; y += 50) {
        final double adjustedX = x + (offset * (y % 100 == 0 ? 1 : -1));
        final double adjustedY = y + (offset * (x % 100 == 0 ? 1 : -1));
        
        canvas.drawCircle(
          Offset(adjustedX, adjustedY),
          20 + (10 * animation.value),
          paint,
        );
      }
    }
  }
  
  @override
  bool shouldRepaint(BackgroundPatternPainter oldDelegate) => 
    animation != oldDelegate.animation || isDarkMode != oldDelegate.isDarkMode;
} 