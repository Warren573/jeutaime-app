import 'package:flutter/material.dart';
import '../models/letter.dart';
import '../config/ui_reference.dart';

class LetterComposer extends StatefulWidget {
  final LetterTemplate? template;
  final LetterType letterType;
  final String recipientName;
  final bool isAnonymous;
  final VoidCallback onBack;
  final Function(String content, Map<String, dynamic> customization) onSend;

  const LetterComposer({
    super.key,
    this.template,
    required this.letterType,
    required this.recipientName,
    required this.isAnonymous,
    required this.onBack,
    required this.onSend,
  });

  @override
  State<LetterComposer> createState() => _LetterComposerState();
}

class _LetterComposerState extends State<LetterComposer>
    with TickerProviderStateMixin {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late AnimationController _previewController;
  late Animation<double> _previewAnimation;
  
  bool _isPreviewMode = false;
  int _wordCount = 0;
  final int _maxWords = 500;
  
  // Personnalisation
  String _selectedPaper = 'white';
  String _selectedFont = 'Georgia';
  double _fontSize = 16.0;
  String _selectedDecoration = 'none';

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    
    _previewController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _previewAnimation = CurvedAnimation(
      parent: _previewController,
      curve: Curves.easeInOut,
    );
    
    _initializeContent();
    _contentController.addListener(_updateWordCount);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _previewController.dispose();
    super.dispose();
  }

  void _initializeContent() {
    if (widget.template != null) {
      _titleController.text = widget.template!.name;
      
      String content = widget.template!.templateContent;
      
      // Remplace les placeholders par des valeurs par défaut
      widget.template!.placeholders.forEach((key, defaultValue) {
        switch (key) {
          case 'name':
          case 'recipient_title':
            content = content.replaceAll('{$key}', widget.recipientName);
            break;
          case 'sender_name':
            content = content.replaceAll('{$key}', widget.isAnonymous ? 'Un(e) admirateur/trice' : 'Votre nom');
            break;
          case 'current_date':
            content = content.replaceAll('{$key}', _formatDate(DateTime.now()));
            break;
          default:
            content = content.replaceAll('{$key}', defaultValue);
        }
      });
      
      _contentController.text = content;
      
      // Applique le style par défaut du template
      final style = widget.template!.defaultStyle;
      _selectedFont = style.fontFamily;
      _fontSize = style.fontSize;
      _selectedPaper = _paperFromBackground(style.backgroundColor);
      _selectedDecoration = style.decorations.isNotEmpty ? style.decorations.first : 'none';
    } else {
      _titleController.text = _getDefaultTitle();
      _contentController.text = _getDefaultContent();
    }
    
    _updateWordCount();
  }

  void _updateWordCount() {
    final text = _contentController.text.trim();
    setState(() {
      _wordCount = text.isEmpty ? 0 : text.split(RegExp(r'\s+')).length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildToolbar(),
          const SizedBox(height: 20),
          Expanded(
            child: AnimatedBuilder(
              animation: _previewAnimation,
              builder: (context, child) {
                return _isPreviewMode 
                  ? _buildPreview() 
                  : _buildEditor();
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UIReference.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIReference.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Mode preview/edit
              Expanded(
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment<bool>(
                      value: false,
                      label: Text('Écrire'),
                      icon: Icon(Icons.edit_rounded, size: 18),
                    ),
                    ButtonSegment<bool>(
                      value: true,
                      label: Text('Aperçu'),
                      icon: Icon(Icons.preview, size: 18),
                    ),
                  ],
                  selected: {_isPreviewMode},
                  onSelectionChanged: (Set<bool> newSelection) {
                    setState(() {
                      _isPreviewMode = newSelection.first;
                    });
                    if (_isPreviewMode) {
                      _previewController.forward();
                    } else {
                      _previewController.reverse();
                    }
                  },
                  style: SegmentedButton.styleFrom(
                    selectedForegroundColor: UIReference.white,
                    selectedBackgroundColor: UIReference.primaryColor,
                    foregroundColor: UIReference.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Compteur de mots
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _wordCount > _maxWords 
                    ? UIReference.warningColor.withOpacity(0.1)
                    : UIReference.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$_wordCount/$_maxWords mots',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _wordCount > _maxWords 
                      ? UIReference.warningColor
                      : UIReference.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          
          if (!_isPreviewMode) ...[
            const SizedBox(height: 16),
            _buildCustomizationTools(),
          ],
        ],
      ),
    );
  }

  Widget _buildCustomizationTools() {
    return Column(
      children: [
        // Papier et police
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Papier',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: UIReference.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedPaper,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: 'white', child: Text('Blanc classique')),
                      DropdownMenuItem(value: 'cream', child: Text('Crème vintage')),
                      DropdownMenuItem(value: 'pink', child: Text('Rose romantique')),
                      DropdownMenuItem(value: 'blue', child: Text('Bleu ciel')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedPaper = value ?? 'white';
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Police',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: UIReference.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedFont,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: 'Georgia', child: Text('Georgia', style: TextStyle(fontFamily: 'Georgia'))),
                      DropdownMenuItem(value: 'ComicSans', child: Text('Comic Sans', style: TextStyle(fontFamily: 'ComicSans'))),
                      DropdownMenuItem(value: 'Times', child: Text('Times')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedFont = value ?? 'Georgia';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        // Taille et décorations
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Taille: ${_fontSize.toInt()}pt',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: UIReference.textSecondary,
                    ),
                  ),
                  Slider(
                    value: _fontSize,
                    min: 12,
                    max: 24,
                    divisions: 12,
                    activeColor: UIReference.primaryColor,
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Décoration',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: UIReference.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedDecoration,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      isDense: true,
                    ),
                    items: [
                      DropdownMenuItem(value: 'none', child: Text('Aucune')),
                      DropdownMenuItem(value: 'hearts', child: Text('💕 Coeurs')),
                      DropdownMenuItem(value: 'stars', child: Text('⭐ Étoiles')),
                      DropdownMenuItem(value: 'flowers', child: Text('🌸 Fleurs')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedDecoration = value ?? 'none';
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEditor() {
    return Container(
      decoration: BoxDecoration(
        color: UIReference.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIReference.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Titre
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: UIReference.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                bottom: BorderSide(
                  color: UIReference.textSecondary.withOpacity(0.1),
                ),
              ),
            ),
            child: TextField(
              controller: _titleController,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: UIReference.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'Titre de votre lettre...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          
          // Contenu
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _contentController,
                maxLines: null,
                expands: true,
                style: TextStyle(
                  fontFamily: _selectedFont,
                  fontSize: _fontSize,
                  color: UIReference.textPrimary,
                  height: 1.6,
                ),
                decoration: InputDecoration(
                  hintText: _getPlaceholderText(),
                  hintStyle: TextStyle(
                    fontFamily: _selectedFont,
                    fontSize: _fontSize,
                    color: UIReference.textSecondary.withOpacity(0.6),
                    height: 1.6,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (text) {
                  _updateWordCount();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreview() {
    return Container(
      decoration: BoxDecoration(
        color: _getPaperColor(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: UIReference.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Texture de papier
          if (_selectedDecoration != 'none')
            Positioned.fill(
              child: _buildDecorationPattern(),
            ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre
                if (_titleController.text.isNotEmpty) ...[
                  Center(
                    child: Text(
                      _titleController.text,
                      style: TextStyle(
                        fontFamily: _selectedFont,
                        fontSize: _fontSize + 4,
                        fontWeight: FontWeight.bold,
                        color: _getTextColor(),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Divider(color: _getTextColor().withOpacity(0.3)),
                  const SizedBox(height: 24),
                ],
                
                // Contenu
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _contentController.text,
                      style: TextStyle(
                        fontFamily: _selectedFont,
                        fontSize: _fontSize,
                        color: _getTextColor(),
                        height: 1.8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDecorationPattern() {
    switch (_selectedDecoration) {
      case 'hearts':
        return CustomPaint(
          painter: DecorationPainter('💕'),
        );
      case 'stars':
        return CustomPaint(
          painter: DecorationPainter('⭐'),
        );
      case 'flowers':
        return CustomPaint(
          painter: DecorationPainter('🌸'),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: widget.onBack,
            style: OutlinedButton.styleFrom(
              foregroundColor: UIReference.textSecondary,
              side: BorderSide(color: UIReference.textSecondary.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retour'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton.icon(
            onPressed: _wordCount > 0 && _wordCount <= _maxWords ? _sendLetter : null,
            icon: const Icon(Icons.send),
            label: const Text('Envoyer la lettre'),
            style: ElevatedButton.styleFrom(
              backgroundColor: UIReference.primaryColor,
              foregroundColor: UIReference.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getPaperColor() {
    switch (_selectedPaper) {
      case 'cream':
        return const Color(0xFFFFFBF0);
      case 'pink':
        return const Color(0xFFFFF5F5);
      case 'blue':
        return const Color(0xFFF0F8FF);
      default:
        return UIReference.white;
    }
  }

  Color _getTextColor() {
    switch (_selectedPaper) {
      case 'cream':
        return const Color(0xFF8B4513);
      case 'pink':
        return const Color(0xFF8B4A6B);
      case 'blue':
        return const Color(0xFF4682B4);
      default:
        return UIReference.textPrimary;
    }
  }

  String _getDefaultTitle() {
    switch (widget.letterType) {
      case LetterType.romantic:
        return 'Pour toi ❤️';
      case LetterType.friendship:
        return 'Mon ami(e) 🤗';
      case LetterType.gratitude:
        return 'Merci 🙏';
      case LetterType.apology:
        return 'Mes excuses 😔';
      default:
        return 'Ma lettre';
    }
  }

  String _getDefaultContent() {
    final suggestions = LetterService.getContentSuggestions(widget.letterType);
    return suggestions.isNotEmpty ? suggestions.first : '';
  }

  String _getPlaceholderText() {
    return 'Écrivez votre message ici...\n\nVous pouvez exprimer vos sentiments, partager vos pensées, ou simplement dire bonjour.\n\nSoyez authentique et laissez parler votre cœur.';
  }

  String _paperFromBackground(String bgColor) {
    switch (bgColor) {
      case '#FFF5F5':
        return 'pink';
      case '#F0F8FF':
        return 'blue';
      case '#FFF8DC':
        return 'cream';
      default:
        return 'white';
    }
  }

  String _formatDate(DateTime date) {
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _sendLetter() {
    final customization = {
      'paper': _selectedPaper,
      'font': _selectedFont,
      'fontSize': _fontSize,
      'decoration': _selectedDecoration,
      'title': _titleController.text,
    };
    
    widget.onSend(_contentController.text, customization);
  }
}

// Painter pour les décorations
class DecorationPainter extends CustomPainter {
  final String emoji;

  DecorationPainter(this.emoji);

  @override
  void paint(Canvas canvas, Size size) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: emoji,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.withOpacity(0.1),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    
    // Dessine les emojis en motif
    for (double x = 0; x < size.width; x += 60) {
      for (double y = 0; y < size.height; y += 60) {
        textPainter.paint(canvas, Offset(x, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}