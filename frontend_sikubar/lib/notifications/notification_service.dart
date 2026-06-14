import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

/// Model untuk satu notifikasi
class AppNotification {
  final int id;
  final String judul;
  final String pesan;
  final String tipe; // 'pengajuan' | 'pengaduan'
  final bool sudahDibaca;
  final String tanggal;
  final Map<String, dynamic>? data; // payload tambahan (id pengajuan, dll)

  AppNotification({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.tipe,
    required this.sudahDibaca,
    required this.tanggal,
    this.data,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? json['title'] ?? '',
      pesan: json['pesan'] ?? json['body'] ?? '',
      tipe: json['tipe'] ?? json['type'] ?? 'pengajuan',
      sudahDibaca: json['sudah_dibaca'] == true ||
          json['read_at'] != null ||
          json['is_read'] == true,
      tanggal: json['created_at'] ?? json['tanggal'] ?? '',
      data: json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
    );
  }

  AppNotification copyWith({bool? sudahDibaca}) {
    return AppNotification(
      id: id,
      judul: judul,
      pesan: pesan,
      tipe: tipe,
      sudahDibaca: sudahDibaca ?? this.sudahDibaca,
      tanggal: tanggal,
      data: data,
    );
  }
}

/// Singleton service — dipanggil dari mana saja via NotificationService.instance
class NotificationService extends ChangeNotifier {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final ApiService _api = ApiService();

  List<AppNotification> _notifikasi = [];
  bool _isLoading = false;
  String? _error;

  List<AppNotification> get notifikasi => _notifikasi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Jumlah notifikasi yang belum dibaca
  int get unreadCount =>
      _notifikasi.where((n) => !n.sudahDibaca).length;

  bool get hasUnread => unreadCount > 0;

  /// Ambil notifikasi dari API. Dipanggil setiap kali halaman notifikasi
  /// dibuka atau app baru aktif (via AppLifecycleObserver).
  Future<void> fetchNotifikasi() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final res = await _api.getNotifikasi();
      final List rawList = res['data'] ?? res['notifications'] ?? [];
      _notifikasi = rawList
          .map((e) => AppNotification.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      // Urutkan: belum dibaca dulu, lalu terbaru
      _notifikasi.sort((a, b) {
        if (a.sudahDibaca != b.sudahDibaca) {
          return a.sudahDibaca ? 1 : -1;
        }
        return b.tanggal.compareTo(a.tanggal);
      });
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Tandai satu notifikasi sebagai sudah dibaca
  Future<void> tandaiDibaca(int id) async {
    // Optimistic update
    final idx = _notifikasi.indexWhere((n) => n.id == id);
    if (idx != -1 && !_notifikasi[idx].sudahDibaca) {
      _notifikasi[idx] = _notifikasi[idx].copyWith(sudahDibaca: true);
      notifyListeners();
    }

    try {
      await _api.tandaiNotifikasiDibaca(id);
    } catch (_) {
      // Rollback jika gagal
      if (idx != -1) {
        _notifikasi[idx] = _notifikasi[idx].copyWith(sudahDibaca: false);
        notifyListeners();
      }
    }
  }

  /// Tandai semua notifikasi sebagai sudah dibaca
  Future<void> tandaiSemuaDibaca() async {
    final prev = List<AppNotification>.from(_notifikasi);
    _notifikasi = _notifikasi
        .map((n) => n.copyWith(sudahDibaca: true))
        .toList();
    notifyListeners();

    try {
      await _api.tandaiSemuaNotifikasiDibaca();
    } catch (_) {
      _notifikasi = prev;
      notifyListeners();
    }
  }

  /// Refresh badge saja (ringan — hanya ambil count, tidak load seluruh list)
  Future<void> refreshBadge() async {
    try {
      final res = await _api.getUnreadNotifikasiCount();
      final int count = res['unread_count'] ?? res['count'] ?? 0;
      // Sinkronkan dengan data lokal jika berbeda
      if (count != unreadCount) {
        await fetchNotifikasi();
      }
    } catch (_) {
      // Silent fail — badge tidak kritis
    }
  }
}


mixin NotificationRefreshMixin<T extends StatefulWidget> on State<T>
    implements RouteAware {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// Panggil ini di didPopNext() atau di initState() halaman yang perlu badge fresh
  void refreshNotifikasi() {
    NotificationService.instance.refreshBadge();
  }

  @override
  void didPush() {}

  @override
  void didPop() {}

  @override
  void didPushNext() {}

  @override
  void didPopNext() {
    refreshNotifikasi();
  }
}

/// Observer lifecycle — refresh badge saat app kembali ke foreground
class AppLifecycleNotificationObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      NotificationService.instance.refreshBadge();
    }
  }
}