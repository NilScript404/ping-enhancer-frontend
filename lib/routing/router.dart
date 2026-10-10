// NOTE example for go_router if it was needed.
//
// import 'package:go_router/go_router.dart';

// final _router = GoRouter(
//   routes: [GoRoute(path: "/", builder: (context, state) => HomeScreen())],
// );
// final GoRouter _router = GoRouter(
//   routes: <GoRoute>[
//     GoRoute(
//       path: '/',
//       builder: (BuildContext context, GoRouterState state) {
//         return const HomeScreen();
//       },
//     ),
//     GoRoute(
//       path: 'icmp/:randomNum',
//       builder: (BuildContext context, GoRouterState state) {
//         return const IcmpScreen();
//       },
//     ),
//   ],
// );

// class IcmpScreen extends StatelessWidget {
//   const IcmpScreen({super.key});

//   @override
//   Widget build(BuildContext context) {

//     return Scaffold(
//       appBar: AppBar(
//       ), // NOTE not needed i suppose
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () => context.go("/"), // NOTE
//           child: const Text("Go to home screen"),
//         ),
//       ),
//     );
//   }
// }
