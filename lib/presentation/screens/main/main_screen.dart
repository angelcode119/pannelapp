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
import '../admins/admin_management_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // حذف شد چون باعث لود دوباره و duplicate میشه
  }

  @override
  void dispose() {
    _navAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final admin = authProvider.currentAdmin;
    final isWide = MediaQuery.of(context).size.width > 768;

    final List<Widget> pages = [
      _DevicesPage(),
      const ProfileScreen(),
      const SettingsScreen(),
      if (admin?.isSuperAdmin == true) const AdminManagementScreen(),
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
                      ? [
                    const Color(0xFF0B0F19),
                    const Color(0xFF1A1F2E),
                  ]
                      : [
                    const Color(0xFFF8FAFC),
                    const Color(0xFFEFF6FF),
                  ],
                ),
              ),
            ),
          ),

          Row(
            children: [
              if (isWide)
                FadeTransition(
                  opacity: _navAnimation,
                  child: Container(
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
                                  label: 'Management',
                                  index: 3,
                                  selectedIndex: _selectedIndex,
                                  onTap: () => setState(() => _selectedIndex = 3),
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
                              onTap: () => _showLogoutDialog(context, authProvider),
                              borderRadius: BorderRadius.circular(7.68),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 9.6),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(7.68),
                                  border: Border.all(
                                    color: Colors.red.withOpacity(0.3),
                                  ),
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
                  ),
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

      bottomNavigationBar: isWide
          ? null
          : Container(
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
              if (admin?.isSuperAdmin == true)
                const BottomNavigationBarItem(
                  icon: Icon(Icons.shield_outlined),
                  activeIcon: Icon(Icons.shield_rounded),
                  label: 'Admin',
                ),
            ],
          ),
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
                }

                if (context.mounted) {
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

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  @override
  Widget build(BuildContext context) {
    final isSelected = widget.index == widget.selectedIndex;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: BorderRadius.circular(7.68),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9.6, horizontal: 14),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
            )
                : null,
            borderRadius: BorderRadius.circular(7.68),
          ),
          child: Row(
            children: [
              Icon(
                widget.icon,
                color: isSelected ? Colors.white : null,
                size: 16,
              ),
              const SizedBox(width: 12),
              Text(
                widget.label,
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

class _DevicesPage extends StatefulWidget {
  @override
  State<_DevicesPage> createState() => _DevicesPageState();
}

class _DevicesPageState extends State<_DevicesPage> {
  final TextEditingController _searchController = TextEditingController();
  final Map<String, bool> _devicePingingStatus = {};
  final Map<String, String?> _devicePingResults = {};

  @override

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

  @override
  Widget build(BuildContext context) {
    final deviceProvider = context.watch<DeviceProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Devices'),
        automaticallyImplyLeading: false,
        actions: [
          // 🔥 دکمه Refresh
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
                  onPressed: () => deviceProvider.setFilter(DeviceFilter.pending),
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
            if (!deviceProvider.isLoading)
              SliverToBoxAdapter(
                child: StatsRow(
                  totalDevices: deviceProvider.stats?.totalDevices ?? deviceProvider.totalDevicesCount,
                  activeDevices: deviceProvider.stats?.activeDevices ?? 0,
                  pendingDevices: deviceProvider.stats?.pendingDevices ?? 0,
                  onlineDevices: deviceProvider.stats?.onlineDevices ?? 0,
                  onStatTap: (filter) {
                    switch (filter) {
                      case 'all':
                        deviceProvider.setFilter(DeviceFilter.all);
                        break;
                      case 'active':
                        deviceProvider.setFilter(DeviceFilter.active);
                        break;
                      case 'pending':
                        deviceProvider.setFilter(DeviceFilter.pending);
                        break;
                      case 'online':
                        deviceProvider.setFilter(DeviceFilter.online);
                        break;
                    }
                  },
                ),
              ),


            if (deviceProvider.totalDevices > 0)
              SliverToBoxAdapter(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All (${deviceProvider.totalDevices})',
                        selected: deviceProvider.currentFilter == DeviceFilter.all,
                        onTap: () => deviceProvider.setFilter(DeviceFilter.all),
                        color: const Color(0xFF6366F1),
                      ),
                      _FilterChip(
                        label: 'Active (${deviceProvider.activeDevices})',
                        selected: deviceProvider.currentFilter == DeviceFilter.active,
                        onTap: () => deviceProvider.setFilter(DeviceFilter.active),
                        color: const Color(0xFF10B981),
                      ),
                      _FilterChip(
                        label: 'Pending (${deviceProvider.pendingDevices})',
                        selected: deviceProvider.currentFilter == DeviceFilter.pending,
                        onTap: () => deviceProvider.setFilter(DeviceFilter.pending),
                        color: const Color(0xFFF59E0B),
                      ),
                      _FilterChip(
                        label: 'Online (${deviceProvider.onlineDevices})',
                        selected: deviceProvider.currentFilter == DeviceFilter.online,
                        onTap: () => deviceProvider.setFilter(DeviceFilter.online),
                        color: const Color(0xFF14B8A6),
                      ),
                      _FilterChip(
                        label: 'Offline (${deviceProvider.offlineDevices})',
                        selected: deviceProvider.currentFilter == DeviceFilter.offline,
                        onTap: () => deviceProvider.setFilter(DeviceFilter.offline),
                        color: const Color(0xFFEF4444),
                      ),
                    ],
                  ),
                ),
              ),


            // 🔥 Page Size Selector
            if (deviceProvider.totalDevices > 0)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      _PageSizeChip(
                        label: '25',
                        selected: deviceProvider.pageSize == 25,
                        onTap: () => deviceProvider.setPageSize(25),
                      ),
                      const SizedBox(width: 4),
                      _PageSizeChip(
                        label: '50',
                        selected: deviceProvider.pageSize == 50,
                        onTap: () => deviceProvider.setPageSize(50),
                      ),
                      const SizedBox(width: 4),
                      _PageSizeChip(
                        label: '100',
                        selected: deviceProvider.pageSize == 100,
                        onTap: () => deviceProvider.setPageSize(100),
                      ),
                      const SizedBox(width: 4),
                      _PageSizeChip(
                        label: '200',
                        selected: deviceProvider.pageSize == 200,
                        onTap: () => deviceProvider.setPageSize(200),
                      ),
                      const SizedBox(width: 4),
                      _PageSizeChip(
                        label: '500',
                        selected: deviceProvider.pageSize == 500,
                        onTap: () => deviceProvider.setPageSize(500),
                      ),
                      const SizedBox(width: 4),
                      _PageSizeChip(
                        label: '1000',
                        selected: deviceProvider.pageSize == 1000,
                        onTap: () => deviceProvider.setPageSize(1000),
                      ),
                    ],
                  ),
                ),
              ),
            // 📊 اطلاعات صفحه فعلی
            if (deviceProvider.devices.isNotEmpty && !deviceProvider.isLoading)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14B8A6).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF14B8A6).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: const Color(0xFF14B8A6),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Current page: ${deviceProvider.devices.length} devices shown (${deviceProvider.devices.where((d) => d.isActive).length} active, ${deviceProvider.devices.where((d) => d.isPending).length} pending, ${deviceProvider.devices.where((d) => d.isOnline).length} online)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF14B8A6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Search Box
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

            if (deviceProvider.isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
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
                    icon: deviceProvider.searchQuery.isNotEmpty
                        ? Icons.search_off_rounded
                        : Icons.devices_other_rounded,
                    title: deviceProvider.searchQuery.isNotEmpty
                        ? 'No Results'
                        : 'No Devices',
                    subtitle: deviceProvider.searchQuery.isNotEmpty
                        ? 'Try a different search'
                        : 'Devices will appear here',
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
                              onPing: device.isActive
                                  ? () => _handlePingDevice(device.deviceId)
                                  : null,
                              isPinging: isPinging,
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
                                      color: pingResult == 'success'
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFEF4444),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        pingResult == 'success'
                                            ? Icons.check_circle_rounded
                                            : Icons.error_rounded,
                                        color: pingResult == 'success'
                                            ? const Color(0xFF10B981)
                                            : const Color(0xFFEF4444),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          pingResult == 'success'
                                              ? 'Ping successful! Refreshing data...'
                                              : 'Failed to ping device',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: pingResult == 'success'
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFEF4444),
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
      // 🔥 Floating Pagination
      floatingActionButton: deviceProvider.totalDevicesCount > deviceProvider.pageSize
          ? _FloatingPagination(deviceProvider: deviceProvider)
          : null,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6.4),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6.4),
              color: selected
                  ? color.withOpacity(0.15)
                  : Theme.of(context).brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.black.withOpacity(0.05),
              border: Border.all(
                color: selected ? color : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Icon(Icons.check_rounded, size: 14, color: color),
                  ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected ? color : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// 🔥 Page Size Chip Widget
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
        borderRadius: BorderRadius.circular(6),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            color: selected
                ? const Color(0xFF6366F1).withOpacity(0.15)
                : Theme.of(context).brightness == Brightness.dark
                ? Colors.white.withOpacity(0.05)
                : Colors.black.withOpacity(0.05),
            border: Border.all(
              color: selected ? const Color(0xFF6366F1) : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: selected
                  ? const Color(0xFF6366F1)
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }
}

// 🔥 Floating Pagination Widget
class _FloatingPagination extends StatelessWidget {
  final DeviceProvider deviceProvider;

  const _FloatingPagination({
    required this.deviceProvider,
  });

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
          // Previous
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

          // Page Info
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

          // Next
          IconButton(
            onPressed: deviceProvider.hasNextPage && !deviceProvider.isLoading
                ? () => deviceProvider.goToNextPage()
                : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: deviceProvider.hasNextPage && !deviceProvider.isLoading
                  ? Colors.white
                  : Colors.white.withOpacity(0.3),
              size: 28,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}