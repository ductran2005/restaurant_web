package market.restaurant_web.controller;

import market.restaurant_web.entity.*;
import market.restaurant_web.service.POSService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/menu")
public class MenuServlet extends BaseServlet {

    private final POSService posService = new POSService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String orderIdParam = request.getParameter("orderId");

        if (orderIdParam != null) {
            int orderId = Integer.parseInt(orderIdParam);
            Order order = posService.getOrderById(orderId);
            List<OrderDetail> details = posService.getOrderDetails(orderId);
            request.setAttribute("order", order);
            request.setAttribute("orderDetails", details);
        }

        List<Product> products = posService.getAvailableProducts();
        List<Category> categories = posService.getAllCategories();
        request.setAttribute("products", products);
        request.setAttribute("categories", categories);

        request.getRequestDispatcher("/WEB-INF/views/menu.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        User user = getCurrentUser(request);
        if (user == null) {
            redirectToLogin(request, response);
            return;
        }

        String action = request.getParameter("action");

        try {
            int orderId = Integer.parseInt(request.getParameter("orderId"));

            if ("addItem".equals(action)) {
                int productId = Integer.parseInt(request.getParameter("productId"));
                int quantity = Integer.parseInt(request.getParameter("quantity"));
                posService.addItemToOrder(orderId, productId, quantity);

            } else if ("confirm".equals(action)) {
                posService.confirmOrder(orderId);

            } else if ("cancel".equals(action)) {
                posService.cancelOrder(orderId);
                response.sendRedirect(request.getContextPath() + "/tables");
                return;
            }

            response.sendRedirect(request.getContextPath() + "/menu?orderId=" + orderId);

        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
            doGet(request, response);
        }
    }
}
