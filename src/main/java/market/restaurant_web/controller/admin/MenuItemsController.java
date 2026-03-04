package market.restaurant_web.controller.admin;

import market.restaurant_web.entity.*;
import market.restaurant_web.service.*;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/admin/menu")
public class MenuItemsController extends HttpServlet {
    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        String catIdStr = req.getParameter("categoryId");
        Integer categoryId = (catIdStr != null && !catIdStr.isEmpty()) ? Integer.parseInt(catIdStr) : null;

        req.setAttribute("products", productService.search(search, categoryId));
        req.setAttribute("categories", categoryService.findAll());
        req.setAttribute("search", search);
        req.setAttribute("selectedCategoryId", categoryId);
        req.getRequestDispatcher("/WEB-INF/views/admin/menu-items.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        if ("toggleStatus".equals(action)) {
            productService.toggleStatus(Integer.parseInt(req.getParameter("itemId")));
        } else if ("delete".equals(action)) {
            productService.delete(Integer.parseInt(req.getParameter("itemId")));
        } else {
            // Create or update
            Product product = new Product();
            String idStr = req.getParameter("itemId");
            if (idStr != null && !idStr.isEmpty())
                product.setId(Integer.parseInt(idStr));
            product.setName(ValidationUtil.sanitize(req.getParameter("itemName")));
            Category cat = categoryService.findById(Integer.parseInt(req.getParameter("categoryId")));
            product.setCategory(cat);
            product.setPrice(new BigDecimal(req.getParameter("price")));
            // cost_price is required in DB
            String costPriceStr = req.getParameter("costPrice");
            product.setCostPrice(costPriceStr != null && !costPriceStr.isEmpty()
                    ? new BigDecimal(costPriceStr)
                    : BigDecimal.ZERO);
            product.setDescription(ValidationUtil.sanitize(req.getParameter("description")));
            product.setStatus(req.getParameter("isActive") != null ? "AVAILABLE" : "UNAVAILABLE");
            productService.save(product);
        }

        req.getSession().setAttribute("flash_msg", "Thao tác thành công!");
        req.getSession().setAttribute("flash_type", "success");
        resp.sendRedirect(req.getContextPath() + "/admin/menu");
    }
}
