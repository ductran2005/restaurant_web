package market.restaurant_web.controller.admin;

import market.restaurant_web.service.UserService;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/users")
public class UsersController extends HttpServlet {
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String roleIdStr = req.getParameter("roleId");
        Integer roleId = (roleIdStr != null && !roleIdStr.isEmpty()) ? Integer.parseInt(roleIdStr) : null;

        req.setAttribute("users", userService.search(keyword, roleId));
        req.setAttribute("roles", userService.findAllRoles());
        req.setAttribute("keyword", keyword);
        req.setAttribute("selectedRoleId", roleId);
        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("create".equals(action)) {
                userService.create(
                        ValidationUtil.sanitize(req.getParameter("username")),
                        ValidationUtil.sanitize(req.getParameter("fullName")),
                        req.getParameter("password"),
                        ValidationUtil.sanitize(req.getParameter("phone")),
                        ValidationUtil.sanitize(req.getParameter("email")),
                        Integer.parseInt(req.getParameter("roleId")));
                req.getSession().setAttribute("flash_msg", "Tạo người dùng thành công!");
                req.getSession().setAttribute("flash_type", "success");
            } else if ("toggleStatus".equals(action)) {
                userService.toggleStatus(Integer.parseInt(req.getParameter("userId")));
            } else if ("resetPassword".equals(action)) {
                userService.resetPassword(
                        Integer.parseInt(req.getParameter("userId")),
                        req.getParameter("newPassword"));
                req.getSession().setAttribute("flash_msg", "Reset mật khẩu thành công!");
                req.getSession().setAttribute("flash_type", "success");
            }
        } catch (RuntimeException e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        resp.sendRedirect(req.getContextPath() + "/admin/users");
    }
}
