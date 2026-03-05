package market.restaurant_web.controller.customer;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

@WebServlet("/booking/status")
public class BookingStatusController extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String code = req.getParameter("code");
        String phone = req.getParameter("phone");

        if (code != null && !code.isEmpty()) {
            Booking booking = bookingService.findByCode(code);
            req.setAttribute("booking", booking);
        } else if (phone != null && !phone.isEmpty()) {
            List<Booking> bookings = bookingService.findByPhone(phone);
            req.setAttribute("bookings", bookings);
            req.setAttribute("phone", phone);
        }

        req.getRequestDispatcher("/WEB-INF/views/customer/booking-status.jsp").forward(req, resp);
    }
}
