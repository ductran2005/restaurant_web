package market.restaurant_web.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import market.restaurant_web.entity.Order;
import market.restaurant_web.entity.OrderDetail;
import market.restaurant_web.entity.Payment;
import market.restaurant_web.service.POSService;

import java.io.IOException;
import java.util.List;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private final POSService posService = new POSService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if (action == null) {
                // Hiển thị danh sách đơn hàng đang chờ
                List<Order> pendingOrders = posService.getPendingOrders();
                request.setAttribute("orders", pendingOrders);
                request.getRequestDispatcher("/WEB-INF/views/checkout.jsp").forward(request, response);

            } else if ("detail".equals(action)) {
                // Chi tiết đơn hàng
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                List<OrderDetail> details = posService.getOrderDetails(orderId);
                request.setAttribute("details", details);
                request.getRequestDispatcher("/WEB-INF/views/orderDetail.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if ("pay".equals(action)) {
                // Thanh toán
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                String paymentMethod = request.getParameter("paymentMethod");

                Payment payment = posService.checkout(orderId, paymentMethod);

                if (payment != null) {
                    request.setAttribute("payment", payment);
                    request.setAttribute("success", "Thanh toán thành công!");
                } else {
                    request.setAttribute("error", "Không thể thanh toán đơn hàng này.");
                }

            } else if ("cancel".equals(action)) {
                // Hủy đơn hàng
                int orderId = Integer.parseInt(request.getParameter("orderId"));
                posService.cancelOrder(orderId);
                request.setAttribute("success", "Đã hủy đơn hàng.");
            }

            response.sendRedirect(request.getContextPath() + "/checkout");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}
