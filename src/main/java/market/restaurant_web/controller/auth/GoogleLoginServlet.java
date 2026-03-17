package market.restaurant_web.controller.auth;

import market.restaurant_web.config.GoogleOAuthConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

/**
 * Step 1 of Google OAuth flow:
 * Builds the Google authorization URL and redirects the user to Google's login page.
 */
@WebServlet("/oauth2/google")
public class GoogleLoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Generate a random state token to prevent CSRF
        String state = UUID.randomUUID().toString();
        HttpSession session = req.getSession(true);
        session.setAttribute("oauth_state", state);

        // Also store state in cookie as fallback (for reverse proxy / Nginx environments
        // where session may be lost during Google's redirect)
        Cookie stateCookie = new Cookie("OAUTH_STATE", state);
        stateCookie.setPath("/");
        stateCookie.setHttpOnly(true);
        stateCookie.setMaxAge(300); // 5 minutes
        resp.addCookie(stateCookie);

        // Build Google OAuth URL
        String authUrl = GoogleOAuthConfig.AUTH_URL
                + "?client_id=" + enc(GoogleOAuthConfig.getClientId())
                + "&redirect_uri=" + enc(GoogleOAuthConfig.getRedirectUri())
                + "&response_type=code"
                + "&scope=" + enc(GoogleOAuthConfig.SCOPE)
                + "&state=" + enc(state)
                + "&access_type=offline"
                + "&prompt=select_account";

        resp.sendRedirect(authUrl);
    }

    private static String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
