import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:sdp_markesy/ui/screens/gerenciar_usuarios_screen.dart';
// import 'package:sdp_markesy/ui/screens/historico_paciente_screen.dart';
import 'package:sdp_markesy/ui/screens/login_screen.dart';
import 'package:local_notifier/local_notifier.dart';
import 'data/providers/auth_provider.dart';
// import 'ui/screens/cadastro_paciente_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sdp_markesy/ui/screens/home_screen.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'secrets.env');

  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);

  await const FlutterSecureStorage().deleteAll();

  await localNotifier.setup(appName: 'Markesý', shortcutPolicy: ShortcutPolicy.requireCreate);

  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Markesý',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true, 
        colorSchemeSeed: Colors.blue,
        elevatedButtonTheme: const ElevatedButtonThemeData(
          style: ButtonStyle(
            mouseCursor: WidgetStatePropertyAll(SystemMouseCursors.click),
          ),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.usuario == null) {
            return const LoginScreen();
          }
          return const HomeScreen();
        },
      ),
    );
  }
}