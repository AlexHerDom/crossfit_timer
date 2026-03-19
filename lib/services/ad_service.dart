import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService extends ChangeNotifier {
  static const String _adsRemovedKey = 'ads_removed';
  static const String removeAdsProductId = 'remove_ads'; // ID a crear en Play Console

  // IDs de anuncios: en debug usa IDs de prueba de Google, en release usa los reales
  static String get _bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Test banner Android
          : 'ca-app-pub-3940256099942544/2934735716'; // Test banner iOS
    }
    return 'ca-app-pub-6636064525240027/7917844691'; // banner_home
  }

  static String get _timerBannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111' // Test banner Android
          : 'ca-app-pub-3940256099942544/2934735716'; // Test banner iOS
    }
    return 'ca-app-pub-6636064525240027/3242567661'; // banner_timer
  }

  BannerAd? _bannerAd;        // Banner para la home
  BannerAd? _timerBannerAd;  // Banner para el timer (instancia separada)
  bool _isBannerAdReady = false;
  bool _isTimerBannerAdReady = false;
  bool _adsRemoved = false;
  bool _isPurchasing = false;
  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;

  bool get adsRemoved => _adsRemoved;
  bool get isBannerAdReady => _isBannerAdReady;
  bool get isTimerBannerAdReady => _isTimerBannerAdReady;
  bool get isPurchasing => _isPurchasing;
  BannerAd? get bannerAd => _bannerAd;
  BannerAd? get timerBannerAd => _timerBannerAd;

  AdService() {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    _adsRemoved = prefs.getBool(_adsRemovedKey) ?? false;

    _purchaseSubscription = InAppPurchase.instance.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _purchaseSubscription?.cancel(),
      onError: (_) {},
    );

    if (!_adsRemoved) {
      _loadBannerAd();
      _loadTimerBannerAd();
    }
    notifyListeners();
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isBannerAdReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isBannerAdReady = false;
          notifyListeners();
        },
      ),
    );
    _bannerAd!.load();
  }

  void _loadTimerBannerAd() {
    _timerBannerAd = BannerAd(
      adUnitId: _timerBannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          _isTimerBannerAdReady = true;
          notifyListeners();
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isTimerBannerAdReady = false;
          notifyListeners();
        },
      ),
    );
    _timerBannerAd!.load();
  }

  Future<void> _onPurchaseUpdate(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID == removeAdsProductId) {
        if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          await markAdsRemoved();
          await InAppPurchase.instance.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.pending) {
          _isPurchasing = true;
          notifyListeners();
        } else {
          _isPurchasing = false;
          notifyListeners();
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        }
      }
    }
  }

  Future<bool> purchaseRemoveAds() async {
    final available = await InAppPurchase.instance.isAvailable();
    if (!available) return false;

    final response = await InAppPurchase.instance
        .queryProductDetails({removeAdsProductId});

    if (response.productDetails.isEmpty) return false;

    _isPurchasing = true;
    notifyListeners();

    final param = PurchaseParam(productDetails: response.productDetails.first);
    return await InAppPurchase.instance.buyNonConsumable(purchaseParam: param);
  }

  Future<void> restorePurchases() async {
    await InAppPurchase.instance.restorePurchases();
  }

  Future<void> markAdsRemoved() async {
    _adsRemoved = true;
    _isPurchasing = false;
    _bannerAd?.dispose();
    _bannerAd = null;
    _isBannerAdReady = false;
    _timerBannerAd?.dispose();
    _timerBannerAd = null;
    _isTimerBannerAdReady = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsRemovedKey, true);
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    _bannerAd?.dispose();
    _timerBannerAd?.dispose();
    super.dispose();
  }
}
