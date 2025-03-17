import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:todo_list/gorev_ekleme.dart';
import 'giris_ekrani.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? mevcutKullaniciUidTutucu;
  Map<String, bool> checkboxDurumlari = {};

  @override
  void initState() {
    super.initState();
    mevcutKullaniciUidsiAl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery
            .of(context)
            .size
            .width,
        height: MediaQuery
            .of(context)
            .size
            .height,
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
            SizedBox(height: 60),
            _buildTopIcons(context),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection("Gorevler")
                    .doc(mevcutKullaniciUidTutucu)
                    .collection("Gorevlerim")
                    .snapshots(),
                builder: (context, veriTabaniVerilerim) {
                  if (veriTabaniVerilerim.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (veriTabaniVerilerim.hasError) {
                    return Center(child: Text(
                        'Bir hata oluştu: ${veriTabaniVerilerim.error}'));
                  } else if (!veriTabaniVerilerim.hasData || veriTabaniVerilerim
                      .data!.docs.isEmpty) {
                    return Center(child: Text('Görevler bulunamadı.'));
                  } else {
                    final alinanVeri = veriTabaniVerilerim.data!.docs;
                    return ListView.builder(
                      itemCount: alinanVeri.length,
                      itemBuilder: (context, index) {
                        var gorev = alinanVeri[index];
                        var eklemeZamani = (alinanVeri[index]["tam zaman"] as Timestamp)
                            .toDate();
                        String gorevId = gorev.id;
                        bool isChecked = checkboxDurumlari[gorevId] ?? false;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            color: Colors.white.withOpacity(0.9),
                            child: ListTile(
                              leading: Checkbox(
                                value: isChecked,
                                onChanged: (bool? value) {
                                  setState(() {
                                    checkboxDurumlari[gorevId] = value ?? false;
                                  });
                                },
                              ),
                              title: Text(
                                gorev["ad"] ?? "Görev adı yok",
                                style: TextStyle(

                                  fontWeight: FontWeight.bold,
                                  decoration: isChecked ? TextDecoration
                                      .lineThrough : TextDecoration.none,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Eklenme Zamanı: ${DateFormat.yMd()
                                      .add_jm()
                                      .format(eklemeZamani)}"),
                                  Text("Son tarih: ${gorev["son tarih"] ??
                                      "Tarih belirtilmemiş"}"),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteTask(gorevId);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add, color: Colors.white),
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GorevEkle()),
          );
        },
      ),
    );
  }

  Widget _buildTopIcons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconWithBackground(Icons.home, Colors.blue, () {}),
          _buildIconWithBackground(Icons.exit_to_app, Colors.green, () async {
            await FirebaseAuth.instance.signOut();
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const GirisEkrani()),
                  (Route<dynamic> route) => false,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIconWithBackground(IconData icon, Color color,
      VoidCallback onTap) {
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

  void mevcutKullaniciUidsiAl() async {
    FirebaseAuth yetki = FirebaseAuth.instance;
    User? mevcutKullanici = yetki.currentUser;
    if (mevcutKullanici != null) {
      setState(() {
        mevcutKullaniciUidTutucu = mevcutKullanici.uid;
      });
    }
  }

  void _deleteTask(String taskId) async {
    try {
      await FirebaseFirestore.instance
          .collection("Gorevler")
          .doc(mevcutKullaniciUidTutucu)
          .collection("Gorevlerim")
          .doc(taskId)
          .delete();
    } catch (e) {
      print("Error deleting task: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Görev silinirken hata oluştu')),
      );
    }
  }
}