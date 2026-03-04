package market.restaurant_web.dao;

import market.restaurant_web.entity.Payment;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.util.List;

public class PaymentDao extends GenericDao<Payment> {
    public PaymentDao() {
        super(Payment.class);
    }

    public Payment findByOrderId(Session session, int orderId) {
        Query<Payment> q = session.createQuery(
                "FROM Payment WHERE order.id = :oid", Payment.class);
        q.setParameter("oid", orderId);
        return q.uniqueResult();
    }

    public List<Payment> findByStatus(Session session, String paymentStatus) {
        Query<Payment> q = session.createQuery(
                "FROM Payment WHERE paymentStatus = :s ORDER BY paidAt DESC", Payment.class);
        q.setParameter("s", paymentStatus);
        return q.list();
    }
}
