package market.restaurant_web.controller.staff;

import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.TableService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet({ "/staff/bookings", "/staff/bookings/confirm", "/staff/bookings/cancel", "/staff/bookings/checkin",
        "/staff/bookings/assign-table", "/staff/bookings/auto-assign", "/staff/bookings/no-show", 
        "/staff/bookings/seat", "/staff/bookings/complete", "/staff/bookings/trigger-auto-assign",
        "/staff/bookings/trigger-auto-cancel" })
public class BookingController extends HttpServlet {
    private final BookingService bookingService = new BookingService();
    private final TableService tableService = new TableService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String keyword = req.getParameter("keyword");
        String status = req.getParameter("status");
        String dateStr = req.getParameter("date");
        LocalDate date = (dateStr != null && !dateStr.isEmpty()) ? LocalDate.parse(dateStr) : null;

        req.setAttribute("bookings", bookingService.search(keyword, status, date));
        req.setAttribute("availableTables", tableService.findAvailableTables());
        req.setAttribute("keyword", keyword);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("selectedDate", dateStr);

        // read and reset new-booking notification counter
        Object raw = getServletContext().getAttribute("newBookingCount");
        int newCount = (raw instanceof Integer) ? (Integer) raw : 0;
        req.setAttribute("newBookingCount", newCount);
        getServletContext().setAttribute("newBookingCount", 0);

        req.getRequestDispatcher("/WEB-INF/views/staff/booking-search.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        // derive action from URL path if not explicitly provided
        if (action == null || action.isEmpty()) {
            String path = req.getServletPath(); // e.g. /staff/bookings/cancel
            if (path.endsWith("/confirm"))
                action = "confirm";
            else if (path.endsWith("/cancel"))
                action = "cancel";
            else if (path.endsWith("/checkin"))
                action = "checkin";
            else if (path.endsWith("/assign-table"))
                action = "assignTable";
            else if (path.endsWith("/auto-assign"))
                action = "autoAssign";
            else if (path.endsWith("/no-show"))
                action = "noShow";
            else if (path.endsWith("/seat"))
                action = "seat";
            else if (path.endsWith("/complete"))
                action = "complete";
            else if (path.endsWith("/trigger-auto-assign"))
                action = "triggerAutoAssign";
            else if (path.endsWith("/trigger-auto-cancel"))
                action = "autoCancelLate";
        }

        try {
            if ("confirm".equals(action)) {
                bookingService.confirm(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Xác nhận booking thành công!", "success");
            } else if ("checkin".equals(action)) {
                bookingService.checkIn(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Check-in thành công!", "success");
            } else if ("cancel".equals(action)) {
                String reason = req.getParameter("reason");
                bookingService.cancel(Integer.parseInt(req.getParameter("bookingId")), reason);
                flash(req, "Đã hủy booking!", "success");
            } else if ("assignTable".equals(action)) {
                bookingService.assignTable(
                        Integer.parseInt(req.getParameter("bookingId")),
                        Integer.parseInt(req.getParameter("tableId")));
                flash(req, "Gán bàn thành công!", "success");
            } else if ("autoAssign".equals(action)) {
                bookingService.autoAssignTable(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Tự động gán bàn thành công!", "success");
            } else if ("noShow".equals(action)) {
                bookingService.markNoShow(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Đã đánh dấu NO_SHOW!", "warning");
            } else if ("seat".equals(action)) {
                bookingService.seatCustomer(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Khách đã ngồi vào bàn!", "success");
            } else if ("complete".equals(action)) {
                bookingService.complete(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Hoàn thành booking!", "success");
            } else if ("triggerAutoAssign".equals(action)) {
                // Trigger auto-assign for all upcoming bookings (for testing)
                bookingService.autoAssignTablesForUpcomingBookings(60);
                flash(req, "Đã chạy auto-assign cho tất cả booking trong 60 phút tới!", "info");
            } else if ("autoCancelLate".equals(action)) {
                // Trigger auto-cancel for late bookings (for testing)
                bookingService.autoCancelLateBookings(20);
                flash(req, "Đã chạy auto-cancel! Kiểm tra log và database để xem kết quả.", "info");
            }
        } catch (RuntimeException e) {
            flash(req, e.getMessage(), "error");
        }
        resp.sendRedirect(req.getContextPath() + "/staff/bookings");
    }

    private void flash(HttpServletRequest req, String msg, String type) {
        req.getSession().setAttribute("flash_msg", msg);
        req.getSession().setAttribute("flash_type", type);
    }
}
