import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'giris_ekrani.dart';

class KayitOlEkrani extends StatefulWidget {
  const KayitOlEkrani({super.key});

  @override
  State<KayitOlEkrani> createState() => _KayitOlEkraniState();
}

class _KayitOlEkraniState extends State<KayitOlEkrani> {
  late String kullaniciAdi, email, sifre;
  final _formAnahtari = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Kayıt Ol',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent.withOpacity(0.3),
              Colors.greenAccent.withOpacity(0.3),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
            child: Form(
              key: _formAnahtari,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.person, size: 80, color: Colors.green),
                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      "Hoş Geldiniz",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    onChanged: (alinanAd) {
                      kullaniciAdi = alinanAd;
                    },
                    validator: (alinanAd) {
                      if (alinanAd == null || alinanAd.isEmpty) {
                        return "Kullanıcı adı boş olamaz!";
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Kullanıcı Adı',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 12),
                  TextFormField(
                    onChanged: (alinanEmail) {
                      email = alinanEmail;
                    },
                    validator: (alinanEmail) {
                      return alinanEmail!.contains('@') ? null : "E-posta geçersiz";
                    },
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      hintText: 'E-posta',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formAnahtari.currentState!.validate()) {
                          kayitEkle();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Kayıt Ol',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
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

  void kayitEkle() async {
    if (!_formAnahtari.currentState!.validate()) return;

    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: sifre);

      await userCredential.user!.updateDisplayName(kullaniciAdi);

      String uidTutucu = userCredential.user!.uid; // UID al

      await FirebaseFirestore.instance.collection("kullanicilar").doc(uidTutucu).set({
        "KullaniciAdi": kullaniciAdi,
        "email": email
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kayıt başarılı!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => GirisEkrani()),
      );
    } catch (e) {
      String hataMesaji = "Kayıt başarısız!";
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          hataMesaji = "Bu e-posta adresi zaten kullanımda.";
        } else if (e.code == 'weak-password') {
          hataMesaji = "Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.";
        } else {
          hataMesaji = e.message ?? hataMesaji;
        }
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hataMesaji)),
      );
    }
  }

}
