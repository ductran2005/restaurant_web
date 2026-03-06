package market.restaurant_web.controller.cashier;

import market.restaurant_web.service.PaymentService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;

/**
 * API endpoint for checking payment status (used by QR payment AJAX polling).
 * GET /api/payment/status?orderId=123
 * Returns JSON: {"status": "PAID"} or {"status": "UNPAID"}
 */
@WebServlet("/api/payment/status")
public class PaymentStatusController extends HttpServlet {
    private final PaymentService paymentService = new PaymentService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr == null || orderIdStr.trim().isEmpty()) {
            out.print("{\"status\": \"ERROR\", \"message\": \"Missing orderId\"}");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdStr);
            String status = paymentService.checkPaymentStatus(orderId);
            out.print("{\"status\": \"" + status + "\"}");
        } catch (NumberFormatException e) {
            out.print("{\"status\": \"ERROR\", \"message\": \"Invalid orderId\"}");
        } catch (Exception e) {
            out.print("{\"status\": \"ERROR\", \"message\": \"" + e.getMessage() + "\"}");
        }
    }
}
