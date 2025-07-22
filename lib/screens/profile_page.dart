import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // User information
  String userName = 'Loading...';
  String userEmail = 'Loading...';
  String userPhone = 'Loading...';
  
  // Settings state
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool twoFactorEnabled = false;
  bool debugModeEnabled = false;
  bool showLayoutBounds = false;
  String selectedLanguage = 'English';
  String apiEnvironment = 'Production';
  String logLevel = 'Warning';
  
  // Expanded sections tracking
  final Map<String, bool> _expandedSections = {
    'Personal Information': false,
    'Account Settings': false,
    'Privacy & Security': false,
    'Developer Options': false,
    'About': false,
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadSettings();
  }

  // Load user data from shared preferences or your auth service
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User Name';
      userEmail = prefs.getString('user_email') ?? 'user@example.com';
      userPhone = prefs.getString('user_phone') ?? '+1 234 567 8900';
    });
  }

  // Load app settings
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      darkModeEnabled = prefs.getBool('dark_mode_enabled') ?? false;
      twoFactorEnabled = prefs.getBool('two_factor_enabled') ?? false;
      debugModeEnabled = prefs.getBool('debug_mode_enabled') ?? false;
      showLayoutBounds = prefs.getBool('show_layout_bounds') ?? false;
      selectedLanguage = prefs.getString('selected_language') ?? 'English';
      apiEnvironment = prefs.getString('api_environment') ?? 'Production';
      logLevel = prefs.getString('log_level') ?? 'Warning';
    });
  }

  // Save a boolean setting
  Future<void> _saveBoolSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  // Save a string setting
  Future<void> _saveStringSetting(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile header with avatar
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blue,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                    // You can use a network image here if available
                    // backgroundImage: NetworkImage('user_avatar_url'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    userEmail,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            
            const Divider(thickness: 1),
            
            // Expandable sections
            ..._buildExpandableSections(),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildExpandableSections() {
    return _expandedSections.entries.map((entry) {
      return Column(
        children: [
          ListTile(
            title: Text(
              entry.key,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            trailing: Icon(
              entry.value ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
            ),
            onTap: () {
              setState(() {
                _expandedSections[entry.key] = !entry.value;
              });
            },
          ),
          if (entry.value) _buildSectionContent(entry.key),
          const Divider(thickness: 1),
        ],
      );
    }).toList();
  }

  Widget _buildSectionContent(String section) {
    switch (section) {
      case 'Personal Information':
        return Column(
          children: [
            _buildSettingItem('Name', userName, Icons.edit, onTap: () => _editPersonalInfo('name')),
            _buildSettingItem('Email', userEmail, Icons.edit, onTap: () => _editPersonalInfo('email')),
            _buildSettingItem('Phone', userPhone, Icons.edit, onTap: () => _editPersonalInfo('phone')),
          ],
        );
      case 'Account Settings':
        return Column(
          children: [
            _buildSettingItem('Language', selectedLanguage, Icons.arrow_forward_ios, 
              onTap: _showLanguageOptions),
            _buildSettingItem('Notifications', notificationsEnabled ? 'On' : 'Off', null, 
              isSwitch: true, 
              switchValue: notificationsEnabled,
              onSwitchChanged: (value) {
                setState(() {
                  notificationsEnabled = value;
                  _saveBoolSetting('notifications_enabled', value);
                });
              }),
            _buildSettingItem('Dark Mode', darkModeEnabled ? 'On' : 'Off', null, 
              isSwitch: true, 
              switchValue: darkModeEnabled,
              onSwitchChanged: (value) {
                setState(() {
                  darkModeEnabled = value;
                  _saveBoolSetting('dark_mode_enabled', value);
                });
              }),
          ],
        );
      case 'Privacy & Security':
        return Column(
          children: [
            _buildSettingItem('Change Password', '', Icons.arrow_forward_ios, 
              onTap: _showChangePasswordDialog),
            _buildSettingItem('Two-Factor Authentication', twoFactorEnabled ? 'On' : 'Off', null, 
              isSwitch: true, 
              switchValue: twoFactorEnabled,
              onSwitchChanged: (value) {
                setState(() {
                  twoFactorEnabled = value;
                  _saveBoolSetting('two_factor_enabled', value);
                });
              }),
            _buildSettingItem('Data Sharing', 'Limited', Icons.arrow_forward_ios, 
              onTap: _showDataSharingOptions),
          ],
        );
      case 'Developer Options':
        return Column(
          children: [
            _buildSettingItem('Debug Mode', debugModeEnabled ? 'On' : 'Off', null, 
              isSwitch: true, 
              switchValue: debugModeEnabled,
              onSwitchChanged: (value) {
                setState(() {
                  debugModeEnabled = value;
                  _saveBoolSetting('debug_mode_enabled', value);
                });
              }),
            _buildSettingItem('API Environment', apiEnvironment, Icons.arrow_forward_ios, 
              onTap: _showApiEnvironmentOptions),
            _buildSettingItem('Clear Cache', '', Icons.delete_outline, 
              onTap: _showClearCacheDialog),
            _buildSettingItem('Log Level', logLevel, Icons.arrow_forward_ios, 
              onTap: _showLogLevelOptions),
            _buildSettingItem('Show Layout Bounds', showLayoutBounds ? 'On' : 'Off', null, 
              isSwitch: true, 
              switchValue: showLayoutBounds,
              onSwitchChanged: (value) {
                setState(() {
                  showLayoutBounds = value;
                  _saveBoolSetting('show_layout_bounds', value);
                });
              }),
          ],
        );
      case 'About':
        return Column(
          children: [
            _buildSettingItem('App Version', '1.0.0', null),
            _buildSettingItem('Terms of Service', '', Icons.arrow_forward_ios, 
              onTap: () => _showLegalDocument('Terms of Service')),
            _buildSettingItem('Privacy Policy', '', Icons.arrow_forward_ios, 
              onTap: () => _showLegalDocument('Privacy Policy')),
            _buildSettingItem('Licenses', '', Icons.arrow_forward_ios, 
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => LicensePage())
              )),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildSettingItem(
    String title, 
    String subtitle, 
    IconData? trailingIcon, {
    bool isSwitch = false, 
    bool switchValue = false,
    Function()? onTap,
    Function(bool)? onSwitchChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 32.0),
      title: Text(title),
      subtitle: subtitle.isNotEmpty ? Text(subtitle) : null,
      trailing: isSwitch
          ? Switch(
              value: switchValue,
              onChanged: onSwitchChanged,
            )
          : trailingIcon != null
              ? Icon(trailingIcon, size: 20)
              : null,
      onTap: onTap,
    );
  }

  // Dialog to edit personal information
  void _editPersonalInfo(String field) {
    String currentValue = '';
    String title = '';
    
    switch (field) {
      case 'name':
        currentValue = userName;
        title = 'Edit Name';
        break;
      case 'email':
        currentValue = userEmail;
        title = 'Edit Email';
        break;
      case 'phone':
        currentValue = userPhone;
        title = 'Edit Phone';
        break;
    }
    
    final TextEditingController controller = TextEditingController(text: currentValue);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter your $field',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final newValue = controller.text.trim();
              if (newValue.isNotEmpty) {
                final prefs = await SharedPreferences.getInstance();
                
                setState(() {
                  switch (field) {
                    case 'name':
                      userName = newValue;
                      prefs.setString('user_name', newValue);
                      break;
                    case 'email':
                      userEmail = newValue;
                      prefs.setString('user_email', newValue);
                      break;
                    case 'phone':
                      userPhone = newValue;
                      prefs.setString('user_phone', newValue);
                      break;
                  }
                });
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show language options dialog
  void _showLanguageOptions() {
    final languages = ['English', 'Spanish', 'French', 'German', 'Chinese', 'Japanese'];
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Language'),
        children: languages.map((language) => 
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                selectedLanguage = language;
                _saveStringSetting('selected_language', language);
              });
              Navigator.pop(context);
            },
            child: Text(language),
          )
        ).toList(),
      ),
    );
  }

  // Show change password dialog
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
              ),
            ),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
              ),
            ),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement password change logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password changed successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  // Show data sharing options
  void _showDataSharingOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Sharing Options'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Choose what data you want to share:'),
            SizedBox(height: 10),
            CheckboxListTile(
              title: Text('Usage Statistics'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('Crash Reports'),
              value: true,
              onChanged: null,
            ),
            CheckboxListTile(
              title: Text('Personal Information'),
              value: false,
              onChanged: null,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  // Show API environment options
  void _showApiEnvironmentOptions() {
    final environments = ['Development', 'Staging', 'Production'];
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select API Environment'),
        children: environments.map((env) => 
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                apiEnvironment = env;
                _saveStringSetting('api_environment', env);
              });
              Navigator.pop(context);
            },
            child: Text(env),
          )
        ).toList(),
      ),
    );
  }

  // Show clear cache dialog
  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text('Are you sure you want to clear the app cache? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Implement cache clearing logic
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
              );
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  // Show log level options
  void _showLogLevelOptions() {
    final logLevels = ['Verbose', 'Debug', 'Info', 'Warning', 'Error', 'Critical'];
    
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Log Level'),
        children: logLevels.map((level) => 
          SimpleDialogOption(
            onPressed: () {
              setState(() {
                logLevel = level;
                _saveStringSetting('log_level', level);
              });
              Navigator.pop(context);
            },
            child: Text(level),
          )
        ).toList(),
      ),
    );
  }

  // Show legal documents
  void _showLegalDocument(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(
          child: Text(
            'This is a placeholder for the $title. In a real app, you would include the actual legal text here.\n\n' 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisi vel consectetur euismod, nisi nisl consectetur nisi, euismod nisi vel consectetur euismod, nisi nisl consectetur nisi.\n\n' +
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam euismod, nisi vel consectetur euismod, nisi nisl consectetur nisi, euismod nisi vel consectetur euismod, nisi nisl consectetur nisi.',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
} 