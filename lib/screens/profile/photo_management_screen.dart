import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/photo_service.dart';
import '../../theme/app_colors.dart';

class PhotoManagementScreen extends StatefulWidget {
  @override
  _PhotoManagementScreenState createState() => _PhotoManagementScreenState();
}

class _PhotoManagementScreenState extends State<PhotoManagementScreen> {
  List<String> _photos = [];
  bool _isLoading = true;
  bool _isUploading = false;
  Map<String, dynamic> _limits = {};

  @override
  void initState() {
    super.initState();
    _loadPhotos();
    _checkLimits();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Récupérer l'ID utilisateur actuel
      const currentUserId = 'current_user_id';
      final photos = await PhotoService.getUserPhotos(currentUserId);
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Erreur de chargement: $e');
    }
  }

  Future<void> _checkLimits() async {
    final limits = await PhotoService.checkLimits();
    setState(() => _limits = limits);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mes Photos',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_isUploading)
            PopupMenuButton(
              icon: Icon(Icons.more_vert, color: AppColors.textPrimary),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'add_single',
                  child: Row(
                    children: [
                      Icon(Icons.add_a_photo, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Text('Ajouter une photo'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'add_multiple',
                  child: Row(
                    children: [
                      Icon(Icons.photo_library, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Text('Ajouter plusieurs'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'reorder',
                  child: Row(
                    children: [
                      Icon(Icons.reorder, color: AppColors.textSecondary),
                      SizedBox(width: 12),
                      Text('Réorganiser'),
                    ],
                  ),
                ),
              ],
              onSelected: _handleMenuAction,
            ),
        ],
      ),
      body: _isLoading
          ? _buildLoadingState()
          : Column(
              children: [
                _buildLimitsInfo(),
                Expanded(child: _buildPhotoGrid()),
                if (_isUploading) _buildUploadProgress(),
              ],
            ),
      floatingActionButton: _photos.length < (_limits['maxPhotos'] ?? 6) && !_isUploading
          ? FloatingActionButton(
              onPressed: _showAddPhotoOptions,
              backgroundColor: AppColors.primary,
              child: Icon(Icons.add_a_photo, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Chargement de vos photos...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildLimitsInfo() {
    if (_limits.isEmpty) return SizedBox.shrink();

    final photosUsed = _limits['photosUsed'] ?? 0;
    final maxPhotos = _limits['maxPhotos'] ?? 6;
    final storageUsedMB = _limits['storageUsedMB'] ?? 0;
    final maxStorageMB = _limits['maxStorageMB'] ?? 50;

    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photos: $photosUsed / $maxPhotos',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: photosUsed / maxPhotos,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ],
            ),
          ),
          SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stockage: ${storageUsedMB}MB / ${maxStorageMB}MB',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                LinearProgressIndicator(
                  value: storageUsedMB / maxStorageMB,
                  backgroundColor: AppColors.secondary.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoGrid() {
    if (_photos.isEmpty) {
      return _buildEmptyState();
    }

    return Padding(
      padding: EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _photos.length,
        itemBuilder: (context, index) {
          return _PhotoCard(
            photoUrl: _photos[index],
            index: index,
            isPrimary: index == 0,
            onDelete: () => _deletePhoto(index),
            onSetPrimary: () => _setPrimaryPhoto(index),
            onView: () => _viewPhoto(index),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add_a_photo,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            SizedBox(height: 24),
            Text(
              'Aucune photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Ajoutez des photos pour que les autres utilisateurs puissent vous découvrir !',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _showAddPhotoOptions,
              icon: Icon(Icons.camera_alt),
              label: Text('Ajouter ma première photo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadProgress() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Text(
              'Upload en cours...',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'add_single':
        _showAddPhotoOptions();
        break;
      case 'add_multiple':
        _addMultiplePhotos();
        break;
      case 'reorder':
        _showReorderDialog();
        break;
    }
  }

  void _showAddPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                height: 4,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Ajouter une photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
                title: Text('Prendre une photo'),
                subtitle: Text('Utilisez l\'appareil photo'),
                onTap: () {
                  Navigator.pop(context);
                  _addPhoto(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.photo_library, color: AppColors.secondary),
                ),
                title: Text('Galerie'),
                subtitle: Text('Choisir depuis la galerie'),
                onTap: () {
                  Navigator.pop(context);
                  _addPhoto(ImageSource.gallery);
                },
              ),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addPhoto(ImageSource source) async {
    if (!(_limits['canUpload'] ?? false)) {
      _showError(_limits['reason'] ?? 'Limite atteinte');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final imageFile = await PhotoService.pickImage(source: source);
      if (imageFile != null) {
        final photoUrl = await PhotoService.uploadProfilePhoto(imageFile);
        if (photoUrl != null) {
          setState(() {
            _photos.add(photoUrl);
          });
          _showSuccess('Photo ajoutée avec succès !');
          _checkLimits();
        } else {
          _showError('Erreur lors de l\'upload');
        }
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _addMultiplePhotos() async {
    if (!(_limits['canUpload'] ?? false)) {
      _showError(_limits['reason'] ?? 'Limite atteinte');
      return;
    }

    setState(() => _isUploading = true);

    try {
      final maxPhotos = (_limits['maxPhotos'] ?? 6) - _photos.length;
      final imageFiles = await PhotoService.pickMultipleImages(maxImages: maxPhotos);
      
      if (imageFiles != null && imageFiles.isNotEmpty) {
        final uploadedUrls = await PhotoService.uploadMultiplePhotos(
          imageFiles,
          onProgress: (uploaded, total) {
            // TODO: Afficher progression détaillée
          },
        );
        
        if (uploadedUrls.isNotEmpty) {
          setState(() {
            _photos.addAll(uploadedUrls);
          });
          _showSuccess('${uploadedUrls.length} photo(s) ajoutée(s) !');
          _checkLimits();
        }
      }
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      setState(() => _isUploading = false);
    }
  }

  Future<void> _deletePhoto(int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Supprimer cette photo ?'),
        content: Text('Cette action est irréversible.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final success = await PhotoService.deletePhoto(_photos[index]);
      if (success) {
        setState(() {
          _photos.removeAt(index);
        });
        _showSuccess('Photo supprimée');
        _checkLimits();
      } else {
        _showError('Erreur lors de la suppression');
      }
    }
  }

  Future<void> _setPrimaryPhoto(int index) async {
    if (index == 0) return; // Déjà photo principale

    setState(() {
      final photo = _photos.removeAt(index);
      _photos.insert(0, photo);
    });

    final success = await PhotoService.reorderPhotos(_photos);
    if (success) {
      _showSuccess('Photo principale mise à jour');
    } else {
      _showError('Erreur lors de la mise à jour');
      _loadPhotos(); // Recharger en cas d'erreur
    }
  }

  void _viewPhoto(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _PhotoViewerScreen(
          photos: _photos,
          initialIndex: index,
        ),
      ),
    );
  }

  void _showReorderDialog() {
    // TODO: Implémenter interface de réorganisation drag & drop
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Réorganisation bientôt disponible')),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  final String photoUrl;
  final int index;
  final bool isPrimary;
  final VoidCallback onDelete;
  final VoidCallback onSetPrimary;
  final VoidCallback onView;

  const _PhotoCard({
    Key? key,
    required this.photoUrl,
    required this.index,
    required this.isPrimary,
    required this.onDelete,
    required this.onSetPrimary,
    required this.onView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onView,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.network(
                photoUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.error, color: Colors.grey),
                    ),
                  );
                },
              ),

              // Badge photo principale
              if (isPrimary)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Menu d'actions
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.white, size: 20),
                    itemBuilder: (context) => [
                      if (!isPrimary)
                        PopupMenuItem(
                          value: 'set_primary',
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 16),
                              SizedBox(width: 8),
                              Text('Photo principale'),
                            ],
                          ),
                        ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 16),
                            SizedBox(width: 8),
                            Text('Supprimer', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      switch (value) {
                        case 'set_primary':
                          onSetPrimary();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoViewerScreen extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;

  const _PhotoViewerScreen({
    Key? key,
    required this.photos,
    required this.initialIndex,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: PageView.builder(
        controller: PageController(initialPage: initialIndex),
        itemCount: photos.length,
        itemBuilder: (context, index) {
          return Center(
            child: InteractiveViewer(
              child: Image.network(
                photos[index],
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                          : null,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}