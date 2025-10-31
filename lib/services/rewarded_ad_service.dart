import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service to manage rewarded ads
class RewardedAdService {
  static RewardedAdService? _instance;
  static RewardedAdService get instance => _instance ??= RewardedAdService._();
  
  RewardedAdService._();

  RewardedAd? _rewardedAd;
  bool _isAdReady = false;
  bool _isLoading = false;
  bool _rewardEarned = false;
  VoidCallback? _onAdDismissedCallback;
  VoidCallback? _onRewardEarnedCallback;

  /// Test ad unit ID for development
  static const String _testAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  
  /// Production ad unit IDs from AdMob console
  static const String _productionAdUnitIdAndroid = 'ca-app-pub-3772142815301617/7363282712';
  static const String _productionAdUnitIdIOS = 'ca-app-pub-3772142815301617/2189315144'; // TODO: Add iOS-specific ID when available

  /// Get the appropriate ad unit ID based on platform and environment
  static String get _adUnitId {
    // For production, use platform-specific IDs
      if (Platform.isAndroid) {
        return _productionAdUnitIdAndroid;
      } else if (Platform.isIOS) {
        return _productionAdUnitIdIOS;
      }
    // For development/testing, use test ad unit ID
    return _productionAdUnitIdAndroid;
  }

  /// Check if ad is ready to show
  bool get isAdReady => _isAdReady;
  
  /// Check if reward was earned in the last ad
  bool get wasRewardEarned => _rewardEarned;

  /// Load rewarded ad
  Future<void> loadAd() async {
    if (_isLoading) {
      print('Ad is already loading, waiting...');
      // Wait for current loading to complete
      while (_isLoading) {
        await Future.delayed(const Duration(milliseconds: 100));
      }
      return;
    }
    
    if (_isAdReady) {
      print('Ad is already ready');
      return;
    }

    _isLoading = true;
    _isAdReady = false;
    print('Loading rewarded ad with ID: ${RewardedAdService._adUnitId}');

    try {
      // Add a small delay to ensure AdMob is fully initialized
      await Future.delayed(const Duration(milliseconds: 500));
      
      await RewardedAd.load(
        adUnitId: RewardedAdService._adUnitId,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            print('Rewarded ad loaded successfully');
            _rewardedAd = ad;
            _isAdReady = true;
            _isLoading = false;
            
            // Set up ad callbacks
            _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
              onAdShowedFullScreenContent: (ad) {
                print('Rewarded ad showed full screen content');
              },
              onAdDismissedFullScreenContent: (ad) {
                print('Rewarded ad dismissed - Reward earned: $_rewardEarned');
                // Call the callback when ad is dismissed
                _onAdDismissedCallback?.call();
                _onAdDismissedCallback = null; // Clear callback
                _disposeAd();
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('Rewarded ad failed to show: $error');
                _disposeAd();
              },
            );
          },
          onAdFailedToLoad: (error) {
            print('Rewarded ad failed to load: $error');
            _isLoading = false;
            _isAdReady = false;
            _rewardedAd = null;
          },
        ),
      );
    } catch (e) {
      print('Error loading rewarded ad: $e');
      _isLoading = false;
      _isAdReady = false;
      _rewardedAd = null;
    }
  }

  /// Show rewarded ad if ready
  Future<bool> showAd({
    VoidCallback? onAdDismissed,
    VoidCallback? onRewardEarned,
  }) async {
    // Try up to 3 times to load and show ad
    for (int attempt = 1; attempt <= 3; attempt++) {
      print('Attempt $attempt to show rewarded ad');
      
      if (!_isAdReady || _rewardedAd == null) {
        print('Rewarded ad not ready, loading new ad...');
        await loadAd();
        
        // Wait a bit more for the ad to be fully ready
        if (_isAdReady && _rewardedAd != null) {
          await Future.delayed(const Duration(milliseconds: 200));
        }
      }

      // Check if ad is ready after loading
      if (!_isAdReady || _rewardedAd == null) {
        print('Rewarded ad still not ready after loading attempt $attempt');
        if (attempt < 3) {
          // Wait before retry
          await Future.delayed(const Duration(milliseconds: 1000));
          continue;
        } else {
          print('All attempts failed to load rewarded ad');
          return false;
        }
      }

      try {
        // Reset reward status
        _rewardEarned = false;
        
        // Store the callbacks
        _onAdDismissedCallback = onAdDismissed;
        _onRewardEarnedCallback = onRewardEarned;
        
        await _rewardedAd!.show(
          onUserEarnedReward: (ad, reward) {
            print('User earned reward: ${reward.amount} ${reward.type}');
            _rewardEarned = true;
            // Call the reward callback when user earns reward
            _onRewardEarnedCallback?.call();
          },
        );
        print('Rewarded ad shown successfully on attempt $attempt');
        return true;
      } catch (e) {
        print('Error showing rewarded ad on attempt $attempt: $e');
        _disposeAd();
        
        if (attempt < 3) {
          // Wait before retry
          await Future.delayed(const Duration(milliseconds: 1000));
        }
      }
    }
    
    print('All attempts to show rewarded ad failed');
    return false;
  }

  /// Show rewarded ad with 100% probability (always show for rewards)
  /// Returns true if ad was shown, false if not shown (due to loading errors)
  Future<bool> showAdAlways({
    VoidCallback? onAdDismissed,
    VoidCallback? onRewardEarned,
  }) async {
    return await showAd(
      onAdDismissed: onAdDismissed,
      onRewardEarned: onRewardEarned,
    );
  }

  /// Preload ad for better user experience
  Future<void> preloadAd() async {
    if (!_isAdReady && !_isLoading) {
      print('Preloading rewarded ad...');
      await loadAd();
      
      // After loading, wait a bit more to ensure it's fully ready
      if (_isAdReady) {
        await Future.delayed(const Duration(milliseconds: 300));
        print('Rewarded ad preloaded and ready');
      }
    }
  }

  /// Dispose current ad
  void _disposeAd() {
    _rewardedAd?.dispose();
    _rewardedAd = null;
    _isAdReady = false;
    
    // Immediately start loading the next ad for better UX
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!_isLoading && !_isAdReady) {
        print('Auto-preloading next rewarded ad...');
        preloadAd();
      }
    });
  }

  /// Dispose service
  void dispose() {
    _disposeAd();
  }
}
