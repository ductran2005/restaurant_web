package market.restaurant_web.controller.auth;

import market.restaurant_web.entity.User;
import market.restaurant_web.service.AuthService;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/register")
public class RegisterController extends HttpServlet {
    private final AuthService authService = new AuthService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String username = ValidationUtil.trim(req.getParameter("username"));
        String fullName = ValidationUtil.sanitize(ValidationUtil.trim(req.getParameter("fullName")));
        String password = req.getParameter("password");
        String confirm = req.getParameter("confirmPassword");

        // Validation
        if (ValidationUtil.isBlank(username) || ValidationUtil.isBlank(fullName)
                || ValidationUtil.isBlank(password)) {
            req.setAttribute("error", "Vui lòng điền đầy đủ thông tin");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }
        if (password.length() < 6) {
            req.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }
        if (!password.equals(confirm)) {
            req.setAttribute("error", "Mật khẩu xác nhận không khớp");
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
            return;
        }

        try {
            User user = authService.register(username, fullName, password, "STAFF");
            // Auto login after register
            HttpSession session = req.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole().getName());
            session.setAttribute("permissions", java.util.Set.of());
            resp.sendRedirect(req.getContextPath() + AuthService.getHomeUrl(user.getRole().getName()));
        } catch (RuntimeException e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(req, resp);
        }
    }
}
