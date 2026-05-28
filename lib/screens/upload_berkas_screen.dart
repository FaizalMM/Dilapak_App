import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_theme.dart';
import '../database/database_helper.dart';
import '../utils/session_manager.dart';
import 'status_permohonan_screen.dart';

// ─── MODEL BERKAS ───

class _BerkasItem {
  final String id;
  final String nama;
  final String format;
  final bool wajib;
  final bool opsional;
  final String? keterangan;
  String? filePath;
  String? fileName;

  _BerkasItem({
    required this.id,
    required this.nama,
    required this.format,
    required this.wajib,
    this.opsional = false,
    this.keterangan,
  });
}

class _BerkasLayanan {
  static List<_BerkasItem> getBerkasWajib(
      String kodeLayanan, String namaLayanan) {
    switch (kodeLayanan) {
      case 'KK-001': // Penerbitan KK
        return [
          _BerkasItem(
              id: 'kk_lama',
              nama: 'KK Lama',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'buku_nikah',
              nama:
                  'Fotokopi Buku Nikah / Akta Perkawinan / Perceraian / SPTJM Perkawinan atau Perceraian / Akta Kematian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true,
              keterangan: 'Salah satu dokumen sesuai status perkawinan'),
          _BerkasItem(
              id: 'skpwni',
              nama: 'Surat Keterangan Pindah WNI (SKPWNI)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'skp_ln',
              nama: 'Surat Keterangan Pindah LN dari Disdukcapil',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'petikan_kepres',
              nama: 'Petikan Kepres tentang Pewarganegaraan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'dok_perjalanan',
              nama: 'Dokumen Perjalanan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'KIA-001': // KIA WNI
        return [
          _BerkasItem(
              id: 'akta_kelahiran',
              nama: 'Fotokopi Akta Kelahiran',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Fotokopi Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_ortu',
              nama: 'Fotokopi KTP-el Orang Tua',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'pas_foto',
              nama: 'Pas Foto 2x3 (2 lembar)',
              format: 'JPG, PNG (Maks. 2MB)',
              wajib: true,
              keterangan:
                  'Background Biru untuk Tahun Lahir Genap, Background Merah untuk Tahun Lahir Ganjil'),
        ];

      case 'KIA-002': // KIA WNA
        return [];

      case 'AK-014': // Keabsahan Akta-Akta
        return [
          _BerkasItem(
              id: 'fotokopi_kutipan_akta',
              nama: 'Fotokopi Kutipan Akta',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_pemohon',
              nama: 'KTP-el Pemohon',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'AK-013': // Penerbitan Surat Keterangan Lahir Mati WNI
        return [
          _BerkasItem(
              id: 'surat_lahir_mati',
              nama: 'Surat Keterangan Kematian dari RS / Bidan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga Orang Tua',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_perkawinan_ortu',
              nama: 'Akta Perkawinan Orang Tua',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_ortu',
              nama: 'KTP Orang Tua',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'formulir',
              nama: 'Formulir Pengajuan Surat Keterangan Lahir Mati',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'SKP-004': // Penerbitan SKPWNA
        return [
          _BerkasItem(
              id: 'sktt',
              nama: 'Foto SKTT Asli',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk_sponsor',
              nama: 'KK Sponsor',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'sk_pindah_imigrasi',
              nama: 'Surat Keterangan Pindah dari Imigrasi',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kitas',
              nama: 'Foto KITAS WNA',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_nikah',
              nama: 'Foto Surat Nikah KUA / Akta Pernikahan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'ktp_sponsor',
              nama: 'KTP Sponsor',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'SKP-003': // Penerbitan SKPWNI Masuk + KK
        return [
          _BerkasItem(
              id: 'skpwni_masuk',
              nama: 'SKPWNI Masuk dari Daerah Asal',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk_madiun',
              nama: 'KK Kota Madiun (jika numpang KK)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'surat_nikah',
              nama: 'Foto Surat Nikah (jika status nikah)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'surat_pernyataan_wali',
              nama: 'Surat Pernyataan Wali untuk Titip Anak di KK',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'sertifikat_rumah',
              nama: 'Sertifikat Rumah untuk Menempati Alamat di Kota Madiun',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'sk_tidak_keberatan',
              nama:
                  'Surat Keterangan Tidak Keberatan dari Pemilik Rumah (jika kontrak/kost)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'SKP-002': // Penerbitan SKPWNI Keluar + KK
        return [
          _BerkasItem(
              id: 'kk_asli',
              nama: 'KK Asli',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_nikah',
              nama: 'Surat Nikah',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'alamat_tujuan',
              nama: 'Keterangan Alamat Tujuan Pindah',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-011': // KTP-EL SILANDEP
        return [
          _BerkasItem(
              id: 'ktp_lama',
              nama: 'KTP Lama',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KK-004': // KK SILANDEP
        return [
          _BerkasItem(
              id: 'kk_lama',
              nama: 'KK Lama',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_cerai',
              nama: 'Akta Cerai',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'hak_asuh',
              nama: 'Hak Asuh Anak',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'buku_nikah',
              nama: 'Buku Nikah',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'KTP-010': // KTP-el Ganti Foto/TTD
        return [
          _BerkasItem(
              id: 'ktp_lama',
              nama: 'KTP Lama Asli',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_pernyataan',
              nama: 'Surat Pernyataan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Fotokopi Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'AK-010': // Penerbitan Kutipan Akta Kelahiran Karena Hilang
        return [
          _BerkasItem(
              id: 'kk',
              nama: 'KK Terbaru',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_kehilangan',
              nama: 'Surat Kehilangan Akta Kelahiran dari Kepolisian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_pelapor',
              nama: 'KTP Pelapor',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'foto_akta_hilang',
              nama: 'Foto Kutipan Akta Kelahiran yang Hilang',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'AK-012': // Penerbitan Kutipan Akta Kematian Karena Hilang / Rusak
        return [
          _BerkasItem(
              id: 'kk',
              nama: 'KK Terbaru',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_kehilangan',
              nama: 'Surat Kehilangan Kutipan Akta Kematian dari Kepolisian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_rusak',
              nama: 'Kutipan Akta Kematian yang Rusak',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'ktp_pelapor',
              nama: 'KTP-el Pelapor',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'foto_akta_hilang',
              nama: 'Foto Kutipan Akta Kematian yang Hilang',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'AK-011': // Penerbitan Kutipan Akta Kematian
        return [
          _BerkasItem(
              id: 'surat_kematian',
              nama:
                  'Surat Kematian dari RS / Kelurahan / Instansi Berwenang / SPTJM Kematian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_kk_nikah',
              nama:
                  'KTP-el, KK, Buku Nikah / Akta Perkawinan / Ijazah / Dokumen Perjalanan Almarhum',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_pelapor',
              nama: 'KTP-el Pelapor',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_saksi',
              nama: 'KTP-el 2 Orang Saksi',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_kuasa',
              nama: 'Surat Kuasa (bila dikuasakan)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'AK-008': // Penerbitan Kutipan Akta Kelahiran
        return [
          _BerkasItem(
              id: 'surat_lahir',
              nama:
                  'Surat Kelahiran dari RS / Bidan / Penolong Kelahiran / SPTJM Kelahiran',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk_ktp_ortu',
              nama: 'KK dan KTP-el Orang Tua',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'nikah_ortu',
              nama: 'Surat Nikah Orang Tua / SPTJM Pasangan Suami Istri',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_saksi',
              nama: 'KTP-el 2 Orang Saksi',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_kuasa',
              nama: 'Surat Kuasa (bila dikuasakan)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'ktp_pelapor',
              nama: 'KTP-el Pelapor (bila dikuasakan)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'AK-009': // Penerbitan Kutipan Ke II Akta Kelahiran
        return [
          _BerkasItem(
              id: 'kk',
              nama: 'KK Terbaru',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_kehilangan',
              nama: 'Surat Kehilangan Kutipan Akta Kelahiran dari Kepolisian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_nikah',
              nama: 'Surat Nikah / Akta Perkawinan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'foto_akta_hilang',
              nama: 'Foto Kutipan Akta Kelahiran yang Hilang',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'ktp_pelapor',
              nama: 'KTP-el Pelapor',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-009': // KTP-el Luar Domisili (LD)
        return [
          _BerkasItem(
              id: 'kk_asal',
              nama: 'KK Daerah Asal Terbaru',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_lama',
              nama: 'KTP-el Asli / Surat Kehilangan dari Kepolisian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'SKTT-001': // SKTT bagi WNA
        return [
          _BerkasItem(
              id: 'kk_sponsor',
              nama: 'KK Sponsor (Kelurahan harus sama dengan domisili)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kitas',
              nama: 'KITAS dari Imigrasi',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'paspor',
              nama: 'Passport WNA',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'visa',
              nama: 'Visa WNA',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'sk_domisili',
              nama: 'Surat Keterangan Domisili dari Kelurahan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'stld',
              nama: 'STLD (Surat Tanda Lapor Diri) WNA dari Kepolisian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-003': // KTP-el Karena Rusak
        return [
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_rusak',
              nama: 'KTP-el yang Rusak',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-002': // KTP-el Karena Hilang
        return [
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_kehilangan',
              nama: 'Surat Keterangan Hilang dari Kepolisian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-004': // KTP-el Karena Perubahan Data
        return [
          _BerkasItem(
              id: 'ktp_lama',
              nama: 'KTP-el Lama',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'KK Terbaru',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-008': // KTP-el Pindah Datang
        return [
          _BerkasItem(
              id: 'kk_baru',
              nama: 'KK Baru',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_asli',
              nama: 'KTP-el Asli dari Daerah Asal',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'skpwni',
              nama: 'SKPWNI (jika KTP-el Asli Ditarik Daerah Asal)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'KTP-001': // KTP-el Baru Rekam
        return [
          _BerkasItem(
              id: 'kk',
              nama: 'Fotokopi Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kia',
              nama: 'KIA (jika sudah memiliki)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'KK-003': // KK Perubahan Data
        return [
          _BerkasItem(
              id: 'kk_lama',
              nama: 'KK Lama',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'skpwni',
              nama: 'Surat Keterangan Pindah WNI (SKPWNI)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'sk_asuh',
              nama: 'Surat Kuasa Pengasuhan Anak',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'pernyataan_anggota',
              nama:
                  'Surat Pernyataan Bersedia Menerima sebagai Anggota Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'buku_nikah',
              nama:
                  'Fotokopi Buku Nikah / Akta Perkawinan / Perceraian / SPTJM Perkawinan atau Perceraian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'bukti_perubahan',
              nama:
                  'Surat Keterangan / Bukti Perubahan Peristiwa Kependudukan dan Peristiwa Penting',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'ijin_tinggal',
              nama: 'Izin Tinggal Tetap',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'kep_menkumham',
              nama: 'Keputusan Menkumham tentang Perubahan Kewarganegaraan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'dok_perjalanan',
              nama: 'Dokumen Perjalanan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'KK-002': // KK Karena Hilang atau Rusak
        return [
          _BerkasItem(
              id: 'surat_kehilangan',
              nama: 'Surat Keterangan Kehilangan dari Kepolisian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'fotokopi_kk',
              nama: 'Fotokopi Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp',
              nama: 'Fotokopi KTP-el',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'AK-007': // Pencatatan Perubahan Nama
        return [
          _BerkasItem(
              id: 'penetapan_pengadilan',
              nama: 'Salinan Penetapan Pengadilan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_sipil',
              nama: 'Kutipan Akta Pencatatan Sipil',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ijazah',
              nama: 'Ijazah',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp',
              nama: 'KTP-el',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'AK-006': // Pencatatan Pengangkatan, Pengakuan dan Pengesahan Anak
        return [
          _BerkasItem(
              id: 'penetapan_pengadilan',
              nama: 'Salinan Penetapan Pengadilan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk_ortu_angkat',
              nama: 'KK Orang Tua Angkat',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp',
              nama: 'KTP-el',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_kelahiran_anak',
              nama: 'Kutipan Akta Kelahiran Anak',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'AK-005': // Penerbitan Akta Perceraian
        return [
          _BerkasItem(
              id: 'putusan_pengadilan',
              nama: 'Salinan Putusan Pengadilan yang Telah Berkekuatan Hukum',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_perkawinan',
              nama: 'Kutipan Akta Perkawinan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_kedua_pasangan',
              nama: 'KTP-el Kedua Pasangan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'AK-003': // Penerbitan Akta Perkawinan
        return [
          _BerkasItem(
              id: 'sk_perkawinan',
              nama:
                  'Surat Keterangan Terjadinya Perkawinan dari Pemuka Agama / Penghayat Kepercayaan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'pas_foto',
              nama: 'Pas Foto Berwarna Suami dan Istri (Calon Pengantin)',
              format: 'JPG, PNG (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk_mempelai',
              nama: 'Fotokopi KK dari Kedua Calon Pengantin',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_lahir_mempelai',
              nama: 'Fotokopi Akta Kelahiran Kedua Calon Pengantin',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'surat_baptis',
              nama: 'Fotokopi Surat Baptis Kedua Calon Pengantin',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'ktp_mempelai',
              nama: 'Fotokopi KTP-el Calon Pengantin',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_ortu',
              nama: 'Fotokopi KTP-el Kedua Orang Tua Calon Pengantin',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_saksi',
              nama: 'Fotokopi KTP-el 2 Orang Saksi',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'akta_cerai_kematian',
              nama:
                  'Akta Perceraian / Akta Kematian (bila pernah bercerai / pasangan meninggal)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'SKP-001': // Penerbitan SKPWNI
        return [
          _BerkasItem(
              id: 'kk_asli',
              nama: 'KK Asli (untuk Pindah Keluar)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'ktp_asli',
              nama: 'KTP-el Asli (untuk Pindah Masuk)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'buku_nikah',
              nama: 'Fotokopi Buku Nikah / Akta Perkawinan / Perceraian',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'bukti_perubahan',
              nama:
                  'Surat Keterangan / Bukti Perubahan Peristiwa Kependudukan dan Peristiwa Penting',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'sk_asuh',
              nama: 'Surat Kuasa Pengasuhan Anak dari Orang Tua / Wali',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'pernyataan_anggota',
              nama:
                  'Surat Pernyataan Bersedia Menerima sebagai Anggota Keluarga dari KK yang Ditumpangi',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'dok_perjalanan',
              nama: 'Dokumen Perjalanan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
          _BerkasItem(
              id: 'kitap',
              nama: 'Kartu Izin Tinggal Tetap (KITAP)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: false,
              opsional: true),
        ];

      case 'KTP-007': // KTP-el Perpanjangan WNA Dengan ITAP
        return [
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp',
              nama: 'KTP-el',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'dok_perjalanan',
              nama: 'Dokumen Perjalanan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'itap',
              nama: 'Kartu Izin Tinggal Tetap (ITAP)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-006': // KTP-el Pindah Datang WNA Dengan ITAP
        return [
          _BerkasItem(
              id: 'itap',
              nama: 'Kartu Izin Tinggal Tetap (ITAP)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'dok_perjalanan',
              nama: 'Dokumen Perjalanan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'ktp_asal',
              nama: 'KTP-el Daerah Asal',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      case 'KTP-005': // KTP-el Pindah Datang Bagi WNI Dari Luar Negeri
        return [
          _BerkasItem(
              id: 'skp_ri',
              nama: 'SKP dari Perwakilan RI',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'dok_perjalanan',
              nama: 'Dokumen Perjalanan',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'skpln',
              nama: 'SKPLN dari Disdukcapil Kabupaten/Kota',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];

      default:
        return [
          _BerkasItem(
              id: 'ktp',
              nama: 'Kartu Tanda Penduduk (KTP)',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
          _BerkasItem(
              id: 'kk',
              nama: 'Kartu Keluarga',
              format: 'JPG, PNG, PDF (Maks. 2MB)',
              wajib: true),
        ];
    }
  }
}

// ─── SCREEN ───

class UploadBerkasScreen extends StatefulWidget {
  final int permohonanId;
  final Map<String, dynamic> permohonanData;
  final Map<String, dynamic>? layananData;

  const UploadBerkasScreen({
    super.key,
    required this.permohonanId,
    required this.permohonanData,
    this.layananData,
  });

  @override
  State<UploadBerkasScreen> createState() => _UploadBerkasScreenState();
}

class _UploadBerkasScreenState extends State<UploadBerkasScreen> {
  late List<_BerkasItem> _berkasWajib;
  final List<_BerkasItem> _berkasPendukung = [];
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final namaLayanan = widget.permohonanData['nama_layanan']?.toString() ?? '';
    // Ambil kode dari permohonanData (via JOIN kode_layanan) atau fallback ke layananData
    final kodeLayanan = widget.permohonanData['kode_layanan']?.toString() ??
        widget.layananData?['kode']?.toString() ??
        '';
    _berkasWajib = _BerkasLayanan.getBerkasWajib(kodeLayanan, namaLayanan);
  }

  int get _jumlahBerkasWajib => _berkasWajib.where((b) => b.wajib).length;

  bool get _canSubmit =>
      _berkasWajib.where((b) => b.wajib).every((b) => b.filePath != null);

  Future<void> _pickFile(int index, {bool isPendukung = false}) async {
    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (picked != null && mounted) {
        final fileName = picked.path.split('/').last;
        setState(() {
          if (isPendukung) {
            _berkasPendukung[index].filePath = picked.path;
            _berkasPendukung[index].fileName = fileName;
          } else {
            _berkasWajib[index].filePath = picked.path;
            _berkasWajib[index].fileName = fileName;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Gagal memilih berkas: $e', Colors.red);
      }
    }
  }

  void _removeFile(int index, {bool isPendukung = false}) {
    setState(() {
      if (isPendukung) {
        _berkasPendukung[index].filePath = null;
        _berkasPendukung[index].fileName = null;
      } else {
        _berkasWajib[index].filePath = null;
        _berkasWajib[index].fileName = null;
      }
    });
  }

  void _tambahBerkasPendukung() {
    final TextEditingController namaController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Nama Berkas Pendukung',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: TextField(
          controller: namaController,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          style: GoogleFonts.plusJakartaSans(fontSize: 13.5),
          decoration: InputDecoration(
            hintText: 'Contoh: Surat Keterangan RT',
            hintStyle: GoogleFonts.plusJakartaSans(
                color: AppColors.textMuted, fontSize: 13),
            filled: true,
            fillColor: AppColors.offWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Batal',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600)),
          ),
          TextButton(
            onPressed: () {
              final nama = namaController.text.trim();
              Navigator.pop(ctx);
              setState(() {
                _berkasPendukung.add(_BerkasItem(
                  id: 'pendukung_${_berkasPendukung.length}',
                  nama: nama.isNotEmpty
                      ? nama
                      : 'Berkas Pendukung ${_berkasPendukung.length + 1}',
                  format: 'JPG, PNG, PDF (Maks. 2MB)',
                  wajib: false,
                ));
              });
            },
            child: Text('Tambah',
                style: GoogleFonts.plusJakartaSans(
                    color: AppColors.dilapakTeal, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: GoogleFonts.plusJakartaSans(fontSize: 13)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  Future<void> _simpanDraft() async {
    _showSnackBar('Berkas disimpan sebagai draft', AppColors.dilapakTeal);
  }

  Future<void> _kirimPermohonan() async {
    if (!_canSubmit) {
      _showSnackBar(
          'Lengkapi semua berkas wajib terlebih dahulu', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = await SessionManager.instance.getUserId();
      if (userId == null) {
        if (mounted) setState(() => _isSubmitting = false);
        return;
      }

      final allBerkas = [..._berkasWajib, ..._berkasPendukung];
      for (final berkas in allBerkas) {
        if (berkas.filePath != null) {
          await DatabaseHelper.instance.insertBerkas({
            'user_id': userId,
            'permohonan_id': widget.permohonanId,
            'nama_berkas': berkas.nama,
            'tipe_berkas': berkas.wajib ? 'wajib' : 'pendukung',
            'path_file': berkas.filePath,
            'status': 'menunggu',
            'created_at': DateTime.now().toIso8601String(),
          });
        }
      }

      await DatabaseHelper.instance.updatePermohonan(
        widget.permohonanId,
        {'status': 'menunggu'},
      );

      // Update tracking step 1 (upload berkas) sebagai selesai
      await DatabaseHelper.instance.markTrackingUploadDone(widget.permohonanId);

      if (!mounted) return;
      setState(() => _isSubmitting = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => _SelesaiScreen(
            nomorResi: widget.permohonanData['nomor_resi']?.toString() ?? '-',
            permohonanId: widget.permohonanId,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      _showSnackBar('Gagal mengirim: $e', Colors.red);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.dilapakBackground,
        body: Column(
          children: [
            _buildAppBar(context),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(),
                    const SizedBox(height: 20),
                    _buildBerkasWajibSection(),
                    const SizedBox(height: 16),
                    _buildBerkasPendukungSection(),
                    const SizedBox(height: 16),
                    _buildInfoNote(),
                    const SizedBox(height: 24),
                    _buildScrolledActions(context),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final top = MediaQuery.of(context).padding.top;
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.fromLTRB(4, top + 4, 16, 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.textPrimary, size: 22),
          ),
          Expanded(
            child: Text(
              'Upload Berkas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: _showBantuanDialog,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderColor),
              ),
              child: const Icon(Icons.help_outline_rounded,
                  size: 18, color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showBantuanDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Bantuan Upload',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15, fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Pastikan semua berkas wajib sudah diunggah sebelum mengirim permohonan.\n\n'
          'Format yang diterima: JPG, PNG, PDF dengan ukuran maksimal 2MB per file.\n\n'
          'Petugas akan memverifikasi berkas dalam 1x24 jam kerja.',
          style: GoogleFonts.plusJakartaSans(
              fontSize: 13, color: AppColors.textSecondary, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Mengerti',
              style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w700, color: AppColors.dilapakTeal),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final p = widget.permohonanData;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nomor Resi + Badge DRAFT
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOMOR RESI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      p['nomor_resi']?.toString() ?? '-',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.dilapakTeal,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF59E0B).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'DRAFT',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFF59E0B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.borderColor),
          ),

          // NIK + Layanan (sejajar)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildInfoChip(
                  'NIK Pemohon',
                  p['nik_pemohon']?.toString() ?? '-',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoChip(
                  'Layanan',
                  p['nama_layanan']?.toString() ?? '-',
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Nama Lengkap (full width)
          _buildInfoChip(
            'Nama Lengkap',
            (p['nama_pemohon']?.toString() ?? '-').toUpperCase(),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 10,
            color: AppColors.textMuted,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 2,
        ),
      ],
    );
  }

  void _previewBerkas(_BerkasItem berkas) {
    if (berkas.filePath == null) return;
    final isPdf = berkas.filePath!.toLowerCase().endsWith('.pdf');
    if (isPdf) {
      _showSnackBar('Preview PDF tidak didukung. Pastikan file sudah benar.',
          AppColors.dilapakTeal);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _PreviewImageScreen(
          filePath: berkas.filePath!,
          namaBerkas: berkas.nama,
        ),
      ),
    );
  }

  Widget _buildBerkasWajibSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berkas Wajib',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.dilapakTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$_jumlahBerkasWajib Dokumen',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.dilapakTeal,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _berkasWajib.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _BerkasCard(
                berkas: _berkasWajib[i],
                onPick: () => _pickFile(i),
                onRemove: () => _removeFile(i),
                onPreview: () => _previewBerkas(_berkasWajib[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBerkasPendukungSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Berkas Pendukung',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: _tambahBerkasPendukung,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.borderColor),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.add_rounded,
                          size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        'Tambah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_berkasPendukung.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.borderColor),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.dilapakBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.folder_open_outlined,
                        size: 24, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Belum ada berkas pendukung\nditambahkan',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 13,
                      color: AppColors.textMuted,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            )
          else
            ...List.generate(
              _berkasPendukung.length,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _BerkasCard(
                  berkas: _berkasPendukung[i],
                  onPick: () => _pickFile(i, isPendukung: true),
                  onRemove: () => _removeFile(i, isPendukung: true),
                  onPreview: () => _previewBerkas(_berkasPendukung[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoNote() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.info_outline_rounded,
                size: 16, color: AppColors.dilapakTeal),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                        text:
                            'Pastikan semua dokumen terbaca dengan jelas dan tidak buram sebelum menekan tombol '),
                    TextSpan(
                      text: 'Kirim Permohonan',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrolledActions(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 0, 16, bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _kirimPermohonan,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Icon(Icons.send_rounded, size: 18),
              label: Text(
                'Kirim Permohonan',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmit
                    ? AppColors.dilapakTeal
                    : AppColors.dilapakTeal.withOpacity(0.35),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _simpanDraft,
              icon: const Icon(Icons.bookmark_outline_rounded, size: 18),
              label: Text(
                'Simpan sebagai Draft',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.dilapakTeal,
                side: const BorderSide(color: AppColors.dilapakTeal),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── BERKAS CARD WIDGET ───

class _BerkasCard extends StatelessWidget {
  final _BerkasItem berkas;
  final VoidCallback onPick;
  final VoidCallback onRemove;
  final VoidCallback? onPreview;

  const _BerkasCard({
    required this.berkas,
    required this.onPick,
    required this.onRemove,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    final isUploaded = berkas.filePath != null;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon dokumen
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isUploaded
                  ? const Color(0xFF22C55E).withOpacity(0.1)
                  : AppColors.dilapakBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isUploaded
                  ? Icons.description_rounded
                  : Icons.upload_file_outlined,
              size: 20,
              color: isUploaded ? const Color(0xFF22C55E) : AppColors.textMuted,
            ),
          ),
          const SizedBox(width: 12),

          // Konten
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nama + badge opsional
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        berkas.nama,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (berkas.opsional) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.dilapakBackground,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'OPSIONAL',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),

                // Keterangan / format
                const SizedBox(height: 3),
                Text(
                  berkas.keterangan != null
                      ? berkas.keterangan!
                      : 'Format: ${berkas.format}',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    color: AppColors.textMuted,
                    fontStyle: berkas.keterangan != null
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),

                const SizedBox(height: 10),

                // Status upload
                if (isUploaded) ...[
                  Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          size: 13, color: Color(0xFF22C55E)),
                      const SizedBox(width: 4),
                      Text(
                        'Berhasil diunggah',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF22C55E),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.dilapakBackground,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.insert_drive_file_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            berkas.fileName ?? 'berkas.pdf',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onPreview,
                          child: const Icon(Icons.visibility_outlined,
                              size: 16, color: AppColors.dilapakTeal),
                        ),
                        const SizedBox(width: 10),
                        GestureDetector(
                          onTap: onRemove,
                          child: const Icon(Icons.delete_outline_rounded,
                              size: 16, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  _PickFileButton(onTap: onPick),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── PICK FILE BUTTON (menggantikan DashedBorderPainterWidget) ───

class _PickFileButton extends StatelessWidget {
  final VoidCallback onTap;
  const _PickFileButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.dilapakTeal.withOpacity(0.5),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded,
                size: 16, color: AppColors.dilapakTeal),
            const SizedBox(width: 6),
            Text(
              'Pilih Berkas',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.dilapakTeal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SELESAI SCREEN ───

class _SelesaiScreen extends StatelessWidget {
  final String nomorResi;
  final int permohonanId;
  const _SelesaiScreen({required this.nomorResi, required this.permohonanId});

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Scaffold(
      backgroundColor: AppColors.dilapakBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 40, 24, bottom + 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Ikon sukses ──
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.dilapakTeal.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 40,
                  color: AppColors.dilapakTeal,
                ),
              ),
              const SizedBox(height: 20),

              // ── Judul ──
              Text(
                'Permohonan Berhasil\nTerkirim!',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),

              // ── Deskripsi ──
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Berkas Anda sedang diverifikasi oleh petugas. '
                          'Kami akan memberikan kabar dalam waktu ',
                    ),
                    TextSpan(
                      text: '1x24\njam kerja',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Card Nomor Resi ──
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 3)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'NOMOR RESI',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textMuted,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nomorResi,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dilapakTeal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Clipboard.setData(ClipboardData(text: nomorResi));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Nomor resi disalin',
                                    style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13)),
                                backgroundColor: AppColors.dilapakTeal,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.dilapakBackground,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.copy_rounded,
                                size: 16, color: AppColors.dilapakTeal),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Tahapan Selanjutnya ──
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'TAHAPAN SELANJUTNYA',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _buildTahapanItem(
                icon: Icons.fact_check_outlined,
                judul: 'Verifikasi Berkas',
                deskripsi:
                    'Tim administrasi sedang memeriksa kelengkapan dokumen Anda.',
              ),
              const SizedBox(height: 10),
              _buildTahapanItem(
                icon: Icons.notifications_outlined,
                judul: 'Terima Notifikasi',
                deskripsi:
                    'Update status akan dikirimkan melalui aplikasi dan email.',
              ),
              const SizedBox(height: 32),

              // ── Tombol Lihat Status ──
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            StatusPermohonanScreen(permohonanId: permohonanId),
                      ),
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.dilapakTeal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: Text(
                    'Lihat Status Permohonan',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // ── Tombol Kembali ──
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.popUntil(context, (route) => route.isFirst),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.dilapakTeal,
                    side: const BorderSide(color: AppColors.dilapakTeal),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTahapanItem({
    required IconData icon,
    required String judul,
    required String deskripsi,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.dilapakTeal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: AppColors.dilapakTeal),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  judul,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  deskripsi,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewImageScreen extends StatelessWidget {
  final String filePath;
  final String namaBerkas;

  const _PreviewImageScreen({
    required this.filePath,
    required this.namaBerkas,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          namaBerkas,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check_circle_outline_rounded,
                color: Color(0xFF22C55E)),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Sudah Benar',
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 0.5,
          maxScale: 5.0,
          child: Image.file(
            File(filePath),
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image_outlined,
                    color: Colors.white54, size: 48),
                const SizedBox(height: 12),
                Text(
                  'Gagal memuat gambar',
                  style: GoogleFonts.plusJakartaSans(
                      color: Colors.white54, fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.black,
        padding: EdgeInsets.fromLTRB(
            16, 12, 16, MediaQuery.of(context).padding.bottom + 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pinch_outlined, size: 16, color: Colors.white54),
            const SizedBox(width: 6),
            Text(
              'Cubit / perbesar untuk melihat detail',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
