enum ThreadStatus {
  active,
  ghosting,
  archived,
}

extension ThreadStatusExtension on ThreadStatus {
  String get displayName {
    switch (this) {
      case ThreadStatus.active:
        return 'Active';
      case ThreadStatus.ghosting:
        return 'En attente';
      case ThreadStatus.archived:
        return 'Archivé';
    }
  }
}