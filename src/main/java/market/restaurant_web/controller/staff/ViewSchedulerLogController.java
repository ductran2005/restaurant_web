package market.restaurant_web.controller.staff;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.entity.Booking;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.hibernate.Session;
import java.io.IOException;
import java.io.PrintWriter;
import java.time.LocalDateTime;
import java.time.Duration;
import java.util.List;

@WebServlet("/staff/scheduler-status")
public class ViewSchedulerLogController extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        
        out.println("<!DOCTYPE html>");
        out.println("<html><head><title>Scheduler Status</title>");
        out.println("<style>");
        out.println("body { font-family: monospace; margin: 20px; background: #f5f5f5; }");
        out.println("table { border-collapse: collapse; margin: 20px 0; background: white; }");
        out.println("th, td { border: 1px solid #ddd; padding: 8px; text-align: left; }");
        out.println("th { background-color: #4CAF50; color: white; }");
        out.println(".late { background-color: #ffcdd2; }");
        out.println(".ok { background-color: #c8e6c9; }");
        out.println(".warning { background-color: #fff3cd; }");
        out.println(".info { background: #e3f2fd; padding: 15px; margin: 10px 0; border-radius: 5px; }");
        out.println("</style>");
        out.println("<meta http-equiv='refresh' content='10'>"); // Auto-refresh every 10s
        out.println("</head><body>");
        
        out.println("<h1>📊 Scheduler Status & Debug Info</h1>");
        out.println("<p style='color: #666;'>Auto-refresh every 10 seconds | Last updated: " + LocalDateTime.now() + "</p>");
        
        LocalDateTime now = LocalDateTime.now();
        
        out.println("<div class='info'>");
        out.println("<h3>⏰ Current Time</h3>");
        out.println("<p><strong>" + now + "</strong></p>");
        out.println("<p>Scheduler runs every 5 minutes</p>");
        out.println("<p>Auto-cancel threshold: 20 minutes late</p>");
        out.println("</div>");
        
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            
            // Get all CONFIRMED bookings
            out.println("<h2>📋 CONFIRMED Bookings (Candidates for Auto-Cancel)</h2>");
            
            List<Booking> confirmedBookings = s.createQuery(
                "FROM Booking WHERE status = 'CONFIRMED' ORDER BY bookingDate, bookingTime",
                Booking.class).list();
            
            if (confirmedBookings.isEmpty()) {
                out.println("<p class='warning'>No CONFIRMED bookings found.</p>");
            } else {
                out.println("<table>");
                out.println("<tr>");
                out.println("<th>Code</th>");
                out.println("<th>Customer</th>");
                out.println("<th>Date</th>");
                out.println("<th>Time</th>");
                out.println("<th>Table</th>");
                out.println("<th>Minutes Late</th>");
                out.println("<th>Status</th>");
                out.println("</tr>");
                
                for (Booking b : confirmedBookings) {
                    LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
                    long minutesLate = Duration.between(bookingDateTime, now).toMinutes();
                    boolean shouldCancel = minutesLate >= 20;
                    
                    String rowClass = "";
                    String statusText = "";
                    
                    if (minutesLate < 0) {
                        rowClass = "ok";
                        statusText = "Future (" + Math.abs(minutesLate) + " min)";
                    } else if (minutesLate < 20) {
                        rowClass = "warning";
                        statusText = "Waiting (" + minutesLate + " min)";
                    } else {
                        rowClass = "late";
                        statusText = "SHOULD BE CANCELLED (" + minutesLate + " min)";
                    }
                    
                    out.println("<tr class='" + rowClass + "'>");
                    out.println("<td>" + b.getBookingCode() + "</td>");
                    out.println("<td>" + b.getCustomerName() + "</td>");
                    out.println("<td>" + b.getBookingDate() + "</td>");
                    out.println("<td>" + b.getBookingTime() + "</td>");
                    out.println("<td>" + (b.getTable() != null ? b.getTable().getTableName() : "No table") + "</td>");
                    out.println("<td>" + minutesLate + "</td>");
                    out.println("<td><strong>" + statusText + "</strong></td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            
            // Get recently cancelled bookings
            out.println("<h2>🚫 Recently Cancelled Bookings</h2>");
            
            List<Booking> cancelledBookings = s.createQuery(
                "FROM Booking WHERE status = 'CANCELLED' " +
                "AND updated_at > :since " +
                "ORDER BY updated_at DESC",
                Booking.class)
                .setParameter("since", now.minusHours(2))
                .setMaxResults(10)
                .list();
            
            if (cancelledBookings.isEmpty()) {
                out.println("<p>No bookings cancelled in the last 2 hours.</p>");
            } else {
                out.println("<table>");
                out.println("<tr>");
                out.println("<th>Code</th>");
                out.println("<th>Customer</th>");
                out.println("<th>Booking Time</th>");
                out.println("<th>Cancelled At</th>");
                out.println("<th>Reason</th>");
                out.println("</tr>");
                
                for (Booking b : cancelledBookings) {
                    out.println("<tr>");
                    out.println("<td>" + b.getBookingCode() + "</td>");
                    out.println("<td>" + b.getCustomerName() + "</td>");
                    out.println("<td>" + b.getBookingDate() + " " + b.getBookingTime() + "</td>");
                    out.println("<td>" + (b.getUpdatedAt() != null ? b.getUpdatedAt() : "N/A") + "</td>");
                    out.println("<td>" + (b.getCancelReason() != null ? b.getCancelReason() : "N/A") + "</td>");
                    out.println("</tr>");
                }
                out.println("</table>");
            }
            
        } catch (Exception e) {
            out.println("<p class='late'>Error: " + e.getMessage() + "</p>");
            e.printStackTrace(out);
        }
        
        out.println("<hr>");
        out.println("<p>");
        out.println("<a href='" + req.getContextPath() + "/staff/test-auto-cancel'>← Test Auto-Cancel</a> | ");
        out.println("<a href='" + req.getContextPath() + "/staff/bookings'>Bookings</a>");
        out.println("</p>");
        
        out.println("</body></html>");
    }
}
