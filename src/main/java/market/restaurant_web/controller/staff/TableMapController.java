package market.restaurant_web.controller.staff;

import market.restaurant_web.entity.Order;
import market.restaurant_web.service.OrderService;
import market.restaurant_web.service.TableService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/staff")
public class TableMapController extends HttpServlet {
    private final TableService tableService = new TableService();
    private final OrderService orderService = new OrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("areas", tableService.findAllAreas());
        req.setAttribute("tables", tableService.findAllTables());

        // Build map: tableId -> openOrderId (for IN_USE tables)
        List<Order> activeOrders = orderService.findActiveOrders();
        Map<Integer, Integer> openOrderByTable = new HashMap<>();
        for (Order o : activeOrders) {
            if (o.getTable() != null) {
                openOrderByTable.put(o.getTable().getId(), o.getId());
            }
        }
        req.setAttribute("openOrderByTable", openOrderByTable);

        req.getRequestDispatcher("/WEB-INF/views/staff/table-map.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // POST no longer used for status update (status driven by orders now)
        resp.sendRedirect(req.getContextPath() + "/staff");
    }
}
