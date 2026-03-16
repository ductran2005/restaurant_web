package market.restaurant_web.controller.user;

import market.restaurant_web.config.HibernateUtil;

import market.restaurant_web.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.io.IOException;

/**
 * User profile — /user/profile
 * GET  → show profile form
 * POST → update profile info (fullName, phone, email)
 */
@WebServlet("/user/profile")
public class UserProfileController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // Capture the page user came from
        String referer = req.getHeader("Referer");
        if (referer != null && !referer.contains("/user/profile")) {
            req.setAttribute("returnUrl", referer);
        }
        req.setAttribute("navActive", "profile");
        req.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession httpSession = req.getSession(false);
        if (httpSession == null || httpSession.getAttribute("user") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        User sessionUser = (User) httpSession.getAttribute("user");
        String fullName = req.getParameter("fullName");
        String phone = req.getParameter("phone");
        String email = req.getParameter("email");
        String returnUrl = req.getParameter("returnUrl");

        Session dbSession = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = dbSession.beginTransaction();
        try {
            User user = dbSession.get(User.class, sessionUser.getId());
            if (user != null) {
                if (fullName != null && !fullName.trim().isEmpty()) {
                    user.setFullName(fullName.trim());
                }
                if (phone != null) {
                    user.setPhone(phone.trim());
                }
                if (email != null && !email.trim().isEmpty()) {
                    user.setEmail(email.trim());
                }
                dbSession.merge(user);
                tx.commit();

                // Update session with new info
                httpSession.setAttribute("user", user);
            }
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            req.setAttribute("error", "Lỗi: " + e.getMessage());
            req.setAttribute("navActive", "profile");
            req.getRequestDispatcher("/WEB-INF/views/user/profile.jsp").forward(req, resp);
            return;
        } finally {
            dbSession.close();
        }

        // Redirect back to previous page
        if (returnUrl != null && !returnUrl.trim().isEmpty()) {
            resp.sendRedirect(returnUrl);
        } else {
            resp.sendRedirect(req.getContextPath() + "/user/home");
        }
    }
}
