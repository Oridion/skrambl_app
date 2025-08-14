import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SeedVaultRequiredScreen extends StatelessWidget {
  const SeedVaultRequiredScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(221, 189, 187, 176),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.lock, color: const Color.fromARGB(255, 60, 59, 58), size: 64),
              const SizedBox(height: 24),
              Text(
                'Seed Vault Required',
                style: TextStyle(
                  fontSize: 24,
                  fontFamily: GoogleFonts.spaceGrotesk().fontFamily,
                  color: const Color.fromARGB(255, 52, 51, 50),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'SKRAMBL requires a Solana Mobile device with Seed Vault support enabled.',
                style: TextStyle(
                  color: const Color.fromARGB(255, 51, 51, 50),
                  fontSize: 16,
                  fontFamily: GoogleFonts.bitter().fontFamily,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
