package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.dao.OrderDAO;
import market.restaurant_web.dao.TableDAO;
import market.restaurant_web.entity.*;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class BookingService {
    private final BookingDao bookingDao = new BookingDao();
    private final TableDAO tableDao = new TableDAO();
    private final OrderDAO orderDao = new OrderDAO();

    public List<Booking> search(String keyword, String status, LocalDate date) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return bookingDao.search(s, keyword, status, date);
        }
    }

    public Booking findById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return bookingDao.findById(s, id);
        }
    }

    public Booking findByCode(String code) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return bookingDao.findByCode(s, code);
        }
    }

    public List<Booking> findByPhone(String phone) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return bookingDao.findByPhone(s, phone);
        }
    }

    public List<Booking> findByDateAndStatus(LocalDate date, String status) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return bookingDao.findByDateAndStatus(s, date, status);
        }
    }

    /** Create a new booking with auto-generated booking code */
    public Booking create(Booking booking) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (booking.getBookingCode() == null || booking.getBookingCode().isBlank()) {
                booking.setBookingCode(generateCode());
            }
            bookingDao.save(s, booking);
            tx.commit();
            return booking;
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Confirm a pending booking */
    public void confirm(int bookingId) {
        updateStatus(bookingId, "CONFIRMED");
    }

    /** Check-in a confirmed booking (called from controller with logged-in staff) */
    public void checkIn(int bookingId, int staffId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");

            // Force-initialize lazy collections needed in this transaction
            Hibernate.initialize(b.getPreOrderItems());
            if (b.getPreOrderItems() != null) {
                for (PreOrderItem item : b.getPreOrderItems()) {
                    Hibernate.initialize(item.getProduct());
                }
            }

            // Validate check-in window: allow 30 minutes before booking time
            LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime earliestCheckIn = bookingDateTime.minusMinutes(30);

            if (now.isBefore(earliestCheckIn)) {
                long minutesUntil = java.time.Duration.between(now, earliestCheckIn).toMinutes();
                throw new RuntimeException(
                    "Chưa đến giờ check-in. Vui lòng quay lại sau " + minutesUntil + " phút " +
                    "(có thể check-in từ " + earliestCheckIn.toLocalTime() + ")"
                );
            }

            if (b.getTable() == null)
                throw new RuntimeException("Booking chưa được gán bàn, không thể check-in");

            DiningTable table = b.getTable();

            // Set booking to CHECKED_IN
            b.setStatus("CHECKED_IN");
            b.setUpdatedAt(now);
            bookingDao.update(s, b);

            boolean hasPreOrder = b.getPreOrderItems() != null && !b.getPreOrderItems().isEmpty();

            if (hasPreOrder) {
                // Has pre-order → table OCCUPIED immediately + create order with items
                table.setStatus(TableStatus.OCCUPIED);
                tableDao.update(s, table);

                Order existingOrder = orderDao.findOpenByTable(s, table.getId());
                if (existingOrder == null) {
                    User staff = s.get(User.class, staffId);
                    if (staff == null)
                        throw new RuntimeException("Không tìm thấy nhân viên (staffId=" + staffId + ")");

                    Order order = new Order();
                    order.setTable(table);
                    order.setCreatedByUser(staff);
                    order.setStatus("OPEN");
                    order.setOrderType("DINE_IN");
                    order.setBooking(b);
                    order.setOrderDetails(new ArrayList<>());
                    orderDao.save(s, order);

                    BigDecimal subtotal = BigDecimal.ZERO;
                    for (PreOrderItem item : b.getPreOrderItems()) {
                        OrderDetail detail = new OrderDetail();
                        detail.setOrder(order);
                        detail.setProduct(item.getProduct());
                        detail.setQuantity(item.getQuantity());
                        detail.setUnitPrice(item.getProduct().getPrice());
                        detail.setItemStatus("PENDING");
                        s.persist(detail);
                        subtotal = subtotal.add(
                            item.getProduct().getPrice()
                                .multiply(BigDecimal.valueOf(item.getQuantity()))
                        );
                    }
                    order.setSubtotal(subtotal);
                    order.setTotalAmount(subtotal.subtract(order.getDiscountAmount()));
                    s.merge(order);
                    System.out.println("✓ Auto-created order #" + order.getId() +
                        " with " + b.getPreOrderItems().size() + " pre-order items for booking " + b.getBookingCode());
                }
            } else {
                // No pre-order → keep table RESERVED, becomes OCCUPIED when staff adds first item
                System.out.println("ℹ No pre-order for booking " + b.getBookingCode() +
                    " — table stays RESERVED until staff creates order");
            }

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

    /** Check-in without staffId — fallback, picks first available staff user */
    public void checkIn(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        try {
            // Find first STAFF or ADMIN user to use as order creator
            User systemUser = s.createQuery(
                "FROM User u WHERE u.role.roleName IN ('STAFF','ADMIN','CASHIER') " +
                "AND u.status = 'ACTIVE' ORDER BY u.id ASC", User.class)
                .setMaxResults(1)
                .uniqueResult();
            int staffId = (systemUser != null) ? systemUser.getId() : 1;
            checkIn(bookingId, staffId);
        } finally {
            s.close();
        }
    }

    /** Cancel a booking without a reason */
    public void cancel(int bookingId) {
        cancel(bookingId, null);
    }

    /** Cancel a booking with an optional reason and free the table if assigned */
    public void cancel(int bookingId, String reason) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");
            
            // Check deposit refund eligibility
            boolean canRefund = false;
            if ("PAID".equals(b.getDepositStatus())) {
                LocalDateTime cutoffTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime())
                        .minusMinutes(60);
                if (LocalDateTime.now().isBefore(cutoffTime)) {
                    canRefund = true;
                    b.setDepositStatus("REFUNDED");
                } else {
                    // After cutoff - deposit is forfeited
                    b.setDepositStatus("FORFEITED");
                }
            }
            
            // If table was assigned, free it
            if (b.getTable() != null) {
                DiningTable t = b.getTable();
                t.setStatus(market.restaurant_web.entity.TableStatus.EMPTY);
                tableDao.update(s, t);
            }
            
            b.setStatus("CANCELLED");
            if (reason != null && !reason.isBlank())
                b.setCancelReason(reason.trim());
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            tx.commit();
            
            if (canRefund) {
                System.out.println("Deposit refunded for booking: " + b.getBookingCode());
            } else if ("FORFEITED".equals(b.getDepositStatus())) {
                System.out.println("Deposit forfeited (cancelled after cutoff): " + b.getBookingCode());
            }
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Assign a table to a booking and set table status to RESERVED */
    public void assignTable(int bookingId, int tableId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            DiningTable t = tableDao.findById(s, tableId);
            if (b == null || t == null)
                throw new RuntimeException("Booking hoặc bàn không tồn tại");
            
            // Validate table capacity
            if (t.getCapacity() < b.getPartySize()) {
                throw new RuntimeException("Bàn không đủ chỗ cho số khách (capacity: " + t.getCapacity() + ", guests: " + b.getPartySize() + ")");
            }
            
            // Check for time conflicts with other bookings
            if (hasTimeConflict(s, t.getId(), b.getBookingDate(), b.getBookingTime(), b.getId())) {
                throw new RuntimeException("Bàn " + t.getTableName() + " đã có booking trùng thời gian");
            }
            
            // Assign table to booking
            b.setTable(t);
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            
            // Set table status to RESERVED
            t.setStatus(market.restaurant_web.entity.TableStatus.RESERVED);
            tableDao.update(s, t);
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Auto-assign best suitable table based on party size */
    public void autoAssignTable(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");
            
            if (b.getTable() != null)
                throw new RuntimeException("Booking đã được gán bàn");
            
            // Find best suitable table: capacity >= partySize, closest to partySize
            DiningTable bestTable = findBestAvailableTable(s, b.getPartySize(), b.getBookingDate(), b.getBookingTime(), b.getId());
            
            if (bestTable == null) {
                throw new RuntimeException("Không tìm thấy bàn phù hợp cho " + b.getPartySize() + " khách");
            }
            
            // Assign table
            b.setTable(bestTable);
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            
            // Set table status to RESERVED
            bestTable.setStatus(market.restaurant_web.entity.TableStatus.RESERVED);
            tableDao.update(s, bestTable);
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Mark booking as NO_SHOW and free the table */
    public void markNoShow(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");
            
            // Free the table if assigned
            if (b.getTable() != null) {
                DiningTable t = b.getTable();
                t.setStatus(market.restaurant_web.entity.TableStatus.EMPTY);
                tableDao.update(s, t);
            }
            
            b.setStatus("NO_SHOW");
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Seat the customer - change booking to SEATED and table to OCCUPIED */
    public void seatCustomer(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");
            
            if (b.getTable() == null)
                throw new RuntimeException("Booking chưa được gán bàn");
            
            // Update booking status
            b.setStatus("SEATED");
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            
            // Update table status to OCCUPIED
            DiningTable t = b.getTable();
            t.setStatus(market.restaurant_web.entity.TableStatus.OCCUPIED);
            tableDao.update(s, t);
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Find best available table for given party size and time.
     *  Only considers tables that are currently EMPTY or AVAILABLE. */
    private DiningTable findBestAvailableTable(Session s, int partySize, LocalDate date, LocalTime time, Integer excludeBookingId) {
        // Only consider tables that are physically free right now
        List<DiningTable> tables = s.createQuery(
            "FROM DiningTable WHERE capacity >= :size " +
            "AND (status = :empty OR status = :available) " +
            "ORDER BY capacity ASC",
            DiningTable.class)
            .setParameter("size", partySize)
            .setParameter("empty", market.restaurant_web.entity.TableStatus.EMPTY)
            .setParameter("available", market.restaurant_web.entity.TableStatus.AVAILABLE)
            .list();

        // Find first table without time conflict with any OTHER booking
        for (DiningTable table : tables) {
            if (!hasTimeConflict(s, table.getId(), date, time, excludeBookingId)) {
                return table;
            }
        }

        return null;
    }

    /** Check if table has booking time conflict (assumes 2-hour booking duration) */
    private boolean hasTimeConflict(Session s, int tableId, LocalDate date, LocalTime time, Integer excludeBookingId) {
        // Booking duration: 2 hours
        LocalTime startTime = time;
        LocalTime endTime = time.plusHours(2);
        
        // Find overlapping bookings for this table on the same date
        String hql = "FROM Booking WHERE table.id = :tableId " +
                     "AND bookingDate = :date " +
                     "AND status NOT IN ('CANCELLED', 'NO_SHOW', 'COMPLETED') ";
        
        if (excludeBookingId != null) {
            hql += "AND id != :excludeId ";
        }
        
        var query = s.createQuery(hql, Booking.class)
                .setParameter("tableId", tableId)
                .setParameter("date", date);
        
        if (excludeBookingId != null) {
            query.setParameter("excludeId", excludeBookingId);
        }
        
        List<Booking> existingBookings = query.list();
        
        // Check for time overlap
        for (Booking existing : existingBookings) {
            LocalTime existingStart = existing.getBookingTime();
            LocalTime existingEnd = existingStart.plusHours(2);
            
            // Check if time ranges overlap
            if (!(endTime.isBefore(existingStart) || endTime.equals(existingStart) || 
                  startTime.isAfter(existingEnd) || startTime.equals(existingEnd))) {
                return true; // Conflict found
            }
        }
        
        return false; // No conflict
    }

    private void updateStatus(int bookingId, String newStatus) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");
            b.setStatus(newStatus);
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Complete a booking after customer finishes dining */
    public void complete(int bookingId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");
            
            b.setStatus("COMPLETED");
            b.setUpdatedAt(LocalDateTime.now());
            bookingDao.update(s, b);
            
            // Note: Table status should be set to DIRTY by staff after customer leaves
            // Then EMPTY after cleaning - this is handled separately
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Get bookings that should be marked as RESERVED (15-30 mins before booking time) */
    public List<Booking> getBookingsToReserve(int minutesBefore) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime targetTime = now.plusMinutes(minutesBefore);
            
            // Use native SQL to avoid TIME vs DATETIME comparison issues
            // PostgreSQL syntax: CAST(booking_date || ' ' || booking_time AS TIMESTAMP)
            return s.createNativeQuery(
                "SELECT * FROM bookings WHERE status = 'CONFIRMED' " +
                "AND table_id IS NOT NULL " +
                "AND booking_date = :date " +
                "AND CAST(booking_date || ' ' || booking_time AS TIMESTAMP) <= :targetDateTime " +
                "AND CAST(booking_date || ' ' || booking_time AS TIMESTAMP) > :currentDateTime",
                Booking.class)
                .setParameter("date", targetTime.toLocalDate())
                .setParameter("targetDateTime", targetTime)
                .setParameter("currentDateTime", now)
                .list();
        }
    }

    /** Get bookings that should be marked as NO_SHOW (15-30 mins after booking time) */
    public List<Booking> getBookingsToNoShow(int minutesAfter) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime targetTime = now.minusMinutes(minutesAfter);
            
            // Use native SQL to avoid TIME vs DATETIME comparison issues
            // PostgreSQL syntax: CAST(booking_date || ' ' || booking_time AS TIMESTAMP)
            return s.createNativeQuery(
                "SELECT * FROM bookings WHERE status IN ('CONFIRMED', 'CHECKED_IN') " +
                "AND CAST(booking_date || ' ' || booking_time AS TIMESTAMP) < :targetDateTime",
                Booking.class)
                .setParameter("targetDateTime", targetTime)
                .list();
        }
    }

    /** 
     * Auto-cancel bookings that are late (customer didn't show up after specified minutes)
     * Only cancels CONFIRMED bookings (not CHECKED_IN)
     * Special handling for bookings with pre-orders:
     * - Regular bookings: cancelled after 20 minutes
     * - Pre-order bookings: cancelled after 40 minutes (more grace time)
     * - Deposits are forfeited when auto-cancelled
     */
    public void autoCancelLateBookings(int minutesAfter) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            LocalDateTime now = LocalDateTime.now();
            
            System.out.println("=== Auto-cancel late bookings check ===");
            System.out.println("Current time: " + now);
            System.out.println("Looking for CONFIRMED bookings late by more than " + minutesAfter + " minutes");
            System.out.println("(Pre-order bookings get 40 minutes grace time)");
            
            // Get all CONFIRMED bookings
            List<Booking> allBookings = s.createQuery(
                "FROM Booking WHERE status = 'CONFIRMED'",
                Booking.class).list();
            
            System.out.println("Found " + allBookings.size() + " CONFIRMED bookings total");
            
            // Debug: Show all bookings with their times
            for (Booking b : allBookings) {
                LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
                boolean hasPreOrder = b.getPreOrderItems() != null && !b.getPreOrderItems().isEmpty();
                int graceMinutes = hasPreOrder ? 40 : minutesAfter;
                LocalDateTime cancelTime = bookingDateTime.plusMinutes(graceMinutes);
                long minutesLate = java.time.Duration.between(bookingDateTime, now).toMinutes();
                boolean shouldCancel = now.isAfter(cancelTime);
                
                System.out.println("  - " + b.getBookingCode() + 
                    ": booking=" + bookingDateTime + 
                    ", has_preorder=" + hasPreOrder +
                    ", grace=" + graceMinutes + "min" +
                    ", cancel_after=" + cancelTime +
                    ", late=" + minutesLate + "min" +
                    ", should_cancel=" + shouldCancel);
            }
            
            // Filter bookings that are late
            // Regular bookings: late after minutesAfter (20 mins)
            // Pre-order bookings: late after 40 mins
            List<Booking> lateBookings = allBookings.stream()
                .filter(b -> {
                    LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
                    boolean hasPreOrder = b.getPreOrderItems() != null && !b.getPreOrderItems().isEmpty();
                    int graceMinutes = hasPreOrder ? 40 : minutesAfter;
                    LocalDateTime cancelTime = bookingDateTime.plusMinutes(graceMinutes);
                    return now.isAfter(cancelTime);
                })
                .toList();
            
            System.out.println("Found " + lateBookings.size() + " late bookings to cancel");
            
            for (Booking b : lateBookings) {
                try {
                    LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
                    long minutesLate = java.time.Duration.between(bookingDateTime, now).toMinutes();
                    boolean hasPreOrder = b.getPreOrderItems() != null && !b.getPreOrderItems().isEmpty();
                    
                    // Handle deposit forfeiture for pre-order bookings
                    if (hasPreOrder && "PAID".equals(b.getDepositStatus())) {
                        b.setDepositStatus("FORFEITED");
                        System.out.println("Deposit forfeited for pre-order booking " + b.getBookingCode() + 
                            " (amount: " + b.getDepositAmount() + ")");
                    }
                    
                    // Free the table if assigned
                    if (b.getTable() != null) {
                        DiningTable t = b.getTable();
                        t.setStatus(market.restaurant_web.entity.TableStatus.EMPTY);
                        tableDao.update(s, t);
                        System.out.println("Freed table " + t.getTableName() + " from booking " + b.getBookingCode());
                    }
                    
                    // Cancel booking with appropriate reason
                    b.setStatus("CANCELLED");
                    String reason = hasPreOrder 
                        ? "Tự động hủy: Khách có pre-order không đến sau " + minutesLate + " phút (cọc bị tịch thu)"
                        : "Tự động hủy: Khách không đến sau " + minutesLate + " phút";
                    b.setCancelReason(reason);
                    b.setUpdatedAt(LocalDateTime.now());
                    bookingDao.update(s, b);
                    
                    System.out.println("✓ Auto-cancelled booking " + b.getBookingCode() + 
                        " (late by " + minutesLate + " minutes" + 
                        (hasPreOrder ? ", has pre-order" : "") + ")");
                        
                } catch (Exception e) {
                    System.err.println("Failed to auto-cancel booking " + b.getBookingCode() + 
                        ": " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            System.err.println("Error in autoCancelLateBookings: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** Update table status to RESERVED for confirmed bookings approaching their time.
     *  Only sets RESERVED if the table is currently EMPTY and belongs to THIS booking. */
    public void updateTableStatusForUpcomingBookings(int minutesBefore) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            List<Booking> bookings = getBookingsToReserve(minutesBefore);

            for (Booking b : bookings) {
                if (b.getTable() == null) continue;
                DiningTable t = b.getTable();

                // Only flip to RESERVED if the table is currently free (EMPTY/AVAILABLE)
                // If it's already RESERVED/OCCUPIED by someone else, skip
                if (t.getStatus() == market.restaurant_web.entity.TableStatus.EMPTY
                        || t.getStatus() == market.restaurant_web.entity.TableStatus.AVAILABLE) {

                    // Double-check: no other active booking is using this table right now
                    boolean takenByOther = s.createQuery(
                        "SELECT COUNT(*) FROM Booking WHERE table.id = :tid " +
                        "AND id != :bid " +
                        "AND status IN ('CHECKED_IN','SEATED','RESERVED')",
                        Long.class)
                        .setParameter("tid", t.getId())
                        .setParameter("bid", b.getId())
                        .uniqueResult() > 0;

                    if (!takenByOther) {
                        t.setStatus(market.restaurant_web.entity.TableStatus.RESERVED);
                        tableDao.update(s, t);
                        System.out.println("✓ Table " + t.getTableName() + " → RESERVED for booking " + b.getBookingCode());
                    } else {
                        System.out.println("✗ Table " + t.getTableName() + " already taken by another booking, skipping " + b.getBookingCode());
                    }
                }
            }

            tx.commit();
        } catch (Exception e) {
            if (tx != null) tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /** 
     * Auto-assign tables for confirmed bookings within specified minutes before booking time
     * Only assigns if booking doesn't have a table yet
     */
    public void autoAssignTablesForUpcomingBookings(int minutesBefore) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            LocalDateTime now = LocalDateTime.now();
            LocalDateTime targetTime = now.plusMinutes(minutesBefore);
            
            System.out.println("=== Auto-assign tables check ===");
            System.out.println("Current time: " + now);
            System.out.println("Target time: " + targetTime);
            
            // Get all CONFIRMED bookings without table, then filter in Java
            List<Booking> allBookings = s.createQuery(
                "FROM Booking WHERE status = 'CONFIRMED' AND table IS NULL",
                Booking.class)
                .list();
            
            // Filter bookings within time window
            List<Booking> bookings = allBookings.stream()
                .filter(b -> {
                    LocalDateTime bookingDateTime = LocalDateTime.of(b.getBookingDate(), b.getBookingTime());
                    return bookingDateTime.isAfter(now) && bookingDateTime.isBefore(targetTime);
                })
                .toList();
            
            System.out.println("Found " + bookings.size() + " bookings to auto-assign (out of " + allBookings.size() + " total CONFIRMED without table)");
            
            for (Booking b : bookings) {
                try {
                    System.out.println("Processing booking: " + b.getBookingCode() + 
                        " (Party: " + b.getPartySize() + ", Date: " + b.getBookingDate() + ", Time: " + b.getBookingTime() + ")");
                    
                    // Find best suitable table
                    DiningTable bestTable = findBestAvailableTable(s, b.getPartySize(), 
                        b.getBookingDate(), b.getBookingTime(), b.getId());
                    
                    if (bestTable != null) {
                        // Assign table
                        b.setTable(bestTable);
                        b.setUpdatedAt(LocalDateTime.now());
                        bookingDao.update(s, b);
                        
                        // Set table status to RESERVED
                        bestTable.setStatus(market.restaurant_web.entity.TableStatus.RESERVED);
                        tableDao.update(s, bestTable);
                        
                        System.out.println("✓ Auto-assigned table " + bestTable.getTableName() + 
                            " to booking " + b.getBookingCode() + " for " + b.getPartySize() + " guests");
                    } else {
                        System.out.println("✗ No suitable table found for booking " + b.getBookingCode() + 
                            " (party size: " + b.getPartySize() + ")");
                    }
                } catch (Exception e) {
                    System.err.println("Failed to auto-assign table for booking " + b.getBookingCode() + 
                        ": " + e.getMessage());
                    e.printStackTrace();
                }
            }
            
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            System.err.println("Error in autoAssignTablesForUpcomingBookings: " + e.getMessage());
            e.printStackTrace();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    private String generateCode() {
        return "BK" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    /**
     * Find active booking for a table (CHECKED_IN or SEATED status)
     * Used to link pre-order items to order when creating order
     */
    public Booking findActiveBookingByTable(int tableId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return bookingDao.findActiveBookingByTable(s, tableId);
        }
    }

}
