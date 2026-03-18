package market.restaurant_web.controller.user;

import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.User;
import market.restaurant_web.service.BookingService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.util.List;

/**
 * User booking history — /user/booking/status
 * Automatically loads booking history based on logged-in user's phone.
 * Also supports viewing single booking via ?code= param.
 */
@WebServlet("/user/booking/status")
public class UserBookingStatusController extends HttpServlet {
    private final BookingService bookingService = new BookingService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String code = req.getParameter("code");
        String msg  = req.getParameter("msg");
        if (msg != null) req.setAttribute("msg", msg);

        User user = (User) req.getSession().getAttribute("user");

        if (code != null && !code.isEmpty()) {
            // ─── Detail view: lookup by booking code ───
            Booking booking = bookingService.findByCode(code.trim().toUpperCase());
            req.setAttribute("booking", booking);
            req.setAttribute("viewMode", "detail");

        } else if (user != null) {
            // ─── History view: load all bookings for logged-in user ───
            List<Booking> bookings = bookingService.findByUserId(user.getId());

            // Fallback: old bookings linked by phone
            if ((bookings == null || bookings.isEmpty())
                    && user.getPhone() != null && !user.getPhone().isEmpty()) {
                String phone = user.getPhone().trim().replaceAll("[^+0-9]", "");
                bookings = bookingService.findByPhone(phone);
            }

            req.setAttribute("bookings", bookings);
            req.setAttribute("viewMode", "history");

        } else {
            // ─── Not logged in, no code → redirect to login ───
            resp.sendRedirect(req.getContextPath() + "/login?redirect=/user/booking/status");
            return;
        }

        req.setAttribute("navActive", "status");
        req.getRequestDispatcher("/WEB-INF/views/user/booking-status.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        String action = req.getParameter("action");
        String idStr  = req.getParameter("bookingId");
        String code   = req.getParameter("code");

        if (action == null || idStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            int id = Integer.parseInt(idStr);
            if ("confirm".equals(action)) {
                bookingService.confirm(id);
                resp.sendRedirect(req.getContextPath()
                    + "/user/booking/status?code=" + code + "&msg=confirmed");
                return;
            }
            if ("cancel".equals(action)) {
                String reason = req.getParameter("reason");
                if (reason == null || reason.isBlank()) reason = "Khách hàng tự hủy";
                bookingService.cancel(id, reason.trim());
                resp.sendRedirect(req.getContextPath() + "/user/booking/status?msg=cancelled");
                return;
            }
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }
}
