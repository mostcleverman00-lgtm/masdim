import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Mainpage extends StatefulWidget {
  const Mainpage({super.key});

  @override
  State<Mainpage> createState() => _MainpageState();
}


class _MainpageState extends State<Mainpage> {
  final url = Uri.parse('http://172.16.118.86/app_keuangan_api/catatan_keuangan.php');
  Future<List<dynamic>> getCatatanKeuangan() async {
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      throw Exception('Error koneksi: $e');
    }
  }

 //fungsi post catatan keuangan:
  Future <void> postCatatanKeuangan(String nominal, String kategori) async {
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "nominal": nominal,
          "kategori": kategori,
        }),
      );
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'sukses') {
          //pesan sukses menggunakan SnackBar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil ditambahkan'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menambahkan catatan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Gagal menyimpan ke database');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data gagal disimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void TampilkanForm(BuildContext context) {
    final TextEditingController nominalController = TextEditingController();
    final List<String> kategoriList = ['Pemasukan', 'Belanja'];
    
    // Perbaikan 1: Ubah default awal menjadi null agar memicu hint 'Pilih Kategori'
    String? selectedKategori; 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        // Gunakan StatefulBuilder agar UI di dalam BottomSheet bisa merender ulang saat dropdown dipilih
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 25,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Tambah Catatan Keuangan',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  TextField(
                    controller: nominalController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nominal',
                      prefixText: 'Rp ',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: selectedKategori, // Pasangkan dengan variabel penampung
                    hint: const Text('Pilih Kategori'),
                    items: kategoriList.map((String kategori) {
                      return DropdownMenuItem<String>(
                        value: kategori,
                        child: Text(kategori),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      // Perbaikan 2: Gunakan setModalState untuk mengubah nilai di dalam BottomSheet
                      setModalState(() {
                        selectedKategori = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () async {
                      // Perbaikan 3: Validasi apakah nominal dan kategori sudah diisi
                      if (nominalController.text.isEmpty || selectedKategori == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Harap isi nominal dan pilih kategori!'),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      // Kirim data sesuai dengan kategori yang dipilih dari dropdown
                      await postCatatanKeuangan(nominalController.text, selectedKategori!);
                      
                      nominalController.clear();
                      
                      // Memperbarui halaman utama (Mainpage) agar langsung menampilkan data terbaru
                      setState(() {}); 
                      
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Simpan',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void hapusCatatanKeuangan(int id) async {
    try {
      final response = await http.delete(Uri.parse('$url?id=$id'));
      if (response.statusCode == 200) {
        var responseData = jsonDecode(response.body);
        if (responseData['status'] == 'sukses') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Catatan berhasil dihapus'),
              backgroundColor: Colors.green,
            ),
          );
          setState(() {}); // Memperbarui halaman utama setelah penghapusan
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus catatan'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Gagal menghapus dari database');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data gagal dihapus: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aplikasi Dimas Finnance'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getCatatanKeuangan(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada catatan transaksi'));
          }
          List<dynamic> listData = snapshot.data!;
          return ListView.builder(
            itemCount: listData.length,
            itemBuilder: (context, index) {
              var catatan = listData[index];
              bool isPemasukan = catatan['kategori'].toString().toLowerCase() == 'pemasukan';
              //ambil id dari catatan untuk keperluan hapus
              //parsing id dari dynamic ke int, jika gagal parsing maka default ke 0
              int hapusId = int.tryParse(catatan['id'].toString()) ?? 0;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: isPemasukan ? Colors.green.shade100 : Colors.red.shade100,
                    child: Icon(
                      isPemasukan ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isPemasukan ? Colors.green : Colors.red,
                    ),
                  ),
                  title: Text(
                    'Rp. ${catatan['nominal']}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Keterangan: ${catatan['kategori']}'),

                  trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            // Tampilkan dialog konfirmasi sebelum menghapus (Opsional, tapi bagus untuk UX)
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Hapus Catatan'),
                  content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // Tutup dialog
                        hapusCatatanKeuangan(hapusId); // Jalankan fungsi hapus
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );
          },
        ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => TampilkanForm(context),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}