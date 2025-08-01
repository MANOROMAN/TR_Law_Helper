import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LawyerContactScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Avukatla İletişime Geç"),
        backgroundColor: const Color(0xFF2D3E50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "İletişim Seçenekleri",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3E50),
              ),
            ),
            const SizedBox(height: 20),
            _buildContactCard(
              icon: FontAwesomeIcons.phone,
              title: "Telefon Görüşmesi",
              subtitle: "Acil durumlar için doğrudan arayın",
              buttonText: "Ara",
              onPressed: () => _makePhoneCall("+90 555 123 4567"),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: FontAwesomeIcons.whatsapp,
              title: "WhatsApp",
              subtitle: "Mesajlaşma ile destek alın",
              buttonText: "Mesaj Gönder",
              onPressed: () => _sendWhatsApp("+90 555 123 4567"),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: FontAwesomeIcons.envelope,
              title: "E-posta",
              subtitle: "Detaylı sorularınız için e-posta gönderin",
              buttonText: "E-posta Gönder",
              onPressed: () => _sendEmail("avukat@example.com"),
            ),
            const SizedBox(height: 16),
            _buildContactCard(
              icon: FontAwesomeIcons.calendar,
              title: "Randevu Al",
              subtitle: "Yüz yüze görüşme için randevu planlayın",
              buttonText: "Randevu Al",
              onPressed: () => _showAppointmentDialog(context),
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade700,
                    size: 30,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Çalışma Saatleri",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Pazartesi - Cuma: 09:00 - 18:00\nCumartesi: 09:00 - 13:00",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.blue.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFF2D3E50),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3E50),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2D3E50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(buttonText),
          ),
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  Future<void> _sendWhatsApp(String phoneNumber) async {
    final Uri launchUri = Uri.parse('https://wa.me/$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _sendEmail(String email) async {
    final Uri launchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=Hukuki Danışmanlık Talebi',
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  void _showAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Randevu Talebi"),
          content: const Text(
            "Randevu talebiniz alınmıştır. En kısa sürede size dönüş yapılacaktır.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tamam"),
            ),
          ],
        );
      },
    );
  }
}
