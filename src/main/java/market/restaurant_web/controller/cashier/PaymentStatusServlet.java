package market.restaurant_web.controller.cashier;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.entity.Order;
import org.hibernate.Session;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * API endpoint for frontend to poll payment status of an order.
 * Called by checkout.jsp every 3 seconds when QR payment is shown.
 *
 * GET /api/payment/status?orderId=123
 * Response: {"status": "PAID"} or {"status": "PENDING"}
 */
@WebServlet("/api/payment/status")
public class PaymentStatusServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        // Allow CORS for local dev if needed
        resp.setHeader("Cache-Control", "no-cache, no-store");

        PrintWriter out = resp.getWriter();

        String orderIdParam = req.getParameter("orderId");
        if (orderIdParam == null || orderIdParam.isEmpty()) {
            resp.setStatus(400);
            out.print("{\"status\":\"ERROR\",\"message\":\"Missing orderId\"}");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);
            try (Session session = HibernateUtil.getSessionFactory().openSession()) {
                Order order = session.get(Order.class, orderId);
                if (order == null) {
                    resp.setStatus(404);
                    out.print("{\"status\":\"ERROR\",\"message\":\"Order not found\"}");
                    return;
                }
                // Return current status
                out.print("{\"status\":\"" + order.getStatus() + "\"}");
            }
        } catch (NumberFormatException e) {
            resp.setStatus(400);
            out.print("{\"status\":\"ERROR\",\"message\":\"Invalid orderId\"}");
        } catch (Exception e) {
            resp.setStatus(500);
            out.print("{\"status\":\"ERROR\",\"message\":\"" + e.getMessage().replace("\"", "'") + "\"}");
        }
    }
}
