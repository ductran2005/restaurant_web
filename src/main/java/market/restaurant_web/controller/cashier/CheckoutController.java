package market.restaurant_web.controller.cashier;

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

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int orderId = Integer.parseInt(req.getParameter("orderId"));
        req.setAttribute("order", orderService.findById(orderId));
        Payment existingPayment = paymentService.findByOrderId(orderId);
        req.setAttribute("payment", existingPayment);
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
