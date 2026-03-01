package market.restaurant_web.controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import market.restaurant_web.entity.Product;
import market.restaurant_web.entity.Category;
import market.restaurant_web.service.POSService;
import market.restaurant_web.dao.CategoryDAO;
import market.restaurant_web.dao.ProductDAO;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardCopyOption;
import java.util.List;
import java.util.UUID;

@WebServlet("/admin/product")
@MultipartConfig(fileSizeThreshold = 1024 * 1024, // 1 MB
        maxFileSize = 5 * 1024 * 1024, // 5 MB
        maxRequestSize = 10 * 1024 * 1024 // 10 MB
)
public class ProductServlet extends BaseServlet {

    private final POSService posService = new POSService();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final ProductDAO productDAO = new ProductDAO();
    private static final String UPLOAD_DIR = "uploads/products";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String action = request.getParameter("action");

        try {
            // Luôn load categories cho dropdown
            List<Category> categories = categoryDAO.getAll();
            request.setAttribute("categories", categories);

            if ("search".equals(action)) {
                // Tìm kiếm theo tên
                String keyword = request.getParameter("keyword");
                request.setAttribute("keyword", keyword);

                List<Product> list;
                if (keyword != null && !keyword.trim().isEmpty()) {
                    list = productDAO.searchByName(keyword.trim());
                } else {
                    list = posService.getAllProducts();
                }
                request.setAttribute("list", list);
                request.getRequestDispatcher("/WEB-INF/views/adminMenu.jsp").forward(request, response);

            } else if ("filter".equals(action)) {
                // Lọc theo category
                String catIdParam = request.getParameter("categoryId");
                if (catIdParam != null && !catIdParam.isEmpty()) {
                    int categoryId = Integer.parseInt(catIdParam);
                    List<Product> list = productDAO.getByCategory(categoryId);
                    request.setAttribute("list", list);
                    request.setAttribute("selectedCategory", categoryId);
                } else {
                    request.setAttribute("list", posService.getAllProducts());
                }
                request.getRequestDispatcher("/WEB-INF/views/adminMenu.jsp").forward(request, response);

            } else if ("delete".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                posService.softDeleteProduct(id);
                response.sendRedirect(request.getContextPath() + "/admin/product?success=Đã ẩn sản phẩm");

            } else if ("edit".equals(action)) {
                int id = Integer.parseInt(request.getParameter("id"));
                Product product = posService.getProductById(id);
                request.setAttribute("product", product);
                request.setAttribute("categories", categoryDAO.getAll());
                request.getRequestDispatcher("/WEB-INF/views/editProduct.jsp").forward(request, response);

            } else {
                // Mặc định: hiển thị tất cả
                List<Product> list = posService.getAllProducts();
                request.setAttribute("list", list);
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
                int id = Integer.parseInt(request.getParameter("productId"));
                Product product = posService.getProductById(id);

                product.setProductName(request.getParameter("name"));
                product.setPrice(new BigDecimal(request.getParameter("price")));
                product.setCostPrice(new BigDecimal(request.getParameter("cost")));

                int categoryId = Integer.parseInt(request.getParameter("category"));
                Category category = categoryDAO.getById(categoryId);
                product.setCategory(category);

                product.setDescription(request.getParameter("description"));

                // Xử lý upload ảnh (nếu có)
                String imageUrl = handleImageUpload(request);
                if (imageUrl != null) {
                    product.setImageUrl(imageUrl);
                }

                posService.updateProduct(product);

            } else {
                // Thêm sản phẩm mới
                String name = request.getParameter("name");
                BigDecimal price = new BigDecimal(request.getParameter("price"));
                BigDecimal cost = new BigDecimal(request.getParameter("cost"));
                int categoryId = Integer.parseInt(request.getParameter("category"));
                String description = request.getParameter("description");

                if (price.compareTo(BigDecimal.ZERO) <= 0) {
                    request.setAttribute("error", "Giá bán phải lớn hơn 0");
                    doGet(request, response);
                    return;
                }

                Category category = categoryDAO.getById(categoryId);

                Product p = new Product();
                p.setProductName(name);
                p.setPrice(price);
                p.setCostPrice(cost);
                p.setCategory(category);
                p.setDescription(description);

                // Xử lý upload ảnh
                String imageUrl = handleImageUpload(request);
                if (imageUrl != null) {
                    p.setImageUrl(imageUrl);
                }

                posService.addProduct(p);
            }

            response.sendRedirect(request.getContextPath() + "/admin/product?success=Lưu thành công");

        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/views/error.jsp").forward(request, response);
        }
    }

    /**
     * Upload ảnh sản phẩm, trả về đường dẫn tương đối.
     * Trả về null nếu không có file.
     */
    private String handleImageUpload(HttpServletRequest request) {
        try {
            Part filePart = request.getPart("image");
            if (filePart == null || filePart.getSize() == 0) {
                return null;
            }

            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            if (fileName == null || fileName.isEmpty()) {
                return null;
            }

            // Validate loại file
            String contentType = filePart.getContentType();
            if (!contentType.startsWith("image/")) {
                return null;
            }

            // Tên file unique
            String ext = fileName.substring(fileName.lastIndexOf("."));
            String newFileName = UUID.randomUUID().toString() + ext;

            // Thư mục upload
            String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR;
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }

            // Lưu file
            Path filePath = Paths.get(uploadPath, newFileName);
            try (InputStream input = filePart.getInputStream()) {
                Files.copy(input, filePath, StandardCopyOption.REPLACE_EXISTING);
            }

            return UPLOAD_DIR + "/" + newFileName;
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
