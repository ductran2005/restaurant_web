package market.restaurant_web.controller.admin;

import market.restaurant_web.entity.*;
import market.restaurant_web.service.*;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;

@WebServlet("/admin/menu")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024,    // 1 MB
        maxFileSize = 5 * 1024 * 1024,       // 5 MB
        maxRequestSize = 10 * 1024 * 1024    // 10 MB
)
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

        try {
            if ("toggleStatus".equals(action)) {
                productService.toggleStatus(Integer.parseInt(req.getParameter("itemId")));
            } else if ("delete".equals(action)) {
                // Also delete image from Supabase
                int itemId = Integer.parseInt(req.getParameter("itemId"));
                Product existing = productService.findById(itemId);
                if (existing != null && existing.getImageUrl() != null) {
                    SupabaseStorageService.deleteImage(existing.getImageUrl());
                }
                productService.delete(itemId);
            } else {
                // Create or update
                Product product = new Product();
                String idStr = req.getParameter("itemId");
                boolean isUpdate = idStr != null && !idStr.isEmpty();

                if (isUpdate) {
                    product.setId(Integer.parseInt(idStr));
                    // Preserve existing image URL if no new image uploaded
                    Product existing = productService.findById(product.getId());
                    if (existing != null) {
                        product.setImageUrl(existing.getImageUrl());
                    }
                }

                product.setName(ValidationUtil.sanitize(req.getParameter("itemName")));
                Category cat = categoryService.findById(Integer.parseInt(req.getParameter("categoryId")));
                product.setCategory(cat);
                product.setPrice(new BigDecimal(req.getParameter("price")));
                String costPriceStr = req.getParameter("costPrice");
                product.setCostPrice(costPriceStr != null && !costPriceStr.isEmpty()
                        ? new BigDecimal(costPriceStr)
                        : BigDecimal.ZERO);
                product.setDescription(ValidationUtil.sanitize(req.getParameter("description")));
                String qtyStr = req.getParameter("quantity");
                product.setQuantity(qtyStr != null && !qtyStr.isEmpty() ? Integer.parseInt(qtyStr) : 0);
                product.setStatus(req.getParameter("isActive") != null ? "AVAILABLE" : "UNAVAILABLE");

                // Handle image upload
                Part filePart = req.getPart("imageFile");
                if (filePart != null && filePart.getSize() > 0) {
                    String contentType = filePart.getContentType();
                    // Only allow image files
                    if (contentType != null && contentType.startsWith("image/")) {
                        // Delete old image if exists (on update)
                        if (isUpdate && product.getImageUrl() != null) {
                            SupabaseStorageService.deleteImage(product.getImageUrl());
                        }

                        String fileName = getFileName(filePart);
                        try (InputStream is = filePart.getInputStream()) {
                            String imageUrl = SupabaseStorageService.uploadImage(is, fileName, contentType);
                            product.setImageUrl(imageUrl);
                        }
                    }
                }

                // Handle remove image checkbox
                String removeImage = req.getParameter("removeImage");
                if ("true".equals(removeImage)) {
                    if (product.getImageUrl() != null) {
                        SupabaseStorageService.deleteImage(product.getImageUrl());
                    }
                    product.setImageUrl(null);
                }

                productService.save(product);
            }

            req.getSession().setAttribute("flash_msg", "Thao tác thành công!");
            req.getSession().setAttribute("flash_type", "success");

        } catch (Exception e) {
            req.getSession().setAttribute("flash_msg", "Lỗi: " + e.getMessage());
            req.getSession().setAttribute("flash_type", "error");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/menu");
    }

    /** Extract file name from Part header */
    private String getFileName(Part part) {
        String header = part.getHeader("content-disposition");
        if (header != null) {
            for (String token : header.split(";")) {
                if (token.trim().startsWith("filename")) {
                    return token.substring(token.indexOf('=') + 1).trim().replace("\"", "");
                }
            }
        }
        return "unknown.jpg";
    }
}
