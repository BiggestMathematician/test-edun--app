import 'dart:math';
import 'package:eschool/data/models/subjectMark.dart';
import 'package:flutter/material.dart';

class CurvedSlider extends StatefulWidget {
  final SubjectMark subjectMark;

  CurvedSlider({required this.subjectMark});

  @override
  _CurvedSliderState createState() => _CurvedSliderState();
}

class _CurvedSliderState extends State<CurvedSlider> {
  late double _percentage; 
  late String _subjectColor;

  @override
  void initState() {
    super.initState();
    _percentage = widget.subjectMark.avarageClass;
    _subjectColor = widget.subjectMark.subjectColor;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Column(
          children: [
            CustomPaint(
              size: Size(300, 50), // Taille de la zone de dessin
              painter: _CurvedSliderPainter(_percentage, _subjectColor),
            ),

            Text(
              '${_percentage.toStringAsFixed(0)}%',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
              ),
            ),
            Text(
              widget.subjectMark.subjectName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.start,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 12.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CurvedSliderPainter extends CustomPainter {
  final double percentage;
  final String subjectColor;

  _CurvedSliderPainter(this.percentage, this.subjectColor);

  Color _parseColor(String hexColor) {
    // Vérifier si la chaîne commence par un #
    if (hexColor.startsWith('#')) {
      hexColor = hexColor.replaceFirst(
          '#', '0xFF'); // Ajoute 0xFF pour l'opacité si nécessaire
    }

    // Tente de parser la couleur en entier
    try {
      return Color(int.parse(hexColor));
    } catch (e) {
      // Si parsing échoue, retourner une couleur par défaut (par exemple, rouge)
      print("Erreur de parsing de la couleur : $e");
      return Colors.red;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paintBackground = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.fill;

    final Paint paintProgress = Paint()
      ..color = _parseColor (subjectColor)/*Color(int.parse(subjectColor.replaceFirst('#', '0xFF')))*/
      ..style = PaintingStyle.fill;

    final Offset center = Offset(size.width / 2, size.height);
    final double radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Début de l'arc à 180° (gauche)
      pi, // Largeur de l'arc à 180° (complète)
      true,
      paintBackground,
    );

    // Calculer l'angle de progression en fonction de percentage
    // Pour une valeur max de 20 (au lieu de 180)
    double progressAngle = pi + (percentage / 20) * pi;

    // Dessiner la barre de progression
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi, // Début de l'arc à 180°
      progressAngle - pi, // Longueur de l'arc proportionnelle à la note
      true,
      paintProgress,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
