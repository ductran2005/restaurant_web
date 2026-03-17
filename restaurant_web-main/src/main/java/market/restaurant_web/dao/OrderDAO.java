package market.restaurant_web.dao;

import market.restaurant_web.entity.Order;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.time.LocalDateTime;
import java.util.List;

public class OrderDAO extends GenericDAO<Order> {
    public OrderDAO() {
        super(Order.class);
    }

    /** DB filtered unique index: only 1 OPEN order per table.
     *  An empty order (no active items) is NOT considered open. */
    public Order findOpenByTable(Session session, int tableId) {
        // First try to find an order that has at least 1 active item
        Query<Order> q = session.createQuery(
                "FROM Order o WHERE o.table.id = :tid AND o.status = 'OPEN' " +
                "AND EXISTS (SELECT 1 FROM OrderDetail d WHERE d.order = o AND d.itemStatus != 'CANCELLED')",
                Order.class);
        q.setParameter("tid", tableId);
        Order withItems = q.uniqueResult();
        if (withItems != null) return withItems;

        // Fall back to any OPEN order (so we reuse it instead of creating a duplicate)
        Query<Order> q2 = session.createQuery(
                "FROM Order WHERE table.id = :tid AND status = 'OPEN'", Order.class);
        q2.setParameter("tid", tableId);
        return q2.uniqueResult();
    }

    public List<Order> findByStatus(Session session, String status) {
        Query<Order> q = session.createQuery(
                "FROM Order WHERE status = :s ORDER BY openedAt DESC", Order.class);
        q.setParameter("s", status);
        return q.list();
    }

    public List<Order> findActiveOrders(Session session) {
        // Return all OPEN/SERVED orders regardless of item count
        // (empty orders are filtered at display layer, not here)
        return session.createQuery(
                "FROM Order o WHERE o.status IN ('OPEN','SERVED') " +
                "ORDER BY o.openedAt DESC", Order.class).list();
    }

    /** Find active orders that have at least 1 non-cancelled item (for display lists) */
    public List<Order> findActiveOrdersWithItems(Session session) {
        return session.createQuery(
                "FROM Order o WHERE o.status IN ('OPEN','SERVED') " +
                "AND EXISTS (SELECT 1 FROM OrderDetail d WHERE d.order = o AND d.itemStatus != 'CANCELLED') " +
                "ORDER BY o.openedAt DESC", Order.class).list();
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
