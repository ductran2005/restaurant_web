package market.restaurant_web.controller.admin;

import market.restaurant_web.service.PermissionService;
import market.restaurant_web.service.UserService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/rbac")
public class RbacController extends HttpServlet {
    private final PermissionService permissionService = new PermissionService();
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setAttribute("roles", userService.findAllRoles());
        req.setAttribute("permissions", permissionService.findAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/rbac.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("toggle".equals(action)) {
                int roleId = Integer.parseInt(req.getParameter("roleId"));
                String permCode = req.getParameter("permission");
                boolean grant = "true".equals(req.getParameter("grant"));
                permissionService.togglePermission(roleId, permCode, grant);
            }
        } catch (RuntimeException e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/rbac");
    }
}
