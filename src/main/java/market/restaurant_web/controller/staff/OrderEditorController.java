package market.restaurant_web.controller.staff;

import market.restaurant_web.entity.User;
import market.restaurant_web.service.*;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/staff/orders")
public class OrderEditorController extends HttpServlet {
    private final OrderService orderService = new OrderService();
    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        // Called from table-map: create a new order for the table then redirect
        if ("create".equals(action)) {
            User staff = (User) req.getSession().getAttribute("user");
            try {
                int tableId = Integer.parseInt(req.getParameter("tableId"));
                var order = orderService.createOrder(tableId, staff.getId());
                resp.sendRedirect(req.getContextPath() + "/staff/orders?orderId=" + order.getId());
            } catch (RuntimeException e) {
                // Table already has an open order — extract order id from message or just
                // redirect
                req.getSession().setAttribute("flash_msg", e.getMessage());
                req.getSession().setAttribute("flash_type", "error");
                resp.sendRedirect(req.getContextPath() + "/staff");
            }
            return;
        }

        String orderIdStr = req.getParameter("orderId");
        if (orderIdStr != null && !orderIdStr.isEmpty()) {
            req.setAttribute("order", orderService.findById(Integer.parseInt(orderIdStr)));
        }
        req.setAttribute("activeOrders", orderService.findActiveOrders());
        req.setAttribute("products", productService.findAvailable());
        req.setAttribute("categories", categoryService.findActive());
        req.getRequestDispatcher("/WEB-INF/views/staff/order-editor.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        User staff = (User) req.getSession().getAttribute("user");

        try {
            if ("create".equals(action)) {
                int tableId = Integer.parseInt(req.getParameter("tableId"));
                var order = orderService.createOrder(tableId, staff.getId());
                resp.sendRedirect(req.getContextPath() + "/staff/orders?orderId=" + order.getId());
                return;
            } else if ("addItem".equals(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                int productId = Integer.parseInt(req.getParameter("productId"));
                int qty = ValidationUtil.parseInt(req.getParameter("quantity"), 1);
                orderService.addItem(orderId, productId, qty);
                resp.sendRedirect(req.getContextPath() + "/staff/orders?orderId=" + orderId);
                return;
            } else if ("removeItem".equals(action)) {
                int orderDetailId = Integer.parseInt(req.getParameter("orderDetailId"));
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                String cancelReason = req.getParameter("cancelReason");
                orderService.removeItem(orderDetailId, cancelReason);
                resp.sendRedirect(req.getContextPath() + "/staff/orders?orderId=" + orderId);
                return;
            } else if ("confirmItems".equals(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                orderService.confirmItems(orderId);
                req.getSession().setAttribute("flash_msg", "Đã gửi thông tin món vào bếp!");
                req.getSession().setAttribute("flash_type", "success");
                resp.sendRedirect(req.getContextPath() + "/staff/orders?orderId=" + orderId);
                return;
            } else if ("confirm".equals(action)) {
                int orderId = Integer.parseInt(req.getParameter("orderId"));
                orderService.confirmOrder(orderId);
                req.getSession().setAttribute("flash_msg", "Đã chốt đơn hàng! Đang chờ thanh toán.");
                req.getSession().setAttribute("flash_type", "success");
                resp.sendRedirect(req.getContextPath() + "/staff/orders?orderId=" + orderId);
                return;
            }
        } catch (RuntimeException e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        resp.sendRedirect(req.getContextPath() + "/staff/orders");
    }
}
