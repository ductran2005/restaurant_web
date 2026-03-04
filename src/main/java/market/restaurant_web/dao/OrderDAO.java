package market.restaurant_web.dao;

import market.restaurant_web.entity.Order;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.time.LocalDateTime;
import java.util.List;

public class OrderDao extends GenericDao<Order> {
    public OrderDao() {
        super(Order.class);
    }

    /** DB filtered unique index: only 1 OPEN order per table */
    public Order findOpenByTable(Session session, int tableId) {
        Query<Order> q = session.createQuery(
                "FROM Order WHERE table.id = :tid AND status = 'OPEN'", Order.class);
        q.setParameter("tid", tableId);
        return q.uniqueResult();
    }

    public List<Order> findByStatus(Session session, String status) {
        Query<Order> q = session.createQuery(
                "FROM Order WHERE status = :s ORDER BY openedAt DESC", Order.class);
        q.setParameter("s", status);
        return q.list();
    }

    public List<Order> findActiveOrders(Session session) {
        return session.createQuery(
                "FROM Order WHERE status IN ('OPEN','SERVED') ORDER BY openedAt DESC", Order.class).list();
    }

    public List<Order> findByDateRange(Session session, LocalDateTime from, LocalDateTime to) {
        Query<Order> q = session.createQuery(
                "FROM Order WHERE openedAt BETWEEN :f AND :t ORDER BY openedAt DESC", Order.class);
        q.setParameter("f", from);
        q.setParameter("t", to);
        return q.list();
    }

    public List<Order> findPaidByDateRange(Session session, LocalDateTime from, LocalDateTime to) {
        Query<Order> q = session.createQuery(
                "FROM Order WHERE status = 'PAID' AND openedAt BETWEEN :f AND :t ORDER BY openedAt DESC",
                Order.class);
        q.setParameter("f", from);
        q.setParameter("t", to);
        return q.list();
    }
}
