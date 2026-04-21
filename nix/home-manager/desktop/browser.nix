# Browsers:
# - Zen Browser (Firefox-based): Primary browser
# - Chromium: Secondary fallback browser

{ inputs, ... }:
{
  flake.homeModules.browser =
    { pkgs, ... }:
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
          DisableAppUpdate = true;
          DisableFirefoxStudies = true;
          DisablePocket = true;
          DisableTelemetry = true;
          NoDefaultBookmarks = true;

          ExtensionSettings = {
            # uBlock Origin
            "uBlock0@raymondhill.net" = {
              installation_mode = "force_installed";
              install_url = "https://addons.mozilla.org/firefox/downloads/latest/uBlock0@raymondhill.net/latest.xpi";
              private_browsing = true;
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
            };
          };

          Preferences = {
            "browser.disableResetPrompt" = {
              Value = true;
              Status = "user";
            };
            "browser.translations.neverTranslateLanguages" = {
              Value = "de";
              Status = "user";
            };
            "signon.firefoxRelay.feature" = {
              Value = "disabled";
              Status = "user";
            };
          };
        };

        nativeMessagingHosts = [
          pkgs.kdePackages.plasma-browser-integration
          pkgs.keepassxc
        ];
      };

      ## Chromium ##
      programs.chromium = {
        enable = true;

        extensions = [
          "ddkjiahejlhfcafbddmgiahcphecmpfh" # uBlock Origin Lite
          "cimiefiiaegbelhefglklhhakcgmhkai" # Plasma Integration
        ];

        nativeMessagingHosts = [
          pkgs.kdePackages.plasma-browser-integration
        ];
      };
    };
}
