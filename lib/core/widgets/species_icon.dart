import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'horseshoe_icon.dart';

/// Standardized species icon widget that returns the exact dedicated icon for each animal.
/// - Horse / Equine: Stylized Golden HorseshoeIcon
/// - Dog / Canine / Dam / Bitch / Puppy: Paw print (Icons.pets)
/// - Cat / Feline / Kitten: Cat icon (Icons.cruelty_free)
/// - Cattle / Cow / Bovine: Cattle icon (Icons.agriculture_rounded)
/// - Sheep / Ovine: Sheep icon (Icons.grass_rounded)
/// - Other: Category icon (Icons.category_outlined)
class SpeciesIcon extends StatelessWidget {
  final String? species;
  final double size;
  final Color? color;

  const SpeciesIcon({
    super.key,
    required this.species,
    this.size = 20.0,
    this.color,
  });

  static bool isHorse(String? s) {
    if (s == null) return false;
    final val = s.toLowerCase().trim();
    return val.contains('horse') || val.contains('equine') || val.contains('mare') || val.contains('foal') || val.contains('stallion');
  }

  static bool isDog(String? s) {
    if (s == null) return false;
    final val = s.toLowerCase().trim();
    return val.contains('dog') || val.contains('canine') || val.contains('bitch') || val.contains('dam') || val.contains('pupp') || val.contains('stud');
  }

  static bool isCat(String? s) {
    if (s == null) return false;
    final val = s.toLowerCase().trim();
    return val.contains('cat') || val.contains('feline') || val.contains('kit') || val.contains('queen');
  }

  static bool isCattle(String? s) {
    if (s == null) return false;
    final val = s.toLowerCase().trim();
    return val.contains('cattle') || val.contains('cow') || val.contains('bull') || val.contains('calf') || val.contains('bovine');
  }

  static bool isSheep(String? s) {
    if (s == null) return false;
    final val = s.toLowerCase().trim();
    return val.contains('sheep') || val.contains('ewe') || val.contains('ram') || val.contains('lamb') || val.contains('ovine');
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.primaryGold;

    if (isHorse(species)) {
      return HorseshoeIcon(size: size, color: iconColor);
    } else if (isDog(species)) {
      return Icon(Icons.pets, size: size, color: iconColor);
    } else if (isCat(species)) {
      return Icon(Icons.cruelty_free, size: size, color: iconColor);
    } else if (isCattle(species)) {
      return Icon(Icons.agriculture_rounded, size: size, color: iconColor);
    } else if (isSheep(species)) {
      return Icon(Icons.grass_rounded, size: size, color: iconColor);
    } else {
      return Icon(Icons.category_outlined, size: size, color: iconColor);
    }
  }
}
