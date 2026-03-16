package market.restaurant_web.controller.user;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.util.ValidationUtil;
import market.restaurant_web.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Map;

/**
 * User booking form — /user/booking/create
 * Same logic as BookingFormController, routes to user views.
 */
@WebServlet("/user/booking/create")
public class UserBookingFormController extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // Pre-fill from session user if no params provided
        User user = (User) req.getSession().getAttribute("user");

        String name = req.getParameter("customerName");
        if (name == null) {
            name = req.getParameter("name");
        }
        if (name == null && user != null && user.getFullName() != null) {
            name = user.getFullName();
        }
        if (name != null) req.setAttribute("customerName", name);

        String phone = req.getParameter("customerPhone");
        if (phone == null) {
            phone = req.getParameter("phone");
        }
        if (phone == null && user != null && user.getPhone() != null) {
            phone = user.getPhone();
        }
        if (phone != null) req.setAttribute("customerPhone", phone);

        String date = req.getParameter("bookingDate");
        if (date == null) {
            date = req.getParameter("date");
            if (date != null) req.setAttribute("bookingDate", date);
        }

        req.setAttribute("navActive", "booking");
        req.getRequestDispatcher("/WEB-INF/views/user/create-booking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        try {
            String name = req.getParameter("customerName");
            if (name != null) name = name.trim();
            String phone = req.getParameter("customerPhone");
            if (phone != null) phone = phone.replaceAll("[^+0-9]", "");
            String dateStr = req.getParameter("bookingDate");
            String timeStr = req.getParameter("bookingTime");
            int partySize = ValidationUtil.parseInt(req.getParameter("partySize"), 2);
            String note = req.getParameter("note");
            if (note != null) note = note.trim();

            Map<String, String> errors = new HashMap<>();

            if (ValidationUtil.isBlank(name)) errors.put("customerName", "Vui lòng nhập họ và tên");
            if (ValidationUtil.isBlank(phone)) {
                errors.put("customerPhone", "Vui lòng nhập số điện thoại");
            } else if (!ValidationUtil.isValidInternationalPhone(phone)) {
                errors.put("customerPhone", "Số điện thoại không hợp lệ (VD: 0901234567 hoặc +84901234567)");
            }
            if (ValidationUtil.isBlank(dateStr)) errors.put("bookingDate", "Vui lòng chọn ngày");
            if (ValidationUtil.isBlank(timeStr)) errors.put("bookingTime", "Vui lòng chọn giờ");

            LocalDate bookingDate = null;
            LocalTime bookingTime = null;
            if (errors.isEmpty()) {
                try { bookingDate = LocalDate.parse(dateStr); }
                catch (Exception ex) { errors.put("bookingDate", "Ngày không hợp lệ"); }

                if (bookingDate != null) {
                    try { bookingTime = LocalTime.parse(timeStr); }
                    catch (Exception ex) {
                        try {
                            bookingTime = LocalTime.parse(timeStr,
                                java.time.format.DateTimeFormatter.ofPattern("h:mm a"));
                        } catch (Exception ex2) { errors.put("bookingTime", "Giờ không hợp lệ"); }
                    }
                }
            }

            if (bookingDate != null && bookingTime != null) {
                LocalDateTime dt = LocalDateTime.of(bookingDate, bookingTime);
                if (dt.isBefore(LocalDateTime.now().plusHours(1))) {
                    errors.put("bookingDate", "Phải đặt trước ít nhất 1 giờ và không được chọn thời gian đã qua");
                }
                LocalTime open = LocalTime.of(10, 0);
                LocalTime close = LocalTime.of(22, 0);
                if (bookingTime.isBefore(open) || bookingTime.isAfter(close)) {
                    errors.put("bookingTime", "Giờ đặt phải nằm trong khoảng 10:00 – 22:00");
                }
            }

            if (!errors.isEmpty()) {
                req.setAttribute("errors", errors);
                req.setAttribute("navActive", "booking");
                req.getRequestDispatcher("/WEB-INF/views/user/create-booking.jsp").forward(req, resp);
                return;
            }

            Booking booking = new Booking();
            booking.setCustomerName(name);
            booking.setCustomerPhone(phone);
            booking.setBookingDate(bookingDate);
            booking.setBookingTime(bookingTime);
            booking.setPartySize(partySize);
            booking.setNote(note);

            bookingService.create(booking);

            Object raw = getServletContext().getAttribute("newBookingCount");
            int count = (raw instanceof Integer) ? (Integer) raw : 0;
            getServletContext().setAttribute("newBookingCount", count + 1);

            resp.sendRedirect(req.getContextPath() + "/user/booking/status?code=" + booking.getBookingCode());
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.setAttribute("navActive", "booking");
            req.getRequestDispatcher("/WEB-INF/views/user/create-booking.jsp").forward(req, resp);
        }
    }
}
