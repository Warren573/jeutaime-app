import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../config/ui_reference.dart';

class LetterTemplateCard extends StatelessWidget {
  final LetterTemplate? template;
  final bool isSelected;
  final VoidCallback onTap;

  const LetterTemplateCard({
    super.key,
    this.template,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Template null = lettre libre
    if (template == null) {
      return _buildFreeLetterCard(context);
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? UIReference.primaryColor.withOpacity(0.1) 
            : UIReference.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? UIReference.primaryColor 
              : UIReference.textSecondary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: UIReference.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getTemplateColor().withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      template!.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              template!.name,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isSelected 
                                  ? UIReference.primaryColor 
                                  : UIReference.textPrimary,
                              ),
                            ),
                          ),
                          if (template!.isPremium)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, 
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    UIReference.accentColor,
                                    UIReference.primaryColor,
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 12,
                                    color: UIReference.white,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    'PREMIUM',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: UIReference.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (template!.unlockLevel > 1)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, 
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: UIReference.textSecondary.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Niv. ${template!.unlockLevel}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: UIReference.textSecondary,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        template!.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: UIReference.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Aperçu du template
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(int.parse(template!.defaultStyle.backgroundColor.replaceAll('#', '0xff'))).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: UIReference.textSecondary.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aperçu :',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: UIReference.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getPreviewText(),
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Color(int.parse(template!.defaultStyle.textColor.replaceAll('#', '0xff'))),
                      fontFamily: template!.defaultStyle.fontFamily,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            
            // Décorations du style
            if (template!.defaultStyle.decorations.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: template!.defaultStyle.decorations.map((decoration) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: _getTemplateColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getDecorationEmoji(decoration),
                      style: const TextStyle(fontSize: 10),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFreeLetterCard(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected 
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  UIReference.primaryColor.withOpacity(0.15),
                  UIReference.accentColor.withOpacity(0.15),
                ],
              )
            : null,
          color: isSelected ? null : UIReference.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
              ? UIReference.primaryColor 
              : UIReference.textSecondary.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: UIReference.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        UIReference.primaryColor.withOpacity(0.2),
                        UIReference.accentColor.withOpacity(0.2),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text(
                      '✨',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lettre libre',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected 
                            ? UIReference.primaryColor 
                            : UIReference.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Écrivez librement, sans modèle',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: UIReference.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: UIReference.primaryColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'LIBRE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: UIReference.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: UIReference.primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: UIReference.primaryColor.withOpacity(0.1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.lightbulb_outline,
                        size: 16,
                        color: UIReference.primaryColor,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Avantages :',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: UIReference.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '• Créativité totale\n• Votre style unique\n• Personnalisation complète',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: UIReference.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getTemplateColor() {
    if (template == null) return UIReference.primaryColor;
    
    switch (template!.type) {
      case LetterType.romantic:
        return const Color(0xFFE91E63);
      case LetterType.friendship:
        return const Color(0xFF2196F3);
      case LetterType.gratitude:
        return const Color(0xFFF57C00);
      case LetterType.apology:
        return const Color(0xFF8BC34A);
      case LetterType.confession:
        return const Color(0xFF9C27B0);
      case LetterType.poetry:
        return const Color(0xFF673AB7);
      default:
        return UIReference.primaryColor;
    }
  }

  String _getPreviewText() {
    if (template == null) return '';
    
    final content = template!.templateContent;
    final firstLines = content.split('\n').take(3).join('\n');
    
    // Remplace les placeholders par des exemples
    String preview = firstLines;
    template!.placeholders.forEach((key, value) {
      switch (key) {
        case 'name':
          preview = preview.replaceAll('{$key}', 'Alice');
          break;
        case 'sender_name':
          preview = preview.replaceAll('{$key}', 'Vous');
          break;
        case 'recipient_title':
          preview = preview.replaceAll('{$key}', 'chérie');
          break;
        default:
          preview = preview.replaceAll('{$key}', '...');
      }
    });
    
    return preview;
  }

  String _getDecorationEmoji(String decoration) {
    switch (decoration) {
      case 'roses':
        return '🌹';
      case 'coeurs':
        return '💕';
      case 'etoiles':
        return '⭐';
      case 'nuages':
        return '☁️';
      case 'feuilles':
        return '🍃';
      case 'plumes':
        return '🪶';
      case 'enluminures':
        return '✨';
      case 'engrenages':
        return '⚙️';
      case 'cristaux':
        return '💎';
      case 'soleil':
        return '☀️';
      case 'fleurs_sauvages':
        return '🌸';
      default:
        return '🎨';
    }
  }
}