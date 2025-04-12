// import 'package:flutter/material.dart';
// import 'package:work_plan_front/model/exercise.dart';

// class BodyPartSelected  extends StatefulWidget{
//  const BodyPartSelected({
//     super.key,
//     required this.onBodyPartSelected,
//   });
//   final void Function() onBodyPartSelected;
  
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     throw UnimplementedError();
//   }

// }
// class _BodyPartSelectedState extends State<BodyPartSelected> {
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 400,
//       child: Column(
//         children: [
//           Text('Select Body Part'),
//           Expanded(
//             child: GridView.builder(
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 3,
//                 childAspectRatio: 1.0,
//               ),
//               itemCount: BodyPart.values.length,
//               itemBuilder: (context, index) {
//                 final bodyPart = BodyPart.values[index];
//                 return BodyPartGridItem(
//                   bodyPart: bodyPart,
//                   onBodyPartSelected: widget.onBodyPartSelected,
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }