package market.restaurant_web.controller.staff;

import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.TableService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.time.LocalDate;

@WebServlet("/staff/bookings")
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
        req.setAttribute("tables", tableService.findAvailableTables());
        req.setAttribute("keyword", keyword);
        req.setAttribute("selectedStatus", status);
        req.setAttribute("selectedDate", dateStr);
        req.getRequestDispatcher("/WEB-INF/views/staff/booking-search.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");

        try {
            if ("confirm".equals(action)) {
                bookingService.confirm(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Xác nhận booking thành công!", "success");
            } else if ("checkin".equals(action)) {
                bookingService.checkIn(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Check-in thành công!", "success");
            } else if ("cancel".equals(action)) {
                bookingService.cancel(Integer.parseInt(req.getParameter("bookingId")));
                flash(req, "Đã hủy booking!", "success");
            } else if ("assignTable".equals(action)) {
                bookingService.assignTable(
                        Integer.parseInt(req.getParameter("bookingId")),
                        Integer.parseInt(req.getParameter("tableId")));
                flash(req, "Gán bàn thành công!", "success");
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
