package market.restaurant_web.controller.cashier;

import market.restaurant_web.entity.Order;
import market.restaurant_web.entity.Payment;
import market.restaurant_web.entity.User;
import market.restaurant_web.service.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/cashier/checkout")
public class CheckoutController extends HttpServlet {
    private final OrderService orderService = new OrderService();
    private final PaymentService paymentService = new PaymentService();
    private final ConfigService configService = new ConfigService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String idStr = req.getParameter("orderId");
        if (idStr == null || idStr.trim().isEmpty()) {
            req.getSession().setAttribute("flash_msg", "Order ID is required");
            req.getSession().setAttribute("flash_type", "error");
            resp.sendRedirect(req.getContextPath() + "/cashier");
            return;
        }
        int orderId;
        try {
            orderId = Integer.parseInt(idStr);
        } catch (NumberFormatException e) {
            req.getSession().setAttribute("flash_msg", "Invalid order ID");
            req.getSession().setAttribute("flash_type", "error");
            resp.sendRedirect(req.getContextPath() + "/cashier");
            return;
        }
        Order order = orderService.findById(orderId);
        if (order == null || !"SERVED".equals(order.getStatus())) {
            req.getSession().setAttribute("flash_msg",
                    "Đơn hàng phải được Staff yêu cầu thanh toán (SERVED) mới có thể xử lý.");
            req.getSession().setAttribute("flash_type", "error");
            resp.sendRedirect(req.getContextPath() + "/cashier");
            return;
        }
        req.setAttribute("order", order);
        Payment existingPayment = paymentService.findByOrderId(orderId);
        req.setAttribute("payment", existingPayment);

        // Calculate deposit and final amount to pay
        java.math.BigDecimal depositAmount = java.math.BigDecimal.ZERO;
        java.math.BigDecimal grandTotal = order.getTotalAmount();
        java.math.BigDecimal finalAmountToPay = grandTotal;

        if (order.getBooking() != null && order.getBooking().getDepositAmount() != null) {
            depositAmount = order.getBooking().getDepositAmount();
            finalAmountToPay = grandTotal.subtract(depositAmount);
            // Ensure final amount is not negative
            if (finalAmountToPay.compareTo(java.math.BigDecimal.ZERO) < 0) {
                finalAmountToPay = java.math.BigDecimal.ZERO;
            }
        }

        req.setAttribute("depositAmount", depositAmount);
        req.setAttribute("finalAmountToPay", finalAmountToPay);

        // SePay QR config
        String sepayEnabled = configService.getValue("SEPAY_ENABLED");
        req.setAttribute("sepayEnabled", "true".equals(sepayEnabled));
        req.setAttribute("sepayBankAccount", configService.getValue("SEPAY_BANK_ACCOUNT"));
        req.setAttribute("sepayBankName", configService.getValue("SEPAY_BANK_NAME"));
        req.setAttribute("sepayAccountName", configService.getValue("SEPAY_ACCOUNT_NAME"));
        req.setAttribute("sepayContentPrefix", configService.getValue("SEPAY_CONTENT_PREFIX"));

        req.getRequestDispatcher("/WEB-INF/views/cashier/checkout.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        User cashier = (User) req.getSession().getAttribute("user");
        String action = req.getParameter("action");

        try {
            if ("pay".equals(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String method = req.getParameter("paymentMethod");
                Payment payment = paymentService.checkout(orderId, method, cashier.getId());
                req.getSession().setAttribute("flash_msg",
                        "Thanh toán thành công! Mã TT: #" + payment.getId());
                req.getSession().setAttribute("flash_type", "success");
                resp.sendRedirect(req.getContextPath() + "/cashier");
                return;
            }
        } catch (RuntimeException e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        resp.sendRedirect(req.getContextPath() + "/cashier");
    }
}
