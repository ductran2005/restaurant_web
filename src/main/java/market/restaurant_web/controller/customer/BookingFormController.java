package market.restaurant_web.controller.customer;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalTime;

@WebServlet("/booking")
public class BookingFormController extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/WEB-INF/views/customer/create-booking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String name = ValidationUtil.sanitize(req.getParameter("customerName"));
            String phone = ValidationUtil.sanitize(req.getParameter("customerPhone"));
            String dateStr = req.getParameter("bookingDate");
            String timeStr = req.getParameter("bookingTime");
            int partySize = ValidationUtil.parseInt(req.getParameter("partySize"), 2);
            String note = ValidationUtil.sanitize(req.getParameter("note"));

            if (ValidationUtil.isBlank(name) || ValidationUtil.isBlank(phone)
                    || ValidationUtil.isBlank(dateStr) || ValidationUtil.isBlank(timeStr)) {
                req.setAttribute("error", "Vui lòng nhập đầy đủ thông tin");
                req.getRequestDispatcher("/WEB-INF/views/customer/create-booking.jsp").forward(req, resp);
                return;
            }

            Booking booking = new Booking();
            booking.setCustomerName(name);
            booking.setCustomerPhone(phone);
            booking.setBookingDate(LocalDate.parse(dateStr));
            booking.setBookingTime(LocalTime.parse(timeStr));
            booking.setPartySize(partySize);
            booking.setNote(note);

            bookingService.create(booking);

            resp.sendRedirect(req.getContextPath() + "/booking/status?code=" + booking.getBookingCode());
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/customer/create-booking.jsp").forward(req, resp);
        }
    }
}
