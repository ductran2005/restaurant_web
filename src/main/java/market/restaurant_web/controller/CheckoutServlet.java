package market.restaurant_web.controller;

import market.restaurant_web.entity.User;
import market.restaurant_web.entity.Order;
import market.restaurant_web.entity.OrderDetail;
import market.restaurant_web.entity.Payment;
import market.restaurant_web.dao.PaymentDAO;
import market.restaurant_web.service.POSService;
import market.restaurant_web.service.PaymentService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Checkout Servlet — Thanh toán tiền mặt + hiển thị hoá đơn.
 *
 * GET /checkout?orderId=X → trang thanh toán
 * GET /checkout?view=receipt&orderId=X → hiển thị hoá đơn
 * POST /checkout → xác nhận thanh toán tiền mặt
 */
@WebServlet(urlPatterns = { "/checkout" })
public class CheckoutServlet extends BaseServlet {
    private final PaymentService paymentService = new PaymentService();
    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final POSService posService = new POSService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String view = request.getParameter("view");
        String orderIdParam = request.getParameter("orderId");

        // ======= Hiển thị hoá đơn (receipt) =======
        if ("receipt".equals(view)) {
            try {
                int orderId = Integer.parseInt(orderIdParam);
                Order order = posService.getOrderById(orderId);
                List<OrderDetail> details = posService.getOrderDetails(orderId);

                // Tìm payment theo orderId
                List<Payment> payments = paymentDAO.findByOrderId(orderId);
                Payment payment = (payments != null && !payments.isEmpty()) ? payments.get(0) : null;

                request.setAttribute("order", order);
                request.setAttribute("orderDetails", details);
                request.setAttribute("payment", payment);
                request.getRequestDispatcher("/WEB-INF/views/receipt.jsp").forward(request, response);
            } catch (Exception e) {
                request.setAttribute("error", "Lỗi khi tải hoá đơn: " + e.getMessage());
                request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
            }
            return;
        }

        // ======= Hiển thị trang thanh toán =======
        if (orderIdParam == null || orderIdParam.isBlank()) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Thiếu orderId");
            return;
        }

        try {
            int orderId = Integer.parseInt(orderIdParam);
            Order order = posService.getOrderById(orderId);
            if (order == null) {
                response.sendError(HttpServletResponse.SC_NOT_FOUND,
                        "Không tìm thấy đơn hàng #" + orderId);
                return;
            }

            List<OrderDetail> details = posService.getOrderDetails(orderId);

            request.setAttribute("orderId", orderId);
            request.setAttribute("order", order);
            request.setAttribute("orderDetails", details);
            request.setAttribute("totalAmount", order.getTotalAmount());

            request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "orderId không hợp lệ");
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi trang thanh toán: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }

    /**
     * POST /checkout — Xác nhận thanh toán tiền mặt.
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User current = getCurrentUser(request);
        if (current == null) {
            redirectToLogin(request, response);
            return;
        }

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));
            Order order = posService.getOrderById(orderId);
            BigDecimal totalAmount = order.getTotalAmount();

            // Thanh toán tiền mặt: amountPaid = totalAmount
            boolean ok = paymentService.processPayment(
                    orderId, totalAmount, "CASH", current.getUserId());

            if (ok) {
                response.sendRedirect(request.getContextPath()
                        + "/checkout?view=receipt&orderId=" + orderId);
            } else {
                request.setAttribute("error", "Thanh toán thất bại hoặc đơn đã đóng");
                loadOrderData(request, orderId);
                request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
            }
        } catch (Exception e) {
            request.setAttribute("error", "Lỗi: " + e.getMessage());
            try {
                int oid = Integer.parseInt(request.getParameter("orderId"));
                loadOrderData(request, oid);
            } catch (Exception ignored) {
            }
            request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);
        }
    }

    private void loadOrderData(HttpServletRequest request, int orderId) {
        Order order = posService.getOrderById(orderId);
        List<OrderDetail> details = posService.getOrderDetails(orderId);
        request.setAttribute("orderId", orderId);
        request.setAttribute("order", order);
        request.setAttribute("orderDetails", details);
        request.setAttribute("totalAmount", order != null ? order.getTotalAmount() : BigDecimal.ZERO);
    }
}
