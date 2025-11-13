// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:makan_mate/features/vendor/presentation/bloc/vendor_state.dart';

// import '../bloc/vendor_bloc.dart';
// import '../widgets/menu_list_widget.dart'; // optional if you split widgets

// class VendorDashboardPage extends StatelessWidget {
//   const VendorDashboardPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Vendor Dashboard'),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           // You can navigate to your AddMenuPage or open dialog here
//         },
//         child: const Icon(Icons.add),
//       ),
//       body: BlocBuilder<VendorBloc, VendorState>(
//         builder: (context, state) {
//           if (state is VendorLoading) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (state is VendorLoaded) {
//             final menus = state.menus;
//             if (menus.isEmpty) {
//               return const Center(child: Text('No menu items yet.'));
//             }
//             return ListView.builder(
//               itemCount: menus.length,
//               itemBuilder: (context, index) {
//                 final menu = menus[index];
//                 return ListTile(
//                   leading: Image.network(menu.imageUrl, width: 50, height: 50, fit: BoxFit.cover),
//                   title: Text(menu.name),
//                   subtitle: Text('RM${menu.price.toStringAsFixed(2)} | ${menu.calories} cal'),
//                   trailing: IconButton(
//                     icon: const Icon(Icons.edit),
//                     onPressed: () {
//                       // TODO: open edit dialog
//                     },
//                   ),
//                 );
//               },
//             );
//           } else if (state is VendorError) {
//             return Center(child: Text('Error: ${state.message}'));
//           }
//           return const Center(child: Text('Loading menus...'));
//         },
//       ),
//     );
//   }
// }
