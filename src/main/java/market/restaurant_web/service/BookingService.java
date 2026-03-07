package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.BookingDao;
import market.restaurant_web.dao.TableDAO;
import market.restaurant_web.entity.Booking;
import market.restaurant_web.entity.DiningTable;
import market.restaurant_web.entity.PreOrderItem;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.UUID;

public class BookingService {
    private final BookingDao bookingDao = new BookingDao();
    private final TableDAO tableDao = new TableDAO();

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
            Booking b = bookingDao.findByCode(s, code);
            if (b != null) {
                Hibernate.initialize(b.getPreOrderItems());
            }
            return b;
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

    /** Check-in a confirmed booking */
    public void checkIn(int bookingId) {
        updateStatus(bookingId, "CHECKED_IN");
    }

    /** Cancel a booking without a reason */
    public void cancel(int bookingId) {
        cancel(bookingId, null);
    }

    /** Cancel a booking with an optional reason */
    public void cancel(int bookingId, String reason) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            if (b == null)
                throw new RuntimeException("Booking không tồn tại");
            b.setStatus("CANCELLED");
            if (reason != null && !reason.isBlank())
                b.setCancelReason(reason.trim());
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

    /** Assign a table to a booking */
    public void assignTable(int bookingId, int tableId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Booking b = bookingDao.findById(s, bookingId);
            DiningTable t = tableDao.findById(s, tableId);
            if (b == null || t == null)
                throw new RuntimeException("Booking hoặc bàn không tồn tại");
            b.setTable(t);
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

    private String generateCode() {
        return "BK" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
    }

    /** Save a pre-order item linked to a booking */
    public void savePreOrderItem(PreOrderItem item) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            s.persist(item);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }
}
