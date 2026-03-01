package market.restaurant_web.controller;

import market.restaurant_web.entity.User;
import market.restaurant_web.service.AuthenticationService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(urlPatterns = { "/auth/login", "/auth/register", "/auth/logout" })
public class AuthServlet extends BaseServlet {
    private final AuthenticationService authService = new AuthenticationService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getRequestURI();

        if (action.contains("/login")) {
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
        } else if (action.contains("/register")) {
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
        } else if (action.contains("/logout")) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            response.sendRedirect(request.getContextPath() + "/auth/login");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getRequestURI();

        if (action.contains("/login")) {
            handleLogin(request, response);
        } else if (action.contains("/register")) {
            handleRegister(request, response);
        }
    }

    private void handleLogin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        User user = authService.login(username, password);

        if (user != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30 minutes
            response.sendRedirect(request.getContextPath() + "/tables");
        } else {
            request.setAttribute("errorMessage", "Invalid username or password");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String email = request.getParameter("email");
        String fullName = request.getParameter("fullName");

        if (!password.equals(confirmPassword)) {
            request.setAttribute("errorMessage", "Passwords do not match");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
            return;
        }

        boolean success = authService.register(username, password, email, fullName, "WAITER");

        if (success) {
            request.setAttribute("successMessage", "Registration successful. Please login.");
            request.getRequestDispatcher("/view/auth/login.jsp").forward(request, response);
        } else {
            request.setAttribute("errorMessage", "Registration failed. Username or email already exists.");
            request.getRequestDispatcher("/view/auth/register.jsp").forward(request, response);
        }
    }
}
