package market.restaurant_web.scheduler;

import market.restaurant_web.service.BookingService;
import market.restaurant_web.service.PreOrderService;
import market.restaurant_web.entity.Booking;
import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;
import java.util.List;

/**
 * Background scheduler to automatically update booking and table statuses
 * - Updates table status to RESERVED 15-30 mins before booking time
 * - Locks pre-orders 60 mins before booking time
 * - Cleans up unavailable items from pre-orders
 * - Can be extended to auto-mark NO_SHOW for late customers
 */
@WebListener
public class BookingScheduler implements ServletContextListener {
    private ScheduledExecutorService scheduler;
    private final BookingService bookingService = new BookingService();
    private final PreOrderService preOrderService = new PreOrderService();

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("========================================");
        System.out.println("BookingScheduler INITIALIZING...");
        System.out.println("========================================");
        
        scheduler = Executors.newScheduledThreadPool(1);
        
        // Run every 5 minutes to check and update booking statuses
        scheduler.scheduleAtFixedRate(() -> {
            try {
                System.out.println("\n>>> Scheduler running at: " + java.time.LocalDateTime.now());
                
                // Auto-assign tables for confirmed bookings 60 mins before booking time
                bookingService.autoAssignTablesForUpcomingBookings(60);
                
                // Update tables to RESERVED for bookings 15-30 mins away
                bookingService.updateTableStatusForUpcomingBookings(30);
                
                // Lock pre-orders for bookings within 60 mins
                lockUpcomingPreOrders();
                
                // Cleanup unavailable items from active pre-orders
                cleanupPreOrders();
                
                // Optional: Auto-mark NO_SHOW for bookings 30 mins late
                // This can be enabled if needed
                // autoMarkNoShow();
                
                System.out.println("<<< Scheduler completed\n");
                
            } catch (Exception e) {
                System.err.println("Error in booking scheduler: " + e.getMessage());
                e.printStackTrace();
            }
        }, 1, 5, TimeUnit.MINUTES);
        
        System.out.println("========================================");
        System.out.println("BookingScheduler STARTED - checking every 5 minutes");
        System.out.println("Next run in 1 minute");
        System.out.println("========================================");
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("========================================");
        System.out.println("BookingScheduler STOPPING...");
        System.out.println("========================================");
        
        if (scheduler != null) {
            scheduler.shutdown();
            try {
                if (!scheduler.awaitTermination(5, TimeUnit.SECONDS)) {
                    scheduler.shutdownNow();
                }
            } catch (InterruptedException e) {
                scheduler.shutdownNow();
            }
        }
        
        System.out.println("BookingScheduler STOPPED");
    }
    
    /**
     * Lock pre-orders for bookings within 60 minutes
     */
    private void lockUpcomingPreOrders() {
        List<Booking> bookings = preOrderService.getBookingsToLock();
        for (Booking booking : bookings) {
            try {
                preOrderService.lockPreOrder(booking.getId());
            } catch (Exception e) {
                System.err.println("Failed to lock pre-order for " + booking.getBookingCode() + ": " + e.getMessage());
            }
        }
    }
    
    /**
     * Clean up unavailable items from active pre-orders
     */
    private void cleanupPreOrders() {
        // Get all active bookings with pre-orders
        List<Booking> activeBookings = bookingService.findByDateAndStatus(
            java.time.LocalDate.now(), 
            "CONFIRMED"
        );
        
        for (Booking booking : activeBookings) {
            if (booking.getPreOrderItems() != null && !booking.getPreOrderItems().isEmpty()) {
                try {
                    preOrderService.cleanupUnavailableItems(booking.getId());
                } catch (Exception e) {
                    System.err.println("Failed to cleanup pre-order for " + booking.getBookingCode() + ": " + e.getMessage());
                }
            }
        }
    }
    
    /**
     * Optional: Automatically mark bookings as NO_SHOW if customer is 30+ mins late
     * Uncomment the call in contextInitialized() to enable
     */
    private void autoMarkNoShow() {
        var lateBookings = bookingService.getBookingsToNoShow(30);
        for (var booking : lateBookings) {
            try {
                bookingService.markNoShow(booking.getId());
                System.out.println("Auto-marked NO_SHOW: " + booking.getBookingCode());
            } catch (Exception e) {
                System.err.println("Failed to mark NO_SHOW for " + booking.getBookingCode() + ": " + e.getMessage());
            }
        }
    }
}
