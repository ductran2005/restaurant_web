package market.restaurant_web.dao;

import market.restaurant_web.entity.Booking;
import org.hibernate.Session;
import java.time.LocalDate;
import java.util.List;

public class BookingDao extends GenericDAO<Booking> {
    public BookingDao() {
        super(Booking.class);
    }

    public Booking findByCode(Session s, String code) {
        return s.createQuery("FROM Booking WHERE bookingCode = :code", Booking.class)
                .setParameter("code", code)
                .uniqueResult();
    }

    public List<Booking> findByDateAndStatus(Session s, LocalDate date, String status) {
        String hql = "FROM Booking WHERE bookingDate = :date";
        if (status != null && !status.isEmpty()) {
            hql += " AND status = :status";
        }
        hql += " ORDER BY bookingTime";
        var q = s.createQuery(hql, Booking.class).setParameter("date", date);
        if (status != null && !status.isEmpty()) {
            q.setParameter("status", status);
        }
        return q.list();
    }

    public List<Booking> search(Session s, String keyword, String status, LocalDate date) {
        StringBuilder hql = new StringBuilder("FROM Booking WHERE 1=1");
        if (keyword != null && !keyword.isBlank()) {
            hql.append(" AND (bookingCode LIKE :kw OR customerPhone LIKE :kw OR customerName LIKE :kwName)");
        }
        if (status != null && !status.isEmpty()) {
            hql.append(" AND status = :status");
        }
        if (date != null) {
            hql.append(" AND bookingDate = :date");
        }
        hql.append(" ORDER BY bookingDate DESC, bookingTime DESC");

        var q = s.createQuery(hql.toString(), Booking.class);
        if (keyword != null && !keyword.isBlank()) {
            q.setParameter("kw", "%" + keyword.trim() + "%");
            q.setParameter("kwName", "%" + keyword.trim() + "%");
        }
        if (status != null && !status.isEmpty()) {
            q.setParameter("status", status);
        }
        if (date != null) {
            q.setParameter("date", date);
        }
        return q.list();
    }

    public List<Booking> findByPhone(Session s, String phone) {
        // Normalize: if user enters 0901234567, also try +84901234567 (strip leading 0,
        // add +84)
        String alt = null;
        if (phone.startsWith("0") && phone.length() >= 10) {
            alt = "+84" + phone.substring(1);
        } else if (phone.startsWith("+84")) {
            alt = "0" + phone.substring(3);
        }
        if (alt != null) {
            return s.createQuery(
                    "FROM Booking WHERE customerPhone = :phone OR customerPhone = :alt ORDER BY bookingDate DESC",
                    Booking.class)
                    .setParameter("phone", phone)
                    .setParameter("alt", alt)
                    .list();
        }
        return s.createQuery("FROM Booking WHERE customerPhone LIKE :phone ORDER BY bookingDate DESC", Booking.class)
                .setParameter("phone", "%" + phone + "%")
                .list();
    }

    public long countByDateAndStatus(Session s, LocalDate date, String status) {
        return s.createQuery(
                "SELECT COUNT(*) FROM Booking WHERE bookingDate = :date AND status = :status", Long.class)
                .setParameter("date", date)
                .setParameter("status", status)
                .uniqueResult();
    }

    /**
     * Find active booking for a table (CHECKED_IN or SEATED status)
     * Used to link pre-order items to order when creating order
     */
    public Booking findActiveBookingByTable(Session s, int tableId) {
        return s.createQuery(
                "FROM Booking WHERE table.id = :tableId AND status IN ('CHECKED_IN', 'SEATED') ORDER BY bookingDate DESC, bookingTime DESC",
                Booking.class)
                .setParameter("tableId", tableId)
                .setMaxResults(1)
                .uniqueResult();
    }

}
