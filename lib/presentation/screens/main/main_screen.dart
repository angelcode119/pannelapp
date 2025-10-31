import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/device_provider.dart';
import '../../widgets/common/stats_card.dart';
import '../../../data/models/stats.dart';
import '../../widgets/common/device_card.dart';
import '../../widgets/common/empty_state.dart';
import '../auth/login_screen.dart';
import '../devices/device_detail_screen.dart';
import '../devices/pending_device_screen.dart';
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../admins/admin_list_screen.dart';
import '../admins/admin_activities_screen.dart';
import '../../widgets/dialogs/note_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late AnimationController _navAnimController;
  late Animation<double> _navAnimation;

  @override
  void initState() {
    super.initState();
    _navAnimController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _navAnimation = CurvedAnimation(
      parent: _navAnimController,
      curve: Curves.easeInOutCubic,
    );
    _navAnimController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeviceProvider>().fetchDevices();
    });
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final admin = authProvider.admin;
    final isWide = MediaQuery.of(context).size.width > 768;

    final List<Widget> pages = [
      _DevicesPage(),
      const ProfileScreen(),
      const SettingsScreen(),
      if (admin?.isSuperAdmin == true) const AdminListScreen(),
      if (admin?.isSuperAdmin == true) const AdminActivitiesScreen(),
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: Theme.of(context).brightness == Brightness.dark
                      ? [const Color(0xFF0B0F19), const Color(0xFF1A1F2E)]
                      : [const Color(0xFFF8FAFC), const Color(0xFFEFF6FF)],
                ),
              ),
            ),
          ),
          Row(
            children: [
              if (isWide)
                FadeTransition(
                  opacity: _navAnimation,
                  child: _buildSideNav(context, admin),
                ),
              Expanded(
                child: FadeTransition(
                  opacity: _navAnimation,
                  child: pages[_selectedIndex],
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: isWide ? null : _buildBottomNav(context, admin),
    );
  }

  Widget _buildSideNav(BuildContext context, admin) {
    return Container(
      width: 208,
      margin: const EdgeInsets.all(9.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.8),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(9.6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    ),
                    borderRadius: BorderRadius.circular(10.24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    size: 25.6,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Admin Panel',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 0.8,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(9.6),
              children: [
                _NavItem(
                  icon: Icons.devices_rounded,
                  label: 'Devices',
                  index: 0,
                  selectedIndex: _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = 0),
                ),
                const SizedBox(height: 6),
                _NavItem(
                  icon: Icons.person_rounded,
                  label: 'Profile',
                  index: 1,
                  selectedIndex: _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = 1),
                ),
                const SizedBox(height: 6),
                _NavItem(
                  icon: Icons.settings_rounded,
                  label: 'Settings',
                  index: 2,
                  selectedIndex: _selectedIndex,
                  onTap: () => setState(() => _selectedIndex = 2),
                ),
                if (admin?.isSuperAdmin == true) ...[
                  const SizedBox(height: 6),
                  _NavItem(
                    icon: Icons.shield_rounded,
                    label: 'Admins',
                    index: 3,
                    selectedIndex: _selectedIndex,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                  const SizedBox(height: 6),
                  _NavItem(
                    icon: Icons.history_rounded,
                    label: 'Activities',
                    index: 4,
                    selectedIndex: _selectedIndex,
                    onTap: () => setState(() => _selectedIndex = 4),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(9.6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showLogoutDialog(context, context.read<AuthProvider>()),
                borderRadius: BorderRadius.circular(7.68),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 9.6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.68),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.red[400], size: 14.4),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          color: Colors.red[400],
                          fontWeight: FontWeight.w600,
                          fontSize: 11.2,
                        ),
                      ),
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

  Widget _buildBottomNav(BuildContext context, admin) {
    return Container(
      margin: const EdgeInsets.all(9.6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.8),
        color: Theme.of(context).colorScheme.surface,
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.05)
              : Colors.black.withOpacity(0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.8),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).textTheme.bodySmall?.color,
          selectedFontSize: 11,
          unselectedFontSize: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.devices_outlined),
              activeIcon: Icon(Icons.devices_rounded),
              label: 'Devices',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded),
              label: 'Settings',
            ),
            if (admin?.isSuperAdmin == true) ...[
              const BottomNavigationBarItem(
                icon: Icon(Icons.shield_outlined),
                activeIcon: Icon(Icons.shield_rounded),
                label: 'Admins',
              ),
              const BottomNavigationBarItem(
                icon: Icon(Icons.history_outlined),
                activeIcon: Icon(Icons.history_rounded),
                label: 'Logs',
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.8)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6.4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.4),
              ),
              child: const Icon(Icons.logout_rounded, color: Colors.red, size: 16),
            ),
            const SizedBox(width: 12),
            const Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (ctx) => const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
              try {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pop(context);
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('error in log out'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int selectedIndex;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = index == selectedIndex;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(7.68),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9.6, horizontal: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)])
                : null,
            borderRadius: BorderRadius.circular(7.68),
          ),
          child: Row(
            children: [
              Icon(icon, color: isSelected ? Colors.white : null, size: 16),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  fontSize: 11.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ?? ???? ???? ?????????
class _DevicesPage extends StatefulWidget {
  @override
  State<_DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<_DevicesPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _devicePingingStatus = {};
  final Map<String, String?> _devicePingResults = {};
  final Map<String, bool> _deviceNotingStatus = {};
  final Map<String, String?> _deviceNoteResults = {};

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handlePingDevice(String deviceId) async {
    if (_devicePingingStatus[deviceId] == true) return;

    setState(() {
      _devicePingingStatus[deviceId] = true;
      _devicePingResults[deviceId] = null;
    });

    final deviceProvider = context.read<DeviceProvider>();

    try {
      final success = await deviceProvider.sendCommand(
        deviceId,
        'ping',
        parameters: {'type': 'firebase'},
      );

      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _devicePingResults[deviceId] = success ? 'success' : 'error';
          _devicePingingStatus[deviceId] = false;
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _devicePingResults.remove(deviceId));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _devicePingResults[deviceId] = 'error';
          _devicePingingStatus[deviceId] = false;
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _devicePingResults.remove(deviceId));
          }
        });
      }
    }
  }

  Future<void> _handleNoteDevice(String deviceId) async {
    final deviceProvider = context.read<DeviceProvider>();

    // ???? ???? ?????? ????
    final device = deviceProvider.devices.firstWhere((d) => d.deviceId == deviceId);

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (dialogContext) => NoteDialog(
        initialMessage: device.noteMessage,
        initialPriority: device.notePriority,
      ),
    );

    if (result == null) return;

    setState(() {
      _deviceNotingStatus[deviceId] = true;
      _deviceNoteResults[deviceId] = null;
    });

    bool success = false; // ?? ????? ????? ??

    try {
      success = await deviceProvider.sendCommand(
        deviceId,
        'note',
        parameters: {
          'priority': result['priority']!,
          'message': result['message']!,
        },
      );

      if (mounted) {
        setState(() {
          _deviceNoteResults[deviceId] = success ? 'success' : 'error';
          _deviceNotingStatus[deviceId] = false;
        });

        // ?? ???? success ????? ???
        if (success) {
          await deviceProvider.refreshSingleDevice(deviceId);
        }

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _deviceNoteResults.remove(deviceId));
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _deviceNoteResults[deviceId] = 'error';
          _deviceNotingStatus[deviceId] = false;
        });

        Future.delayed(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() => _deviceNoteResults.remove(deviceId));
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Devices'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: deviceProvider.isLoading
                ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
              ),
            )
                : const Icon(Icons.refresh_rounded),
            onPressed: deviceProvider.isLoading ? null : () => deviceProvider.refreshDevices(),
            tooltip: 'Refresh',
          ),
          if (deviceProvider.pendingDevices > 0)
            Stack(
              clipBehavior: Clip.none,
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_rounded),
                  onPressed: () => deviceProvider.setStatusFilter(StatusFilter.pending),
                ),
                Positioned(
                  right: 6.4,
                  top: 6.4,
                  child: Container(
                    padding: const EdgeInsets.all(3.2),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${deviceProvider.pendingDevices}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 7.2,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => deviceProvider.refreshDevices(),
        child: CustomScrollView(
          slivers: [
            // ?? ???? ???
            if (!deviceProvider.isLoading)
              SliverToBoxAdapter(
                child: StatsRow(
                  totalDevices: deviceProvider.stats?.totalDevices ?? deviceProvider.totalDevicesCount,
                  activeDevices: deviceProvider.stats?.activeDevices ?? 0,
                  pendingDevices: deviceProvider.stats?.pendingDevices ?? 0,
                  onlineDevices: deviceProvider.stats?.onlineDevices ?? 0,
                  onStatTap: (filter) {
                    switch (filter) {
                      case 'active':
                        deviceProvider.setStatusFilter(StatusFilter.active);
                        break;
                      case 'pending':
                        deviceProvider.setStatusFilter(StatusFilter.pending);
                        break;
                      case 'online':
                        deviceProvider.setConnectionFilter(ConnectionFilter.online);
                        break;
                    }
                  },
                ),
              ),

            // ?? ???????? ?????? ? ???????
            if (deviceProvider.totalDevices > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
                  child: Column(
                    children: [
                      // Header ?? ????? ?????
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6366F1).withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(Icons.filter_list_rounded, size: 16, color: Colors.white),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Quick Filters',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                          ),
                          // ?????? ????? ???????? ????
                          if (deviceProvider.statusFilter != null ||
                              deviceProvider.connectionFilter != null ||
                              deviceProvider.upiFilter != null ||
                              deviceProvider.notePriorityFilter != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle, size: 12, color: Colors.red[400]),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${[
                                      deviceProvider.statusFilter,
                                      deviceProvider.connectionFilter,
                                      deviceProvider.upiFilter,
                                      deviceProvider.notePriorityFilter
                                    ].where((f) => f != null).length} active',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(width: 8),
                          // ???? Clear
                          if (deviceProvider.statusFilter != null ||
                              deviceProvider.connectionFilter != null ||
                              deviceProvider.upiFilter != null ||
                              deviceProvider.notePriorityFilter != null)
                            Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => deviceProvider.clearAllFilters(),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                                  ),
                                  child: Icon(Icons.clear_rounded, size: 16, color: Colors.red[400]),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // ??????? ?? ?? ?? ????
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            // Status Filters
                            _CompactFilterGroup(
                              icon: Icons.check_circle_outline,
                              filters: [
                                _CompactFilterData(
                                  label: 'Active',
                                  count: deviceProvider.activeDevices,
                                  isSelected: deviceProvider.statusFilter == StatusFilter.active,
                                  onTap: () => deviceProvider.setStatusFilter(StatusFilter.active),
                                  color: const Color(0xFF10B981),
                                ),
                                _CompactFilterData(
                                  label: 'Pending',
                                  count: deviceProvider.pendingDevices,
                                  isSelected: deviceProvider.statusFilter == StatusFilter.pending,
                                  onTap: () => deviceProvider.setStatusFilter(StatusFilter.pending),
                                  color: const Color(0xFFF59E0B),
                                ),
                              ],
                            ),

                            // Divider
                            Container(
                              width: 1,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context).dividerColor,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Connection Filters
                            _CompactFilterGroup(
                              icon: Icons.wifi,
                              filters: [
                                _CompactFilterData(
                                  label: 'Online',
                                  count: deviceProvider.onlineDevices,
                                  isSelected: deviceProvider.connectionFilter == ConnectionFilter.online,
                                  onTap: () => deviceProvider.setConnectionFilter(ConnectionFilter.online),
                                  color: const Color(0xFF14B8A6),
                                ),
                                _CompactFilterData(
                                  label: 'Offline',
                                  count: deviceProvider.offlineDevices,
                                  isSelected: deviceProvider.connectionFilter == ConnectionFilter.offline,
                                  onTap: () => deviceProvider.setConnectionFilter(ConnectionFilter.offline),
                                  color: const Color(0xFFEF4444),
                                ),
                              ],
                            ),

                            // Divider
                            Container(
                              width: 1,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context).dividerColor,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // UPI Filters
                            _CompactFilterGroup(
                              icon: Icons.payment,
                              filters: [
                                _CompactFilterData(
                                  label: 'With UPI',
                                  count: deviceProvider.devicesWithUpi,
                                  isSelected: deviceProvider.upiFilter == UpiFilter.withUpi,
                                  onTap: () => deviceProvider.setUpiFilter(UpiFilter.withUpi),
                                  color: const Color(0xFF8B5CF6),
                                ),
                                _CompactFilterData(
                                  label: 'No UPI',
                                  count: deviceProvider.devicesWithoutUpi,
                                  isSelected: deviceProvider.upiFilter == UpiFilter.withoutUpi,
                                  onTap: () => deviceProvider.setUpiFilter(UpiFilter.withoutUpi),
                                  color: const Color(0xFF6B7280),
                                ),
                              ],
                            ),

                            // Divider
                            Container(
                              width: 1,
                              height: 40,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.transparent,
                                    Theme.of(context).dividerColor,
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),

                            // Note Priority Filters ??
                            _CompactFilterGroup(
                              icon: Icons.label_important_rounded,
                              filters: [
                                _CompactFilterData(
                                  label: 'Low Balance',
                                  count: deviceProvider.devicesLowBalance,
                                  isSelected: deviceProvider.notePriorityFilter == NotePriorityFilter.lowBalance,
                                  onTap: () => deviceProvider.setNotePriorityFilter(NotePriorityFilter.lowBalance),
                                  color: const Color(0xFFF59E0B),
                                ),
                                _CompactFilterData(
                                  label: 'High Balance',
                                  count: deviceProvider.devicesHighBalance,
                                  isSelected: deviceProvider.notePriorityFilter == NotePriorityFilter.highBalance,
                                  onTap: () => deviceProvider.setNotePriorityFilter(NotePriorityFilter.highBalance),
                                  color: const Color(0xFF10B981),
                                ),
                                _CompactFilterData(
                                  label: 'No Priority',
                                  count: deviceProvider.devicesNoPriority,
                                  isSelected: deviceProvider.notePriorityFilter == NotePriorityFilter.none,
                                  onTap: () => deviceProvider.setNotePriorityFilter(NotePriorityFilter.none),
                                  color: const Color(0xFF6B7280),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Page Size
            if (deviceProvider.totalDevices > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.view_list, size: 14, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 4),
                            Text(
                              'Per Page',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _PageSizeChip(label: '25', selected: deviceProvider.pageSize == 25, onTap: () => deviceProvider.setPageSize(25)),
                              const SizedBox(width: 4),
                              _PageSizeChip(label: '50', selected: deviceProvider.pageSize == 50, onTap: () => deviceProvider.setPageSize(50)),
                              const SizedBox(width: 4),
                              _PageSizeChip(label: '100', selected: deviceProvider.pageSize == 100, onTap: () => deviceProvider.setPageSize(100)),
                              const SizedBox(width: 4),
                              _PageSizeChip(label: '200', selected: deviceProvider.pageSize == 200, onTap: () => deviceProvider.setPageSize(200)),
                              const SizedBox(width: 4),
                              _PageSizeChip(label: '500', selected: deviceProvider.pageSize == 500, onTap: () => deviceProvider.setPageSize(500)),
                              const SizedBox(width: 4),
                              _PageSizeChip(label: '1000', selected: deviceProvider.pageSize == 1000, onTap: () => deviceProvider.setPageSize(1000)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Page Info
            if (deviceProvider.devices.isNotEmpty && !deviceProvider.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF14B8A6).withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 16, color: Color(0xFF14B8A6)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Showing ${deviceProvider.devices.length} devices (${deviceProvider.devices.where((d) => d.isActive).length} active, ${deviceProvider.devices.where((d) => d.isOnline).length} online)',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xFF14B8A6)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Search
            if (deviceProvider.totalDevicesCount > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(9.6, 0, 9.6, 12),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search devices...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 16),
                      suffixIcon: deviceProvider.searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 16),
                        onPressed: () {
                          _searchController.clear();
                          deviceProvider.clearSearch();
                        },
                      )
                          : null,
                    ),
                    onChanged: (value) => deviceProvider.setSearchQuery(value),
                  ),
                ),
              ),

            // Device List
            if (deviceProvider.isLoading)
              const SliverFillRemaining(child: Center(child: CircularProgressIndicator()))
            else if (deviceProvider.errorMessage != null && deviceProvider.devices.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.error_outline_rounded,
                  title: 'Error',
                  subtitle: deviceProvider.errorMessage,
                  actionText: 'Retry',
                  onAction: () => deviceProvider.fetchDevices(),
                ),
              )
            else if (deviceProvider.devices.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: deviceProvider.searchQuery.isNotEmpty ? Icons.search_off_rounded : Icons.devices_other_rounded,
                    title: deviceProvider.searchQuery.isNotEmpty ? 'No Results' : 'No Devices',
                    subtitle: deviceProvider.searchQuery.isNotEmpty ? 'Try different search or filters' : 'Devices will appear here',
                    actionText: deviceProvider.searchQuery.isNotEmpty ? 'Clear' : 'Refresh',
                    onAction: deviceProvider.searchQuery.isNotEmpty
                        ? () {
                      _searchController.clear();
                      deviceProvider.clearSearch();
                    }
                        : () => deviceProvider.refreshDevices(),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final device = deviceProvider.devices[index];
                        final isPinging = _devicePingingStatus[device.deviceId] ?? false;
                        final pingResult = _devicePingResults[device.deviceId];
                        final isNoting = _deviceNotingStatus[device.deviceId] ?? false;
                        final noteResult = _deviceNoteResults[device.deviceId];

                        return Column(
                          children: [
                            DeviceCard(
                              device: device,
                              onTap: () {
                                if (device.isActive) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DeviceDetailScreen(device: device),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => PendingDeviceScreen(device: device),
                                    ),
                                  );
                                }
                              },
                              onPing: device.isActive ? () => _handlePingDevice(device.deviceId) : null,
                              isPinging: isPinging,
                              onNote: device.isActive ? () => _handleNoteDevice(device.deviceId) : null,
                              isNoting: isNoting,
                            ),
                            if (pingResult != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: pingResult == 'success'
                                        ? const Color(0xFF10B981).withOpacity(0.15)
                                        : const Color(0xFFEF4444).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: pingResult == 'success' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        pingResult == 'success' ? Icons.check_circle_rounded : Icons.error_rounded,
                                        color: pingResult == 'success' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          pingResult == 'success' ? 'Ping successful!' : 'Failed to ping device',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: pingResult == 'success' ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            if (noteResult != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12, left: 12, right: 12),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: noteResult == 'success'
                                        ? const Color(0xFF8B5CF6).withOpacity(0.15)
                                        : const Color(0xFFEF4444).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: noteResult == 'success' ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        noteResult == 'success' ? Icons.check_circle_rounded : Icons.error_rounded,
                                        color: noteResult == 'success' ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          noteResult == 'success' ? 'Note sent successfully!' : 'Failed to send note',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: noteResult == 'success' ? const Color(0xFF8B5CF6) : const Color(0xFFEF4444),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                      childCount: deviceProvider.devices.length,
                    ),
                  ),
                ),
          ],
        ),
      ),
      floatingActionButton: deviceProvider.totalDevicesCount > deviceProvider.pageSize
          ? _FloatingPagination(deviceProvider: deviceProvider)
          : null,
    );
  }
}

// ?? Compact Filter Group Widget
class _CompactFilterGroup extends StatelessWidget {
  final IconData icon;
  final List<_CompactFilterData> filters;

  const _CompactFilterGroup({
    required this.icon,
    required this.filters,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withOpacity(0.08)
              : Colors.black.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 14, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(width: 6),
          ...filters.map((filter) {
            return Padding(
              padding: const EdgeInsets.only(right: 4),
              child: _CompactFilterChip(
                label: filter.label,
                count: filter.count,
                selected: filter.isSelected,
                onTap: filter.onTap,
                color: filter.color,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

// ?? Compact Filter Data
class _CompactFilterData {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  _CompactFilterData({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });
}

// ?? Compact Filter Chip
class _CompactFilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _CompactFilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            gradient: selected
                ? LinearGradient(
              colors: [color, color.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: !selected
                ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.04)
                : Colors.black.withOpacity(0.02))
                : null,
            border: Border.all(
              color: selected ? color.withOpacity(0.5) : Colors.transparent,
              width: 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withOpacity(0.25)
                      : color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ?? Page Size Chip Widget
class _PageSizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PageSizeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected
                ? const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
                : null,
            color: !selected
                ? (Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.06)
                : Colors.black.withOpacity(0.04))
                : null,
            border: Border.all(
              color: selected ? const Color(0xFF6366F1) : Colors.transparent,
              width: selected ? 1.5 : 1,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              color: selected
                  ? Colors.white
                  : Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }
}



// ?? Floating Pagination Widget
class _FloatingPagination extends StatelessWidget {
  final DeviceProvider deviceProvider;

  const _FloatingPagination({required this.deviceProvider});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 80, right: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.5),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: deviceProvider.hasPreviousPage && !deviceProvider.isLoading
                ? () => deviceProvider.goToPreviousPage()
                : null,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: deviceProvider.hasPreviousPage && !deviceProvider.isLoading
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              size: 28,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${deviceProvider.currentPage} / ${deviceProvider.totalPages}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            onPressed: deviceProvider.hasNextPage && !deviceProvider.isLoading
                ? () => deviceProvider.goToNextPage()
                : null,
            icon: Icon(
                Icons.chevron_right_rounded,
                color: deviceProvider.hasNextPage && !deviceProvider.isLoading
                    ? Colors.white
                    : Colors.white.withOpacity(0.3),
                size: 28),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}