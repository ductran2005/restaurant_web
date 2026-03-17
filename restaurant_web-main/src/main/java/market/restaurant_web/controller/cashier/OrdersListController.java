package market.restaurant_web.controller.cashier;

import market.restaurant_web.service.OrderService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/cashier")
public class OrdersListController extends HttpServlet {
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String tab = req.getParameter("tab");
        if ("paid".equals(tab)) {
            req.setAttribute("paidOrders", orderService.findByStatus("PAID"));
            req.setAttribute("activeTab", "paid");
        } else {
            req.setAttribute("orders", orderService.findActiveOrdersWithItems());
            req.setAttribute("activeTab", "orders");
        }
        req.getRequestDispatcher("/WEB-INF/views/cashier/orders-list.jsp").forward(req, resp);
    }
}
