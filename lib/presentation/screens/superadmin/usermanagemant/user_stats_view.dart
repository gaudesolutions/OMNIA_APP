import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_bloc.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_event.dart';
import 'package:medical_app/presentation/screens/superadmin/usermanagemant/user_service_bloc/user_state.dart';

class UserStatsView extends StatelessWidget {
 const UserStatsView({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return BlocBuilder<UserBloc, UserState>(
     buildWhen: (previous, current) {
       return previous.statistics != current.statistics || 
              previous.clinicUsers != current.clinicUsers ||
              previous.status != current.status;
     },
     builder: (context, state) {
       if (state.status == UserStatus.initial) {
         return const Center(child: CircularProgressIndicator());
       } else if (state.status == UserStatus.loading && state.statistics == null) {
         return const Center(child: CircularProgressIndicator());
       } else if (state.status == UserStatus.failure && state.statistics == null) {
         return Center(
           child: Column(
             mainAxisAlignment: MainAxisAlignment.center,
             children: [
               const Icon(Icons.error_outline, size: 60, color: Colors.red),
               const SizedBox(height: 16),
               Text(
                 state.errorMessage ?? 'Failed to load statistics',
                 textAlign: TextAlign.center,
                 style: const TextStyle(fontSize: 16),
               ),
               const SizedBox(height: 24),
               ElevatedButton.icon(
                 onPressed: () {
                   context.read<UserBloc>().add(FetchUserStatsEvent());
                   context.read<UserBloc>().add(FetchUsersByClinicEvent());
                 },
                 icon: const Icon(Icons.refresh),
                 label: const Text('Retry'),
               ),
             ],
           ),
         );
       }

       // If statistics are loaded, show them
       if (state.statistics != null) {
         return RefreshIndicator(
           onRefresh: () async {
             context.read<UserBloc>().add(FetchUserStatsEvent());
             context.read<UserBloc>().add(FetchUsersByClinicEvent());
           },
           child: SingleChildScrollView(
             physics: const AlwaysScrollableScrollPhysics(),
             padding: const EdgeInsets.all(16),
             child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 const Text(
                   'User Statistics',
                   style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 24),
                 _buildStatCards(context, state),
                 const SizedBox(height: 32),
                 const Text(
                   'Users by Role',
                   style: TextStyle(
                     fontSize: 18,
                     fontWeight: FontWeight.bold,
                   ),
                 ),
                 const SizedBox(height: 16),
                 Container(
                   height: 300,
                   padding: const EdgeInsets.all(16),
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
                   child: _buildPieChart(state),
                 ),
                 if (state.clinicUsers != null && state.clinicUsers!.isNotEmpty) ...[
                   const SizedBox(height: 32),
                   const Text(
                     'Users by Clinic',
                     style: TextStyle(
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
                   const SizedBox(height: 16),
                   Container(
                     height: 300,
                     padding: const EdgeInsets.all(16),
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
                     child: _buildBarChart(state),
                   ),
                 ],
                 const SizedBox(height: 32),
               ],
             ),
           ),
         );
       }

       return const Center(child: Text('No statistics available'));
     },
   );
 }

 Widget _buildStatCards(BuildContext context, UserState state) {
   final stats = state.statistics!;
   final totalUsers = stats.superAdmin + stats.admin + stats.doctor + stats.nurse + stats.reception;
   
   return LayoutBuilder(
     builder: (context, constraints) {
       final isSmallScreen = constraints.maxWidth < 600;
       final cardWidth = isSmallScreen ? double.infinity : (constraints.maxWidth - 16) / 2;
       
       return Wrap(
         spacing: 16,
         runSpacing: 16,
         children: [
           _buildStatCard(
             context,
             'Total Users',
             totalUsers.toString(),
             Icons.people,
             Colors.blue,
             width: cardWidth,
           ),
           _buildStatCard(
             context,
             'Doctors',
             stats.doctor.toString(),
             Icons.local_hospital,
             Colors.teal,
             width: cardWidth,
           ),
           _buildStatCard(
             context,
             'Nurses',
             stats.nurse.toString(),
             Icons.medical_services,
             Colors.orange,
             width: cardWidth,
           ),
           _buildStatCard(
             context,
             'Receptionists',
             stats.reception.toString(),
             Icons.person,
             Colors.indigo,
             width: cardWidth,
           ),
           _buildStatCard(
             context,
             'Admins',
             (stats.admin + stats.superAdmin).toString(),
             Icons.admin_panel_settings,
             Colors.purple,
             width: cardWidth,
           ),
         ],
       );
     },
   );
 }

 Widget _buildStatCard(
   BuildContext context,
   String title,
   String value,
   IconData icon,
   Color color,
   {required double width}
 ) {
   return Container(
     width: width,
     padding: const EdgeInsets.all(20),
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
     child: Row(
       children: [
         Container(
           padding: const EdgeInsets.all(16),
           decoration: BoxDecoration(
             color: color.withOpacity(0.1),
             borderRadius: BorderRadius.circular(12),
           ),
           child: Icon(icon, color: color, size: 24),
         ),
         const SizedBox(width: 16),
         Column(
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               title,
               style: TextStyle(
                 color: Colors.grey[600],
                 fontSize: 14,
               ),
             ),
             const SizedBox(height: 4),
             Text(
               value,
               style: const TextStyle(
                 fontWeight: FontWeight.bold,
                 fontSize: 24,
               ),
             ),
           ],
         ),
       ],
     ),
   );
 }

 Widget _buildPieChart(UserState state) {
   final stats = state.statistics!;
   final sections = [
     PieChartSectionData(
       value: stats.doctor.toDouble(),
       title: '${stats.doctor}',
       color: Colors.teal,
       radius: 100,
       titleStyle: const TextStyle(
         fontSize: 16,
         fontWeight: FontWeight.bold,
         color: Colors.white,
       ),
     ),
     PieChartSectionData(
       value: stats.nurse.toDouble(),
       title: '${stats.nurse}',
       color: Colors.orange,
       radius: 100,
       titleStyle: const TextStyle(
         fontSize: 16,
         fontWeight: FontWeight.bold,
         color: Colors.white,
       ),
     ),
     PieChartSectionData(
       value: stats.reception.toDouble(),
       title: '${stats.reception}',
       color: Colors.indigo,
       radius: 100,
       titleStyle: const TextStyle(
         fontSize: 16,
         fontWeight: FontWeight.bold,
         color: Colors.white,
       ),
     ),
     PieChartSectionData(
       value: stats.admin.toDouble(),
       title: '${stats.admin}',
       color: Colors.blue,
       radius: 100,
       titleStyle: const TextStyle(
         fontSize: 16,
         fontWeight: FontWeight.bold,
         color: Colors.white,
       ),
     ),
     PieChartSectionData(
       value: stats.superAdmin.toDouble(),
       title: '${stats.superAdmin}',
       color: Colors.purple,
       radius: 100,
       titleStyle: const TextStyle(
         fontSize: 16,
         fontWeight: FontWeight.bold,
         color: Colors.white,
       ),
     ),
   ];

   final indicators = [
     _buildIndicator('Doctors', Colors.teal),
     _buildIndicator('Nurses', Colors.orange),
     _buildIndicator('Receptionists', Colors.indigo),
     _buildIndicator('Admins', Colors.blue),
     _buildIndicator('Super Admins', Colors.purple),
   ];

   return Row(
     children: [
       Expanded(
         flex: 3,
         child: PieChart(
           PieChartData(
             sections: sections,
             centerSpaceRadius: 40,
             sectionsSpace: 2,
             borderData: FlBorderData(show: false),
           ),
         ),
       ),
       Expanded(
         flex: 2,
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: indicators,
         ),
       ),
     ],
   );
 }

 Widget _buildIndicator(String title, Color color) {
   return Padding(
     padding: const EdgeInsets.symmetric(vertical: 4.0),
     child: Row(
       children: [
         Container(
           width: 16,
           height: 16,
           decoration: BoxDecoration(
             color: color,
             shape: BoxShape.circle,
           ),
         ),
         const SizedBox(width: 8),
         Text(
           title,
           style: TextStyle(
             color: Colors.grey[800],
             fontSize: 14,
           ),
         ),
       ],
     ),
   );
 }

 Widget _buildBarChart(UserState state) {
   if (state.clinicUsers == null || state.clinicUsers!.isEmpty) {
     return const Center(child: Text('No clinic data available'));
   }

   final clinics = state.clinicUsers!;
   final maxCount = clinics.map((c) => c.userCount).reduce((a, b) => a > b ? a : b).toDouble();

   return BarChart(
     BarChartData(
       alignment: BarChartAlignment.spaceAround,
       maxY: maxCount * 1.2,
       barTouchData: BarTouchData(
         enabled: true,
         touchTooltipData: BarTouchTooltipData(
          //  tooltipBgColor: Colors.blueGrey.shade800,
           getTooltipItem: (group, groupIndex, rod, rodIndex) {
             return BarTooltipItem(
               '${clinics[groupIndex].clinicName}: ${rod.toY.round()} users',
               const TextStyle(color: Colors.white),
             );
           },
         ),
       ),
       titlesData: FlTitlesData(
         show: true,
         bottomTitles: AxisTitles(
           sideTitles: SideTitles(
             showTitles: true,
             getTitlesWidget: (value, meta) {
               if (value >= 0 && value < clinics.length) {
                 // Truncate clinic name if too long
                 var name = clinics[value.toInt()].clinicName;
                 if (name.length > 10) {
                   name = '${name.substring(0, 8)}...';
                 }
                 return Padding(
                   padding: const EdgeInsets.only(top: 8.0),
                   child: Text(
                     name,
                     style: const TextStyle(
                       fontWeight: FontWeight.bold,
                       fontSize: 12,
                     ),
                   ),
                 );
               }
               return const SizedBox();
             },
           ),
         ),
         leftTitles: AxisTitles(
           sideTitles: SideTitles(
             showTitles: true,
             reservedSize: 30,
             getTitlesWidget: (value, meta) {
               if (value % 5 == 0) {
                 return Text(
                   value.toInt().toString(),
                   style: const TextStyle(
                     color: Colors.grey,
                     fontSize: 12,
                   ),
                 );
               }
               return const SizedBox();
             },
           ),
         ),
         topTitles: AxisTitles(
           sideTitles: SideTitles(showTitles: false),
         ),
         rightTitles: AxisTitles(
           sideTitles: SideTitles(showTitles: false),
         ),
       ),
       borderData: FlBorderData(
         show: false,
       ),
       barGroups: List.generate(
         clinics.length,
         (i) => BarChartGroupData(
           x: i,
           barRods: [
             BarChartRodData(
               toY: clinics[i].userCount.toDouble(),
              //  color: Theme.of(i % 2 == 0 ? const ColorScheme.light().primary : const ColorScheme.light().secondary),
               width: 20,
               borderRadius: const BorderRadius.only(
                 topLeft: Radius.circular(6),
                 topRight: Radius.circular(6),
               ),
             ),
           ],
         ),
       ),
     ),
   );
 }
}