import 'package:flutter/material.dart';

class BarModel {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String illustration;
  final int currentUsers;
  final bool isLocked;
  final String? lockReason;
  final bool isPremiumOnly;
  final int minimumAge;
  final List<String> requiredInterests;
  final String category;
  final String theme;
  final List<String> activities;
  final int maxCapacity;
  final int defaultGroupSize;
  final DateTime createdAt;
  final DateTime validUntil;

  BarModel({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.illustration,
    this.currentUsers = 0,
    this.isLocked = false,
    this.lockReason,
    this.isPremiumOnly = false,
    this.minimumAge = 18,
    this.requiredInterests = const [],
    this.category = '',
    this.theme = '',
    this.activities = const [],
    this.maxCapacity = 100,
    this.defaultGroupSize = 4,
    DateTime? createdAt,
    DateTime? validUntil,
  }) : createdAt = createdAt ?? DateTime.now(),
       validUntil = validUntil ?? DateTime.now().add(const Duration(days: 30));
}
