import 'package:flutter/material.dart';
import 'package:salas_beats/services/localization_service.dart';

/// Widget de demostración para mostrar la funcionalidad de internacionalización
class LocalizationDemoWidget extends StatelessWidget {
  const LocalizationDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Localization Demo',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Mostrar strings localizados
            _buildLocalizedText(context, 'App Title', context.l10n.appTitle),
            _buildLocalizedText(context, 'Welcome', context.l10n.welcome),
            _buildLocalizedText(context, 'Email', context.l10n.email),
            _buildLocalizedText(context, 'Password', context.l10n.password),
            _buildLocalizedText(context, 'Login', context.l10n.login),
            _buildLocalizedText(context, 'Register', context.l10n.register),
            _buildLocalizedText(context, 'Search', context.l10n.search),
            _buildLocalizedText(context, 'Language', context.l10n.language),
            
            const SizedBox(height: 16),
            
            // Botones para cambiar idioma
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _changeLanguage('es'),
                  child: const Text('🇪🇸 ES'),
                ),
                ElevatedButton(
                  onPressed: () => _changeLanguage('en'),
                  child: const Text('🇺🇸 EN'),
                ),
                ElevatedButton(
                  onPressed: () => _changeLanguage('pt'),
                  child: const Text('🇧🇷 PT'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Current language: ${LocalizationService().currentLanguageCode}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalizedText(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _changeLanguage(String languageCode) async {
    await LocalizationService().changeLanguage(languageCode);
  }
}