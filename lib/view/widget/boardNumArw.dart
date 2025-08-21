// import 'package:flutter/material.dart';
//
// class PaginationControls extends StatelessWidget {
//   final int currentPage;
//   final int totalItems;
//   final int itemsPerPage;
//   final VoidCallback onPrevious;
//   final VoidCallback onNext;
//
//   const PaginationControls({
//     required this.currentPage,
//     required this.totalItems,
//     required this.itemsPerPage,
//     required this.onPrevious,
//     required this.onNext,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: <Widget>[
//         IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: currentPage == 0
//               ? null
//               : onPrevious,
//         ),
//         if (currentPage > 0)
//           TextButton(
//             child: Text("${currentPage}"),
//             onPressed: onPrevious,
//           ),
//         Text("${currentPage + 1}"),
//         if ((currentPage + 1) * itemsPerPage < totalItems)
//           TextButton(
//             child: Text("${currentPage + 2}"),
//             onPressed: onNext,
//           ),
//         IconButton(
//           icon: Icon(Icons.arrow_forward),
//           onPressed: (currentPage + 1) * itemsPerPage >= totalItems
//               ? null
//               : onNext,
//         ),
//       ],
//     );
//   }
// }
