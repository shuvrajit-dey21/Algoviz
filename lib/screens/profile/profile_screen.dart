import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  // Animation controllers
  late final AnimationController _headerAnimationController;
  late final AnimationController _contentAnimationController;
  late final AnimationController _avatarAnimationController;
  
  // Animations
  late final Animation<double> _headerSlideAnimation;
  late final Animation<double> _avatarScaleAnimation;
  late final Animation<double> _contentFadeAnimation;
  late final Animation<double> _itemSlideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize header animation
    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    
    _headerSlideAnimation = Tween<double>(
      begin: -1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Initialize avatar animation
    _avatarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _avatarScaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _avatarAnimationController,
      curve: Curves.elasticOut,
    ));
    
    // Initialize content animations
    _contentAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _contentFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeIn,
    ));
    
    _itemSlideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _contentAnimationController,
      curve: Curves.easeOutCubic,
    ));
    
    // Start animations sequentially
    _headerAnimationController.forward().then((_) {
      _avatarAnimationController.forward().then((_) {
        _contentAnimationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _headerAnimationController.dispose();
    _avatarAnimationController.dispose();
    _contentAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Animated Header
            AnimatedBuilder(
              animation: _headerAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(_headerSlideAnimation.value * MediaQuery.of(context).size.width, 0),
                  child: Container(
                    height: 240,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.primary.withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Animated background patterns
                        _buildAnimatedPatterns(),
                        
                        // Profile content
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // Animated Avatar
                              ScaleTransition(
                                scale: _avatarScaleAnimation,
                                child: Container(
                                  width: 120,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    backgroundColor: Colors.white,
                                    child: Icon(
                                      Icons.person,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Animated Name and Email
                              FadeTransition(
                                opacity: _contentFadeAnimation,
                                child: Column(
                                  children: [
                                    Text(
                                      'User Name',
                                      style: theme.textTheme.headlineSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'user@example.com',
                                      style: theme.textTheme.bodyLarge?.copyWith(
                                        color: Colors.white.withOpacity(0.9),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            
            // Animated Content Sections
            AnimatedBuilder(
              animation: _contentAnimationController,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _itemSlideAnimation.value),
                  child: FadeTransition(
                    opacity: _contentFadeAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSection(
                            title: 'Personal Information',
                            items: [
                              _buildInfoItem(Icons.person_outline, 'Name', 'User Name'),
                              _buildInfoItem(Icons.email_outlined, 'Email', 'user@example.com'),
                              _buildInfoItem(Icons.phone_outlined, 'Phone', '+1 234 567 8900'),
                            ],
                          ),
                          const SizedBox(height: 24),
                          _buildSection(
                            title: 'Account Settings',
                            items: [
                              _buildSettingItem(
                                Icons.language,
                                'Language',
                                'English',
                                onTap: () {
                                  // Handle language settings
                                },
                              ),
                              _buildSettingItem(
                                Icons.notifications_outlined,
                                'Notifications',
                                'On',
                                onTap: () {
                                  // Handle notification settings
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: items,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem(
    IconData icon,
    String label,
    String value, {
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedPatterns() {
    return CustomPaint(
      painter: ProfilePatternPainter(
        animation: _headerAnimationController,
        color: Colors.white,
      ),
      size: const Size(double.infinity, double.infinity),
    );
  }
}

class ProfilePatternPainter extends CustomPainter {
  final Animation<double> animation;
  final Color color;

  ProfilePatternPainter({
    required this.animation,
    required this.color,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Draw animated patterns
    for (var i = 0; i < 5; i++) {
      final progress = animation.value;
      final offset = 30.0 * i;
      
      // Draw circles
      canvas.drawCircle(
        Offset(size.width * 0.8, size.height * 0.2 + offset),
        20 + 10 * progress + offset,
        paint,
      );
      
      // Draw lines
      canvas.drawLine(
        Offset(-50 + progress * 100, offset),
        Offset(50 + progress * 100, 50 + offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ProfilePatternPainter oldDelegate) {
    return true;
  }
} 