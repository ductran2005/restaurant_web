package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.dao.ProductDAO;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.PreOrderItem;
import market.restaurant_web.entity.Product;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

/**
 * Service for managing pre-orders with deposit policy
 * - Customers can pre-order when booking is PENDING or CONFIRMED
 * - Deposit = 10% of pre-order total
 * - Pre-order locked 60 mins before booking time
 * - Auto-remove unavailable items
 */
public class PreOrderService {
    private static final BigDecimal DEPOSIT_RATE = new BigDecimal("0.10"); // 10%
    private static final int CUTOFF_MINUTES = 60; // Lock pre-order 60 mins before
    
    private final BookingDao bookingDao = new BookingDao();
    private final ProductDAO productDao = new ProductDAO();

    /** Add item to pre-order */
    public void addPreOrderItem(int bookingId, int productId, int quantity, String note) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking booking = bookingDao.findById(s, bookingId);
            if (booking == null) {
                throw new RuntimeException("Booking không tồn tại");
            }
            
            // Check booking status
            if (!canModifyPreOrder(booking)) {
                throw new RuntimeException("Không thể đặt món trước cho booking này (status: " + booking.getStatus() + ")");
            }
            
            // Check if pre-order is locked
            if (booking.isPreorderLocked()) {
                throw new RuntimeException("Đã quá thời gian cho phép đặt món trước (cutoff: 60 phút trước giờ đặt bàn)");
            }
            
            // Check product availability
            Product product = productDao.findById(s, productId);
            if (product == null) {
                throw new RuntimeException("Món không tồn tại");
            }
            if (!"AVAILABLE".equals(product.getStatus())) {
                throw new RuntimeException("Món '" + product.getProductName() + "' hiện không có sẵn");
            }
            if (product.getQuantity() < quantity) {
                throw new RuntimeException("Món '" + product.getProductName() + "' không đủ số lượng (còn: " + product.getQuantity() + ")");
            }
            
            // Check if item already exists in pre-order
            PreOrderItem existing = findExistingItem(s, bookingId, productId);
            if (existing != null) {
                // Update quantity
                existing.setQuantity(existing.getQuantity() + quantity);
                if (note != null && !note.isBlank()) {
                    existing.setNote(note);
                }
                s.merge(existing);
            } else {
                // Create new item
                PreOrderItem item = new PreOrderItem();
                item.setBooking(booking);
                item.setProduct(product);
                item.setQuantity(quantity);
                item.setNote(note);
                s.persist(item);
            }
            
            // Recalculate deposit
            updateDepositAmount(s, booking);
            
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Update pre-order item quantity */
    public void updatePreOrderItem(int itemId, int newQuantity) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            PreOrderItem item = s.get(PreOrderItem.class, itemId);
            if (item == null) {
                throw new RuntimeException("Món đặt trước không tồn tại");
            }
            
            Booking booking = item.getBooking();
            if (!canModifyPreOrder(booking)) {
                throw new RuntimeException("Không thể sửa món cho booking này");
            }
            
            if (booking.isPreorderLocked()) {
                throw new RuntimeException("Đã quá thời gian cho phép sửa món (cutoff: 60 phút trước giờ đặt bàn)");
            }
            
            if (newQuantity <= 0) {
                throw new RuntimeException("Số lượng phải lớn hơn 0");
            }
            
            // Check product availability
            Product product = item.getProduct();
            if (!"AVAILABLE".equals(product.getStatus())) {
                throw new RuntimeException("Món '" + product.getProductName() + "' hiện không có sẵn");
            }
            if (product.getQuantity() < newQuantity) {
                throw new RuntimeException("Món '" + product.getProductName() + "' không đủ số lượng (còn: " + product.getQuantity() + ")");
            }
            
            item.setQuantity(newQuantity);
            s.merge(item);
            
            // Recalculate deposit
            updateDepositAmount(s, booking);
            
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Remove item from pre-order */
    public void removePreOrderItem(int itemId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            PreOrderItem item = s.get(PreOrderItem.class, itemId);
            if (item == null) {
                throw new RuntimeException("Món đặt trước không tồn tại");
            }
            
            Booking booking = item.getBooking();
            if (!canModifyPreOrder(booking)) {
                throw new RuntimeException("Không thể xóa món cho booking này");
            }
            
            if (booking.isPreorderLocked()) {
                throw new RuntimeException("Đã quá thời gian cho phép xóa món (cutoff: 60 phút trước giờ đặt bàn)");
            }
            
            s.remove(item);
            
            // Recalculate deposit
            updateDepositAmount(s, booking);
            
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Mark deposit as paid */
    public void markDepositPaid(int bookingId, String paymentRef) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking booking = bookingDao.findById(s, bookingId);
            if (booking == null) {
                throw new RuntimeException("Booking không tồn tại");
            }
            
            if (booking.getDepositAmount().compareTo(BigDecimal.ZERO) <= 0) {
                throw new RuntimeException("Không có tiền cọc cần thanh toán");
            }
            
            booking.setDepositStatus("PAID");
            booking.setDepositRef(paymentRef);
            booking.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, booking);
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Refund deposit (when cancel before cutoff) */
    public void refundDeposit(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking booking = bookingDao.findById(s, bookingId);
            if (booking == null) {
                throw new RuntimeException("Booking không tồn tại");
            }
            
            if (!"PAID".equals(booking.getDepositStatus())) {
                throw new RuntimeException("Tiền cọc chưa được thanh toán");
            }
            
            // Check if before cutoff
            LocalDateTime cutoffTime = LocalDateTime.of(booking.getBookingDate(), booking.getBookingTime())
                    .minusMinutes(CUTOFF_MINUTES);
            
            if (LocalDateTime.now().isAfter(cutoffTime)) {
                throw new RuntimeException("Đã quá thời gian hoàn cọc (cutoff: 60 phút trước giờ đặt bàn). Tiền cọc sẽ bị giữ lại.");
            }
            
            booking.setDepositStatus("REFUNDED");
            booking.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, booking);
            
            tx.commit();
        } catch (RuntimeException e) {
            if (tx != null) tx.rollback();
            throw e;
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Auto-remove unavailable items from pre-orders */
    public void cleanupUnavailableItems(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking booking = bookingDao.findById(s, bookingId);
            if (booking == null) {
                return;
            }
            
            List<PreOrderItem> items = s.createQuery(
                "FROM PreOrderItem WHERE booking.id = :bookingId", 
                PreOrderItem.class)
                .setParameter("bookingId", bookingId)
                .list();
            
            boolean changed = false;
            for (PreOrderItem item : items) {
                Product product = item.getProduct();
                // Remove if unavailable or out of stock
                if (!"AVAILABLE".equals(product.getStatus()) || product.getQuantity() < item.getQuantity()) {
                    s.remove(item);
                    changed = true;
                    System.out.println("Removed unavailable item: " + product.getProductName() + " from booking " + booking.getBookingCode());
                }
            }
            
            if (changed) {
                updateDepositAmount(s, booking);
            }
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            System.err.println("Error cleaning up unavailable items: " + e.getMessage());
        } finally {
            s.close();
        }
    }

    /** Lock pre-order (60 mins before booking time) */
    public void lockPreOrder(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking booking = bookingDao.findById(s, bookingId);
            if (booking == null) {
                return;
            }
            
            if (booking.getPreorderLockedAt() == null) {
                booking.setPreorderLockedAt(LocalDateTime.now());
                bookingDao.update(s, booking);
                System.out.println("Locked pre-order for booking: " + booking.getBookingCode());
            }
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            System.err.println("Error locking pre-order: " + e.getMessage());
        } finally {
            s.close();
        }
    }

    /** Get bookings that should have pre-order locked */
    public List<Booking> getBookingsToLock() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            LocalDateTime cutoffTime = LocalDateTime.now().plusMinutes(CUTOFF_MINUTES);
            
            return s.createQuery(
                "FROM Booking WHERE status IN ('PENDING', 'CONFIRMED') " +
                "AND preorderLockedAt IS NULL " +
                "AND CONCAT(bookingDate, ' ', bookingTime) <= :cutoffTime",
                Booking.class)
                .setParameter("cutoffTime", cutoffTime)
                .list();
        }
    }

    // === Private Helper Methods ===

    private boolean canModifyPreOrder(Booking booking) {
        String status = booking.getStatus();
        return "PENDING".equals(status) || "CONFIRMED".equals(status);
    }

    private PreOrderItem findExistingItem(Session s, int bookingId, int productId) {
        List<PreOrderItem> items = s.createQuery(
            "FROM PreOrderItem WHERE booking.id = :bookingId AND product.id = :productId",
            PreOrderItem.class)
            .setParameter("bookingId", bookingId)
            .setParameter("productId", productId)
            .list();
        return items.isEmpty() ? null : items.get(0);
    }

    private void updateDepositAmount(Session s, Booking booking) {
        // Refresh pre-order items
        List<PreOrderItem> items = s.createQuery(
            "FROM PreOrderItem WHERE booking.id = :bookingId",
            PreOrderItem.class)
            .setParameter("bookingId", booking.getId())
            .list();
        
        // Calculate total
        BigDecimal total = items.stream()
            .map(item -> item.getProduct().getPrice().multiply(new BigDecimal(item.getQuantity())))
            .reduce(BigDecimal.ZERO, BigDecimal::add);
        
        // Calculate deposit (10% of total)
        BigDecimal deposit = total.multiply(DEPOSIT_RATE).setScale(2, RoundingMode.HALF_UP);
        
        booking.setDepositAmount(deposit);
        booking.setUpdatedAt(LocalDateTime.now());
        
        // Reset deposit status if amount changed and was not paid yet
        if ("PENDING".equals(booking.getDepositStatus()) && deposit.compareTo(BigDecimal.ZERO) > 0) {
            // Keep PENDING
        } else if (deposit.compareTo(BigDecimal.ZERO) == 0) {
            booking.setDepositStatus("PENDING");
            booking.setDepositRef(null);
        }
        
        bookingDao.update(s, booking);
    }
}
