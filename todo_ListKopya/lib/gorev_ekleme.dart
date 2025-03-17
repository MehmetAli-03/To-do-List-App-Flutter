import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class GorevEkle extends StatefulWidget {
  const GorevEkle({super.key});

  @override
  State<GorevEkle> createState() => _GorevEkleState();
}

class _GorevEkleState extends State<GorevEkle> {
  TextEditingController adAlici = TextEditingController();
  TextEditingController tarihAlici = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blueAccent.withOpacity(0.3),
              Colors.greenAccent.withOpacity(0.3),
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 40),
            _buildTopIcons(context),
            SizedBox(height: 10),
            Image.asset("assets/todo2.png", width: 120, height: 125),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
              child: Text(
                "Yeni bir görev ekleyerek, yapılacak işleri daha düzenli hale getirebilirsiniz.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: adAlici,
                      decoration: InputDecoration(
                        labelText: "Görev Ekle",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: tarihAlici,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            selectedDate = pickedDate;
                            tarihAlici.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                          });
                        }
                      },
                      decoration: InputDecoration(
                        labelText: "Son Tarih",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          verileriEkle();
                        },
                        child: Text("Görevi Ekle", style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopIcons(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIconWithBackground(Icons.home, Colors.blue, () {
                Navigator.pop(context);
              }),
              _buildIconWithBackground(Icons.exit_to_app, Colors.green, () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const GorevEkle()),
                      (Route<dynamic> route) => false,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIconWithBackground(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }

  void verileriEkle() async {
    FirebaseAuth yetki = FirebaseAuth.instance;
    User? mevcutKullanici = yetki.currentUser;

    if (mevcutKullanici != null) {
      String uidTutucu = mevcutKullanici.uid;
      var zamanTutucu = DateTime.now();

      await FirebaseFirestore.instance
          .collection("Gorevler")
          .doc(uidTutucu)
          .collection("Gorevlerim")
          .doc(zamanTutucu.toString())
          .set({
        "ad": adAlici.text,
        "son tarih": tarihAlici.text,
        "zaman": zamanTutucu.toString(),
        "tam zaman": zamanTutucu,
      });
      Fluttertoast.showToast(msg: "Görev Eklendi");
    } else {
      Fluttertoast.showToast(msg: "Kullanıcı Giriş Yapmamış");
    }
  }
}
