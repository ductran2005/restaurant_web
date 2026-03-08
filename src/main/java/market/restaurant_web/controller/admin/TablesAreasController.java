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
        HttpSession session = req.getSession();

        if ("saveArea".equals(action)) {
            String areaName = ValidationUtil.sanitize(req.getParameter("areaName"));
            String idStr = req.getParameter("areaId");
            Integer areaId = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : null;

            if (tableService.isAreaNameDuplicate(areaName, areaId)) {
                session.setAttribute("flash_msg", "Tên khu vực \"" + areaName + "\" đã tồn tại!");
                session.setAttribute("flash_type", "error");
                resp.sendRedirect(req.getContextPath() + "/admin/tables");
                return;
            }

            Area area = new Area();
            area.setId(areaId);
            area.setName(areaName);
            area.setDescription(ValidationUtil.sanitize(req.getParameter("description")));
            tableService.saveArea(area);

        } else if ("saveTable".equals(action)) {
            String tableCode = ValidationUtil.sanitize(req.getParameter("tableCode"));
            String idStr = req.getParameter("tableId");
            Integer tableId = (idStr != null && !idStr.isEmpty()) ? Integer.parseInt(idStr) : null;

            if (tableService.isTableNameDuplicate(tableCode, tableId)) {
                session.setAttribute("flash_msg", "Tên bàn \"" + tableCode + "\" đã tồn tại!");
                session.setAttribute("flash_type", "error");
                resp.sendRedirect(req.getContextPath() + "/admin/tables");
                return;
            }

            DiningTable table = new DiningTable();
            table.setId(tableId);
            table.setCode(tableCode);
            table.setArea(tableService.findAreaById(Integer.parseInt(req.getParameter("areaId"))));
            table.setSeats(ValidationUtil.parseInt(req.getParameter("seats"), 4));
            String statusStr = req.getParameter("status");
            TableStatus status = TableStatus.EMPTY;
            if (statusStr != null) {
                try {
                    status = TableStatus.valueOf(statusStr);
                } catch (IllegalArgumentException e) {
                    if ("AVAILABLE".equals(statusStr))
                        status = TableStatus.EMPTY;
                    else if ("IN_USE".equals(statusStr))
                        status = TableStatus.OCCUPIED;
                }
            }
            table.setStatus(status);
            tableService.saveTable(table);
        }

        session.setAttribute("flash_msg", "Thao tác thành công!");
        session.setAttribute("flash_type", "success");
        resp.sendRedirect(req.getContextPath() + "/admin/tables");
    }
}
