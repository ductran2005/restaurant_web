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

        // carry over any flash messages from POST
        String msg = req.getParameter("msg");
        if (msg != null) {
            req.setAttribute("msg", msg);
        }

        if (code != null && !code.isEmpty()) {
            Booking booking = bookingService.findByCode(code);
            req.setAttribute("booking", booking);
            req.setAttribute("searched", true);
        } else if (phone != null && !phone.isEmpty()) {
            req.setAttribute("searched", true);
            String phoneTrimmed = phone.trim().replaceAll("[^+0-9]", "");
            if (phoneTrimmed.isEmpty()) {
                req.setAttribute("error", "Số điện thoại không hợp lệ");
            } else {
                List<Booking> bookings = bookingService.findByPhone(phoneTrimmed);
                req.setAttribute("bookings", bookings);
                req.setAttribute("phone", phoneTrimmed);
            }
        }

        req.getRequestDispatcher("/WEB-INF/views/customer/booking-status.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        String idStr = req.getParameter("bookingId");
        String code = req.getParameter("code");
        if (action == null || idStr == null) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
            return;
        }
        try {
            int id = Integer.parseInt(idStr);
            if ("confirm".equals(action)) {
                bookingService.confirm(id);
                // redirect back to status with success message
                resp.sendRedirect(req.getContextPath() + "/booking/status?code=" + code + "&msg=confirmed");
                return;
            }
            // other actions could go here
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (NumberFormatException e) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST);
        } catch (Exception e) {
            req.setAttribute("error", e.getMessage());
            doGet(req, resp);
        }
    }
}
