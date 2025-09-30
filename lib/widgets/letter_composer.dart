import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class LetterComposer extends StatefulWidget {
  final String? recipientName;
  final String? templateContent;
  final dynamic template;
  final Function(String content) onSend;

  const LetterComposer({
    super.key,
    this.recipientName,
    this.templateContent,
    this.template,
    required this.onSend,
  });

  @override
  State<LetterComposer> createState() => _LetterComposerState();
}

class _LetterComposerState extends State<LetterComposer> {
  late TextEditingController _contentController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController(text: widget.templateContent ?? '');
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Icon(
                    Icons.mail_outline,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.recipientName != null
                          ? 'Lettre pour ${widget.recipientName}'
                          : 'Nouvelle lettre',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Zone de saisie
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    hintText: 'Écrivez votre lettre ici...\n\nExprimez-vous avec authenticité et bienveillance.',
                    hintStyle: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      height: 1.5,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.textSecondary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppColors.textDark,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Veuillez écrire votre lettre';
                    }
                    if (value.trim().length < 10) {
                      return 'Votre lettre doit contenir au moins 10 caractères';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              
              // Compteur de caractères et boutons
              Row(
                children: [
                  Text(
                    '${_contentController.text.length} caractères',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _sendLetter,
                    icon: const Icon(Icons.send),
                    label: const Text('Envoyer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _sendLetter() {
    if (_formKey.currentState!.validate()) {
      widget.onSend(_contentController.text.trim());
      Navigator.pop(context);
    }
  }
}