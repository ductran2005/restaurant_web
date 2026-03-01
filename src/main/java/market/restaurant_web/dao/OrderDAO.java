package market.restaurant_web.dao;

import market.restaurant_web.entity.Order;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class OrderDAO extends GenericDAO<Order> {

    public OrderDAO() {
        super(Order.class);
    }

    // ====== GET BY STATUS ======
    public List<Order> getByStatus(String status) {
        try (Session session = getSession()) {
            Query<Order> query = session.createQuery(
                    "FROM Order o WHERE o.status = :status", Order.class);
            query.setParameter("status", status);
            return query.list();
        }
    }

    // ====== GET BY TABLE ======
    public List<Order> getByTable(int tableId) {
        try (Session session = getSession()) {
            Query<Order> query = session.createQuery(
                    "FROM Order o WHERE o.table.tableId = :tableId AND o.status = 'PENDING'", Order.class);
            query.setParameter("tableId", tableId);
            return query.list();
        }
    }
}
