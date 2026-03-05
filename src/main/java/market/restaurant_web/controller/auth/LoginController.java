package market.restaurant_web.controller.auth;

import market.restaurant_web.entity.User;
import market.restaurant_web.service.AuthService;
import market.restaurant_web.service.PermissionService;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/login")
public class LoginController extends HttpServlet {
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // If already logged in, redirect to home
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("user") != null) {
            User user = (User) session.getAttribute("user");
            resp.sendRedirect(req.getContextPath() + AuthService.getHomeUrl(user.getRole().getName()));
            return;
        }
        req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = ValidationUtil.trim(req.getParameter("username"));
        String password = req.getParameter("password");

        if (ValidationUtil.isBlank(username) || ValidationUtil.isBlank(password)) {
            req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        User user = authService.login(username, password);
        if (user == null) {
            req.setAttribute("error", "Tài khoản hoặc mật khẩu không đúng");
            req.setAttribute("username", username);
            req.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(req, resp);
            return;
        }

        // Create session
        HttpSession session = req.getSession(true);
        session.invalidate(); // prevent session fixation
        session = req.getSession(true);
        session.setAttribute("user", user);
        session.setAttribute("role", user.getRole().getName());
        // Load permissions from DB
        PermissionService permService = new PermissionService();
        java.util.Set<String> permissions = permService.getPermissionsByRoleId(user.getRole().getId());
        session.setAttribute("permissions", permissions);

        // Redirect to saved URL or role-based home
        String redirectUrl = (String) session.getAttribute("redirect_after_login");
        if (redirectUrl != null) {
            session.removeAttribute("redirect_after_login");
            resp.sendRedirect(req.getContextPath() + redirectUrl);
        } else {
            resp.sendRedirect(req.getContextPath() + AuthService.getHomeUrl(user.getRole().getName()));
        }
    }
}
