import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/components/user_card.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/components/user_table.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_event.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_state.dart';

class UserListView extends StatelessWidget {
  const UserListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserBloc, UserState>(
      listenWhen: (previous, current) => 
        previous.status != current.status && 
        current.status == UserStatus.failure,
      listener: (context, state) {
        if (state.status == UserStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      buildWhen: (previous, current) {
        return previous.users != current.users || 
               previous.status != current.status ||
               previous.searchQuery != current.searchQuery;
      },
      builder: (context, state) {
        if (state.status == UserStatus.initial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == UserStatus.loading && state.users.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        } else if (state.status == UserStatus.failure && state.users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  state.errorMessage ?? 'Failed to load users',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<UserBloc>().add(const FetchUsersEvent());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 900;
            final isTablet = constraints.maxWidth > 600 && constraints.maxWidth <= 900;
            
            if (state.users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/no_data.png',
                      height: 150,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.searchQuery != null && state.searchQuery!.isNotEmpty
                          ? 'No users match "${state.searchQuery}"'
                          : 'No users found',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 16),
                    if (state.searchQuery != null && state.searchQuery!.isNotEmpty)
                      ElevatedButton(
                        onPressed: () {
                          context.read<UserBloc>().add(const FetchUsersEvent());
                        },
                        child: const Text('Clear Search'),
                      ),
                  ],
                ),
              );
            }
            
            if (isDesktop) {
              return Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: UserTable(users: state.users),
                  ),
                  if (state.status == UserStatus.loading)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            } else if (isTablet) {
              return Stack(
                children: [
                  GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.5,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: state.users[index]);
                    },
                  ),
                  if (state.status == UserStatus.loading)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            } else {
              return Stack(
                children: [
                  ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: state.users.length,
                    itemBuilder: (context, index) {
                      return UserCard(user: state.users[index]);
                    },
                  ),
                  if (state.status == UserStatus.loading)
                    Container(
                      color: Colors.black26,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                ],
              );
            }
          },
        );
      },
    );
  }
}