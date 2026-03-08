package market.restaurant_web.controller.customer;

import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.PreOrderService;
import market.restaurant_web.service.ProductService;
import market.restaurant_web.entity.Booking;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

/**
 * Controller for customer pre-order management
 * Allows customers to add/update/remove items from their booking pre-order
 */
@WebServlet({
    "/customer/preorder/add",
    "/customer/preorder/update", 
    "/customer/preorder/remove",
    "/customer/preorder/pay-deposit"
})
public class PreOrderController extends HttpServlet {
    private final PreOrderService preOrderService = new PreOrderService();
    private final BookingService bookingService = new BookingService();
    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String bookingCode = req.getParameter("bookingCode");
        
        if (bookingCode == null || bookingCode.isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing booking code");
            return;
        }
        
        Booking booking = bookingService.findByCode(bookingCode);
        if (booking == null) {
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Booking not found");
            return;
        }
        
        req.setAttribute("booking", booking);
        req.setAttribute("products", productService.findAvailableProducts());
        req.getRequestDispatcher("/WEB-INF/views/customer/preorder.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = getAction(req);
        String bookingCode = req.getParameter("bookingCode");
        
        try {
            switch (action) {
                case "add":
                    handleAdd(req);
                    flash(req, "Đã thêm món vào đơn đặt trước!", "success");
                    break;
                    
                case "update":
                    handleUpdate(req);
                    flash(req, "Đã cập nhật số lượng!", "success");
                    break;
                    
                case "remove":
                    handleRemove(req);
                    flash(req, "Đã xóa món khỏi đơn đặt trước!", "success");
                    break;
                    
                case "pay-deposit":
                    handlePayDeposit(req);
                    flash(req, "Đã xác nhận thanh toán tiền cọc!", "success");
                    break;
                    
                default:
                    throw new RuntimeException("Invalid action");
            }
        } catch (RuntimeException e) {
            flash(req, e.getMessage(), "error");
        }
        
        // Redirect back to pre-order page
        resp.sendRedirect(req.getContextPath() + "/customer/preorder?bookingCode=" + bookingCode);
    }

    private void handleAdd(HttpServletRequest req) {
        int bookingId = Integer.parseInt(req.getParameter("bookingId"));
        int productId = Integer.parseInt(req.getParameter("productId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));
        String note = req.getParameter("note");
        
        preOrderService.addPreOrderItem(bookingId, productId, quantity, note);
    }

    private void handleUpdate(HttpServletRequest req) {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        int quantity = Integer.parseInt(req.getParameter("quantity"));
        
        preOrderService.updatePreOrderItem(itemId, quantity);
    }

    private void handleRemove(HttpServletRequest req) {
        int itemId = Integer.parseInt(req.getParameter("itemId"));
        
        preOrderService.removePreOrderItem(itemId);
    }

    private void handlePayDeposit(HttpServletRequest req) {
        int bookingId = Integer.parseInt(req.getParameter("bookingId"));
        String paymentRef = req.getParameter("paymentRef");
        
        if (paymentRef == null || paymentRef.isEmpty()) {
            paymentRef = "DEPOSIT-" + System.currentTimeMillis();
        }
        
        preOrderService.markDepositPaid(bookingId, paymentRef);
    }

    private String getAction(HttpServletRequest req) {
        String path = req.getServletPath();
        if (path.endsWith("/add")) return "add";
        if (path.endsWith("/update")) return "update";
        if (path.endsWith("/remove")) return "remove";
        if (path.endsWith("/pay-deposit")) return "pay-deposit";
        return req.getParameter("action");
    }

    private void flash(HttpServletRequest req, String msg, String type) {
        req.getSession().setAttribute("flash_msg", msg);
        req.getSession().setAttribute("flash_type", type);
    }
}
