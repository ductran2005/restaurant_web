package market.restaurant_web.dao;

import market.restaurant_web.entity.Payment;

import java.util.List;

public class PaymentDAO extends GenericDAO<Payment> {
    public PaymentDAO() {
        super(Payment.class);
    }

    public List<Payment> findByOrderId(int orderId) {
        return findByQuery("FROM Payment WHERE orderId = :orderId", "orderId", orderId);
    }
}
