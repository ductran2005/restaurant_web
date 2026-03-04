package market.restaurant_web.controller.admin;

import market.restaurant_web.entity.Category;
import market.restaurant_web.service.CategoryService;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/admin/categories")
public class CategoriesController extends HttpServlet {
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        if (search != null && !search.isEmpty()) {
            req.setAttribute("categories", categoryService.search(search));
            req.setAttribute("search", search);
        } else {
            req.setAttribute("categories", categoryService.findAll());
        }
        req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("create".equals(action) || "update".equals(action)) {
            Category cat = new Category();
            String idStr = req.getParameter("categoryId");
            if (idStr != null && !idStr.isEmpty())
                cat.setId(Integer.parseInt(idStr));
            cat.setName(ValidationUtil.sanitize(req.getParameter("categoryName")));
            // Status: ACTIVE or INACTIVE (no description column in DB)
            cat.setStatus(req.getParameter("isActive") != null ? "ACTIVE" : "INACTIVE");
            categoryService.save(cat);

            HttpSession session = req.getSession();
            session.setAttribute("flash_msg", "Lưu danh mục thành công!");
            session.setAttribute("flash_type", "success");

        } else if ("delete".equals(action)) {
            int id = Integer.parseInt(req.getParameter("categoryId"));
            categoryService.delete(id);

            req.getSession().setAttribute("flash_msg", "Đã xóa danh mục");
            req.getSession().setAttribute("flash_type", "success");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/categories");
    }
}
