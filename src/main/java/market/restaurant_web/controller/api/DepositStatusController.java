package market.restaurant_web.controller.api;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.entity.Booking;
import org.hibernate.Session;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * GET /api/deposit/status?code=BK...
 * Returns {"status":"PAID"} or {"status":"PENDING"}
 * Used by QR polling on pre-order checkout page.
 */
@WebServlet("/api/deposit/status")
public class DepositStatusController extends HttpServlet {
    private final BookingDao bookingDao = new BookingDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        String code = req.getParameter("code");
        if (code == null || code.isBlank()) {
            out.print("{\"status\":\"ERROR\",\"message\":\"Missing code\"}");
            return;
        }
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Booking b = bookingDao.findByCode(s, code.trim().toUpperCase());
            if (b == null) {
                out.print("{\"status\":\"ERROR\",\"message\":\"Booking not found\"}");
                return;
            }
            String depositStatus = b.getDepositStatus();
            if ("PAID".equals(depositStatus)) {
                out.print("{\"status\":\"PAID\"}");
            } else {
                out.print("{\"status\":\"PENDING\"}");
            }
        } catch (Exception e) {
            out.print("{\"status\":\"ERROR\",\"message\":\"" + e.getMessage() + "\"}");
        }
    }
}
