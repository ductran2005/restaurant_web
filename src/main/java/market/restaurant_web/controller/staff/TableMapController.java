package market.restaurant_web.controller.staff;

import market.restaurant_web.service.TableService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/staff")
public class TableMapController extends HttpServlet {
    private final TableService tableService = new TableService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("areas", tableService.findAllAreas());
        req.setAttribute("tables", tableService.findAllTables());
        req.getRequestDispatcher("/WEB-INF/views/staff/table-map.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("updateStatus".equals(action)) {
            int tableId = Integer.parseInt(req.getParameter("tableId"));
            String status = req.getParameter("status");
            tableService.updateTableStatus(tableId, status);
        }
        resp.sendRedirect(req.getContextPath() + "/staff");
    }
}
