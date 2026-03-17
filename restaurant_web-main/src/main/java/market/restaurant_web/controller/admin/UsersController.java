package market.restaurant_web.controller.admin;

import market.restaurant_web.service.UserService;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet(urlPatterns = { "/admin/users", "/admin/users/save", "/admin/users/update",
        "/admin/users/lock", "/admin/users/unlock", "/admin/users/reset-password" })
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
        String ctx = req.getContextPath();
        String uri = req.getRequestURI().substring(ctx.length());

        try {
            switch (uri) {
                case "/admin/users/save" -> handleCreate(req);
                case "/admin/users/update" -> handleUpdate(req);
                case "/admin/users/lock" -> handleToggleStatus(req);
                case "/admin/users/unlock" -> handleToggleStatus(req);
                case "/admin/users/reset-password" -> handleResetPassword(req);
                default -> {
                    // fallback: old action-based routing
                    String action = req.getParameter("action");
                    if ("create".equals(action))
                        handleCreate(req);
                    else if ("toggleStatus".equals(action))
                        handleToggleStatus(req);
                    else if ("resetPassword".equals(action))
                        handleResetPassword(req);
                }
            }
        } catch (RuntimeException e) {
            req.getSession().setAttribute("flash_msg", e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }
        resp.sendRedirect(ctx + "/admin/users");
    }

    private void handleCreate(HttpServletRequest req) {
        userService.create(
                ValidationUtil.sanitize(req.getParameter("username")),
                ValidationUtil.sanitize(req.getParameter("fullName")),
                req.getParameter("password"),
                ValidationUtil.sanitize(req.getParameter("phone")),
                ValidationUtil.sanitize(req.getParameter("email")),
                Integer.parseInt(req.getParameter("roleId")));
        req.getSession().setAttribute("flash_msg", "Tạo người dùng thành công!");
        req.getSession().setAttribute("flash_type", "success");
    }

    private void handleUpdate(HttpServletRequest req) {
        int userId = Integer.parseInt(req.getParameter("userId"));
        userService.update(
                userId,
                ValidationUtil.sanitize(req.getParameter("fullName")),
                ValidationUtil.sanitize(req.getParameter("email")),
                ValidationUtil.sanitize(req.getParameter("phone")),
                Integer.parseInt(req.getParameter("roleId")),
                req.getParameter("password"));
        req.getSession().setAttribute("flash_msg", "Cập nhật người dùng thành công!");
        req.getSession().setAttribute("flash_type", "success");
    }

    private void handleToggleStatus(HttpServletRequest req) {
        String idStr = req.getParameter("id");
        if (idStr == null)
            idStr = req.getParameter("userId");
        userService.toggleStatus(Integer.parseInt(idStr));
        req.getSession().setAttribute("flash_msg", "Cập nhật trạng thái thành công!");
        req.getSession().setAttribute("flash_type", "success");
    }

    private void handleResetPassword(HttpServletRequest req) {
        String idStr = req.getParameter("id");
        if (idStr == null)
            idStr = req.getParameter("userId");
        userService.resetPassword(Integer.parseInt(idStr), "123456");
        req.getSession().setAttribute("flash_msg", "Reset mật khẩu thành công! Mật khẩu mới: 123456");
        req.getSession().setAttribute("flash_type", "success");
    }
}
