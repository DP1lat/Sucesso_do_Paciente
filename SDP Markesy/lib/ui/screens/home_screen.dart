import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sdp_markesy/data/providers/auth_provider.dart';
import 'package:sdp_markesy/ui/screens/cadastro_paciente_screen.dart';
import 'package:sdp_markesy/ui/screens/gerenciar_usuarios_screen.dart';
import 'package:sdp_markesy/ui/screens/historico_paciente_screen.dart';
import 'package:sdp_markesy/ui/screens/login_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    
    const Color primaryBlue = Color(0xFF2441DE); 
    
    final String nomeUsuario = Sessao.usuario ?? 'Usuário';
    final String cargoUsuario = Sessao.cargo ?? 'Funcionário';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent, 
        elevation: 0,
        title: const Text('Painel da Clínica', style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.black54),
            tooltip: 'Sair do Sistema',
            onPressed: () {
              Sessao.usuario = null;
              Sessao.cargo = null;
              auth.logout();

              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (route) => false);
            },
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 16.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900), 
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BEM-VINDO', 
                  style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12)
                ),
                const SizedBox(height: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87, fontFamily: 'Segoe UI'),
                    children: [
                      const TextSpan(text: 'Olá, '),
                      TextSpan(text: nomeUsuario, style: const TextStyle(color: primaryBlue)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Você está conectado como $cargoUsuario. Selecione uma das opções abaixo para começar.',
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
                
                const SizedBox(height: 48),

                Wrap(
                  spacing: 24, 
                  runSpacing: 24, 
                  children: [
                    _buildActionCard(
                      context,
                      title: 'Cadastrar Novo\nPaciente',
                      description: 'Adicione um novo paciente ao sistema com todas as informações de avaliação.',
                      icon: Icons.person_add_alt_1,
                      primaryBlue: primaryBlue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const CadastroPacienteScreen())),
                    ),
                    _buildActionCard(
                      context,
                      title: 'Ver Histórico da\nClínica',
                      description: 'Acesse o histórico completo de avaliações e atendimentos dos pacientes.',
                      icon: Icons.history,
                      primaryBlue: primaryBlue,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const HistoricoPacienteScreen())),
                    ),
                    if (Sessao.isAdmin)
                      _buildActionCard(
                        context,
                        title: 'Gerenciar\nFuncionários',
                        description: 'Administre os profissionais da clínica, permissões e especialidades.',
                        icon: Icons.people_alt,
                        primaryBlue: primaryBlue,
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => const GerenciarUsuariosScreen())),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, {
    required String title, 
    required String description, 
    required IconData icon, 
    required Color primaryBlue, 
    bool isHighlighted = false, 
    required VoidCallback onTap
  }) {
    bool isHovered = false;

    return StatefulBuilder(
      builder: (context, setState) {
        return MouseRegion(
          cursor: SystemMouseCursors.click,
          onEnter: (_) => setState(() => isHovered = true),
          onExit: (_) => setState(() => isHovered = false), 
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 280,
              height: 280,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: isHovered ? primaryBlue.withValues(alpha:0.06) : Colors.white, 
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isHovered ? primaryBlue.withValues(alpha:0.3) : Colors.grey.shade300, 
                  width: 1.5
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isHighlighted ? primaryBlue : primaryBlue.withValues(alpha:0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(icon, color: isHighlighted ? Colors.white : primaryBlue, size: 32),
                      ),
                      AnimatedPadding(
                        duration: const Duration(milliseconds: 200),
                        padding: EdgeInsets.only(right: isHovered ? 0 : 4),
                        child: Icon(
                          Icons.arrow_forward, 
                          color: isHovered ? primaryBlue : Colors.grey.shade400, 
                          size: 20
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),
                  
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87, height: 1.3)),
                  const SizedBox(height: 12),
                  Text(description, style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.4)),
                ],
              ),
            ),
          ),
        );
      }
    );
  }
}