package market.restaurant_web.dao;

import market.restaurant_web.entity.Payment;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class PaymentDAO extends GenericDAO<Payment> {

    public PaymentDAO() {
        super(Payment.class);
    }

    // ====== GET BY ORDER ID ======
    public Payment getByOrderId(int orderId) {
        try (Session session = getSession()) {
            Query<Payment> query = session.createQuery(
                    "FROM Payment p WHERE p.order.orderId = :orderId", Payment.class);
            query.setParameter("orderId", orderId);
            return query.uniqueResult();
        }
    }
}
