import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header Section
            _buildProfileHeader(context, isMobile),
            const SizedBox(height: 24),
            
            // Stats Cards
            if (!isMobile) _buildDesktopStatsRow(),
            if (isMobile) _buildMobileStatsColumn(),
            const SizedBox(height: 24),
            
            // Content Tabs
            _buildTabSection(context),
            const SizedBox(height: 24),
            
            // Main Content Area
            _buildContentSection(context, isMobile),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isMobile) {
    final theme = Theme.of(context);
    
    return isMobile 
        ? _buildMobileProfileHeader(theme)
        : _buildDesktopProfileHeader(theme);
  }

  Widget _buildDesktopProfileHeader(ThemeData theme) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile Picture
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: theme.colorScheme.primary.withOpacity(0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              )
            ],
          ),
          child: ClipOval(
            child: Image.network(
              'https://randomuser.me/api/portraits/women/68.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Icon(
                Icons.person,
                size: 60,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 24),
        
        // Profile Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Dr. Sarah Johnson',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      'Verified',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Cardiologist | Massachusetts General Hospital',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Harvard Medical School graduate with 12 years of experience in interventional cardiology and heart failure management.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildInfoChip(Iconsax.briefcase, '15 Years Exp'),
                  _buildInfoChip(Iconsax.award, 'Board Certified'),
                  _buildInfoChip(Iconsax.location, 'Boston, MA'),
                ],
              ),
            ],
          ),
        ),
        
        // Action Buttons
        Column(
          children: [
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.edit, size: 18),
              label: const Text('Edit Profile'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Iconsax.share, size: 18),
              label: const Text('Share Profile'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMobileProfileHeader(ThemeData theme) {
    return Column(
      children: [
        // Profile Picture
        Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: theme.colorScheme.primary.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ],
            ),
            child: ClipOval(
              child: Image.network(
                'https://randomuser.me/api/portraits/women/68.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.person,
                  size: 50,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Profile Info
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Dr. Sarah Johnson',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Verified',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Cardiologist | Massachusetts General Hospital',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'Harvard Medical School graduate with 12 years of experience in interventional cardiology and heart failure management.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                _buildInfoChip(Iconsax.briefcase, '15 Years Exp'),
                _buildInfoChip(Iconsax.award, 'Board Certified'),
                _buildInfoChip(Iconsax.location, 'Boston, MA'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.edit, size: 16),
                  label: const Text('Edit'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Iconsax.share, size: 16),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildDesktopStatsRow() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Completed Projects', '1,248', Iconsax.health)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Reviews', '4.9/5.0', Iconsax.star)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Years Experience', '15', Iconsax.calendar)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Publications', '42', Iconsax.document)),
      ],
    );
  }

  Widget _buildMobileStatsColumn() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Cases', '1,248', Iconsax.health)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Reviews', '4.9/5', Iconsax.star)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildStatCard('Experience', '15', Iconsax.calendar)),
            const SizedBox(width: 16),
            Expanded(child: _buildStatCard('Publications', '42', Iconsax.document)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _buildTabButton(context, 'Activity', true),
          _buildTabButton(context, 'Schedule', false),
          _buildTabButton(context, 'Documents', false),
          _buildTabButton(context, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildTabButton(BuildContext context, String text, bool isActive) {
    final theme = Theme.of(context);
    
    return Expanded(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          backgroundColor: isActive 
              ? theme.colorScheme.primary.withOpacity(0.05)
              : Colors.transparent,
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: isActive 
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context, bool isMobile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildActivityItem(
                  Iconsax.calendar_tick,
                  'Appointment with Michael B.',
                  'Today, 10:30 AM',
                  Colors.green,
                ),
                const Divider(height: 32),
                _buildActivityItem(
                  Iconsax.document_text,
                  'Uploaded patient report',
                  'Yesterday, 3:45 PM',
                  Colors.blue,
                ),
                const Divider(height: 32),
                _buildActivityItem(
                  Iconsax.message,
                  'New message from Sarah W.',
                  'Yesterday, 11:20 AM',
                  Colors.purple,
                ),
                const Divider(height: 32),
                _buildActivityItem(
                  Iconsax.health,
                  'Completed case review',
                  'Monday, 4:30 PM',
                  Colors.orange,
                ),
              ],
            ),
          ),
        ),
        if (!isMobile) ...[
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildCalendarSection(),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 1,
                child: _buildQuickActionsSection(),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildActivityItem(IconData icon, String title, String time, Color color) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Iconsax.more, size: 20),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCalendarSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Upcoming Schedule',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 300,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.withOpacity(0.05),
              ),
              child: const Center(
                child: Text(
                  'Calendar View Placeholder',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            _buildQuickActionButton(Iconsax.note, 'New Note'),
            const SizedBox(height: 12),
            _buildQuickActionButton(Iconsax.calendar_add, 'Add Appointment'),
            const SizedBox(height: 12),
            _buildQuickActionButton(Iconsax.document_upload, 'Upload File'),
            const SizedBox(height: 12),
            _buildQuickActionButton(Iconsax.message, 'Send Message'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(IconData icon, String text) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 18),
      ),
      label: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(text),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.centerLeft,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}