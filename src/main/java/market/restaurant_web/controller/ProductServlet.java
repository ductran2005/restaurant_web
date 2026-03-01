package market.restaurant_web.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import market.restaurant_web.entity.Product;
import market.restaurant_web.service.POSService;

import java.io.IOException;
import java.util.List;

@WebServlet("/admin/product")
public class ProductServlet extends HttpServlet {

    private final POSService posService = new POSService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            if (action == null) {
                // Hiển thị danh sách sản phẩm
                List<Product> list = posService.getAllProducts();
                request.setAttribute("list", list);
                request.getRequestDispatcher("/WEB-INF/views/adminMenu.jsp").forward(request, response);

            } else if ("delete".equals(action)) {
                // Soft delete sản phẩm
                int id = Integer.parseInt(request.getParameter("id"));
                posService.softDeleteProduct(id);
                response.sendRedirect(request.getContextPath() + "/admin/product");

            } else if ("edit".equals(action)) {
                // Hiển thị form edit
                int id = Integer.parseInt(request.getParameter("id"));
                Product product = posService.getProductById(id);
                request.setAttribute("product", product);
                request.getRequestDispatcher("/WEB-INF/views/editProduct.jsp").forward(request, response);

            } else if ("search".equals(action)) {
                // Tìm kiếm sản phẩm
                String keyword = request.getParameter("keyword");
                List<Product> list = posService.searchProducts(keyword);
                request.setAttribute("list", list);
                request.setAttribute("keyword", keyword);
                request.getRequestDispatcher("/WEB-INF/views/adminMenu.jsp").forward(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        request.setCharacterEncoding("UTF-8");
        String action = request.getParameter("action");

        try {
            if ("update".equals(action)) {
                // Cập nhật sản phẩm
                int id = Integer.parseInt(request.getParameter("productId"));
                Product product = posService.getProductById(id);

                product.setProductName(request.getParameter("name"));
                product.setPrice(Double.parseDouble(request.getParameter("price")));
                product.setCostPrice(Double.parseDouble(request.getParameter("cost")));
                product.setCategoryId(Integer.parseInt(request.getParameter("category")));
                product.setDescription(request.getParameter("description"));

                posService.updateProduct(product);

            } else {
                // Thêm sản phẩm mới
                String name = request.getParameter("name");
                double price = Double.parseDouble(request.getParameter("price"));
                double cost = Double.parseDouble(request.getParameter("cost"));
                int categoryId = Integer.parseInt(request.getParameter("category"));
                String description = request.getParameter("description");

                if (price <= 0) {
                    request.setAttribute("error", "Giá bán phải lớn hơn 0");
                    doGet(request, response);
                    return;
                }

                Product p = new Product(categoryId, name, price, cost, "AVAILABLE", description);
                posService.addProduct(p);
            }

            response.sendRedirect(request.getContextPath() + "/admin/product");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }
}
