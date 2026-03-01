package market.restaurant_web.controller;

import market.restaurant_web.entity.*;
import market.restaurant_web.service.POSService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/tables")
public class TableServlet extends BaseServlet {

    private final POSService posService = new POSService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        List<Area> areas = posService.getAllAreas();
        List<RestaurantTable> tables = posService.getAllTables();

        request.setAttribute("areas", areas);
        request.setAttribute("tables", tables);
        request.getRequestDispatcher("/WEB-INF/views/tables.jsp").forward(request, response);
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
            if ("open".equals(action)) {
                int tableId = Integer.parseInt(request.getParameter("tableId"));
                int orderId = posService.openTable(tableId, user);
                response.sendRedirect(request.getContextPath() + "/menu?orderId=" + orderId);
                return;
            }
        } catch (Exception e) {
            request.setAttribute("error", e.getMessage());
        }

        doGet(request, response);
    }
}
