package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.*;
import market.restaurant_web.entity.*;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;

/**
 * Payment service - handles order checkout and payment operations.
 * In new DB schema, there's no invoices table.
 * Payment links directly to Order. Order has
 * subtotal/discount_amount/total_amount.
 */
public class PaymentService {
    private final OrderDAO orderDao = new OrderDAO();
    private final PaymentDAO paymentDao = new PaymentDAO();
    private final TableDAO tableDao = new TableDAO();

    /**
     * Checkout: calculate order totals, create payment, mark order PAID.
     */
    public Payment checkout(int orderId, String paymentMethod, int cashierId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Order order = orderDao.findById(s, orderId);
            if (order == null)
                throw new RuntimeException("Order không tồn tại");
            if ("PAID".equals(order.getStatus()))
                throw new RuntimeException("Order đã được thanh toán");
            if ("CANCELLED".equals(order.getStatus()))
                throw new RuntimeException("Order đã bị hủy");

            // Check if payment already exists (UQ on order_id)
            Payment existingPayment = paymentDao.findByOrderId(s, orderId);
            if (existingPayment != null && "SUCCESS".equals(existingPayment.getPaymentStatus())) {
                throw new RuntimeException("Order đã được thanh toán");
            }

            // Calculate subtotal from non-cancelled order details
            List<OrderDetail> details = s.createQuery(
                    "FROM OrderDetail WHERE order.id = :oid AND itemStatus = 'ORDERED'", OrderDetail.class)
                    .setParameter("oid", orderId).list();

            BigDecimal subtotal = BigDecimal.ZERO;
            for (OrderDetail d : details) {
                subtotal = subtotal.add(d.getUnitPrice().multiply(BigDecimal.valueOf(d.getQuantity())));
            }

            BigDecimal discountAmount = order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO;
            BigDecimal totalAmount = subtotal.subtract(discountAmount);
            if (totalAmount.compareTo(BigDecimal.ZERO) < 0)
                totalAmount = BigDecimal.ZERO;

            // Update order amounts
            order.setSubtotal(subtotal);
            order.setTotalAmount(totalAmount);
            order.setStatus("PAID");
            order.setClosedAt(LocalDateTime.now());
            orderDao.update(s, order);

            // Create payment record
            User cashier = s.get(User.class, cashierId);
            Payment payment = new Payment();
            payment.setOrder(order);
            payment.setCashier(cashier);
            payment.setPaidAt(LocalDateTime.now());
            payment.setMethod(paymentMethod);
            payment.setAmountPaid(totalAmount);
            payment.setDiscountAmount(discountAmount);
            payment.setFinalAmount(totalAmount);
            payment.setPaymentStatus("SUCCESS");
            s.persist(payment);

            // Update table status back to DIRTY (as per requirements)
            if (order.getTable() != null) {
                DiningTable table = order.getTable();
                table.setStatus(TableStatus.DIRTY);
                tableDao.update(s, table);
            }

            tx.commit();
            return payment;
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /**
     * Checkout via bank transfer (called by SePay webhook).
     * Uses the first ADMIN or CASHIER user as auto-cashier.
     */
    public Payment checkoutViaTransfer(int orderId, long transferAmount, String referenceCode) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Order order = orderDao.findById(s, orderId);
            if (order == null)
                throw new RuntimeException("Order không tồn tại: " + orderId);
            if ("PAID".equals(order.getStatus()))
                throw new RuntimeException("Order đã được thanh toán");
            if ("CANCELLED".equals(order.getStatus()))
                throw new RuntimeException("Order đã bị hủy");

            // Check existing payment
            Payment existingPayment = paymentDao.findByOrderId(s, orderId);
            if (existingPayment != null && "SUCCESS".equals(existingPayment.getPaymentStatus())) {
                throw new RuntimeException("Order đã được thanh toán");
            }

            // Calculate subtotal
            List<OrderDetail> details = s.createQuery(
                    "FROM OrderDetail WHERE order.id = :oid AND itemStatus = 'ORDERED'", OrderDetail.class)
                    .setParameter("oid", orderId).list();

            BigDecimal subtotal = BigDecimal.ZERO;
            for (OrderDetail d : details) {
                subtotal = subtotal.add(d.getUnitPrice().multiply(BigDecimal.valueOf(d.getQuantity())));
            }

            BigDecimal discountAmount = order.getDiscountAmount() != null ? order.getDiscountAmount() : BigDecimal.ZERO;
            BigDecimal totalAmount = subtotal.subtract(discountAmount);
            if (totalAmount.compareTo(BigDecimal.ZERO) < 0)
                totalAmount = BigDecimal.ZERO;

            // Verify transfer amount (allow equal or greater)
            if (transferAmount < totalAmount.longValue()) {
                throw new RuntimeException(
                        "Số tiền chuyển khoản không đủ. Cần: " + totalAmount + ", Nhận: " + transferAmount);
            }

            // Update order
            order.setSubtotal(subtotal);
            order.setTotalAmount(totalAmount);
            order.setStatus("PAID");
            order.setClosedAt(LocalDateTime.now());
            orderDao.update(s, order);

            // Find a system/admin user as auto-cashier
            User autoCashier = s.createQuery("FROM User WHERE role.name IN ('ADMIN','CASHIER') ORDER BY id", User.class)
                    .setMaxResults(1).uniqueResult();
            if (autoCashier == null) {
                autoCashier = s.createQuery("FROM User ORDER BY id", User.class).setMaxResults(1).uniqueResult();
            }

            // Create payment
            Payment payment = new Payment();
            payment.setOrder(order);
            payment.setCashier(autoCashier);
            payment.setPaidAt(LocalDateTime.now());
            payment.setMethod("TRANSFER");
            payment.setAmountPaid(BigDecimal.valueOf(transferAmount));
            payment.setDiscountAmount(discountAmount);
            payment.setFinalAmount(totalAmount);
            payment.setPaymentStatus("SUCCESS");
            payment.setTransactionRef(referenceCode);
            s.persist(payment);

            // Update table status
            if (order.getTable() != null) {
                DiningTable table = order.getTable();
                table.setStatus(TableStatus.AVAILABLE);
                tableDao.update(s, table);
            }

            tx.commit();
            return payment;
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /**
     * Check if an order has been paid (for AJAX polling from QR payment page).
     * Returns "PAID" or "UNPAID".
     */
    public String checkPaymentStatus(int orderId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Order order = orderDao.findById(s, orderId);
            if (order != null && "PAID".equals(order.getStatus())) {
                return "PAID";
            }
            return "UNPAID";
        }
    }

    /**
     * Find payment by order ID.
     */
    public Payment findByOrderId(int orderId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return paymentDao.findByOrderId(s, orderId);
        }
    }

    /**
     * Find all paid orders in date range (for dashboard revenue).
     */
    public List<Order> findPaidOrdersByDateRange(LocalDate from, LocalDate to) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            List<Order> list = orderDao.findPaidByDateRange(s,
                    from.atStartOfDay(), to.atTime(LocalTime.MAX));
            // initialize order details and their products to avoid lazy errors later
            for (Order o : list) {
                if (o.getOrderDetails() != null) {
                    Hibernate.initialize(o.getOrderDetails());
                    for (OrderDetail d : o.getOrderDetails()) {
                        Hibernate.initialize(d.getProduct());
                    }
                }
            }
            return list;
        }
    }
}
