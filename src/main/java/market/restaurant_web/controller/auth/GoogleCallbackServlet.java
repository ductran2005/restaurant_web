package market.restaurant_web.controller.auth;

import market.restaurant_web.config.GoogleOAuthConfig;
import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.UserDAO;
import market.restaurant_web.entity.User;
import market.restaurant_web.service.AuthService;
import market.restaurant_web.service.PermissionService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.hibernate.Session;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Set;

/**
 * Step 2 of Google OAuth flow:
 * 1. Receives authorization code from Google
 * 2. Exchanges code for access token
 * 3. Fetches user's email from Google
 * 4. Looks up email in DB → gets the user's ROLE
 * 5. Creates session and redirects to role-based home
 *
 * ⚠️ If email is NOT in the DB → access denied (no auto-registration)
 */
@WebServlet("/oauth2/google/callback")
public class GoogleCallbackServlet extends HttpServlet {

    private final UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Check for errors from Google
        String error = req.getParameter("error");
        if (error != null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=google_denied");
            return;
        }

        // 2. Verify CSRF state
        String state = req.getParameter("state");
        HttpSession httpSession = req.getSession(false);
        if (httpSession == null) {
            resp.sendRedirect(req.getContextPath() + "/login?error=invalid_state");
            return;
        }
        String savedState = (String) httpSession.getAttribute("oauth_state");
        if (state == null || !state.equals(savedState)) {
            resp.sendRedirect(req.getContextPath() + "/login?error=invalid_state");
            return;
        }
        httpSession.removeAttribute("oauth_state");

        // 3. Get authorization code
        String code = req.getParameter("code");
        if (code == null || code.isEmpty()) {
            resp.sendRedirect(req.getContextPath() + "/login?error=no_code");
            return;
        }

        try {
            // 4. Exchange code for access token
            String accessToken = exchangeCodeForToken(code);
            if (accessToken == null) {
                resp.sendRedirect(req.getContextPath() + "/login?error=token_failed");
                return;
            }

            // 5. Get user info from Google (email, name)
            String[] userInfo = fetchUserInfo(accessToken);
            String email = userInfo[0];

            if (email == null || email.isEmpty()) {
                resp.sendRedirect(req.getContextPath() + "/login?error=no_email");
                return;
            }

            // 6. Look up user in DB by email
            User user;
            try (Session dbSession = HibernateUtil.getSessionFactory().openSession()) {
                user = userDao.findByEmail(dbSession, email);
            }

            // 7. If email not found in DB → deny access
            if (user == null) {
                req.setAttribute("error", "Email " + email + " chưa được đăng ký trong hệ thống. Vui lòng liên hệ Admin.");
                req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
                return;
            }

            // 8. Check if user is active
            if (!user.isActive()) {
                resp.sendRedirect(req.getContextPath() + "/login?error=disabled");
                return;
            }

            // 9. Check if account is locked
            if (user.getLockedUntil() != null
                    && user.getLockedUntil().isAfter(java.time.LocalDateTime.now())) {
                resp.sendRedirect(req.getContextPath() + "/login?error=disabled");
                return;
            }

            // 10. Create session (same logic as LoginController.doPost)
            HttpSession session = req.getSession(true);
            session.invalidate(); // prevent session fixation
            session = req.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole().getName());

            // 11. Load permissions from DB
            PermissionService permService = new PermissionService();
            Set<String> permissions = permService.getPermissionsByRoleId(user.getRole().getId());
            session.setAttribute("permissions", permissions);

            // 12. Redirect to role-based home page
            String redirectUrl = (String) session.getAttribute("redirect_after_login");
            if (redirectUrl != null) {
                session.removeAttribute("redirect_after_login");
                resp.sendRedirect(req.getContextPath() + redirectUrl);
            } else {
                resp.sendRedirect(req.getContextPath() + AuthService.getHomeUrl(user.getRole().getName()));
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Đăng nhập Google thất bại: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
        }
    }

    /**
     * Exchange authorization code for access token using Google's token endpoint.
     */
    private String exchangeCodeForToken(String code) throws IOException {
        String params = "code=" + enc(code)
                + "&client_id=" + enc(GoogleOAuthConfig.getClientId())
                + "&client_secret=" + enc(GoogleOAuthConfig.getClientSecret())
                + "&redirect_uri=" + enc(GoogleOAuthConfig.getRedirectUri())
                + "&grant_type=authorization_code";

        HttpURLConnection conn = (HttpURLConnection) new URL(GoogleOAuthConfig.TOKEN_URL).openConnection();
        conn.setRequestMethod("POST");
        conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(params.getBytes(StandardCharsets.UTF_8));
        }

        if (conn.getResponseCode() != 200) {
            System.err.println("Google token exchange failed: " + conn.getResponseCode());
            return null;
        }

        String responseBody = readStream(conn.getInputStream());
        // Parse access_token from JSON response (simple parsing without external JSON lib)
        return extractJsonValue(responseBody, "access_token");
    }

    /**
     * Fetch user info (email, name) from Google's userinfo endpoint.
     */
    private String[] fetchUserInfo(String accessToken) throws IOException {
        HttpURLConnection conn = (HttpURLConnection) new URL(GoogleOAuthConfig.USERINFO_URL).openConnection();
        conn.setRequestProperty("Authorization", "Bearer " + accessToken);
        conn.setRequestMethod("GET");

        if (conn.getResponseCode() != 200) {
            throw new IOException("Failed to fetch user info: " + conn.getResponseCode());
        }

        String responseBody = readStream(conn.getInputStream());
        String email = extractJsonValue(responseBody, "email");
        String name = extractJsonValue(responseBody, "name");
        return new String[]{email, name};
    }

    /** Read an input stream into a String */
    private String readStream(InputStream is) throws IOException {
        try (BufferedReader br = new BufferedReader(new InputStreamReader(is, StandardCharsets.UTF_8))) {
            StringBuilder sb = new StringBuilder();
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
            return sb.toString();
        }
    }

    /**
     * Simple JSON value extractor — works for flat JSON responses.
     * Extracts the value of a given key from a JSON string.
     * Example: {"access_token":"abc123",...} → extractJsonValue(json, "access_token") → "abc123"
     */
    private String extractJsonValue(String json, String key) {
        String searchKey = "\"" + key + "\"";
        int keyIndex = json.indexOf(searchKey);
        if (keyIndex == -1) return null;

        int colonIndex = json.indexOf(':', keyIndex + searchKey.length());
        if (colonIndex == -1) return null;

        // Skip whitespace after colon
        int start = colonIndex + 1;
        while (start < json.length() && json.charAt(start) == ' ') start++;

        if (start >= json.length()) return null;

        if (json.charAt(start) == '"') {
            // String value
            int end = json.indexOf('"', start + 1);
            return (end != -1) ? json.substring(start + 1, end) : null;
        } else {
            // Number or boolean
            int end = start;
            while (end < json.length() && json.charAt(end) != ',' && json.charAt(end) != '}') end++;
            return json.substring(start, end).trim();
        }
    }

    private static String enc(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}
