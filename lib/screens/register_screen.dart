import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tersalin ke clipboard')));
  }

  @override
  Widget build(BuildContext context) {
    // Replace these placeholders with real company contact details.
    const supportEmail = 'support@yourcompany.com';
    const supportPhone = '+62-811-0000-000';

    return Scaffold(
      appBar: AppBar(title: const Text('Cara Mendapatkan Akun')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Untuk mendapatkan akun pengguna:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            const Text(
              '1. Hubungi perusahaan/penyedia layanan Anda untuk meminta akses akun.',
            ),
            const SizedBox(height: 6),
            const Text(
              '2. Berikan informasi yang diminta (nama, organisasi, posisi, dsb).',
            ),
            const SizedBox(height: 6),
            const Text(
              '3. Setelah disetujui, Anda akan menerima username dan password melalui email atau kontak resmi.',
            ),
            const SizedBox(height: 18),
            const Text(
              'Kontak dukungan (contoh):',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email dukungan'),
              subtitle: const Text(supportEmail),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(context, supportEmail),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('Telepon / WhatsApp'),
              subtitle: const Text(supportPhone),
              trailing: IconButton(
                icon: const Icon(Icons.copy),
                onPressed: () => _copyToClipboard(context, supportPhone),
              ),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali ke Login'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
