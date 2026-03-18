package market.restaurant_web.controller.customer;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.EmailService;
import market.restaurant_web.util.ValidationUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/booking")
public class BookingFormController extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // preserve values submitted from the landing page (field names may differ)
        String name = req.getParameter("customerName");
        if (name == null) {
            name = req.getParameter("name");
            if (name != null) {
                req.setAttribute("customerName", name);
            }
        }
        String phone = req.getParameter("customerPhone");
        if (phone == null) {
            phone = req.getParameter("phone");
            if (phone != null) {
                req.setAttribute("customerPhone", phone);
            }
        }
        String date = req.getParameter("bookingDate");
        if (date == null) {
            date = req.getParameter("date");
            if (date != null) {
                req.setAttribute("bookingDate", date);
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/customer/create-booking.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String name = req.getParameter("customerName");
            if (name != null)
                name = name.trim();
            String phone = req.getParameter("customerPhone");
            // remove non‑numeric characters except leading + (intl-tel-input may insert
            // spaces)
            if (phone != null) {
                phone = phone.replaceAll("[^+0-9]", "");
            }
            String email = req.getParameter("customerEmail");
            if (email != null) email = email.trim();
            String dateStr = req.getParameter("bookingDate");
            String timeStr = req.getParameter("bookingTime");
            boolean fromLanding = "true".equals(req.getParameter("fromLanding"));
            int partySize = ValidationUtil.parseInt(req.getParameter("partySize"), 2);
            String note = req.getParameter("note");
            if (note != null)
                note = note.trim();

            // defaults when submitted from landing teaser
            if (fromLanding) {
                if (ValidationUtil.isBlank(timeStr)) {
                    timeStr = LocalTime.now().plusHours(1)
                            .format(java.time.format.DateTimeFormatter.ofPattern("HH:mm"));
                }
                if (partySize <= 0) {
                    partySize = 2;
                }
            }

            // collect individual errors for field feedback
            Map<String, String> errors = new HashMap<>();

            if (ValidationUtil.isBlank(name)) {
                errors.put("customerName", "Vui lòng nhập họ và tên");
            }
            if (ValidationUtil.isBlank(phone)) {
                errors.put("customerPhone", "Vui lòng nhập số điện thoại");
            } else if (!ValidationUtil.isValidInternationalPhone(phone)) {
                errors.put("customerPhone", "Số điện thoại không hợp lệ (VD: 0901234567 hoặc +84901234567)");
            }
            if (ValidationUtil.isBlank(dateStr)) {
                errors.put("bookingDate", "Vui lòng chọn ngày");
            }
            if (!fromLanding && ValidationUtil.isBlank(timeStr)) {
                errors.put("bookingTime", "Vui lòng chọn giờ");
            }

            LocalDate bookingDate = null;
            LocalTime bookingTime = null;
            if (errors.isEmpty()) {
                try {
                    bookingDate = LocalDate.parse(dateStr);
                } catch (Exception ex) {
                    errors.put("bookingDate", "Ngày không hợp lệ");
                }
                if (bookingDate != null) {
                    // parse time, accept both 24h and 12h formats with AM/PM
                    try {
                        bookingTime = LocalTime.parse(timeStr);
                    } catch (Exception ex) {
                        try {
                            java.time.format.DateTimeFormatter fmt = java.time.format.DateTimeFormatter
                                    .ofPattern("h:mm a");
                            bookingTime = LocalTime.parse(timeStr, fmt);
                        } catch (Exception ex2) {
                            errors.put("bookingTime", "Giờ không hợp lệ");
                        }
                    }
                }
            }

            // business rules: no past bookings, at least 1h in advance, within operating
            // hours
            if (bookingDate != null && bookingTime != null) {
                LocalDateTime dt = LocalDateTime.of(bookingDate, bookingTime);
                LocalDateTime now = LocalDateTime.now();
                if (dt.isBefore(now.plusHours(1))) {
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
                // preserve submitted values so JSP can repopulate
                req.getRequestDispatcher("/WEB-INF/views/customer/create-booking.jsp").forward(req, resp);
                return;
            }

            // no validation errors, proceed with creation
            Booking booking = new Booking();
            booking.setCustomerName(name);
            booking.setCustomerPhone(phone);
            booking.setBookingDate(bookingDate);
            booking.setBookingTime(bookingTime);
            booking.setPartySize(partySize);
            booking.setNote(note);

            bookingService.create(booking);

            // Send confirmation email if customer provided email
            if (email != null && !email.isBlank()) {
                EmailService.sendBookingConfirmation(
                    email,
                    booking.getCustomerName(),
                    booking.getBookingCode(),
                    booking.getBookingDate().toString(),
                    booking.getBookingTime().toString(),
                    booking.getPartySize(),
                    booking.getNote()
                );
            }

            // notify staff page: increment pending booking counter in application scope
            Object raw = getServletContext().getAttribute("newBookingCount");
            int count = (raw instanceof Integer) ? (Integer) raw : 0;
            getServletContext().setAttribute("newBookingCount", count + 1);

            resp.sendRedirect(req.getContextPath() + "/booking/status?code=" + booking.getBookingCode());
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/customer/create-booking.jsp").forward(req, resp);
        }
    }
}
