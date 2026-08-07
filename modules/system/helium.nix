{
  lib,
  pkgs,
  config,
  inputs,
  ...
}:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.helium;
in
{
  imports = builtins.attrValues {
    inherit (inputs.helium.nixosModules)
      default
      ;
  };

  options.helium = {
    enable = mkOption {
      type = types.bool;
      default = config.wayland.enable;
      description = ''
        Whether to enable the "helium" module.

        This enables the Helium Browser with custom policies.
      '';
    };
  };

  config = mkIf cfg.enable {
    # Enforce the module dependencies.
    assertions = [
      (lib.requireModule "helium" "wayland" config.wayland.enable)
    ];

    # Enable "Helium Browser".
    # See: https://helium.computer
    programs.helium = {
      enable = true;

      # Pre-configure first run preferences.
      # These settings have no enterprise policies and are seeded as
      # default preferences the browser copies into every new profile.
      package = pkgs.helium.overrideAttrs (attrs: {
        postInstall = (attrs.postInstall or "") + ''
          printf '%s\n' '${
            builtins.toJSON {
              browser = {
                # Use the system title bar and borders.
                custom_chrome_frame = false;
              };

              helium = {
                # Skip the setup page on first start.
                completed_onboarding = true;

                browser = {
                  # Set the browser layout.
                  layout = 2;
                  # Left-align the vertical tabs.
                  vertical_right_aligned = false;
                  # Enable the minimal address bar.
                  minimal_location_bar = true;
                  # Hide the media controls button.
                  show_media_button = false;
                  # Hide the profile controls button.
                  show_avatar_button = false;
                };

                services = {
                  # Consent to use "Helium" services.
                  user_consented = true;
                  # Disable automatic component updates.
                  browser_updates = false;
                  # Disable schema alert notifications.
                  disable_schema_alerts = true;
                };
              };

              ntp = {
                # Hide the shortcut tiles on the "New Tab" page.
                # This cursed typo cost an entire afternoon.
                shortcust_visible = false;
              };
            }
          }' > $out/opt/helium/initial_preferences
        '';
      });

      # Chromium enterprise policies.
      # See: https://chromeenterprise.google/policies
      # See: helium://policy
      policies = {
        # Restore previous session on startup.
        "RestoreOnStartup" = 1;
        # Don't ask about being the default browser.
        "DefaultBrowserSettingEnabled" = false;

        # Disable browser sign-in.
        "BrowserSignin" = 0;
        # Disable browser sync.
        "SyncDisabled" = true;

        # Disable "Save and fill addresses".
        "AutofillAddressEnabled" = false;
        # Disable "Save and fill payment methods".
        "AutofillCreditCardEnabled" = false;
        # Delete form data on session exit.
        "ClearBrowsingDataOnExitList" = [ "autofill" ];

        # Disable automatic crash/usage reporting.
        "MetricsReportingEnabled" = false;
        # Disable automatic Google network time queries.
        "BrowserNetworkTimeQueriesEnabled" = false;
        # Disable URL-keyed anonymized usage data collection.
        "UrlKeyedAnonymizedDataCollectionEnabled" = false;
        # Block third-party cookies.
        "BlockThirdPartyCookies" = true;
        # Block built-in AI queries.
        "BuiltInAIAPIsEnabled" = false;
        # Block payment method queries.
        "PaymentMethodQueryEnabled" = false;

        # Disable search suggestions.
        "SearchSuggestEnabled" = false;
        # Disable alternate error pages.
        "AlternateErrorPagesEnabled" = false;
        # Disable promotional content.
        "PromotionsEnabled" = false;
        # Disable browser experiments.
        "BrowserLabsEnabled" = false;
        # Disable Chrome variations.
        "ChromeVariations" = 2;
        # Disable the bookmarks bar.
        "BookmarkBarEnabled" = false;
        # Disable shopping/price tracking.
        "ShoppingListEnabled" = false;
        # Disable media recommendations.
        "MediaRecommendationsEnabled" = false;
      };
    };
  };
}
