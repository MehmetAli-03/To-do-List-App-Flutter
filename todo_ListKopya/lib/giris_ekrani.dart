import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'ana_sayfa.dart';
import 'kayit_ol.dart';

class GirisEkrani extends StatefulWidget {
  const GirisEkrani({super.key});

  @override
  State<GirisEkrani> createState() => _GirisEkraniState();
}

class _GirisEkraniState extends State<GirisEkrani> {
  final _formKey = GlobalKey<FormState>(); // Global Key eklendi
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth eklendi

  late String email, sifre;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.3),
              Colors.greenAccent.withOpacity(0.3)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
            child: Form( // Form eklendi
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/todo.png',
                    height: 180,
                  ),
                  const SizedBox(height: 10),

                  // Mail Girişi
                  TextFormField(
                    onChanged: (alinanEmail) {
                      email = alinanEmail;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "E-posta boş olamaz!";
                      } else if (!value.contains('@')) {
                        return "Geçerli bir e-posta giriniz!";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Mail Hesabı',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 15),

                  // Şifre Girişi
                  TextFormField(
                    onChanged: (alinanSifre) {
                      sifre = alinanSifre;
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Şifre boş olamaz!";
                      } else if (value.length < 6) {
                        return "Şifre en az 6 karakter olmalı!";
                      }
                      return null;
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: 'Şifre',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: const TextStyle(color: Colors.black),
                  ),
                  const SizedBox(height: 10),

                  // Şifremi Unuttum
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        "Şifremi Unuttum",
                        style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  // Giriş Yap Butonu
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: girisYap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Giriş Yap",
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Kayıt Ol Butonu
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.amber.withOpacity(0.3),
                          blurRadius: 8.0,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const KayitOlEkrani()),
                        );
                      },
                      child: const Text(
                        "Kayıt Ol",
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Firebase ile Giriş Yap Fonksiyonu
  void girisYap() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: sifre);

      // Giriş başarılı -> Ana sayfaya yönlendir
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) =>  HomePage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Giriş Başarılı!")),
      );
    } catch (e) {
      // Hata mesajını göster
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Giriş Başarısız: ")),
      );
    }
  }
}
