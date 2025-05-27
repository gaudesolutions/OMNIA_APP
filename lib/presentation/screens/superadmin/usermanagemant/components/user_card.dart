import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/data/models/user.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_form_page.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_event.dart';

class UserCard extends StatelessWidget {
  final User1 user;

  const UserCard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildUserAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${user.firstName} ${user.lastName}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.username,

              style: TextStyle(
                         fontSize: 14,
                         color: Colors.grey[600],
                       ),
                     ),
                     const SizedBox(height: 4),
                     _buildRoleBadge(),
                   ],
                 ),
               ),
               _buildStatusBadge(),
             ],
           ),
           const SizedBox(height: 16),
           const Divider(),
           _buildInfoRow(Icons.email, user.email),
           if (user.phoneNumber != null)
             _buildInfoRow(Icons.phone, user.phoneNumber!),
           if (user.clinicName != null)
             _buildInfoRow(Icons.local_hospital, user.clinicName!),
           const SizedBox(height: 8),
           Row(
             mainAxisAlignment: MainAxisAlignment.end,
             children: [
               TextButton.icon(
                 icon: const Icon(Icons.edit, size: 20),
                 label: const Text('Edit'),
                 style: TextButton.styleFrom(
                   foregroundColor: Colors.blue,
                 ),
                 onPressed: () => _navigateToEditUser(context),
               ),
               const SizedBox(width: 8),
               TextButton.icon(
                 icon: const Icon(Icons.delete, size: 20),
                 label: const Text('Delete'),
                 style: TextButton.styleFrom(
                   foregroundColor: Colors.red,
                 ),
                 onPressed: () => _showDeleteConfirmation(context),
               ),
             ],
           ),
         ],
       ),
     ),
   );
 }

 Widget _buildUserAvatar() {
   return CircleAvatar(
     radius: 28,
     backgroundColor: _getUserRoleColor().withOpacity(0.2),
     child: user.profileImage != null
         ? ClipRRect(
             borderRadius: BorderRadius.circular(28),
             child: Image.network(
               user.profileImage!,
               width: 56,
               height: 56,
               fit: BoxFit.cover,
               errorBuilder: (context, error, stackTrace) => Icon(
                 Icons.person,
                 size: 30,
                 color: _getUserRoleColor(),
               ),
             ),
           )
         : Icon(
             Icons.person,
             size: 30,
             color: _getUserRoleColor(),
           ),
   );
 }

 Widget _buildRoleBadge() {
   return Container(
     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
     decoration: BoxDecoration(
       color: _getUserRoleColor().withOpacity(0.1),
       borderRadius: BorderRadius.circular(12),
     ),
     child: Text(
       _getUserRoleDisplay(),
       style: TextStyle(
         color: _getUserRoleColor(),
         fontWeight: FontWeight.bold,
         fontSize: 12,
       ),
     ),
   );
 }

 Widget _buildStatusBadge() {
   return Container(
     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
     decoration: BoxDecoration(
       color: user.isActive
           ? Colors.green.shade100
           : Colors.red.shade100,
       borderRadius: BorderRadius.circular(12),
     ),
     child: Text(
       user.isActive ? 'Active' : 'Inactive',
       style: TextStyle(
         color: user.isActive
             ? Colors.green.shade800
             : Colors.red.shade800,
         fontWeight: FontWeight.bold,
         fontSize: 12,
       ),
     ),
   );
 }

 Widget _buildInfoRow(IconData icon, String text) {
   return Padding(
     padding: const EdgeInsets.only(bottom: 8.0),
     child: Row(
       children: [
         Icon(icon, size: 16, color: Colors.grey.shade700),
         const SizedBox(width: 8),
         Expanded(
           child: Text(
             text,
             style: TextStyle(color: Colors.grey.shade800),
             overflow: TextOverflow.ellipsis,
           ),
         ),
       ],
     ),
   );
 }

 Color _getUserRoleColor() {
   switch (user.userType) {
     case 'super_admin':
       return Colors.purple;
     case 'admin':
       return Colors.blue;
     case 'doctor':
       return Colors.teal;
     case 'nurse':
       return Colors.orange;
     case 'reception':
       return Colors.indigo;
     default:
       return Colors.grey;
   }
 }

 String _getUserRoleDisplay() {
   switch (user.userType) {
     case 'super_admin':
       return 'Super Admin';
     case 'admin':
       return 'Admin';
     case 'doctor':
       return 'Doctor';
     case 'nurse':
       return 'Nurse';
     case 'reception':
       return 'Receptionist';
     default:
       return user.userType;
   }
 }

 void _navigateToEditUser(BuildContext context) async {
   final result = await Navigator.push(
     context,
     MaterialPageRoute(
       builder: (_) => BlocProvider.value(
         value: BlocProvider.of<UserBloc>(context),
         child: UserFormPage(user: user),
       ),
     ),
   );
   if (result == true) {
     context.read<UserBloc>().add(const FetchUsersEvent());
   }
 }

 void _showDeleteConfirmation(BuildContext context) {
   showDialog(
     context: context,
     builder: (dialogContext) {
       return AlertDialog(
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(16),
         ),
         title: const Text('Delete User'),
         content: Column(
           mainAxisSize: MainAxisSize.min,
           children: [
             const Icon(
               Icons.warning_amber_rounded,
               size: 64,
               color: Colors.orange,
             ),
             const SizedBox(height: 16),
             Text(
               'Are you sure you want to delete ${user.firstName} ${user.lastName}?',
               textAlign: TextAlign.center,
             ),
             const SizedBox(height: 8),
             const Text(
               'This action cannot be undone.',
               style: TextStyle(color: Colors.grey, fontSize: 12),
               textAlign: TextAlign.center,
             ),
           ],
         ),
         actions: [
           TextButton(
             child: const Text('Cancel'),
             onPressed: () => Navigator.pop(context),
           ),
           ElevatedButton.icon(
             icon: const Icon(Icons.delete),
             label: const Text('Delete'),
             style: ElevatedButton.styleFrom(
               backgroundColor: Colors.red,
               foregroundColor: Colors.white,
             ),
             onPressed: () {
               context.read<UserBloc>().add(DeleteUserEvent(userId: user.id));
               Navigator.pop(dialogContext);
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text('${user.firstName} ${user.lastName} deleted'),
                   backgroundColor: Colors.black87,
                   behavior: SnackBarBehavior.floating,
                 ),
               );
             },
           ),
         ],
       );
     },
   );
 }
}

