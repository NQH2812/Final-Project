import 'dart:ui';

import 'package:webview_flutter/webview_flutter.dart';

/// Helper class for managing security features in WebViews
class WebSecurityHelper {
  /// Injects CSS to block ads and unwanted content
  static void injectAdBlockingCSS(WebViewController? controller) {
    controller?.runJavaScript('''
      (function() {
        var style = document.createElement('style');
        style.textContent = `
          /* Hide common ad elements */
          iframe:not([src*="vidsrc"]), 
          div[id*="ads"], div[class*="ads"], div[id*="google_ads"], 
          div[id*="banner"], div[class*="banner"],
          ins[class*="adsbygoogle"],
          a[href*="aff"], a[href*="affiliate"], a[href*="shopee"],
          div[style*="z-index: 999999"],
          div[class*="popup"], div[id*="popup"],
          div[class*="overlay"]:not(.jw-overlay) {
            display: none !important;
            opacity: 0 !important;
            visibility: hidden !important;
            pointer-events: none !important;
          }
          
          /* Ensure video player stays visible */
          .jw-video, video, .jw-media, .jw-wrapper {
            display: block !important;
            visibility: visible !important;
          }
        `;
        document.head.appendChild(style);
        
        // Remove any existing ad iframes
        setInterval(() => {
          const iframes = document.querySelectorAll('iframe:not([src*="vidsrc"])');
          iframes.forEach(iframe => iframe.remove());
          
          // Remove overlay divs
          const overlays = document.querySelectorAll('div[style*="position: fixed"]');
          overlays.forEach(overlay => {
            const zIndex = parseInt(window.getComputedStyle(overlay).zIndex || '0');
            if (zIndex > 1000) {
              overlay.remove();
            }
          });
        }, 1000);
      })();
    ''');
  }

  /// Check for suspicious activity in the WebView and mitigate issues
  static void checkForSuspiciousActivity(WebViewController? controller) {
    controller?.runJavaScript('''
      (function() {
        // Look for hidden iframes (common ad delivery method)
        const hiddenIframes = document.querySelectorAll('iframe[style*="display: none"]');
        if (hiddenIframes.length > 0) {
          hiddenIframes.forEach(iframe => iframe.remove());
          console.log("Removed hidden iframes: " + hiddenIframes.length);
        }
        
        // Check for newly added scripts
        const suspiciousScripts = document.querySelectorAll('script[src*="ads"], script[src*="track"], script[src*="analytics"]');
        if (suspiciousScripts.length > 0) {
          suspiciousScripts.forEach(script => script.remove());
          console.log("Removed suspicious scripts: " + suspiciousScripts.length);
        }
        
        // Re-apply our blocking CSS to ensure it hasn't been removed
        var style = document.getElementById('security-css');
        if (!style) {
          style = document.createElement('style');
          style.id = 'security-css';
          document.head.appendChild(style);
        }
        
        // Block common overlay techniques
        style.textContent = `
          body * {
            max-z-index: 999999 !important;
          }
          [id*="popup"], [class*="popup"], 
          [id*="overlay"]:not(.jw-overlay), [class*="overlay"]:not(.jw-overlay),
          [style*="position: fixed"][style*="z-index"] {
            display: none !important;
          }
          .jw-video, video, .jw-media, .jw-wrapper {
            display: block !important;
            visibility: visible !important;
          }
        `;
      })();
    ''');
  }

  /// Check if URL is allowed based on whitelist approach
  static bool isAllowedUrl(String url) {
    // Base domain whitelist - only allow the movie content provider and necessary CDNs
    List<String> allowedDomains = [
      'vidsrc.icu', // Main content provider
      'vidsrc.me',
      'vidsrc.to',
      'tmdb.org', // For movie info and images
      'googleapis.com', // Required for some content
      'gstatic.com',
      'cloudflare.com', // CDN
      'cloudflare.net',
      'jsdelivr.net', // CDN
      'jwplayer.com', // Video player
      'hls.js', // Video player dependencies
    ];
    
    // Block common ad/tracking domains
    List<String> blockedDomains = [
      'ads', 'ad.', 'adserv', 
      'analytics', 'tracker', 'track', 
      'affiliate', 'aff.', 
      'shopee', 'invl.io', 
      'mrktmtrcs', 'metric', 
      'facebook', 'google-analytics',
      'doubleclick', 'amazon-adsystem',
    ];
    
    // Check for blocked domains first
    for (String domain in blockedDomains) {
      if (url.contains(domain)) {
        return false;
      }
    }
    
    // Check if URL is from allowed domains
    for (String domain in allowedDomains) {
      if (url.contains(domain)) {
        return true;
      }
    }
    
    // For deep links or non-http protocols (except initial video protocols)
    if (!url.startsWith('http') && 
        !url.startsWith('https') && 
        !url.startsWith('data:') &&
        !url.startsWith('blob:') &&
        !url.startsWith('file:')) {
      return false;
    }
    
    // Default to blocking to be safe
    return false;
  }
  
  /// Initialize WebView controller with enhanced security
  static WebViewController initSecuredWebViewController(int movieId) {
    return WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Required for video player functionality
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            print('Navigation request: $url');
            
            // Block navigation to ad networks, analytics, trackers, and non-video content
            if (!isAllowedUrl(url)) {
              print('Blocked navigation to: $url');
              return NavigationDecision.prevent;
            }
            
            // Allow initial page and video content
            return NavigationDecision.navigate;
          },
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
            
            // Inject CSS to hide unwanted elements
            // Note: This will be called from the page using this controller
          },
          onWebResourceError: (WebResourceError error) {
            print('Web resource error: ${error.description}');
          },
        ),
      )
      ..enableZoom(false)
      ..setUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/100.0.0.0 Safari/537.36') // Use desktop user agent to avoid mobile redirects
      ..loadRequest(Uri.parse('https://vidsrc.icu/embed/movie/$movieId'));
  }
}