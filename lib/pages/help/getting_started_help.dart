import 'package:flutter/material.dart';

class GettingStartedHelpPage extends StatefulWidget {
  const GettingStartedHelpPage({Key? key}) : super(key: key);

  @override
  State<GettingStartedHelpPage> createState() => _GettingStartedHelpPageState();
}

class _GettingStartedHelpPageState extends State<GettingStartedHelpPage> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Getting Started',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
              color: Colors.white,
            ),
          ),
          backgroundColor: isDarkMode 
              ? const Color(0xFF2C384A) // Dark blue-grey
              : const Color(0xFF4CAF50), // Material green
          elevation: 4.0,
          shadowColor: isDarkMode ? Colors.black : Colors.black26,
          actions: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: isDarkMode 
                    ? Colors.white.withOpacity(0.2) 
                    : Colors.black.withOpacity(0.2),
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
          color: isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              _buildHeaderSection(),
              const SizedBox(height: 16),
              _buildSection(
                'Welcome to AlgoViz',
                'Start your journey with algorithm visualization:',
                [
                  'Interactive visualization of various algorithms',
                  'Step-by-step explanation of each process',
                  'Customizable animation speeds',
                  'Practice exercises and examples',
                ],
                Icons.home_outlined,
              ),
              _buildSection(
                'Creating Your Account',
                'Set up your personalized experience:',
                [
                  'Sign up with email or social accounts',
                  'Complete your profile information',
                  'Choose your preferred settings',
                  'Enable notifications for updates',
                ],
                Icons.person_add_outlined,
              ),
              _buildSection(
                'Basic Navigation',
                'Learn to navigate through the app:',
                [
                  'Explore the main dashboard',
                  'Access different algorithm categories',
                  'Use the search functionality',
                  'Customize your workspace',
                ],
                Icons.navigation_outlined,
              ),
              _buildSection(
                'First Steps',
                'Begin your learning journey:',
                [
                  'Choose an algorithm to visualize',
                  'Adjust visualization parameters',
                  'Follow the step-by-step guide',
                  'Practice with example problems',
                ],
                Icons.school_outlined,
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
            ? const Color(0xFF2C384A).withOpacity(0.2)
            : const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode 
              ? Colors.green.withOpacity(0.3)
              : Colors.green.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to AlgoViz!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isDarkMode ? Colors.green[300] : Colors.green[900],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Get started with algorithm visualization. This guide will help you navigate through the basic features and functionalities of AlgoViz.',
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String subtitle, List<String> details, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDarkMode ? Colors.grey[800] : Colors.white,
      child: ExpansionTile(
        leading: Icon(
          icon,
          color: isDarkMode ? Colors.green[300] : Colors.green,
          size: 28,
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
                          color: isDarkMode ? Colors.grey[300] : Colors.grey[800],
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