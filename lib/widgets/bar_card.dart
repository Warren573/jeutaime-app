import 'package:flutter/material.dart';
import '../models/bar_model.dart';
import '../theme/app_colors.dart';

class BarCard extends StatelessWidget {
  final BarModel bar;
  final bool isFunMode;
  final VoidCallback onTap;

  const BarCard({
    Key? key,
    required this.bar,
    required this.isFunMode,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: bar.isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isFunMode ? AppColors.funCardBackground : AppColors.seriousCardBackground,
          borderRadius: BorderRadius.circular(isFunMode ? 20 : 12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
          border: bar.isLocked 
            ? Border.all(color: Colors.grey, width: 2)
            : Border.all(color: bar.color.withOpacity(0.3), width: 2),
        ),
        child: Column(
          children: [
            // Header avec icône et statut
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: bar.isLocked 
                  ? Colors.grey.withOpacity(0.3)
                  : bar.color.withOpacity(0.2),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isFunMode ? 20 : 12),
                  topRight: Radius.circular(isFunMode ? 20 : 12),
                ),
              ),
              child: Center(
                child: Stack(
                  children: [
                    Icon(
                      bar.isLocked ? Icons.lock : bar.icon,
                      size: 30,
                      color: bar.isLocked ? Colors.grey : bar.color,
                    ),
                    if (bar.currentUsers > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${bar.currentUsers}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Contenu principal
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bar.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: bar.isLocked 
                          ? Colors.grey 
                          : (isFunMode ? AppColors.funText : AppColors.seriousText),
                        fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        bar.isLocked ? (bar.lockReason ?? 'Accès restreint') : bar.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    
                    // Indicateur d'activité
                    if (!bar.isLocked)
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: bar.currentUsers > 5 
                                ? AppColors.success 
                                : bar.currentUsers > 0 
                                  ? AppColors.warning 
                                  : Colors.grey,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4),
                          Text(
                            bar.currentUsers > 5 
                              ? 'Très actif'
                              : bar.currentUsers > 0 
                                ? 'Actif'
                                : 'Calme',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
