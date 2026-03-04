package market.restaurant_web.controller.admin;

import market.restaurant_web.entity.*;
import market.restaurant_web.service.*;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/tables")
public class TablesAreasController extends HttpServlet {
    private final TableService tableService = new TableService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("areas", tableService.findAllAreas());
        req.setAttribute("tables", tableService.findAllTables());
        req.getRequestDispatcher("/WEB-INF/views/admin/tables-areas.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if ("saveArea".equals(action)) {
            Area area = new Area();
            String idStr = req.getParameter("areaId");
            if (idStr != null && !idStr.isEmpty())
                area.setId(Integer.parseInt(idStr));
            area.setName(ValidationUtil.sanitize(req.getParameter("areaName")));
            // description column exists in areas table
            area.setDescription(ValidationUtil.sanitize(req.getParameter("description")));
            tableService.saveArea(area);
        } else if ("saveTable".equals(action)) {
            DiningTable table = new DiningTable();
            String idStr = req.getParameter("tableId");
            if (idStr != null && !idStr.isEmpty())
                table.setId(Integer.parseInt(idStr));
            table.setCode(ValidationUtil.sanitize(req.getParameter("tableCode")));
            table.setArea(tableService.findAreaById(Integer.parseInt(req.getParameter("areaId"))));
            table.setSeats(ValidationUtil.parseInt(req.getParameter("seats"), 4));
            // DB constraint: status IN ('AVAILABLE','IN_USE')
            String status = req.getParameter("status");
            table.setStatus(status != null ? status : "AVAILABLE");
            tableService.saveTable(table);
        }
        req.getSession().setAttribute("flash_msg", "Thao tác thành công!");
        req.getSession().setAttribute("flash_type", "success");
        resp.sendRedirect(req.getContextPath() + "/admin/tables");
    }
}
