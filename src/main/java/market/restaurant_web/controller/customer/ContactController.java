package market.restaurant_web.controller.customer;

import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/contact")
public class ContactController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("navActive", "contact");
        req.getRequestDispatcher("/WEB-INF/views/public/contact.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String name = ValidationUtil.sanitize(req.getParameter("name"));
            String email = req.getParameter("email");
            String phone = req.getParameter("phone");
            String subject = ValidationUtil.sanitize(req.getParameter("subject"));
            String message = ValidationUtil.sanitize(req.getParameter("message"));

            if (ValidationUtil.isBlank(name) || ValidationUtil.isBlank(email) ||
                    ValidationUtil.isBlank(subject) || ValidationUtil.isBlank(message)) {
                throw new IllegalArgumentException("Vui lòng điền đầy đủ thông tin");
            }

            req.setAttribute("success", "Cảm ơn bạn đã liên hệ! Chúng tôi sẽ phản hồi trong vòng 24h.");
            req.getRequestDispatcher("/WEB-INF/views/public/contact.jsp").forward(req, resp);

        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("name", req.getParameter("name"));
            req.setAttribute("email", req.getParameter("email"));
            req.setAttribute("phone", req.getParameter("phone"));
            req.setAttribute("subject", req.getParameter("subject"));
            req.setAttribute("message", req.getParameter("message"));
            req.getRequestDispatcher("/WEB-INF/views/public/contact.jsp").forward(req, resp);
        }
    }
}