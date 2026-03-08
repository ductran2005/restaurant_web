package market.restaurant_web.controller.staff;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.DiningTable;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

@WebServlet("/staff/debug-bookings")
public class DebugBookingController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Debug Bookings</title>");
        out.println("<style>");
        out.println("body { font-family: monospace; margin: 20px; }");
        out.println("table { border-collapse: collapse; margin: 20px 0; }");
        out.println("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        out.println("th { background-color: #4CAF50; color: white; }");
        out.println(".ok { color: green; }");
        out.println(".error { color: red; }");
        out.println(".warning { color: orange; }");
        out.println("</style></head><body>");
        
        out.println("<h1>Debug Auto-Assign Bookings</h1>");
        
        LocalDateTime now = LocalDateTime.now();
        LocalDateTime targetTime = now.plusMinutes(60);
        
        out.println("<h2>Thời gian</h2>");
        out.println("<p>Hiện tại: <strong>" + now + "</strong></p>");
        out.println("<p>Target (60 phút): <strong>" + targetTime + "</strong></p>");
        
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            
            // Check bookings
            out.println("<h2>Bookings CONFIRMED chưa có bàn</h2>");
            
            // Get all CONFIRMED bookings without table
            List<Booking> allBookings = s.createQuery(
                "FROM Booking WHERE status = 'CONFIRMED' AND table IS NULL ORDER BY bookingDate, bookingTime",
                Booking.class).list();
            
            // Filter bookings within time window
            List<Booking> bookings = allBookings.stream()
                .filter(b -> {
                    LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
                    return bookingDateTime.isAfter(now) && bookingDateTime.isBefore(targetTime);
                })
                .toList();
            
            if (bookings.isEmpty()) {
                out.println("<p class='warning'>Không tìm thấy booking nào trong vòng 60 phút!</p>");
                
                // Show all CONFIRMED bookings
                out.println("<h3>Tất cả bookings CONFIRMED chưa có bàn:</h3>");
                
                if (allBookings.isEmpty()) {
                    out.println("<p class='error'>Không có booking CONFIRMED nào chưa có bàn!</p>");
                } else {
                    out.println("<table>");
                    out.println("<tr><th>Code</th><th>Date</th><th>Time</th><th>Party</th><th>Trong 60p?</th></tr>");
                    for (Booking b : allBookings) {
                        LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
                        boolean inRange = bookingDateTime.isAfter(now) && bookingDateTime.isBefore(targetTime);
                        out.println("<tr>");
                        out.println("<td>" + b.getBookingCode() + "</td>");
                        out.println("<td>" + b.getBookingDate() + "</td>");
                        out.println("<td>" + b.getBookingTime() + "</td>");
                        out.println("<td>" + b.getPartySize() + "</td>");
                        out.println("<td class='" + (inRange ? "ok" : "error") + "'>" + (inRange ? "✓ Có" : "✗ Không") + "</td>");
                        out.println("</tr>");
                    }
                    out.println("</table>");
                }
            } else {
                out.println("<p class='ok'>Tìm thấy " + bookings.size() + " booking(s) đủ điều kiện:</p>");
                out.println("<table>");
                out.println("<tr><th>Code</th><th>Customer</th><th>Date</th><th>Time</th><th>Party</th></tr>");
                for (Booking b : bookings) {
                    out.println("<tr>");
                    out.println("<td>" + b.getBookingCode() + "</td>");
                    out.println("<td>" + b.getCustomerName() + "</td>");
                    out.println("<td>" + b.getBookingDate() + "</td>");
                    out.println("<td>" + b.getBookingTime() + "</td>");
                    out.println("<td>" + b.getPartySize() + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            
            // Check available tables
            out.println("<h2>Bàn trống</h2>");
            List<DiningTable> tables = s.createQuery(
                "FROM DiningTable WHERE status = 'EMPTY' ORDER BY capacity",
                DiningTable.class).list();
            
            if (tables.isEmpty()) {
                out.println("<p class='error'>Không có bàn trống nào!</p>");
            } else {
                out.println("<p class='ok'>Có " + tables.size() + " bàn trống:</p>");
                out.println("<table>");
                out.println("<tr><th>Table Name</th><th>Capacity</th><th>Status</th></tr>");
                for (DiningTable t : tables) {
                    out.println("<tr>");
                    out.println("<td>" + t.getTableName() + "</td>");
                    out.println("<td>" + t.getCapacity() + "</td>");
                    out.println("<td>" + t.getStatus() + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            
        } catch (Exception e) {
            out.println("<p class='error'>Lỗi: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }
        
        out.println("<hr>");
        out.println("<p><a href='" + req.getContextPath() + "/staff/test-auto-assign'>← Test Auto-Assign</a></p>");
        out.println("<p><a href='" + req.getContextPath() + "/staff/bookings'>← Quay lại Bookings</a></p>");
        
        out.println("</body></html>");
    }
}
