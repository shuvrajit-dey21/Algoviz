// import 'package:flutter/material.dart';

// class TeamPage extends StatelessWidget {
//   const TeamPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Developers',
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 2,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.search, color: Colors.black87),
//             onPressed: () {
//               // Search functionality
//             },
//           ),
//           IconButton(
//             icon: const Icon(Icons.menu, color: Colors.black87),
//             onPressed: () {
//               // Menu functionality
//             },
//           ),
//           const SizedBox(width: 12),
//         ],
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           color: Colors.grey.shade200,
//           image: DecorationImage(
//             image: AssetImage('assets/images/pattern_background.png'), // Add a subtle pattern background
//             opacity: 0.15,
//             fit: BoxFit.cover,
//           ),
//         ),
//         child: SafeArea(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Padding(
//                   padding: EdgeInsets.only(left: 16, top: 8, bottom: 16),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           SizedBox(
//                             width: 6,
//                             height: 40,
//                             child: DecoratedBox(
//                               decoration: BoxDecoration(
//                                 color: Color(0xFF4A6FFF),
//                                 borderRadius: BorderRadius.all(Radius.circular(3)),
//                               ),
//                             ),
//                           ),
//                           SizedBox(width: 12),
//                           Text(
//                             'Meet Our Team',
//                             style: TextStyle(
//                               fontSize: 28,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black87,
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12),
//                       Text(
//                         'The brilliant minds behind Algorithm Visualizer',
//                         style: TextStyle(
//                           fontSize: 18,
//                           color: Colors.black54,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 _buildTeamMemberCard(
//                   name: 'Shuvrajit',
//                   role: 'Lead Developer',
//                   description: 'Specializes in algorithm optimization and UI design',
//                   skills: ['Flutter', 'Algorithms', 'UI/UX'],
//                   avatarColor: Color(0xFFE8EFFF),
//                   iconColor: Color(0xFF4A6FFF),
//                 ),
//                 const SizedBox(height: 20),
//                 _buildTeamMemberCard(
//                   name: 'Debajyoti',
//                   role: 'Backend Developer',
//                   description: 'Expert in data structures and algorithm implementation',
//                   skills: ['Python', 'Data Structures', 'Databases'],
//                   avatarColor: Color(0xFFE8F5FF),
//                   iconColor: Color(0xFF2D8EFF),
//                 ),
//                 const SizedBox(height: 80), // Add space at the bottom for better scrolling
//               ],
//             ),
//           ),
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // Add member functionality
//         },
//         backgroundColor: Color(0xFF4A6FFF),
//         child: const Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }

//   Widget _buildTeamMemberCard({
//     required String name,
//     required String role,
//     required String description,
//     required List<String> skills,
//     required Color avatarColor,
//     required Color iconColor,
//   }) {
//     return Card(
//       elevation: 3,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   width: 80,
//                   height: 80,
//                   decoration: BoxDecoration(
//                     color: avatarColor,
//                     shape: BoxShape.circle,
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 3),
//                       ),
//                     ],
//                   ),
//                   child: Icon(
//                     Icons.person,
//                     size: 42,
//                     color: iconColor,
//                   ),
//                 ),
//                 const SizedBox(width: 20),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         name,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.black87,
//                         ),
//                       ),
//                       const SizedBox(height: 8),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 16,
//                           vertical: 8,
//                         ),
//                         decoration: BoxDecoration(
//                           color: avatarColor,
//                           borderRadius: BorderRadius.circular(20),
//                         ),
//                         child: Text(
//                           role,
//                           style: TextStyle(
//                             fontSize: 14,
//                             fontWeight: FontWeight.w500,
//                             color: iconColor,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),
//             Text(
//               description,
//               style: const TextStyle(
//                 fontSize: 16,
//                 color: Colors.black54,
//               ),
//             ),
//             const SizedBox(height: 16),
//             const Text(
//               'Skills',
//               style: TextStyle(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 12),
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: skills.map((skill) => _buildSkillChip(skill, avatarColor, iconColor)).toList(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSkillChip(String skill, Color backgroundColor, Color textColor) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//       decoration: BoxDecoration(
//         color: backgroundColor.withOpacity(0.7),
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         skill,
//         style: TextStyle(
//           fontSize: 14,
//           color: textColor,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// } 