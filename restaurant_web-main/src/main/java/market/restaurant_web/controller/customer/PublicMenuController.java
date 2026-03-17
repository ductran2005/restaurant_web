package market.restaurant_web.controller.customer;

import market.restaurant_web.service.CategoryService;
import market.restaurant_web.service.ProductService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/menu")
public class PublicMenuController extends HttpServlet {
    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("search");
        String catId = req.getParameter("categoryId");
        Integer categoryId = (catId != null && !catId.isEmpty()) ? Integer.parseInt(catId) : null;

        req.setAttribute("categories", categoryService.findActive());
        req.setAttribute("products", productService.search(search, categoryId));
        req.setAttribute("search", search);
        req.setAttribute("selectedCategoryId", categoryId);
        req.setAttribute("navActive", "menu");
        req.getRequestDispatcher("/WEB-INF/views/public/public-menu.jsp").forward(req, resp);
    }
}
