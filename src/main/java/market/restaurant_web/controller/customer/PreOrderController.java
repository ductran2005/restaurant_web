package market.restaurant_web.controller.customer;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.PreOrderItem;
import market.restaurant_web.entity.Product;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.CategoryService;
import market.restaurant_web.service.ProductService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/pre-order")
public class PreOrderController extends HttpServlet {
    private final BookingService bookingService = new BookingService();
    private final ProductService productService = new ProductService();
    private final CategoryService categoryService = new CategoryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // Show success message after redirect
        if ("1".equals(req.getParameter("success"))) {
            req.setAttribute("successMsg", "Đặt món trước thành công! Món ăn sẽ được chuẩn bị khi bạn đến.");
        }
        String code = req.getParameter("code");
        if (code != null && !code.isEmpty()) {
            Booking booking = bookingService.findByCode(code);
            if (booking != null) {
                req.setAttribute("booking", booking);
                req.setAttribute("menuItems", productService.findAvailable());
                req.setAttribute("categories", categoryService.findActive());
            } else {
                req.setAttribute("error", "Không tìm thấy đặt bàn với mã: " + code);
            }
        }
        req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String action = req.getParameter("action");
        String bookingCode = req.getParameter("bookingCode");

        if ("confirm".equals(action) && bookingCode != null) {
            Booking booking = bookingService.findByCode(bookingCode);
            if (booking == null) {
                req.setAttribute("error", "Không tìm thấy đặt bàn.");
                doGet(req, resp);
                return;
            }

            try {
                int itemCount = Integer.parseInt(req.getParameter("itemCount"));
                String note = req.getParameter("note");

                for (int i = 0; i < itemCount; i++) {
                    int productId = Integer.parseInt(req.getParameter("productId_" + i));
                    int quantity = Integer.parseInt(req.getParameter("quantity_" + i));

                    Product product = productService.findById(productId);
                    if (product != null && quantity > 0) {
                        PreOrderItem item = new PreOrderItem();
                        item.setBooking(booking);
                        item.setProduct(product);
                        item.setQuantity(quantity);
                        item.setNote(note);
                        bookingService.savePreOrderItem(item);
                    }
                }

                resp.sendRedirect(req.getContextPath() + "/pre-order?code=" + bookingCode + "&success=1");
            } catch (Exception e) {
                req.setAttribute("error", "Có lỗi xảy ra khi đặt món: " + e.getMessage());
                req.setAttribute("booking", booking);
                req.setAttribute("menuItems", productService.findAvailable());
                req.setAttribute("categories", categoryService.findActive());
                req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
            }
        } else {
            doGet(req, resp);
        }
    }
}
