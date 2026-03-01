package market.restaurant_web.dao;

import market.restaurant_web.entity.OrderDetail;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class OrderDetailDAO extends GenericDAO<OrderDetail> {

    public OrderDetailDAO() {
        super(OrderDetail.class);
    }

    // ====== GET BY ORDER ID ======
    public List<OrderDetail> getByOrderId(int orderId) {
        try (Session session = getSession()) {
            Query<OrderDetail> query = session.createQuery(
                    "FROM OrderDetail od WHERE od.order.orderId = :orderId", OrderDetail.class);
            query.setParameter("orderId", orderId);
            return query.list();
        }
    }
}
