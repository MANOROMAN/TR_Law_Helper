import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firebase_service.dart';
import '../../constants/app_colors.dart';
import '../home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firebaseService = FirebaseService();
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _selectedGender;
  int? _selectedAge;
  String _selectedCountry = 'Türkiye';

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  final List<String> _genders = ['Erkek', 'Kadın', 'Diğer'];
  final List<String> _countries = [
    'Türkiye', 'Almanya', 'Fransa', 'İngiltere', 'İtalya', 'İspanya',
    'Hollanda', 'Belçika', 'Avusturya', 'İsviçre', 'Diğer'
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _firebaseService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        gender: _selectedGender!,
        age: _selectedAge!,
        country: _selectedCountry,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Hesabınız başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'Kayıt oluşturulamadı. Lütfen bilgilerinizi kontrol edin.';
      if (e.code == 'weak-password') {
        message = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
      } else if (e.code == 'email-already-in-use') {
        message = 'Bu e-posta adresi ile zaten bir hesap mevcut.';
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Beklenmedik bir hata oluştu: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlue, // Fallback color
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primaryBlue,
              AppColors.secondaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom - 40,
              ),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Başlık
                      const SizedBox(height: 20),
                      const Text(
                        'TCK AI',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Yeni Hesap Oluştur',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: AppColors.lightWhite,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Ad ve Soyad
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _firstNameController,
                              style: const TextStyle(color: AppColors.white),
                              decoration: _buildInputDecoration(labelText: 'Ad', prefixIcon: Icons.person_outline),
                              validator: (value) => value == null || value.isEmpty ? 'Ad gerekli' : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _lastNameController,
                              style: const TextStyle(color: AppColors.white),
                              decoration: _buildInputDecoration(labelText: 'Soyad', prefixIcon: Icons.person_outline),
                              validator: (value) => value == null || value.isEmpty ? 'Soyad gerekli' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      
                      // E-posta
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _buildInputDecoration(labelText: 'E-posta', prefixIcon: Icons.email_outlined),
                        validator: (value) => value == null || value.isEmpty || !value.contains('@') ? 'Geçerli bir e-posta girin' : null,
                      ),
                      const SizedBox(height: 20),

                      // Cinsiyet ve Yaş
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedGender,
                              hint: const Text('Cinsiyet', style: TextStyle(color: AppColors.lightWhite, fontSize: 14)),
                              style: const TextStyle(color: AppColors.white, fontSize: 14),
                              dropdownColor: AppColors.secondaryBlue,
                              decoration: _buildInputDecoration(prefixIcon: Icons.wc),
                              items: _genders.map((gender) => DropdownMenuItem(value: gender, child: Text(gender, style: const TextStyle(fontSize: 14)))).toList(),
                              onChanged: (value) => setState(() => _selectedGender = value),
                              validator: (value) => value == null ? 'Cinsiyet seçin' : null,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: _selectedAge,
                              hint: const Text('Yaş', style: TextStyle(color: AppColors.lightWhite, fontSize: 14)),
                              style: const TextStyle(color: AppColors.white, fontSize: 14),
                              dropdownColor: AppColors.secondaryBlue,
                              decoration: _buildInputDecoration(prefixIcon: Icons.cake_outlined),
                              items: List.generate(83, (index) => index + 18)
                                  .map((age) => DropdownMenuItem(value: age, child: Text('$age', style: const TextStyle(fontSize: 14))))
                                  .toList(),
                              onChanged: (value) => setState(() => _selectedAge = value),
                              validator: (value) => value == null ? 'Yaş seçin' : null,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Ülke
                      DropdownButtonFormField<String>(
                        value: _selectedCountry,
                        style: const TextStyle(color: AppColors.white),
                        dropdownColor: AppColors.secondaryBlue,
                        decoration: _buildInputDecoration(labelText: 'Ülke', prefixIcon: Icons.flag_outlined),
                        items: _countries.map((country) => DropdownMenuItem(value: country, child: Text(country))).toList(),
                        onChanged: (value) => setState(() => _selectedCountry = value!),
                      ),
                      const SizedBox(height: 20),
                      
                      // Şifre
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _buildInputDecoration(
                          labelText: 'Şifre',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, color: AppColors.lightWhite),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                        ),
                        validator: (value) => value == null || value.length < 6 ? 'Şifre en az 6 karakter olmalı' : null,
                      ),
                      const SizedBox(height: 20),
                      
                      // Şifre Tekrar
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        style: const TextStyle(color: AppColors.white),
                        decoration: _buildInputDecoration(
                          labelText: 'Şifreyi Onayla',
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, color: AppColors.lightWhite),
                            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          ),
                        ),
                        validator: (value) => value != _passwordController.text ? 'Şifreler eşleşmiyor' : null,
                      ),
                      const SizedBox(height: 40),
                      
                      // Kayıt Ol Butonu
                      _isLoading
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : ElevatedButton(
                              onPressed: _signUp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.white,
                                foregroundColor: AppColors.primaryBlue,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                splashFactory: NoSplash.splashFactory,
                              ),
                              child: const Text('Hesap Oluştur', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                      
                      const SizedBox(height: 20),
                      
                      // Giriş Yap Linki
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Zaten bir hesabınız var mı?', style: TextStyle(color: AppColors.lightWhite)),
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.white,
                              splashFactory: NoSplash.splashFactory,
                            ),
                            child: const Text('Giriş Yap', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({String? labelText, required IconData prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: AppColors.lightWhite),
      hintStyle: const TextStyle(color: AppColors.lightWhite),
      prefixIcon: Icon(prefixIcon, color: AppColors.lightWhite),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: AppColors.white, width: 1.5)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: const BorderSide(color: Colors.redAccent, width: 1.5)),
    );
  }
}
