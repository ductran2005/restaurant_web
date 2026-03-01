package market.restaurant_web.controller;

import market.restaurant_web.entity.*;
import market.restaurant_web.service.POSService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/orders")
public class OrderServlet extends BaseServlet {

    private final POSService posService = new POSService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String tab = request.getParameter("tab");
        List<Order> orders;

        if ("paid".equals(tab)) {
            orders = posService.getPaidOrders();
        } else {
            orders = posService.getOpenOrders();
            tab = "open";
        }

        request.setAttribute("orders", orders);
        request.setAttribute("tab", tab);
        request.getRequestDispatcher("/WEB-INF/views/cart.jsp").forward(request, response);
    }
}
