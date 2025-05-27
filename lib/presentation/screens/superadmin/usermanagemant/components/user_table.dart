import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:medical_app/data/models/user.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_form_page.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_event.dart';

class UserTable extends StatelessWidget {
 final List<User1> users;

 const UserTable({Key? key, required this.users}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return Container(
     decoration: BoxDecoration(
       color: Colors.white,
       borderRadius: BorderRadius.circular(16),
       boxShadow: [
         BoxShadow(
           color: Colors.black.withOpacity(0.05),
           blurRadius: 10,
           offset: const Offset(0, 5),
         ),
       ],
     ),
     child: ClipRRect(
       borderRadius: BorderRadius.circular(16),
       child: SingleChildScrollView(
         scrollDirection: Axis.horizontal,
         child: SingleChildScrollView(
           child: DataTable(
             columnSpacing: 24,
             horizontalMargin: 24,
             headingRowColor: MaterialStateProperty.all(
               Theme.of(context).primaryColor.withOpacity(0.1),
             ),
             columns: const [
               DataColumn(
                 label: Text(
                   'USERNAME',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ),
               DataColumn(
                 label: Text(
                   'NAME',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ),
               DataColumn(
                 label: Text(
                   'EMAIL',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ),
               DataColumn(
                 label: Text(
                   'ROLE',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ),
               DataColumn(
                 label: Text(
                   'CLINIC',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ),
               DataColumn(
                 label: Text(
                   'STATUS',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ),
               DataColumn(
                 label: Text(
                   'ACTIONS',
                   style: TextStyle(fontWeight: FontWeight.bold),
                 ),
               ),
             ],
             rows: users.map((user) {
               return DataRow(
                 cells: [
                   DataCell(Text(user.username)),
                   DataCell(Text('${user.firstName} ${user.lastName}')),
                   DataCell(Text(user.email)),
                   DataCell(_buildRoleBadge(user)),
                   DataCell(Text(user.clinicName ?? 'N/A')),
                   DataCell(_buildStatusBadge(user)),
                   DataCell(
                     Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                           tooltip: 'Edit',
                           onPressed: () => _navigateToEditUser(context, user),
                         ),
                         const SizedBox(width: 8),
                         IconButton(
                           icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                           tooltip: 'Delete',
                           onPressed: () => _showDeleteConfirmation(context, user),
                         ),
                       ],
                     ),
                   ),
                 ],
               );
             }).toList(),
           ),
         ),
       ),
     ),
   );
 }

 Widget _buildRoleBadge(User1 user) {
   return Container(
     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
     decoration: BoxDecoration(
       color: _getUserRoleColor(user).withOpacity(0.1),
       borderRadius: BorderRadius.circular(12),
     ),
     child: Text(
       _getUserRoleDisplay(user),
       style: TextStyle(
         color: _getUserRoleColor(user),
         fontWeight: FontWeight.bold,
         fontSize: 12,
       ),
     ),
   );
 }

 Widget _buildStatusBadge(User1 user) {
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

 Color _getUserRoleColor(User1 user) {
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

 String _getUserRoleDisplay(User1 user) {
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

 void _navigateToEditUser(BuildContext context, User1 user) async {
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

 void _showDeleteConfirmation(BuildContext context, User1 user) {
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
             onPressed: () => Navigator.pop(dialogContext),
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
