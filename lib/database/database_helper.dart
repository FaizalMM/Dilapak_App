import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dilapak.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path,
        version: 2, onCreate: _createDB, onUpgrade: _onUpgrade);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Perbaiki permohonan lama: jika status 'menunggu' tapi belum ada berkas,
      // kembalikan ke 'baru' supaya user bisa lanjut upload berkas
      final rows = await db.rawQuery('''
        SELECT p.id FROM permohonan p
        WHERE p.status = 'menunggu'
        AND NOT EXISTS (
          SELECT 1 FROM berkas b WHERE b.permohonan_id = p.id
        )
      ''');
      for (final row in rows) {
        await db.update(
          'permohonan',
          {'status': 'baru'},
          where: 'id = ?',
          whereArgs: [row['id']],
        );
      }
    }
  }

  Future<void> _createDB(Database db, int version) async {
    // Tabel users
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nik TEXT,
        no_kk TEXT,
        nama_lengkap TEXT,
        email TEXT,
        no_whatsapp TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        jenis_kelamin TEXT,
        provinsi TEXT,
        kabupaten TEXT,
        kecamatan TEXT,
        kelurahan TEXT,
        is_verified_wa INTEGER DEFAULT 0,
        is_verified_berkas INTEGER DEFAULT 0,
        is_profil_lengkap INTEGER DEFAULT 0,
        kode_verifikasi TEXT,
        status_berkas TEXT DEFAULT 'belum',
        foto_ktp TEXT,
        foto_swafoto TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Tabel layanan (dummy seed)
    await db.execute('''
      CREATE TABLE layanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        kode TEXT NOT NULL UNIQUE,
        nama TEXT NOT NULL,
        kategori TEXT NOT NULL,
        deskripsi TEXT,
        syarat TEXT,
        estimasi_hari INTEGER DEFAULT 3,
        is_aktif INTEGER DEFAULT 1
      )
    ''');

    // Tabel permohonan
    await db.execute('''
      CREATE TABLE permohonan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nomor_resi TEXT NOT NULL UNIQUE,
        layanan_id INTEGER NOT NULL,
        jenis_layanan TEXT NOT NULL,
        nama_pemohon TEXT NOT NULL,
        nik_pemohon TEXT,
        kecamatan TEXT,
        kelurahan TEXT,
        alamat TEXT,
        rt TEXT,
        rw TEXT,
        status TEXT DEFAULT 'baru',
        catatan TEXT,
        tanggal_pengajuan TEXT DEFAULT CURRENT_TIMESTAMP,
        tanggal_selesai TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (layanan_id) REFERENCES layanan(id)
      )
    ''');

    // Tabel tracking
    await db.execute('''
      CREATE TABLE tracking (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        permohonan_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        deskripsi TEXT,
        waktu TEXT,
        is_done INTEGER DEFAULT 0,
        urutan INTEGER NOT NULL,
        FOREIGN KEY (permohonan_id) REFERENCES permohonan(id)
      )
    ''');

    // Tabel notifikasi
    await db.execute('''
      CREATE TABLE notifikasi (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        judul TEXT NOT NULL,
        isi TEXT NOT NULL,
        tipe TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    // Tabel berkas — menyimpan path foto KTP & swafoto yang diupload user
    await db.execute('''
      CREATE TABLE berkas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        permohonan_id INTEGER,
        nama_berkas TEXT NOT NULL,
        tipe_berkas TEXT NOT NULL,
        path_file TEXT NOT NULL,
        status TEXT DEFAULT 'menunggu',
        catatan_petugas TEXT,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await _seedLayanan(db);
  }

  Future<void> _seedLayanan(Database db) async {
    final list = [
      {
        'kode': 'KTP-001',
        'nama': 'KTP-el Baru (Rekam)',
        'kategori': 'Kependudukan',
        'deskripsi': 'Pembuatan KTP-el baru untuk pertama kali',
        'syarat': 'Surat pengantar RT/RW, Fotokopi KK, Pas foto 3x4',
        'estimasi_hari': 3
      },
      {
        'kode': 'KTP-002',
        'nama': 'KTP-el Karena Hilang',
        'kategori': 'Kependudukan',
        'deskripsi': 'Penggantian KTP-el yang hilang',
        'syarat': 'Surat kehilangan dari polisi, Fotokopi KK',
        'estimasi_hari': 3
      },
      {
        'kode': 'KTP-003',
        'nama': 'KTP-el Karena Rusak',
        'kategori': 'Kependudukan',
        'deskripsi': 'Penggantian KTP-el yang rusak',
        'syarat': 'KTP-el lama yang rusak, Fotokopi KK',
        'estimasi_hari': 2
      },
      {
        'kode': 'KTP-004',
        'nama': 'KTP-el Perubahan Data',
        'kategori': 'Kependudukan',
        'deskripsi': 'Perubahan data pada KTP-el',
        'syarat': 'Dokumen pendukung perubahan, KTP-el lama',
        'estimasi_hari': 5
      },
      {
        'kode': 'KK-001',
        'nama': 'Penerbitan KK Baru',
        'kategori': 'Kartu Keluarga',
        'deskripsi': 'Pembuatan Kartu Keluarga baru',
        'syarat': 'Surat nikah, KTP kedua orang tua, Surat pengantar',
        'estimasi_hari': 5
      },
      {
        'kode': 'KK-002',
        'nama': 'KK Karena Hilang/Rusak',
        'kategori': 'Kartu Keluarga',
        'deskripsi': 'Penggantian KK yang hilang atau rusak',
        'syarat': 'Surat kehilangan dari polisi atau KK rusak',
        'estimasi_hari': 3
      },
      {
        'kode': 'KK-003',
        'nama': 'KK Perubahan Data',
        'kategori': 'Kartu Keluarga',
        'deskripsi': 'Perubahan data anggota keluarga',
        'syarat': 'KK lama, Dokumen pendukung perubahan',
        'estimasi_hari': 5
      },
      {
        'kode': 'AK-001',
        'nama': 'Akta Kelahiran Baru',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan akta kelahiran',
        'syarat': 'Surat keterangan lahir, KK, KTP orang tua, Buku nikah',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-002',
        'nama': 'Akta Kelahiran Hilang',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penggantian akta kelahiran yang hilang',
        'syarat': 'Surat kehilangan dari polisi, Fotokopi akta lama',
        'estimasi_hari': 5
      },
      {
        'kode': 'AK-003',
        'nama': 'Akta Perkawinan',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan akta perkawinan',
        'syarat': 'Surat nikah dari KUA/gereja, KTP, KK',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-004',
        'nama': 'Akta Kematian',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan akta kematian',
        'syarat': 'Surat keterangan kematian, KK, KTP almarhum',
        'estimasi_hari': 3
      },
      {
        'kode': 'KIA-001',
        'nama': 'Kartu Identitas Anak (KIA)',
        'kategori': 'KIA',
        'deskripsi': 'Penerbitan KIA usia 0-17 tahun',
        'syarat': 'Akta kelahiran, KK, KTP orang tua',
        'estimasi_hari': 3
      },
      {
        'kode': 'PD-001',
        'nama': 'Surat Keterangan Pindah WNI',
        'kategori': 'Pindah Datang',
        'deskripsi': 'Surat keterangan pindah dalam negeri',
        'syarat': 'KK, KTP, Surat pengantar RT/RW',
        'estimasi_hari': 3
      },
      {
        'kode': 'PD-002',
        'nama': 'Surat Keterangan Pindah Masuk',
        'kategori': 'Pindah Datang',
        'deskripsi': 'Surat keterangan pindah masuk ke Kota Madiun',
        'syarat': 'Surat keterangan pindah dari daerah asal, KK, KTP',
        'estimasi_hari': 5
      },
      {
        'kode': 'SKD-001',
        'nama': 'Surat Keterangan Domisili',
        'kategori': 'Surat Keterangan',
        'deskripsi': 'Surat keterangan tempat tinggal/domisili',
        'syarat': 'KTP, KK, Surat pengantar RT/RW',
        'estimasi_hari': 2
      },
      // ── KTP TAMBAHAN ─────────────────────────────────────
      {
        'kode': 'KTP-005',
        'nama': 'KTP-el Pindah Datang Bagi WNI Dari Luar Negeri',
        'kategori': 'Kependudukan',
        'deskripsi':
            'Penerbitan KTP-el bagi WNI yang baru pindah datang dari luar negeri',
        'syarat': 'Paspor, SKPLN/SPLP, KK, Surat datang dari kedutaan',
        'estimasi_hari': 7
      },
      {
        'kode': 'KTP-006',
        'nama': 'KTP-el Pindah Datang WNA Dengan ITAP',
        'kategori': 'Kependudukan',
        'deskripsi':
            'Penerbitan KTP-el bagi WNA pemegang ITAP yang pindah datang',
        'syarat': 'Paspor, ITAP, Surat pindah datang dari instansi imigrasi',
        'estimasi_hari': 7
      },
      {
        'kode': 'KTP-007',
        'nama': 'KTP-el Perpanjangan WNA Dengan ITAP',
        'kategori': 'Kependudukan',
        'deskripsi': 'Perpanjangan KTP-el bagi WNA pemegang ITAP',
        'syarat': 'Paspor, ITAP yang masih berlaku, KTP-el lama',
        'estimasi_hari': 5
      },
      {
        'kode': 'KTP-008',
        'nama': 'KTP-el Pindah Datang',
        'kategori': 'Kependudukan',
        'deskripsi': 'Penerbitan KTP-el bagi WNI pindah datang antar daerah',
        'syarat': 'Surat keterangan pindah datang, KK baru',
        'estimasi_hari': 3
      },
      {
        'kode': 'KTP-009',
        'nama': 'KTP-el Luar Domisili (LD)',
        'kategori': 'Kependudukan',
        'deskripsi':
            'Penerbitan KTP-el luar domisili bagi yang berdomisili di luar daerah asal',
        'syarat':
            'KTP lama, Surat pengantar RT/RW, Surat keterangan domisili sementara',
        'estimasi_hari': 5
      },
      {
        'kode': 'KTP-010',
        'nama': 'KTP-el Ganti Foto/TTD',
        'kategori': 'Kependudukan',
        'deskripsi':
            'Penggantian KTP-el karena perubahan foto atau tanda tangan',
        'syarat': 'KTP-el lama, Pas foto terbaru, KK',
        'estimasi_hari': 3
      },
      {
        'kode': 'KTP-011',
        'nama': 'KTP-el SILANDEP',
        'kategori': 'Kependudukan',
        'deskripsi': 'Penerbitan KTP-el melalui sistem layanan antar jemput',
        'syarat': 'KK, Surat pengantar RT/RW, Pas foto',
        'estimasi_hari': 3
      },
      // ── SKPWNI / SKPWNA ──────────────────────────────────
      {
        'kode': 'SKP-001',
        'nama': 'Penerbitan SKPWNI',
        'kategori': 'Pindah Datang',
        'deskripsi': 'Surat Keterangan Pindah Warga Negara Indonesia',
        'syarat': 'KK, KTP, Surat pengantar RT/RW dan kelurahan',
        'estimasi_hari': 3
      },
      {
        'kode': 'SKP-002',
        'nama': 'Penerbitan SKPWNI Keluar + KK',
        'kategori': 'Pindah Datang',
        'deskripsi': 'SKPWNI keluar disertai penerbitan KK baru',
        'syarat': 'KK lama, KTP, Surat pengantar RT/RW',
        'estimasi_hari': 5
      },
      {
        'kode': 'SKP-003',
        'nama': 'Penerbitan SKPWNI Masuk + KK',
        'kategori': 'Pindah Datang',
        'deskripsi': 'SKPWNI masuk disertai penerbitan KK di daerah tujuan',
        'syarat': 'SKPWNI dari daerah asal, KTP, Surat pengantar RT/RW tujuan',
        'estimasi_hari': 5
      },
      {
        'kode': 'SKP-004',
        'nama': 'Penerbitan SKPWNA',
        'kategori': 'Pindah Datang',
        'deskripsi': 'Surat Keterangan Pindah Warga Negara Asing',
        'syarat': 'Paspor, ITAP/ITAS, Surat ijin tinggal dari imigrasi',
        'estimasi_hari': 7
      },
      // ── KK TAMBAHAN ──────────────────────────────────────
      {
        'kode': 'KK-004',
        'nama': 'KK SILANDEP',
        'kategori': 'Kartu Keluarga',
        'deskripsi': 'Penerbitan KK melalui sistem layanan antar jemput',
        'syarat': 'KK lama, Dokumen pendukung perubahan, KTP kepala keluarga',
        'estimasi_hari': 5
      },
      // ── SKTT ─────────────────────────────────────────────
      {
        'kode': 'SKTT-001',
        'nama': 'SKTT (Surat Keterangan Tinggal Tetap) bagi WNA',
        'kategori': 'Surat Keterangan',
        'deskripsi':
            'Surat keterangan tinggal tetap bagi Warga Negara Asing pemegang ITAP',
        'syarat': 'Paspor, ITAP, Surat rekomendasi imigrasi, KK',
        'estimasi_hari': 7
      },
      // ── AKTA TAMBAHAN ────────────────────────────────────
      {
        'kode': 'AK-005',
        'nama': 'Penerbitan Akta Perceraian',
        'kategori': 'Pencatatan Sipil',
        'deskripsi':
            'Penerbitan akta perceraian berdasarkan putusan pengadilan',
        'syarat':
            'Putusan pengadilan yang berkekuatan hukum tetap, Akta perkawinan, KTP, KK',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-006',
        'nama': 'Pencatatan Pengangkatan, Pengakuan dan Pengesahan Anak',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Pencatatan perubahan status anak secara hukum',
        'syarat':
            'Penetapan pengadilan, Akta kelahiran anak, KTP orang tua, KK',
        'estimasi_hari': 14
      },
      {
        'kode': 'AK-007',
        'nama': 'Pencatatan Perubahan Nama',
        'kategori': 'Pencatatan Sipil',
        'deskripsi':
            'Pencatatan perubahan nama berdasarkan penetapan pengadilan',
        'syarat': 'Penetapan pengadilan, Akta kelahiran, KTP, KK',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-008',
        'nama': 'Penerbitan Kutipan Akta Kelahiran',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan kutipan pertama akta kelahiran',
        'syarat': 'Surat keterangan lahir, KK, KTP orang tua, Buku nikah',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-009',
        'nama': 'Penerbitan Kutipan Ke II Akta Kelahiran',
        'kategori': 'Pencatatan Sipil',
        'deskripsi':
            'Penerbitan kutipan kedua akta kelahiran karena hilang atau rusak',
        'syarat': 'Surat kehilangan dari polisi, KK, KTP pemohon',
        'estimasi_hari': 7
      },
      {
        'kode': 'AK-010',
        'nama': 'Penerbitan Kutipan Akta Kelahiran Karena Hilang',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penggantian akta kelahiran yang hilang',
        'syarat':
            'Surat kehilangan dari polisi, Fotokopi akta lama jika ada, KK, KTP',
        'estimasi_hari': 5
      },
      {
        'kode': 'AK-011',
        'nama': 'Penerbitan Kutipan Akta Kematian',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penerbitan kutipan akta kematian',
        'syarat': 'Surat keterangan kematian, KK, KTP almarhum, KTP pelapor',
        'estimasi_hari': 3
      },
      {
        'kode': 'AK-012',
        'nama': 'Penerbitan Kutipan Akta Kematian Karena Hilang / Rusak',
        'kategori': 'Pencatatan Sipil',
        'deskripsi': 'Penggantian akta kematian yang hilang atau rusak',
        'syarat':
            'Surat kehilangan dari polisi, Fotokopi akta lama jika ada, KTP pelapor, KK',
        'estimasi_hari': 5
      },
      {
        'kode': 'AK-013',
        'nama': 'Penerbitan Surat Keterangan Lahir Mati WNI',
        'kategori': 'Pencatatan Sipil',
        'deskripsi':
            'Surat keterangan untuk bayi yang lahir dalam keadaan meninggal',
        'syarat':
            'Surat keterangan lahir mati dari rumah sakit/bidan, KK, KTP orang tua, Buku nikah',
        'estimasi_hari': 3
      },
      {
        'kode': 'AK-014',
        'nama': 'Keabsahan Akta-Akta',
        'kategori': 'Pencatatan Sipil',
        'deskripsi':
            'Legalisasi atau pengecekan keabsahan dokumen akta catatan sipil',
        'syarat': 'Akta asli yang akan dilegalisasi, KTP pemohon',
        'estimasi_hari': 3
      },
      // ── KIA TAMBAHAN ─────────────────────────────────────
      {
        'kode': 'KIA-002',
        'nama': 'KIA (Kartu Identitas Anak) WNA',
        'kategori': 'KIA',
        'deskripsi': 'Penerbitan KIA bagi anak Warga Negara Asing',
        'syarat':
            'Paspor anak, ITAP/ITAS, Akta kelahiran, KK, KTP orang tua WNA',
        'estimasi_hari': 5
      },
    ];
    for (final l in list) {
      await db.insert('layanan', l);
    }
  }

  // ═══════════ USER ═══════════

  Future<int> insertUser(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('users', data,
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  Future<Map<String, dynamic>?> getUserByWa(String noWa) async {
    final db = await database;
    final res =
        await db.query('users', where: 'no_whatsapp = ?', whereArgs: [noWa]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await database;
    final res = await db.query('users', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('users', data, where: 'id = ?', whereArgs: [id]);
  }

  Future<bool> isWaTaken(String noWa) async {
    final db = await database;
    final res =
        await db.query('users', where: 'no_whatsapp = ?', whereArgs: [noWa]);
    return res.isNotEmpty;
  }

  // ═══════════ LAYANAN ═══════════

  Future<List<Map<String, dynamic>>> getAllLayanan() async {
    final db = await database;
    return await db.query('layanan',
        where: 'is_aktif = 1', orderBy: 'kategori, nama');
  }

  Future<Map<String, dynamic>?> getLayananById(int id) async {
    final db = await database;
    final res = await db.query('layanan', where: 'id = ?', whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  // ═══════════ PERMOHONAN ═══════════

  Future<int> insertPermohonan(Map<String, dynamic> data) async {
    final db = await database;
    final id = await db.insert('permohonan', data);
    await _initTracking(db, id);
    return id;
  }

  Future<void> _initTracking(Database db, int permohonanId) async {
    final steps = [
      {
        'judul': 'Permohonan Diterima',
        'deskripsi': 'Permohonan berhasil diterima oleh sistem',
        'is_done': 1,
        'waktu': DateTime.now().toIso8601String(),
        'urutan': 1
      },
      {
        'judul': 'Verifikasi Dokumen',
        'deskripsi': 'Dokumen sedang diverifikasi oleh petugas',
        'is_done': 0,
        'waktu': null,
        'urutan': 2
      },
      {
        'judul': 'Sedang Diproses',
        'deskripsi': 'Permohonan sedang dalam proses penerbitan',
        'is_done': 0,
        'waktu': null,
        'urutan': 3
      },
      {
        'judul': 'Selesai',
        'deskripsi': 'Dokumen siap diambil di kantor Dispendukcapil',
        'is_done': 0,
        'waktu': null,
        'urutan': 4
      },
    ];
    for (final s in steps) {
      await db.insert('tracking', {...s, 'permohonan_id': permohonanId});
    }
  }

  Future<List<Map<String, dynamic>>> getPermohonanByUser(int userId) async {
    final db = await database;
    return await db.rawQuery('''
      SELECT p.*, l.nama as nama_layanan, l.kode as kode_layanan, l.kategori
      FROM permohonan p
      JOIN layanan l ON p.layanan_id = l.id
      WHERE p.user_id = ?
      ORDER BY p.tanggal_pengajuan DESC
    ''', [userId]);
  }

  Future<List<Map<String, dynamic>>> getTrackingByPermohonan(
      int permohonanId) async {
    final db = await database;
    return await db.query('tracking',
        where: 'permohonan_id = ?',
        whereArgs: [permohonanId],
        orderBy: 'urutan');
  }

  Future<Map<String, dynamic>?> getPermohonanById(int id) async {
    final db = await database;
    final res = await db.rawQuery('''
      SELECT p.*, l.nama as nama_layanan, l.kode as kode_layanan, l.kategori
      FROM permohonan p JOIN layanan l ON p.layanan_id = l.id
      WHERE p.id = ?
    ''', [id]);
    return res.isNotEmpty ? res.first : null;
  }

  Future<int> updatePermohonan(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db
        .update('permohonan', data, where: 'id = ?', whereArgs: [id]);
  }

  // ═══════════ NOTIFIKASI ═══════════

  Future<List<Map<String, dynamic>>> getNotifikasiByUser(int userId) async {
    final db = await database;
    return await db.query('notifikasi',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<int> getUnreadCount(int userId) async {
    final db = await database;
    final res = await db.rawQuery(
        'SELECT COUNT(*) as c FROM notifikasi WHERE user_id = ? AND is_read = 0',
        [userId]);
    return Sqflite.firstIntValue(res) ?? 0;
  }

  Future<void> markRead(int id) async {
    final db = await database;
    await db.update('notifikasi', {'is_read': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> markAllRead(int userId) async {
    final db = await database;
    await db.update('notifikasi', {'is_read': 1},
        where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<int> insertNotifikasi(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('notifikasi', data);
  }

  // ═══════════ BERKAS ═══════════

  Future<int> insertBerkas(Map<String, dynamic> data) async {
    final db = await database;
    return await db.insert('berkas', data);
  }

  Future<List<Map<String, dynamic>>> getBerkasByUser(int userId) async {
    final db = await database;
    return await db.query('berkas',
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getBerkasByTipe(
      int userId, String tipe) async {
    final db = await database;
    return await db.query('berkas',
        where: 'user_id = ? AND tipe_berkas = ?',
        whereArgs: [userId, tipe],
        orderBy: 'created_at DESC');
  }

  /// Menandai tracking step upload (urutan=1) sebagai selesai
  Future<void> markTrackingUploadDone(int permohonanId) async {
    final db = await database;
    await db.update(
      'tracking',
      {'is_done': 1, 'waktu': DateTime.now().toIso8601String()},
      where: 'permohonan_id = ? AND urutan = ?',
      whereArgs: [permohonanId, 1],
    );
  }

  Future<List<Map<String, dynamic>>> getBerkasByPermohonan(
      int permohonanId) async {
    final db = await database;
    return await db.query(
      'berkas',
      where: 'permohonan_id = ?',
      whereArgs: [permohonanId],
      orderBy: 'created_at ASC',
    );
  }

  Future<int> updateBerkas(int id, Map<String, dynamic> data) async {
    final db = await database;
    return await db.update('berkas', data, where: 'id = ?', whereArgs: [id]);
  }
}
