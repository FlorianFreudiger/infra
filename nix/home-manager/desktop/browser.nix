# Browsers:
# - Zen Browser (Firefox-based): Primary browser
# - Chromium: Secondary fallback browser

{ inputs, ... }:
{
  flake.homeModules.browser =
    { pkgs, lib, ... }:
    {
      home.packages = with pkgs; [
        kdePackages.plasma-browser-integration
      ];

      ## Zen Browser ##
      imports = [
        inputs.zen-browser.homeModules.beta
      ];

      programs.zen-browser = {
        enable = true;
        setAsDefaultBrowser = true;

        policies = {
          # See https://firefox-admin-docs.mozilla.org/reference/policies/
          DisableAppUpdate = true;
          DisableFirefoxStudies = true;
          DisableRemoteImprovements = true;
          DisableTelemetry = true;
          EnableTrackingProtection = {
            Value = true;
            Category = "strict";
            BaselineExceptions = true;
          };
          HttpsOnlyMode = "enabled";
          NetworkPrediction = false; # Disable DNS prefetching
          NoDefaultBookmarks = true;
          OfferToSaveLoginsDefault = false;
          Permissions = {
            Autoplay = {
              Allow = [
                "https://www.youtube.com"
                "https://www.twitch.tv"
              ];
              Default = "block-audio-video";
            };
          };

          ExtensionSettings = {
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi";
              private_browsing = true;
              default_area = "navbar";
            };
            # Plasma Integration
            "plasma-browser-integration@kde.org" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/plasma-browser-integration@kde.org/latest.xpi";
            };
            # KeePassXC-Browser
            "keepassxc-browser@keepassxc.org" = {
              installation_mode = "normal_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/keepassxc-browser@keepassxc.org/latest.xpi";
              default_area = "navbar";
            };
          };

          # Partly from https://github.com/arkenfox/user.js/blob/master/user.js
          Preferences = {
            ## UX ##
            "browser.disableResetPrompt" = {
              Value = true;
              Status = "locked";
            };
            "browser.translations.neverTranslateLanguages" = {
              Value = "de";
              Status = "default";
            };
            "signon.firefoxRelay.feature" = {
              Value = "disabled";
              Status = "locked";
            };
            "browser.search.region" = {
              # Keep search region in Germany to avoid search engine additions from different regions
              Value = "DE";
              Status = "locked";
            };
            "browser.region.update.enabled" = {
              # Disable region updates as the region follows VPN exit node
              Value = false;
              Status = "locked";
            };

            ## Privacy ##
            "browser.places.speculativeConnect.enabled" = {
              # Disable mousedown speculative connections for bookmarks and history
              Value = false;
              Status = "locked";
            };
            "browser.safebrowsing.downloads.remote.enabled" = {
              # Disable sending downloaded-binary metadata to Google
              Value = false;
              Status = "locked";
            };
            "browser.urlbar.speculativeConnect.enabled" = {
              # Disable urlbar making speculative connections
              Value = false;
              Status = "locked";
            };
            "network.http.speculative-parallel-limit" = {
              # Disable link-mouseover opening connection to linked server
              Value = 0;
              Status = "locked";
            };
            "network.prefetch-next" = {
              # Disable link prefetching
              Value = false;
              Status = "locked";
            };
            "privacy.fingerprintingProtection.overrides" = {
              # Add some resist-fingerprinting (RFP) targets to make fingerprinting harder
              Value = lib.concatStringsSep "," [
                "+WebGPULimits" # Normalise reported WebGPU adapter limits
                "+WebGPUIsFallbackAdapter" # Hide whether the GPU adapter is a software fallback
                "+WebGPUSubgroupSizes" # Normalise reported WebGPU subgroup sizes
                "+IMEStyle" # Normalise input-method composition styling
                "+MediaError" # Drop detailed media error messages
                "+StreamVideoFacingMode" # Drop facingMode from camera track settings
                "+VideoElementMozFrames" # Spoof legacy moz* video frame counters
                "+VideoElementMozFrameDelay" # Spoof legacy mozFrameDelay
                "+AudioContext" # Normalise AudioContext properties
                "+AudioSampleRate" # Report a fixed audio sample rate

                ## Some potential for site breakage ##
                "+WebGLRenderInfo" # Report WebGL vendor and renderer as "Mozilla"
                "+FontVisibilityBaseSystem" # Limit web-visible fonts, doesn't work on NixOS though
                "+MediaDevices" # Use generic media device names and groups
                "+WebGLRenderCapability" # Normalise reported WebGL limits
              ];
              Status = "default";
            };
          };

          SearchEngines = {
            Add = [
              {
                Name = "NixOS packages";
                URLTemplate = "https://search.nixos.org/packages?query={searchTerms}";
                Alias = "@nixpkgs";
                Description = "Search NixOS packages.";
                IconURL = "https://search.nixos.org/images/nixos-logomark-default-gradient-none.svg";
                Encoding = "UTF-8";
                Method = "GET";
              }
              {
                Name = "NixOS options";
                URLTemplate = "https://search.nixos.org/options?query={searchTerms}";
                Alias = "@nixopts";
                Description = "Search NixOS configuration options.";
                IconURL = "https://search.nixos.org/images/nixos-logomark-rainbow-gradient-none.svg";
                Encoding = "UTF-8";
                Method = "GET";
              }
            ];
            # Keep default search engines: DDG, Google, Wikipedia (en)
            Remove = [
              "Amazon.com"
              "Bing"
              "eBay"
              "Ecosia"
              "Perplexity"
              "Qwant"
              "Startpage"
            ];
          };
        };

        nativeMessagingHosts = with pkgs; [
          kdePackages.plasma-browser-integration
          keepassxc
        ];
      };

      ## Chromium ##
      programs.chromium = {
        enable = true;

        extensions = [
          "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
          "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma Integration
        ];

        nativeMessagingHosts = with pkgs; [
          kdePackages.plasma-browser-integration
        ];
      };
    };
}
