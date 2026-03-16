package market.restaurant_web.filter;

import market.restaurant_web.entity.User;
import jakarta.servlet.*;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.util.Map;
import java.util.Set;

/**
 * RBAC Filter: simple role-based access control.
 * Since DB has no permissions/role_permissions tables,
 * we check by role name directly.
 */
public class RbacFilter implements Filter {

    /**
     * URL prefix → required role names.
     */
    private static final Map<String, Set<String>> URL_ROLE_MAP = Map.of(
            "/admin", Set.of("ADMIN"),
            "/staff", Set.of("ADMIN", "STAFF"),
            "/cashier", Set.of("ADMIN", "CASHIER"),
            "/user", Set.of("ADMIN", "CUSTOMER"));

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;
        String ctx = request.getContextPath();
        String uri = request.getRequestURI().substring(ctx.length());

        // Only check RBAC for admin/staff/cashier routes
        if (!uri.startsWith("/admin") && !uri.startsWith("/staff") && !uri.startsWith("/cashier") && !uri.startsWith("/user")) {
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(ctx + "/login");
            return;
        }

        String userRole = user.getRole() != null ? user.getRole().getName() : "";

        // Find required roles for URL
        for (Map.Entry<String, Set<String>> entry : URL_ROLE_MAP.entrySet()) {
            if (uri.startsWith(entry.getKey())) {
                if (!entry.getValue().contains(userRole)) {
                    response.sendRedirect(ctx + "/access-denied");
                    return;
                }
                break;
            }
        }

        chain.doFilter(request, response);
    }
}
