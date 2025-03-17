import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../providers/settings_provider.dart';
import '../providers/auth_provider.dart';
import '../theme/eddie_colors.dart';
import '../theme/eddie_constants.dart';
import '../theme/eddie_text_styles.dart';
import '../widgets/eddie_button.dart';
import '../widgets/eddie_outlined_button.dart';
import '../widgets/eddie_text_field.dart';
import '../widgets/eddie_theme_toggle.dart';
import '../theme/eddie_theme.dart';

class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final TextEditingController _promptController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handlePromptSubmit() {
    if (_promptController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _promptController.clear();
        });
        
        // Show snackbar with prompt
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Processing: ${_promptController.text}'),
            backgroundColor: EddieColors.getPrimary(context),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final settingsState = ref.watch(settingsProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;
    
    return Scaffold(
      backgroundColor: EddieColors.getBackground(context),
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context, isSmallScreen),
            
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(EddieConstants.spacingLg),
                  child: Column(
                    children: [
                      // Hero Section
                      _buildHeroSection(context, isSmallScreen),
                      
                      SizedBox(height: EddieConstants.spacingXxl),
                      
                      // Community Section
                      _buildCommunitySection(context, isSmallScreen),
                      
                      SizedBox(height: EddieConstants.spacingXxl),
                      
                      // Features Section
                      _buildFeaturesSection(context, isSmallScreen),
                    ],
                  ),
                ),
              ),
            ),
            
            // Footer
            _buildFooter(context, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isSmallScreen) {
    final settingsState = ref.watch(settingsProvider);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: EddieConstants.spacingLg,
        vertical: EddieConstants.spacingMd,
      ),
      decoration: BoxDecoration(
        color: EddieColors.getSurface(context),
        boxShadow: EddieConstants.getShadowSmall(context),
      ),
      child: Row(
        children: [
          // Logo
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: EddieColors.getPrimary(context),
                  borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                ),
                child: Center(
                  child: Text(
                    'E',
                    style: EddieTextStyles.heading2(context).copyWith(
                      color: EddieColors.getButtonText(context),
                    ),
                  ),
                ),
              ),
              SizedBox(width: EddieConstants.spacingSm),
              Text(
                'eddie',
                style: EddieTextStyles.heading2(context),
              ),
            ],
          ),
          const Spacer(),
          
          // Theme Toggle
          EddieThemeToggle(
            currentThemeMode: settingsState.themeMode,
            onThemeModeChanged: (EddieThemeMode mode) {
              ref.read(settingsProvider.notifier).setThemeMode(mode);
            },
            showLabel: !isSmallScreen,
            isCompact: isSmallScreen,
          ),
          SizedBox(width: EddieConstants.spacingMd),
          
          // Sign In / Sign Up buttons with navigation
          if (!isSmallScreen) ...[
            EddieOutlinedButton(
              label: 'Sign In',
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              buttonType: ButtonType.secondary,
              size: EddieButtonSize.small,
            ),
            SizedBox(width: EddieConstants.spacingSm),
            EddieButton(
              label: 'Sign Up',
              onPressed: () => Navigator.of(context).pushNamed('/signup'),
              buttonType: ButtonType.primary,
              size: EddieButtonSize.small,
            ),
          ] else ...[
            EddieButton(
              label: 'Sign In',
              onPressed: () => Navigator.of(context).pushNamed('/login'),
              buttonType: ButtonType.primary,
              size: EddieButtonSize.small,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, bool isSmallScreen) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: EdgeInsets.symmetric(
        vertical: EddieConstants.spacingXl,
      ),
      child: Column(
        children: [
          Text(
            'What can I help you design?',
            style: EddieTextStyles.heading1(context).copyWith(
              fontSize: isSmallScreen ? 28 : 36,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: EddieConstants.spacingXl),
          
          // Prompt Input
          Container(
            decoration: BoxDecoration(
              color: EddieColors.getSurface(context),
              borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
              border: Border.all(
                color: EddieColors.getOutline(context),
              ),
              boxShadow: EddieConstants.getShadowSmall(context),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promptController,
                    decoration: InputDecoration(
                      hintText: 'Ask Eddie to create...',
                      hintStyle: EddieTextStyles.body1(context).copyWith(
                        color: EddieColors.getTextSecondary(context),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(EddieConstants.spacingMd),
                    ),
                    style: EddieTextStyles.body1(context),
                    onSubmitted: (_) => _handlePromptSubmit(),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: EddieColors.getPrimary(context),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(EddieConstants.borderRadiusMedium),
                      bottomRight: Radius.circular(EddieConstants.borderRadiusMedium),
                    ),
                  ),
                  child: IconButton(
                    icon: _isLoading
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: EddieColors.getButtonText(context),
                            ),
                          )
                        : Icon(
                            Icons.arrow_forward,
                            color: EddieColors.getButtonText(context),
                          ),
                    onPressed: _isLoading ? null : _handlePromptSubmit,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: EddieConstants.spacingLg),
          
          // Quick Actions
          Wrap(
            spacing: EddieConstants.spacingSm,
            runSpacing: EddieConstants.spacingSm,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickActionButton(
                context,
                'Clone a Design',
                Icons.copy_outlined,
              ),
              _buildQuickActionButton(
                context,
                'Import from Figma',
                Icons.upload_file_outlined,
              ),
              _buildQuickActionButton(
                context,
                'Landing Page',
                Icons.web_outlined,
              ),
              _buildQuickActionButton(
                context,
                'Sign Up Form',
                Icons.person_add_outlined,
              ),
              _buildQuickActionButton(
                context,
                'Dashboard',
                Icons.dashboard_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommunitySection(BuildContext context, bool isSmallScreen) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'From the Community',
                style: EddieTextStyles.heading2(context),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: Text(
                  'View All',
                  style: EddieTextStyles.link(context),
                ),
                label: Icon(
                  Icons.arrow_forward,
                  size: 16,
                  color: EddieColors.getPrimary(context),
                ),
              ),
            ],
          ),
          SizedBox(height: EddieConstants.spacingMd),
          
          // Project Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isSmallScreen ? 1 : MediaQuery.of(context).size.width < 900 ? 2 : 3,
              crossAxisSpacing: EddieConstants.spacingMd,
              mainAxisSpacing: EddieConstants.spacingMd,
              childAspectRatio: 1.2,
            ),
            itemCount: 6,
            itemBuilder: (context, index) {
              return _buildProjectCard(context, index);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context, bool isSmallScreen) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 1200),
      child: Column(
        children: [
          Text(
            'Features',
            style: EddieTextStyles.heading2(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: EddieConstants.spacingLg),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: isSmallScreen ? 1 : 3,
            crossAxisSpacing: EddieConstants.spacingLg,
            mainAxisSpacing: EddieConstants.spacingLg,
            children: [
              _buildFeatureCard(
                context,
                'Design System',
                'Consistent components and styles for your applications',
                Icons.web_outlined,
              ),
              _buildFeatureCard(
                context,
                'Cross-Platform',
                'Works seamlessly on web, mobile, and desktop',
                Icons.devices_outlined,
              ),
              _buildFeatureCard(
                context,
                'AI-Powered',
                'Generate UI components and layouts with AI assistance',
                Icons.auto_awesome_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.all(EddieConstants.spacingLg),
      decoration: BoxDecoration(
        color: EddieColors.getSurface(context),
        border: Border(
          top: BorderSide(
            color: EddieColors.getOutline(context),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: EddieColors.getPrimary(context),
                  borderRadius: BorderRadius.circular(EddieConstants.borderRadiusSmall),
                ),
                child: Center(
                  child: Text(
                    'E',
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getButtonText(context),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: EddieConstants.spacingXs),
              Text(
                'eddie',
                style: EddieTextStyles.medium(context),
              ),
            ],
          ),
          if (!isSmallScreen)
            Row(
              children: [
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'About',
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Documentation',
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'Blog',
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: Text(
                    'GitHub',
                    style: EddieTextStyles.body2(context).copyWith(
                      color: EddieColors.getTextSecondary(context),
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(
        icon,
        size: 16,
        color: EddieColors.getTextPrimary(context),
      ),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(
          horizontal: EddieConstants.spacingMd,
          vertical: EddieConstants.spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
        ),
        side: BorderSide(
          color: EddieColors.getOutline(context),
        ),
        backgroundColor: EddieColors.getSurfaceVariant(context),
      ),
    );
  }

  Widget _buildProjectCard(BuildContext context, int index) {
    final projectTitles = [
      'Analytics Dashboard',
      'E-commerce Product Page',
      'Mobile App UI Kit',
      'Financial Dashboard',
      'Login Form',
      'Settings Panel',
    ];
    
    final authors = [
      'Sarah',
      'Michael',
      'Jessica',
      'David',
      'Alex',
      'Emma',
    ];
    
    final forks = [
      '1.8k',
      '1.2k',
      '2.5k',
      '4.3k',
      '2.7k',
      '1.9k',
    ];
    
    return Container(
      decoration: BoxDecoration(
        color: EddieColors.getSurface(context),
        borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
        border: Border.all(
          color: EddieColors.getOutline(context),
        ),
        boxShadow: EddieConstants.getShadowSmall(context),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Project Image
          Expanded(
            child: Container(
              width: double.infinity,
              color: EddieColors.getSurfaceVariant(context),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: EddieColors.getTextSecondary(context),
                ),
              ),
            ),
          ),
          
          // Project Info
          Padding(
            padding: EdgeInsets.all(EddieConstants.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: EddieColors.getSurfaceVariant(context),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          authors[index][0],
                          style: EddieTextStyles.caption(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: EddieConstants.spacingSm),
                    Text(
                      projectTitles[index],
                      style: EddieTextStyles.medium(context),
                    ),
                  ],
                ),
                SizedBox(height: EddieConstants.spacingXs),
                Row(
                  children: [
                    Icon(
                      Icons.copy_outlined,
                      size: 14,
                      color: EddieColors.getTextSecondary(context),
                    ),
                    SizedBox(width: EddieConstants.spacingXxs),
                    Text(
                      '${forks[index]} Forks',
                      style: EddieTextStyles.caption(context).copyWith(
                        color: EddieColors.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String description, IconData icon) {
    return Container(
      padding: EdgeInsets.all(EddieConstants.spacingLg),
      decoration: BoxDecoration(
        color: EddieColors.getSurface(context),
        borderRadius: BorderRadius.circular(EddieConstants.borderRadiusMedium),
        border: Border.all(
          color: EddieColors.getOutline(context),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: EddieColors.getPrimary(context),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: EddieColors.getButtonText(context),
            ),
          ),
          SizedBox(height: EddieConstants.spacingMd),
          Text(
            title,
            style: EddieTextStyles.heading3(context),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: EddieConstants.spacingSm),
          Text(
            description,
            style: EddieTextStyles.body2(context).copyWith(
              color: EddieColors.getTextSecondary(context),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
} 