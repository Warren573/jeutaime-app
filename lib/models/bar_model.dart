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
  });
}
