import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/constants.dart';
import 'package:medical_app/data/repositories/auth_repository.dart';
import 'package:medical_app/data/repositories/token_repository.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/components/user_list_view.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_form_page.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_event.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_stats_view.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;
  late UserBloc _userBloc;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  // Add this new method to force refresh
  void _forceRefresh() {
    if (mounted) {
      print("Force refreshing screen...");
      setState(() {
        // This triggers a rebuild of the entire screen
      });
      
      // Fetch fresh data
      _userBloc.add(const FetchUsersEvent());
      _userBloc.add(FetchUserStatsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: TokenRepository().getToken(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          final token = snapshot.data ?? '';

          if (token.isEmpty) {
            return const Center(child: Text('Not logged in'));
          }

          final userService = UserService(
            baseUrl: AppConstants.baseUrl,
            token: token,
          );

          return BlocProvider(
            create: (context) {
              _userBloc = UserBloc(userService)
                ..add(const FetchUsersEvent())
                ..add(FetchUserStatsEvent());
              return _userBloc;
            },
            child: Scaffold(
              appBar: AppBar(
                title: _showSearch
                    ? _buildSearchField()
                    : const Text('User Management'),
                backgroundColor: Theme.of(context).primaryColor,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: Icon(_showSearch ? Icons.close : Icons.search),
                    onPressed: () {
                      setState(() {
                        if (_showSearch) {
                          _searchController.clear();
                          _userBloc.add(const FetchUsersEvent());
                        }
                        _showSearch = !_showSearch;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _forceRefresh,
                  ),
                ],
                bottom: TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(text: 'USER LIST'),
                    Tab(text: 'STATISTICS'),
                  ],
                ),
              ),
              drawer: _buildDrawer(context),
              body: TabBarView(
                controller: _tabController,
                children: const [
                  UserListView(),
                  UserStatsView(),
                ],
              ),
              floatingActionButton: FloatingActionButton(
                backgroundColor: Theme.of(context).primaryColor,
                child: const Icon(Icons.add),
                onPressed: () async {
                  print("Opening user form...");
                  
                  // Use pushReplacement to ensure clean navigation
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlocProvider.value(
                        value: _userBloc,
                        child: const UserFormPage(),
                      ),
                    ),
                  );
                  
                  print("Form returned with result: $result");
                  
                  if (result == true) {
                    print("User added successfully, refreshing list...");
                    
                    // Longer delay to ensure backend processing completes
                    await Future.delayed(const Duration(milliseconds: 2000));
                    
                    // Use more aggressive approach to ensure UI updates
                    if (mounted) {
                      print("Dispatching refresh events and forcing rebuild...");
                      
                      // Option 1: Force refresh with setState and fresh data fetch
                      _forceRefresh();
                      
                      // Option 2: If Option 1 doesn't work, uncomment this for full screen rebuild
                      // Navigator.pushReplacement(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const UserManagementScreen(),
                      //   ),
                      // );
                    }
                  }
                },
              ),
            ),
          );
        } else {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
      },
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        hintText: 'Search users...',
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.8)),
        border: InputBorder.none,
      ),
      style: const TextStyle(color: Colors.white),
      autofocus: true,
      onChanged: (query) {
        _userBloc.add(FetchUsersEvent(searchQuery: query));
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            color: Theme.of(context).primaryColor,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 36, color: Colors.blueGrey),
                ),
                SizedBox(height: 16),
                Text(
                  'Admin User',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'admin@clinic.com',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildDrawerItem(context, Icons.dashboard, 'Dashboard', () {
            Navigator.pop(context);
            // Navigator.pushReplacementNamed(context, '/dashboard');
          }),
          _buildDrawerItem(context, Icons.local_hospital, 'Clinics', () {
            Navigator.pop(context);
            // Navigator.pushReplacementNamed(context, '/clinics');
          }),
          _buildDrawerItem(context, Icons.people, 'Users', () {
            Navigator.pop(context);
          }, isSelected: true),
          _buildDrawerItem(context, Icons.analytics, 'Analytics', () {
            Navigator.pop(context);
            // Navigator.pushReplacementNamed(context, '/analytics');
          }),
          _buildDrawerItem(context, Icons.settings, 'Settings', () {
            Navigator.pop(context);
            // Navigator.pushReplacementNamed(context, '/settings');
          }),
          const Spacer(),
          Divider(color: Colors.grey.shade300),
          _buildDrawerItem(context, Icons.logout, 'Logout', () {
            // Implement logout functionality
          }, textColor: Colors.red),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, IconData icon, String title, VoidCallback onTap,
      {bool isSelected = false, Color? textColor}) {
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected
            ? Theme.of(context).primaryColor
            : (textColor ?? Colors.blueGrey),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : (textColor ?? Colors.blueGrey),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: isSelected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.1),
    );
  }
}