import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdp_markesy/ui/screens/gerenciar_usuarios_screen.dart';
import 'package:sdp_markesy/ui/screens/historico_paciente_screen.dart';
import 'package:sdp_markesy/ui/screens/login_screen.dart';
import 'package:sdp_markesy/ui/screens/primeiro_acesso_screen.dart';
import 'package:local_notifier/local_notifier.dart';
import 'data/providers/auth_provider.dart';
import 'ui/screens/cadastro_paciente_screen.dart';
import 'package:sdp_markesy/data/security/secure_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
bool _isFirstTime = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: 'secrets.env');

  await Supabase.initialize(url: dotenv.env['SUPABASE_URL']!, anonKey: dotenv.env['SUPABASE_ANON_KEY']!);

  await const FlutterSecureStorage().deleteAll();

  _isFirstTime = await SecureAuth.isPrimeiroAcesso();

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
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.usuario == null) {
            return _isFirstTime ? const PrimeiroAcessoScreen() : const LoginScreen();
          }
          return const HistoricoPacienteScreen();
        },
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel da Clínica'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sair',
            onPressed: () {
              Sessao.usuario = null;
              Sessao.cargo = null;
              auth.logout();

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Bem-Vindo! Setor: ${Sessao.cargo ?? "Funcionário"}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
                icon: const Icon(Icons.person_add),
                label: const Text('Cadastrar Novo Paciente'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CadastroPacienteScreen())),
              ),

              const SizedBox(height: 15),

              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(minimumSize: const Size(250, 50)),
                icon: const Icon(Icons.history),
                label: const Text('Ver Histórico da Clínica'),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const HistoricoPacienteScreen())),
              ),

              if (Sessao.isAdmin) ...[
                const SizedBox(height: 15),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.orange, foregroundColor: Colors.white, minimumSize: const Size(250, 50)),
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Gerenciar Funcionários'),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (ctx) => const GerenciarUsuariosScreen()));
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
