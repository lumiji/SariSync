import 'package:flutter/material.dart';
import 'package:sarisync/services/pdf_generator.dart';

class PDFBtn extends StatelessWidget {
  final VoidCallback? onTap;

  const PDFBtn({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    
    void showLoading(BuildContext context) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFFF8787)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Generate Report',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                Icon(Icons.picture_as_pdf, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
