import 'package:flutter/material.dart';

void main() => runApp(const NurtureAssistantApp());

class AppColors {
  static const cream = Color(0xFFFFF8F0);
  static const peach = Color(0xFFFFE5D4);
  static const sage = Color(0xFFDDEBDD);
  static const sky = Color(0xFFDDEBFF);
  static const lavender = Color(0xFFECE4FF);
  static const amber = Color(0xFFF7D590);
  static const coral = Color(0xFFE86F61);
  static const ink = Color(0xFF25313B);
  static const muted = Color(0xFF65717A);
  static const line = Color(0xFFEADFDA);
}

enum AuthStep { entry, signUp, login, onboarding, app }

enum AppTab { home, timeline, medicine, supplies, guide }

enum SettingsPage { settings, profile, password, subscription }

class BabyLog {
  const BabyLog(this.time, this.title, this.detail, this.icon, this.color);

  final String time;
  final String title;
  final String detail;
  final IconData icon;
  final Color color;
}

class QuickAction {
  const QuickAction(this.label, this.icon, this.color);

  final String label;
  final IconData icon;
  final Color color;
}

class NurtureAssistantApp extends StatelessWidget {
  const NurtureAssistantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nurture Assistant',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.ink),
        fontFamily: 'Arial',
      ),
      home: const AppRoot(),
    );
  }
}

class AppRoot extends StatefulWidget {
  const AppRoot({super.key});

  @override
  State<AppRoot> createState() => _AppRootState();
}

class _AppRootState extends State<AppRoot> {
  AuthStep _authStep = AuthStep.entry;
  AppTab _tab = AppTab.home;
  SettingsPage? _settingsPage;
  bool _showAiReview = false;

  void _enterApp() {
    setState(() {
      _authStep = AuthStep.app;
      _settingsPage = null;
      _showAiReview = false;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveShell(
      child: switch (_authStep) {
        AuthStep.entry => AccountEntryScreen(
          onCreate: () => setState(() => _authStep = AuthStep.signUp),
          onLogin: () => setState(() => _authStep = AuthStep.login),
        ),
        AuthStep.signUp => SignUpScreen(
          onBack: () => setState(() => _authStep = AuthStep.entry),
          onSubmit: () => setState(() => _authStep = AuthStep.onboarding),
        ),
        AuthStep.login => LoginScreen(
          onBack: () => setState(() => _authStep = AuthStep.entry),
          onSubmit: _enterApp,
        ),
        AuthStep.onboarding => OnboardingScreen(onDone: _enterApp),
        AuthStep.app => _buildAppShell(),
      },
    );
  }

  Widget _buildAppShell() {
    if (_settingsPage != null) {
      return switch (_settingsPage!) {
        SettingsPage.settings => SettingsScreen(
          onBack: () => setState(() => _settingsPage = null),
          onProfile: () => setState(() => _settingsPage = SettingsPage.profile),
          onPassword: () =>
              setState(() => _settingsPage = SettingsPage.password),
          onSubscription: () =>
              setState(() => _settingsPage = SettingsPage.subscription),
        ),
        SettingsPage.profile => ProfileScreen(
          onBack: () => setState(() => _settingsPage = SettingsPage.settings),
          onSave: () => _showSnack('Profile saved'),
        ),
        SettingsPage.password => ChangePasswordScreen(
          onBack: () => setState(() => _settingsPage = SettingsPage.settings),
          onSave: () => _showSnack('Password updated'),
        ),
        SettingsPage.subscription => SubscriptionScreen(
          onBack: () => setState(() => _settingsPage = SettingsPage.settings),
          onSubscribe: () => _showSnack('Family plan subscription confirmed'),
        ),
      };
    }

    final child = _showAiReview
        ? AiReviewScreen(
            onBack: () => setState(() => _showAiReview = false),
            onSave: () {
              setState(() => _showAiReview = false);
              _showSnack('Feeding and medicine saved for Emma');
            },
          )
        : switch (_tab) {
            AppTab.home => HomeScreen(
              onAssistant: () => setState(() => _showAiReview = true),
              onQuickAdd: _openQuickAdd,
              onSettings: () =>
                  setState(() => _settingsPage = SettingsPage.settings),
            ),
            AppTab.timeline => const TimelineScreen(),
            AppTab.medicine => const MedicineScreen(),
            AppTab.supplies => const SuppliesScreen(),
            AppTab.guide => const GuideScreen(),
          };

    return Scaffold(
      body: SafeArea(child: child),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab.index,
        onTap: (index) => setState(() {
          _tab = AppTab.values[index];
          _showAiReview = false;
        }),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.ink,
        unselectedItemColor: AppColors.muted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_rounded),
            label: 'Timeline',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_rounded),
            label: 'Medicine',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2_rounded),
            label: 'Supplies',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_rounded),
            label: 'Guide',
          ),
        ],
      ),
    );
  }

  void _openQuickAdd(QuickAction action) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QuickAddSheet(
        action: action,
        onSave: () {
          Navigator.of(context).pop();
          _showSnack('${action.label} saved for Emma');
        },
      ),
    );
  }
}

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    // The app stays mobile-first, while desktop web gets a centered phone-width canvas.
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cream, Color(0xFFFFEFE4), AppColors.sage],
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              MediaQuery.sizeOf(context).width > 700 ? 32 : 0,
            ),
            child: Material(color: AppColors.cream, child: child),
          ),
        ),
      ),
    );
  }
}

class AccountEntryScreen extends StatelessWidget {
  const AccountEntryScreen({
    required this.onCreate,
    required this.onLogin,
    super.key,
  });

  final VoidCallback onCreate;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Welcome to Nurture Assistant',
      subtitle: 'Track baby care with your family in a few quick taps.',
      child: AppCard(
        color: AppColors.sky,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionTitle('Choose how to continue'),
            const MutedText(
              'New parents create an account. Returning caregivers log in.',
            ),
            const SizedBox(height: 16),
            PrimaryButton(label: 'Create account', onPressed: onCreate),
            const SizedBox(height: 10),
            SecondaryButton(label: 'Log in', onPressed: onLogin),
            const SizedBox(height: 14),
            const NoteBox(
              'Accepting an invite? Use the invite link so your caregiver role is applied automatically.',
            ),
          ],
        ),
      ),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({required this.onBack, required this.onSubmit, super.key});

  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FormScreen(
      title: 'Create your account',
      subtitle:
          'Set up your secure parent account, then add your baby profile.',
      onBack: onBack,
      buttonLabel: 'Create account',
      onSubmit: onSubmit,
      footer: SecondaryButton(
        label: 'I already have an account',
        onPressed: onBack,
      ),
      fields: const [
        AppField(label: 'Full name', value: 'Maya Chen'),
        AppField(label: 'Email', value: 'maya@example.com'),
        AppField(label: 'Password', value: '••••••••••'),
        AppField(label: 'Confirm password', value: '••••••••••'),
        CheckLine('I agree to the terms and privacy policy.'),
      ],
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({required this.onBack, required this.onSubmit, super.key});

  final VoidCallback onBack;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return FormScreen(
      title: 'Log in',
      subtitle: 'Welcome back. Continue tracking care for your family.',
      onBack: onBack,
      buttonLabel: 'Log in',
      onSubmit: onSubmit,
      footer: SecondaryButton(label: 'Forgot password?', onPressed: () {}),
      fields: const [
        AppField(label: 'Email', value: 'maya@example.com'),
        AppField(label: 'Password', value: '••••••••••'),
      ],
    );
  }
}

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({required this.onDone, super.key});

  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Tell us about your baby',
      subtitle: 'Only the essentials first. You can add more details later.',
      children: [
        const AppCard(
          child: Column(
            children: [
              AppField(label: 'Baby name', value: 'Emma'),
              AppField(label: 'Birthday or due date', value: 'May 10, 2026'),
              AppField(label: 'Feeding preference', value: 'Formula'),
            ],
          ),
        ),
        const AppCard(
          color: AppColors.peach,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Care team'),
              MutedText(
                'Invite caregivers and allow microphone, camera, and reminders after setup.',
              ),
            ],
          ),
        ),
        PrimaryButton(label: 'Finish setup', onPressed: onDone),
      ],
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    required this.onAssistant,
    required this.onQuickAdd,
    required this.onSettings,
    super.key,
  });

  final VoidCallback onAssistant;
  final ValueChanged<QuickAction> onQuickAdd;
  final VoidCallback onSettings;

  static const actions = [
    QuickAction('Feeding', Icons.local_drink_rounded, AppColors.peach),
    QuickAction('Diaper', Icons.water_drop_rounded, AppColors.sage),
    QuickAction('Sleep', Icons.bedtime_rounded, AppColors.lavender),
    QuickAction('Medicine', Icons.medical_services_rounded, AppColors.amber),
    QuickAction('Temperature', Icons.thermostat_rounded, AppColors.sky),
    QuickAction('Note', Icons.note_alt_rounded, AppColors.peach),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Good evening, Maya',
      subtitle: 'Emma was last updated by Dad at 7:52pm.',
      trailing: IconButton.filledTonal(
        onPressed: onSettings,
        icon: const Icon(Icons.settings_rounded),
      ),
      children: [
        const BabySelector(),
        AppCard(
          color: AppColors.sky,
          onTap: onAssistant,
          child: const Row(
            children: [
              CircleIcon(Icons.mic_rounded, dark: true),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionTitle('Tell me what happened'),
                    MutedText(
                      '“Emma drank 90ml formula at 8pm and I gave 2.5ml fever medicine.”',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        QuickActionGrid(actions: actions, onTap: onQuickAdd),
        const StatusGrid(),
        const AppCard(
          color: AppColors.amber,
          child: ListTileContent(
            icon: Icons.notifications_active_rounded,
            title: 'Upcoming reminder',
            subtitle: 'Fever medicine check · 12:00am for Emma',
          ),
        ),
        const TimelinePreview(),
      ],
    );
  }
}

class AiReviewScreen extends StatefulWidget {
  const AiReviewScreen({required this.onBack, required this.onSave, super.key});

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  State<AiReviewScreen> createState() => _AiReviewScreenState();
}

class _AiReviewScreenState extends State<AiReviewScreen> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Review before saving',
      subtitle:
          'Medicine requires confirmation of child, medicine, dose, and time.',
      leading: BackButton(onPressed: widget.onBack),
      children: [
        const ReviewCard(
          title: 'Feeding',
          icon: Icons.local_drink_rounded,
          rows: {
            'Baby': 'Emma',
            'Type': 'Formula',
            'Amount': '90ml',
            'Time': '8:00pm',
          },
        ),
        const ReviewCard(
          title: 'Medicine',
          icon: Icons.medical_services_rounded,
          color: AppColors.amber,
          rows: {
            'Baby': 'Emma',
            'Name': 'Fever medicine',
            'Dose': '2.5ml',
            'Time': '8:00pm',
          },
        ),
        AppCard(
          color: AppColors.amber,
          child: CheckboxListTile(
            value: _confirmed,
            onChanged: (value) => setState(() => _confirmed = value ?? false),
            title: const Text(
              'I checked this medicine dose for Emma.',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            subtitle: const Text(
              'BabyCopilot tracks medicine but does not provide medical advice.',
            ),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),
        PrimaryButton(
          label: 'Save 2 logs',
          onPressed: _confirmed ? widget.onSave : null,
        ),
      ],
    );
  }
}

class QuickAddSheet extends StatelessWidget {
  const QuickAddSheet({required this.action, required this.onSave, super.key});

  final QuickAction action;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final isMedicine = action.label == 'Medicine';
    final amountLabel = isMedicine ? 'Dose' : 'Amount';
    final amountValue = isMedicine
        ? '2.5 ml'
        : action.label == 'Temperature'
        ? '99.1 °F'
        : '90 ml';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cream,
          borderRadius: BorderRadius.circular(28),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Log ${action.label.toLowerCase()}'),
              const SizedBox(height: 10),
              const AppField(label: 'Baby', value: 'Emma'),
              AppField(label: 'Type', value: action.label),
              if (action.label != 'Diaper' &&
                  action.label != 'Sleep' &&
                  action.label != 'Note')
                AppField(label: amountLabel, value: amountValue),
              const AppField(label: 'Time', value: 'Now'),
              const AppField(label: 'Notes', value: 'Optional'),
              if (isMedicine)
                const CheckLine(
                  'I checked the medicine, dose, time, and child.',
                ),
              if (isMedicine)
                const NoteBox(
                  'BabyCopilot tracks medicine but does not provide medical advice.',
                ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Save ${action.label.toLowerCase()}',
                onPressed: onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TimelineScreen extends StatelessWidget {
  const TimelineScreen({super.key});

  static const logs = [
    BabyLog(
      '8:00p',
      'Formula 90ml',
      'Emma · Maya · Edit · Delete',
      Icons.local_drink_rounded,
      AppColors.peach,
    ),
    BabyLog(
      '8:00p',
      'Fever medicine 2.5ml',
      'Emma · Confirmed dose · Edit · Delete',
      Icons.medical_services_rounded,
      AppColors.amber,
    ),
    BabyLog(
      '7:40p',
      'Wet diaper',
      'Emma · Dad · Edit · Delete',
      Icons.water_drop_rounded,
      AppColors.sage,
    ),
    BabyLog(
      '6:55p',
      'Nap ended',
      '45 minutes · Edit · Delete',
      Icons.bedtime_rounded,
      AppColors.lavender,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Today',
      subtitle: '4 feeds · 6 diapers · 2 naps · 1 medicine',
      children: [
        const BabySelector(),
        const Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChipView('All', selected: true),
            FilterChipView('Feeding'),
            FilterChipView('Diaper'),
            FilterChipView('Sleep'),
            FilterChipView('Medicine'),
            FilterChipView('Temp'),
            FilterChipView('Note'),
          ],
        ),
        ...logs.map((log) => LogTile(log: log)),
      ],
    );
  }
}

class MedicineScreen extends StatelessWidget {
  const MedicineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Medicine',
      subtitle: 'Safety-first tracking for active medicines and reminders.',
      children: const [
        AppCard(
          color: AppColors.amber,
          child: ListTileContent(
            icon: Icons.medical_services_rounded,
            title: 'Fever medicine',
            subtitle: 'Last: 8:00pm · Emma\nNext reminder: 12:00am',
          ),
        ),
        AppCard(
          color: Color(0xFFFFE2DC),
          child: ListTileContent(
            icon: Icons.warning_rounded,
            title: 'This dose may be too soon.',
            subtitle:
                'Fever medicine was last logged for Emma at 8:00pm. Check the label or contact a clinician before giving more.',
          ),
        ),
        AppCard(
          child: ListTileContent(
            icon: Icons.add_circle_rounded,
            title: 'Add medicine manually',
            subtitle:
                'Name, usual dose label, unit, and optional reminder interval.',
          ),
        ),
        NoteBox(
          'BabyCopilot tracks medicine but does not provide medical advice.',
        ),
      ],
    );
  }
}

class SuppliesScreen extends StatelessWidget {
  const SuppliesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Supplies',
      subtitle: 'Track essentials and know when to reorder.',
      children: const [
        SupplyCard(
          icon: Icons.inventory_2_rounded,
          name: 'Diapers',
          detail: '42 left · about 6 days · reorder at 20',
          progress: .58,
        ),
        SupplyCard(
          icon: Icons.local_drink_rounded,
          name: 'Formula',
          detail: '1.5 cans · about 5 days · buy tomorrow',
          progress: .42,
        ),
        SupplyCard(
          icon: Icons.clean_hands_rounded,
          name: 'Wipes',
          detail: '3 packs · about 18 days',
          progress: .78,
        ),
        Row(
          children: [
            Expanded(child: SecondaryButton(label: 'Add item')),
            SizedBox(width: 12),
            Expanded(child: PrimaryButton(label: 'Log purchase')),
          ],
        ),
      ],
    );
  }
}

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Guide',
      subtitle: 'Simple checklists by baby stage.',
      children: const [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChipView('Before delivery', selected: true),
            FilterChipView('0-3 months'),
            FilterChipView('3-6 months'),
            FilterChipView('6-12 months'),
          ],
        ),
        ChecklistCard(
          title: 'Hospital bag',
          items: ['ID and insurance', 'Going-home outfit', 'Phone charger'],
        ),
        ChecklistCard(
          title: 'Newborn essentials',
          items: [
            'Safe sleep space',
            'Feeding essentials',
            'Diapering essentials',
            'Medicine cabinet checklist',
          ],
        ),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    required this.onBack,
    required this.onProfile,
    required this.onPassword,
    required this.onSubscription,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onProfile;
  final VoidCallback onPassword;
  final VoidCallback onSubscription;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Family & Settings',
      subtitle:
          'Manage account, caregivers, notifications, baby profiles, and data.',
      leading: BackButton(onPressed: onBack),
      children: [
        AppCard(
          color: AppColors.peach,
          child: Column(
            children: [
              SettingsRow(
                icon: Icons.person_rounded,
                title: 'Profile',
                subtitle: 'Maya Chen · Parent',
                onTap: onProfile,
              ),
              SettingsRow(
                icon: Icons.lock_rounded,
                title: 'Change password',
                subtitle: 'Keep your account secure',
                onTap: onPassword,
              ),
              SettingsRow(
                icon: Icons.credit_card_rounded,
                title: 'Subscription and payment',
                subtitle: 'Family plan · monthly billing',
                onTap: onSubscription,
              ),
            ],
          ),
        ),
        const SettingsGroup(
          title: 'Caregivers',
          rows: ['Maya · parent', 'Taylor · grandparent', 'Add caregiver'],
        ),
        const SettingsGroup(
          title: 'Notifications',
          rows: ['Medicine reminders', 'Feeding reminders', 'Quiet hours'],
        ),
        const SettingsGroup(
          title: 'Baby profiles',
          rows: ['Emma · care preferences', 'Add another child'],
        ),
        const SettingsGroup(
          title: 'Privacy and data',
          rows: ['Export data', 'Privacy policy', 'Delete account placeholder'],
        ),
      ],
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({required this.onBack, required this.onSave, super.key});

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return FormScreen(
      title: 'Profile',
      subtitle:
          'Keep profile focused on who you are and how your care team can contact you.',
      onBack: onBack,
      buttonLabel: 'Save profile',
      onSubmit: onSave,
      footer: const NoteBox(
        'Milk and temperature units belong in baby care preferences, not personal profile.',
      ),
      fields: const [
        AppField(label: 'Name', value: 'Maya Chen'),
        AppField(label: 'Email', value: 'maya@example.com'),
        AppField(label: 'Phone optional', value: '(555) 010-2026'),
        AppField(label: 'Role', value: 'Parent'),
      ],
    );
  }
}

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({
    required this.onBack,
    required this.onSave,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return FormScreen(
      title: 'Change password',
      subtitle:
          'Update your account password without changing baby-care settings.',
      onBack: onBack,
      buttonLabel: 'Update password',
      onSubmit: onSave,
      footer: const NoteBox('Use at least 8 characters.'),
      fields: const [
        AppField(label: 'Current password', value: '••••••••••'),
        AppField(label: 'New password', value: '••••••••••••'),
        AppField(label: 'Confirm new password', value: '••••••••••••'),
      ],
    );
  }
}

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({
    required this.onBack,
    required this.onSubscribe,
    super.key,
  });

  final VoidCallback onBack;
  final VoidCallback onSubscribe;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: 'Subscription',
      subtitle:
          'Choose the right plan for your family. Basic logging stays available.',
      leading: BackButton(onPressed: onBack),
      children: [
        const AppCard(
          color: AppColors.sage,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle('Family plan'),
              MutedText(
                'Shared caregivers, reminders, supplies, and data export.',
              ),
              SizedBox(height: 8),
              Text(
                r'$8/month',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
        const Row(
          children: [
            Expanded(
              child: PlanCard(name: 'Free', price: r'$0', detail: 'Basic logs'),
            ),
            SizedBox(width: 12),
            Expanded(
              child: PlanCard(
                name: 'Premium',
                price: r'$14',
                detail: 'AI trends',
              ),
            ),
          ],
        ),
        const AppCard(
          child: Column(
            children: [
              SectionTitle('Payment'),
              AppField(label: 'Cardholder', value: 'Maya Chen'),
              AppField(label: 'Card number', value: '•••• •••• •••• 4242'),
              AppField(label: 'Expires / ZIP', value: '08/29 · 94107'),
            ],
          ),
        ),
        const NoteBox(
          r'Review: Family plan, $8/month, renews monthly. Cancel anytime from Subscription.',
        ),
        PrimaryButton(label: 'Subscribe', onPressed: onSubscribe),
      ],
    );
  }
}

class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.leading,
    this.trailing,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> children;
  final Widget? leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (leading != null) ...[leading!, const SizedBox(width: 8)],
              Expanded(
                child: HeaderText(title: title, subtitle: subtitle),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 18),
          ...children.expand((child) => [child, const SizedBox(height: 14)]),
        ],
      ),
    );
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.nightlight_round,
                size: 54,
                color: AppColors.ink,
              ),
              const SizedBox(height: 20),
              HeaderText(title: title, subtitle: subtitle),
              const SizedBox(height: 20),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class FormScreen extends StatelessWidget {
  const FormScreen({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.onBack,
    required this.buttonLabel,
    required this.onSubmit,
    this.footer,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final VoidCallback onBack;
  final String buttonLabel;
  final VoidCallback onSubmit;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      title: title,
      subtitle: subtitle,
      leading: BackButton(onPressed: onBack),
      children: [
        AppCard(
          child: Column(
            children: [
              ...fields.expand((field) => [field, const SizedBox(height: 10)]),
              PrimaryButton(label: buttonLabel, onPressed: onSubmit),
            ],
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}

class HeaderText extends StatelessWidget {
  const HeaderText({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 32,
            height: 1.05,
            fontWeight: FontWeight.w900,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 16,
            height: 1.45,
            color: AppColors.muted,
          ),
        ),
      ],
    );
  }
}

class AppCard extends StatelessWidget {
  const AppCard({
    required this.child,
    this.color = Colors.white,
    this.onTap,
    super.key,
  });

  final Widget child;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(26),
          ),
          child: child,
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w900,
        color: AppColors.ink,
      ),
    );
  }
}

class MutedText extends StatelessWidget {
  const MutedText(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(fontSize: 14, height: 1.45, color: AppColors.muted),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({required this.label, this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        backgroundColor: AppColors.ink,
        disabledBackgroundColor: AppColors.muted.withValues(alpha: .35),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({required this.label, this.onPressed, super.key});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    );
  }
}

class AppField extends StatelessWidget {
  const AppField({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            color: AppColors.muted,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          minHeight: 52,
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFAF6),
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

class CheckLine extends StatelessWidget {
  const CheckLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_box_rounded, color: AppColors.ink),
        const SizedBox(width: 10),
        Expanded(child: MutedText(text)),
      ],
    );
  }
}

class NoteBox extends StatelessWidget {
  const NoteBox(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(18),
        color: Colors.white.withValues(alpha: .65),
      ),
      child: MutedText(text),
    );
  }
}

class CircleIcon extends StatelessWidget {
  const CircleIcon(this.icon, {this.dark = false, super.key});

  final IconData icon;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 25,
      backgroundColor: dark ? AppColors.ink : AppColors.peach,
      child: Icon(icon, color: dark ? Colors.white : AppColors.ink),
    );
  }
}

class BabySelector extends StatelessWidget {
  const BabySelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: AppColors.line),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.peach,
                child: Text('E'),
              ),
              SizedBox(width: 8),
              Text('Emma', style: TextStyle(fontWeight: FontWeight.w900)),
              Icon(Icons.expand_more_rounded),
            ],
          ),
        ),
      ],
    );
  }
}

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({
    required this.actions,
    required this.onTap,
    super.key,
  });

  final List<QuickAction> actions;
  final ValueChanged<QuickAction> onTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      childAspectRatio: 1.08,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: actions
          .map(
            (action) => AppCard(
              color: Colors.white,
              onTap: () => onTap(action),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(action.icon, color: AppColors.ink),
                  const SizedBox(height: 6),
                  Text(
                    action.label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class StatusGrid extends StatelessWidget {
  const StatusGrid({super.key});

  @override
  Widget build(BuildContext context) {
    const stats = [
      ('Last fed', '8:00pm', '90ml formula'),
      ('Last diaper', '7:40pm', 'Wet'),
      ('Last sleep', '45m nap', 'Ended 6:55pm'),
      ('Last medicine', '8:00pm', '2.5ml'),
    ];
    return GridView.count(
      crossAxisCount: 2,
      childAspectRatio: 1.55,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: stats
          .map(
            (stat) => AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MutedText(stat.$1.toUpperCase()),
                  const SizedBox(height: 6),
                  SectionTitle(stat.$2),
                  MutedText(stat.$3),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class TimelinePreview extends StatelessWidget {
  const TimelinePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle('Today'),
          SizedBox(height: 10),
          ListTileContent(
            icon: Icons.local_drink_rounded,
            title: '8:00p · Formula + fever medicine',
            subtitle: 'Emma · Maya',
          ),
          ListTileContent(
            icon: Icons.water_drop_rounded,
            title: '7:40p · Wet diaper',
            subtitle: 'Emma · Dad',
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({
    required this.title,
    required this.icon,
    required this.rows,
    this.color = Colors.white,
    super.key,
  });

  final String title;
  final IconData icon;
  final Map<String, String> rows;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: color,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon),
              const SizedBox(width: 8),
              SectionTitle(title),
              const Spacer(),
              const Text('Edit', style: TextStyle(fontWeight: FontWeight.w900)),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: rows.entries
                .map(
                  (row) => SizedBox(
                    width: 135,
                    child: AppField(label: row.key, value: row.value),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class FilterChipView extends StatelessWidget {
  const FilterChipView(this.label, {this.selected = false, super.key});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: selected ? Colors.white : AppColors.muted,
        ),
      ),
      backgroundColor: selected ? AppColors.ink : Colors.white,
      side: const BorderSide(color: AppColors.line),
    );
  }
}

class LogTile extends StatelessWidget {
  const LogTile({required this.log, super.key});

  final BabyLog log;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              log.time,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                color: AppColors.muted,
              ),
            ),
          ),
          CircleIcon(log.icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [SectionTitle(log.title), MutedText(log.detail)],
            ),
          ),
        ],
      ),
    );
  }
}

class ListTileContent extends StatelessWidget {
  const ListTileContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleIcon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(title),
              const SizedBox(height: 4),
              MutedText(subtitle),
            ],
          ),
        ),
      ],
    );
  }
}

class SupplyCard extends StatelessWidget {
  const SupplyCard({
    required this.icon,
    required this.name,
    required this.detail,
    required this.progress,
    super.key,
  });

  final IconData icon;
  final String name;
  final String detail;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTileContent(icon: icon, title: name, subtitle: detail),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            borderRadius: BorderRadius.circular(999),
            color: AppColors.coral,
            backgroundColor: AppColors.line,
          ),
        ],
      ),
    );
  }
}

class ChecklistCard extends StatelessWidget {
  const ChecklistCard({required this.title, required this.items, super.key});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          const SizedBox(height: 10),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  const Icon(Icons.check_box_outline_blank_rounded),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleIcon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right_rounded),
      onTap: onTap,
    );
  }
}

class SettingsGroup extends StatelessWidget {
  const SettingsGroup({required this.title, required this.rows, super.key});

  final String title;
  final List<String> rows;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(title),
          const SizedBox(height: 8),
          ...rows.map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: MutedText(row),
            ),
          ),
        ],
      ),
    );
  }
}

class PlanCard extends StatelessWidget {
  const PlanCard({
    required this.name,
    required this.price,
    required this.detail,
    super.key,
  });

  final String name;
  final String price;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MutedText(name.toUpperCase()),
          SectionTitle(price),
          MutedText(detail),
        ],
      ),
    );
  }
}
