package market.restaurant_web.controller;

import market.restaurant_web.entity.User;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

public abstract class BaseServlet extends HttpServlet {

    protected User getCurrentUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            return (User) session.getAttribute("user");
        }
        return null;
    }

    protected boolean hasRole(HttpServletRequest request, String roleName) {
        User user = getCurrentUser(request);
        return user != null && user.getRole().getRoleName().equals(roleName);
    }

    protected boolean isLoggedIn(HttpServletRequest request) {
        return getCurrentUser(request) != null;
    }

    protected void redirectToLogin(HttpServletRequest request,
            jakarta.servlet.http.HttpServletResponse response)
            throws java.io.IOException {
        response.sendRedirect(request.getContextPath() + "/auth/login");
    }
}
