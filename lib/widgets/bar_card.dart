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
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: bar.isLocked 
              ? [Colors.grey.shade300, Colors.grey.shade400]
              : [
                  bar.color.withOpacity(0.1),
                  bar.color.withOpacity(0.2),
                ],
          ),
          border: Border.all(
            color: bar.isLocked ? Colors.grey.shade300 : bar.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec icône et badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: bar.isLocked 
                        ? Colors.grey.shade200 
                        : bar.color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      bar.isLocked ? Icons.lock : bar.icon,
                      color: bar.isLocked ? Colors.grey : bar.color,
                      size: 24,
                    ),
                  ),
                  if (bar.currentUsers > 0 && !bar.isLocked)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success,
                        borderRadius: BorderRadius.circular(12),
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
                ],
              ),
              
              Spacer(),
              
              // Titre
              Text(
                bar.name,
                style: TextStyle(
                  color: bar.isLocked ? Colors.grey : AppColors.primary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
                ),
              ),
              SizedBox(height: 4),
              
              // Description
              Text(
                bar.isLocked ? (bar.lockReason ?? 'Verrouillé') : bar.description,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontFamily: isFunMode ? 'ComicSans' : 'Montserrat',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8),
              
              // Indicateur d'activité
              if (!bar.isLocked)
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: bar.currentUsers > 10 
                          ? AppColors.success 
                          : bar.currentUsers > 0 
                            ? AppColors.warning 
                            : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      bar.currentUsers > 10 
                        ? 'Très actif'
                        : bar.currentUsers > 0 
                          ? 'Actif'
                          : 'Calme',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey[600],
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
}
