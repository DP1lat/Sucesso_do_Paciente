import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:async';

class RealtimeService {
  static final _supabase = Supabase.instance.client;
  static RealtimeChannel? _canalRealtime;

  static void iniciarEscuta() {
    _canalRealtime?.unsubscribe();

    _canalRealtime = _supabase.channel('public:realtime');

    _canalRealtime!.onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'avaliacoes',
      callback: (payload) {
        final dados = payload.newRecord;

        Future.microtask(() {
          LocalNotification(
            title: 'Nova Avaliação Finalizada!',
            body: 'Um novo paciente foi registrado: ${dados['nome']} fechou o tratamento de ${dados['especialidade']} registrado no valor de R\$ ${dados['valor']}.',
          ).show();
        });
      },
    );

    _canalRealtime!.onPostgresChanges(
      event: PostgresChangeEvent.update,
      schema: 'public',
      table: 'pacientes',
      callback: (payload) {
        final dadosAlterados = payload.newRecord;

        Future.microtask(() {
          LocalNotification(title: 'Paciente Atualizado!', body: 'Os dados de ${dadosAlterados['nome']} foram alterados.').show();
        });
      },
    );
    _canalRealtime!.subscribe();
  }

  static void pararEscuta() {
    _canalRealtime?.unsubscribe();
  }
}
