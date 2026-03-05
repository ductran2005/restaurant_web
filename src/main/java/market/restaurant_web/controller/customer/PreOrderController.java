package market.restaurant_web.controller.customer;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.ProductService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;

@WebServlet("/booking/pre-order")
public class PreOrderController extends HttpServlet {
    private final BookingService bookingService = new BookingService();
    private final ProductService productService = new ProductService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        if (code != null && !code.isEmpty()) {
            Booking booking = bookingService.findByCode(code);
            req.setAttribute("booking", booking);
        }
        req.setAttribute("products", productService.findAvailable());
        req.getRequestDispatcher("/WEB-INF/views/customer/pre-order.jsp").forward(req, resp);
    }
}
