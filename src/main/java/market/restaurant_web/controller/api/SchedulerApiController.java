package market.restaurant_web.controller.api;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.PreOrderService;
import market.restaurant_web.entity.Booking;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

/**
 * API endpoint for external cron to trigger scheduler tasks
 * URL: /api/scheduler/run
 * Method: POST
 * Auth: API Key in header X-API-Key
 * 
 * Usage:
 * curl -X POST https://your-domain.com/api/scheduler/run \
 *   -H "X-API-Key: your-secret-api-key-change-this"
 */
@WebServlet("/api/scheduler/run")
public class SchedulerApiController extends HttpServlet {
    
    private final BookingService bookingService = new BookingService();
    private final PreOrderService preOrderService = new PreOrderService();
    
    // TODO: Change this to a secure random key in production
    // Generate a strong key: https://www.uuidgenerator.net/
    private static final String API_KEY = "your-secret-api-key-change-this";
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        PrintWriter out = resp.getWriter();
        
        try {
            // Verify API key
            String apiKey = req.getHeader("X-API-Key");
            if (apiKey == null || !apiKey.equals(API_KEY)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                out.println("{\"error\": \"Unauthorized\", \"message\": \"Invalid or missing API key\"}");
                System.err.println("Unauthorized scheduler API call from: " + req.getRemoteAddr());
                return;
            }
            
            System.out.println("\n========================================");
            System.out.println(">>> External Cron triggered at: " + java.time.LocalDateTime.now());
            System.out.println(">>> Remote IP: " + req.getRemoteAddr());
            System.out.println("========================================");
            
            // Run scheduler tasks
            StringBuilder result = new StringBuilder();
            result.append("{\"status\": \"success\", \"tasks\": [");
            
            boolean firstTask = true;
            
            // Task 1: Auto-assign tables for bookings 60 mins before
            try {
                System.out.println("\n[Task 1] Auto-assigning tables...");
                bookingService.autoAssignTablesForUpcomingBookings(60);
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"auto_assign_tables\", \"status\": \"completed\"}");
                firstTask = false;
                System.out.println("[Task 1] ✓ Completed");
            } catch (Exception e) {
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"auto_assign_tables\", \"status\": \"failed\", \"error\": \"")
                      .append(escapeJson(e.getMessage())).append("\"}");
                firstTask = false;
                System.err.println("[Task 1] ✗ Failed: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Task 2: Update table status to RESERVED for bookings 15-30 mins away
            try {
                System.out.println("\n[Task 2] Updating table status to RESERVED...");
                bookingService.updateTableStatusForUpcomingBookings(30);
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"update_table_status\", \"status\": \"completed\"}");
                firstTask = false;
                System.out.println("[Task 2] ✓ Completed");
            } catch (Exception e) {
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"update_table_status\", \"status\": \"failed\", \"error\": \"")
                      .append(escapeJson(e.getMessage())).append("\"}");
                firstTask = false;
                System.err.println("[Task 2] ✗ Failed: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Task 3: Auto-cancel bookings if customer is 20+ mins late
            try {
                System.out.println("\n[Task 3] Auto-cancelling late bookings...");
                bookingService.autoCancelLateBookings(20);
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"auto_cancel_late\", \"status\": \"completed\"}");
                firstTask = false;
                System.out.println("[Task 3] ✓ Completed");
            } catch (Exception e) {
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"auto_cancel_late\", \"status\": \"failed\", \"error\": \"")
                      .append(escapeJson(e.getMessage())).append("\"}");
                firstTask = false;
                System.err.println("[Task 3] ✗ Failed: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Task 4: Lock pre-orders for bookings within 60 mins
            try {
                System.out.println("\n[Task 4] Locking pre-orders...");
                List<Booking> bookings = preOrderService.getBookingsToLock();
                int locked = 0;
                for (Booking booking : bookings) {
                    try {
                        preOrderService.lockPreOrder(booking.getId());
                        locked++;
                    } catch (Exception e) {
                        System.err.println("Failed to lock pre-order for " + booking.getBookingCode() + ": " + e.getMessage());
                    }
                }
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"lock_preorders\", \"status\": \"completed\", \"count\": ")
                      .append(locked).append("}");
                firstTask = false;
                System.out.println("[Task 4] ✓ Completed - Locked " + locked + " pre-orders");
            } catch (Exception e) {
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"lock_preorders\", \"status\": \"failed\", \"error\": \"")
                      .append(escapeJson(e.getMessage())).append("\"}");
                firstTask = false;
                System.err.println("[Task 4] ✗ Failed: " + e.getMessage());
                e.printStackTrace();
            }
            
            // Task 5: Cleanup unavailable items from active pre-orders
            try {
                System.out.println("\n[Task 5] Cleaning up unavailable items...");
                List<Booking> activeBookings = bookingService.findByDateAndStatus(
                    java.time.LocalDate.now(), "CONFIRMED"
                );
                int cleaned = 0;
                for (Booking booking : activeBookings) {
                    if (booking.getPreOrderItems() != null && !booking.getPreOrderItems().isEmpty()) {
                        try {
                            preOrderService.cleanupUnavailableItems(booking.getId());
                            cleaned++;
                        } catch (Exception e) {
                            System.err.println("Failed to cleanup pre-order for " + booking.getBookingCode() + ": " + e.getMessage());
                        }
                    }
                }
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"cleanup_items\", \"status\": \"completed\", \"count\": ")
                      .append(cleaned).append("}");
                System.out.println("[Task 5] ✓ Completed - Cleaned " + cleaned + " bookings");
            } catch (Exception e) {
                if (!firstTask) result.append(",");
                result.append("{\"task\": \"cleanup_items\", \"status\": \"failed\", \"error\": \"")
                      .append(escapeJson(e.getMessage())).append("\"}");
                System.err.println("[Task 5] ✗ Failed: " + e.getMessage());
                e.printStackTrace();
            }
            
            result.append("], \"timestamp\": \"").append(java.time.LocalDateTime.now()).append("\"}");
            
            System.out.println("\n========================================");
            System.out.println("<<< External Cron completed successfully");
            System.out.println("========================================\n");
            
            resp.setStatus(HttpServletResponse.SC_OK);
            out.println(result.toString());
            
        } catch (Exception e) {
            System.err.println("\n========================================");
            System.err.println("✗✗✗ CRITICAL ERROR in scheduler API ✗✗✗");
            System.err.println("Error: " + e.getMessage());
            System.err.println("========================================");
            e.printStackTrace();
            
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            out.println("{\"error\": \"Internal server error\", \"message\": \"" + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        
        PrintWriter out = resp.getWriter();
        out.println("{");
        out.println("  \"service\": \"Restaurant Booking Scheduler API\",");
        out.println("  \"status\": \"running\",");
        out.println("  \"message\": \"Use POST method with X-API-Key header to trigger scheduler tasks\",");
        out.println("  \"endpoint\": \"/api/scheduler/run\",");
        out.println("  \"method\": \"POST\",");
        out.println("  \"auth\": \"X-API-Key header required\",");
        out.println("  \"tasks\": [");
        out.println("    \"auto_assign_tables\",");
        out.println("    \"update_table_status\",");
        out.println("    \"auto_cancel_late\",");
        out.println("    \"lock_preorders\",");
        out.println("    \"cleanup_items\"");
        out.println("  ]");
        out.println("}");
    }
    
    /**
     * Escape special characters for JSON
     */
    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }
}
