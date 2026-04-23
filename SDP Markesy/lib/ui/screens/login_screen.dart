import 'package:flutter/material.dart';
import 'package:sdp_markesy/data/database/db_helper.dart';
import 'package:sdp_markesy/data/services/realtime_service.dart';
import 'package:sdp_markesy/ui/screens/home_screen.dart';

class Sessao {
  static String? usuario;
  static String? cargo;
  static bool get isAdmin => cargo == 'admin';
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  
  bool _isLoading = false;
  bool _lembrarMe = false;
  bool _ocultarSenha = true;

  void _tentarLogin() async {
    String loginDigitado = _userController.text.trim();
    String senhaDigitada = _passController.text.trim();

    if (loginDigitado.isEmpty || senhaDigitada.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, preencha todos os campos.')));
      return;
    }

    setState(() => _isLoading = true);

    final user = await DbHelper.verificarLogin(loginDigitado, senhaDigitada);

    setState(() => _isLoading = false);

    if (user != null) {
      Sessao.usuario = user['login'];
      Sessao.cargo = user['cargo'];

      RealtimeService.iniciarEscuta();

      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário ou senha incorretos!'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void dispose() {
    _userController.dispose();
    _passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF2140e1);
    const Color buttonColor = Color.fromARGB(255, 255, 255, 255); 
    const Color borderColor = Colors.white30; 

    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Image.asset(
                    'assets/images/markesy-logo.png',
                    height: 120,
                  ),
                ),
                const SizedBox(height: 12),
                const Center(
                  child: Text(
                    'Sucesso do Paciente', 
                    style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w400)
                  ),
                ),
                
                const SizedBox(height: 48),

                _buildLabelRow(Icons.person_outline, 'Usuário'),
                const SizedBox(height: 8),
                TextField(
                  controller: _userController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(hint: 'seu.usuario', borderColor: borderColor),
                ),

                const SizedBox(height: 24),

                _buildLabelRow(Icons.lock_outline, 'Senha'),
                const SizedBox(height: 8),
                TextField(
                  controller: _passController,
                  obscureText: _ocultarSenha,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(hint: '••••••••', borderColor: borderColor).copyWith(
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarSenha ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.white70,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarSenha = !_ocultarSenha;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          height: 24,
                          width: 24,
                          child: Checkbox(
                            value: _lembrarMe,
                            onChanged: (val) => setState(() => _lembrarMe = val ?? false),
                            side: const BorderSide(color: Colors.white, width: 1.5),
                            activeColor: Colors.white,
                            checkColor: bgColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text('Lembrar-me', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Esqueci a senha', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                _isLoading
                    ? const Center(child: CircularProgressIndicator(color: Colors.white))
                    : SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _tentarLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            foregroundColor: bgColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Entrar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward, size: 20),
                            ],
                          ),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildLabelRow(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({required String hint, required Color borderColor}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54, fontSize: 14),
      filled: true,
      fillColor: const Color.fromARGB(58, 0, 0, 0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: borderColor)
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: BorderSide(color: borderColor)
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12), 
        borderSide: const BorderSide(color: Colors.white, width: 1.5)
      ),
    );
  }
}