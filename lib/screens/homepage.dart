import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:mahaweli_admin_system/components/annual_task_card.dart';
import 'package:mahaweli_admin_system/components/build_media_section_card.dart';
import 'package:mahaweli_admin_system/services/user_service.dart';
import '../classes/task.dart';
import 'package:intl/intl.dart';
import 'package:dots_indicator/dots_indicator.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Task> tasks = [
    Task(
        name: 'Annual Report',
        description: 'Complete the annual report for 2023',
        dueDate: DateTime.now().add(const Duration(days: 7)),
        priority: 'High',
        status: 'In Progress',
        imageUrl: ""),
    Task(
        name: 'Budget Planning',
        description: 'Prepare the budget for Q1 2024',
        dueDate: DateTime.now().add(const Duration(days: 14)),
        priority: 'Medium',
        status: 'Not Started',
        imageUrl: ""),
    Task(
        name: 'Team Meeting',
        description: 'Schedule a team meeting for next week',
        dueDate: DateTime.now().add(const Duration(days: 3)),
        priority: 'Low',
        status: 'Completed',
        imageUrl: ""),
  ];

  String? role = UserService.currentUserRole;

  @override
  Widget build(BuildContext context) {
    return _buildMainContent(context);
  }

  Widget _buildMainContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isEmpty = tasks.isEmpty;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildTaskCarousel(context, isEmpty),
                if (!isEmpty) ...[
                  const SizedBox(height: 16),
                  _buildCarouselIndicator(),
                ],
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 24),
                _buildMediaSection(context),
                const SizedBox(height: 24),
                _buildWelcomeSection(context),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          role!,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('MMMM d, y').format(DateTime.now()),
                style: textTheme.bodySmall?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCarousel(BuildContext context, bool isEmpty) {
    final isLargeScreen = MediaQuery.of(context).size.width > 1200;

    return SizedBox(
      height: isLargeScreen ? 350 : 250,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CarouselSlider(
            options: CarouselOptions(
              height: isLargeScreen ? 350 : 250,
              viewportFraction: isEmpty ? 1.0 : (isLargeScreen ? 0.82 : 0.88),
              enlargeCenterPage: !isEmpty,
              autoPlay: !isEmpty,
              autoPlayInterval: const Duration(seconds: 5),
              autoPlayCurve: Curves.fastEaseInToSlowEaseOut,
              enableInfiniteScroll: !isEmpty,
              aspectRatio: 16 / 9,
              pauseAutoPlayOnTouch: true,
              scrollPhysics: const BouncingScrollPhysics(),
            ),
            items: isEmpty
                ? [_buildEmptyStateCard(context)]
                : tasks.map((task) => _buildTaskCard(context, task)).toList(),
          ),
          if (isEmpty)
            Positioned.fill(
              child: AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Theme.of(context).colorScheme.surface.withOpacity(0.6),
                        Theme.of(context).colorScheme.surface.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCarouselIndicator() {
    return DotsIndicator(
      dotsCount: tasks.length,
      position: 0,
      decorator: DotsDecorator(
        color: Theme.of(context).colorScheme.surfaceVariant,
        activeColor: Theme.of(context).colorScheme.primary,
        size: const Size.square(8),
        activeSize: const Size(24, 8),
        spacing: const EdgeInsets.symmetric(horizontal: 4),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildMediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Media & Resources',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 16),
       BuildMediaSectionCard(),
      ],
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;
    final isMediumScreen = MediaQuery.of(context).size.width > 800;

    return Center(
      child: Column(
        children: [
          Text(
            'Welcome back, Administrator',
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Need assistance? Here are quick actions to get started',
            style: textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            alignment: WrapAlignment.center,
            children: [
              _buildQuickAction(context, Icons.folder_open, 'Files'),
              _buildQuickAction(context, Icons.request_page, 'Requests'),
              if (isMediumScreen)
                _buildQuickAction(context, Icons.bar_chart, 'Reports'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCard(BuildContext context, Task task) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        child: AnnualTaskCard.buildCard(task),
      ),
    );
  }

  Widget _buildEmptyStateCard(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final constraints = MediaQuery.of(context).size;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: constraints.width * 0.9,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: colorScheme.surface,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 64,
              color: colorScheme.primary.withOpacity(0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Tasks Found',
              style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600, color: colorScheme.primary),
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 24),
            FilledButton.tonal(
              onPressed: () {},
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Create New Task'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, IconData icon, String label) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              size: 24,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}