package market.restaurant_web.filter;

import market.restaurant_web.entity.User;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Set;

/**
 * Authentication Filter: protects /admin/*, /staff/*, /cashier/*
 * Allows public pages through without login.
 */
public class AuthFilter implements Filter {

    private static final Set<String> PUBLIC_PREFIXES = Set.of(
            "/assets/", "/css/", "/js/", "/img/", "/images/");

    private static final Set<String> PUBLIC_PAGES = Set.of(
            "", "/", "/index.jsp",
            "/login", "/register", "/forgot-password",
            "/access-denied",
            "/menu", "/public-menu",
            "/about", "/contact");

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String ctx = request.getContextPath();
        String uri = request.getRequestURI().substring(ctx.length());

        // Allow static resources
        for (String prefix : PUBLIC_PREFIXES) {
            if (uri.startsWith(prefix)) {
                chain.doFilter(request, response);
                return;
            }
        }

        // Allow public pages
        if (PUBLIC_PAGES.contains(uri)) {
            chain.doFilter(request, response);
            return;
        }

        // Check if protected path needs auth
        boolean requiresAuth = uri.startsWith("/admin") ||
                uri.startsWith("/staff") ||
                uri.startsWith("/cashier");

        if (requiresAuth) {
            HttpSession session = request.getSession(false);
            User user = (session != null) ? (User) session.getAttribute("user") : null;

            if (user == null) {
                // Save original URL for redirect after login
                session = request.getSession(true);
                session.setAttribute("redirect_after_login", uri);
                response.sendRedirect(ctx + "/login");
                return;
            }

            // Check if user is active (status = 'ACTIVE')
            if (!user.isActive()) {
                session.invalidate();
                response.sendRedirect(ctx + "/login?error=disabled");
                return;
            }
        }

        chain.doFilter(request, response);
    }
}
