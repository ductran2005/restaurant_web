package market.restaurant_web.config;

import market.restaurant_web.service.ConfigService;

/**
 * Google OAuth 2.0 configuration.
 * Reads CLIENT_ID, CLIENT_SECRET, REDIRECT_URI from system_config table in Supabase.
 * 
 * To manage these values:
 * - Go to Admin → Cấu hình hệ thống
 * - Or update directly in Supabase → system_config table
 */
public class GoogleOAuthConfig {

    private static final ConfigService configService = new ConfigService();

    /** Read Google Client ID from DB */
    public static String getClientId() {
        String val = configService.getValue("GOOGLE_CLIENT_ID");
        return val != null ? val : "";
    }

    /** Read Google Client Secret from DB */
    public static String getClientSecret() {
        String val = configService.getValue("GOOGLE_CLIENT_SECRET");
        return val != null ? val : "";
    }

    /** Read Google Redirect URI from DB */
    public static String getRedirectUri() {
        String val = configService.getValue("GOOGLE_REDIRECT_URI");
        return val != null ? val : "http://localhost:8080/oauth2/google/callback";
    }

    /** Google OAuth endpoints (these are fixed, no need to store in DB) */
    public static final String AUTH_URL     = "https://accounts.google.com/o/oauth2/v2/auth";
    public static final String TOKEN_URL    = "https://oauth2.googleapis.com/token";
    public static final String USERINFO_URL = "https://www.googleapis.com/oauth2/v3/userinfo";

    /** Scopes: email + profile */
    public static final String SCOPE = "openid email profile";
}
