package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.*;
import market.restaurant_web.entity.*;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;

public class OrderService {
    private final OrderDAO orderDao = new OrderDAO();
    private final ProductDAO productDao = new ProductDAO();
    private final TableDAO tableDao = new TableDAO();

    public Order findById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Order o = orderDao.findById(s, id);
            if (o != null && o.getOrderDetails() != null)
                o.getOrderDetails().size(); // init lazy
            return o;
        }
    }

    public List<Order> findActiveOrders() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            List<Order> list = orderDao.findActiveOrders(s);
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

    public List<Order> findByStatus(String status) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return orderDao.findByStatus(s, status);
        }
    }

    /**
     * Create order for a table.
     * Business rule: 1 table only has 1 OPEN order (DB filtered unique index).
     */
    public Order createOrder(int tableId, int staffId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            // Check constraint: 1 table 1 open order
            Order existing = orderDao.findOpenByTable(s, tableId);
            if (existing != null) {
                throw new RuntimeException("Bàn này đã có order đang mở (#" + existing.getId() + ")");
            }

            DiningTable table = tableDao.findById(s, tableId);
            User staff = s.get(User.class, staffId);

            Order order = new Order();
            order.setTable(table);
            order.setCreatedByUser(staff);
            order.setStatus("OPEN");
            order.setOrderType("DINE_IN");
            order.setOrderDetails(new ArrayList<>());
            orderDao.save(s, order);

            // Update table status
            table.setStatus("IN_USE");
            tableDao.update(s, table);

            tx.commit();
            return order;
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /**
     * Add item to order.
     * Business rule: cannot add if product is UNAVAILABLE.
     */
    public void addItem(int orderId, int productId, int qty) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Order order = orderDao.findById(s, orderId);
            if (order == null)
                throw new RuntimeException("Order không tồn tại");
            if (!"OPEN".equals(order.getStatus())) {
                throw new RuntimeException("Không thể thêm món vào order đã đóng");
            }

            Product product = productDao.findById(s, productId);
            if (product == null)
                throw new RuntimeException("Sản phẩm không tồn tại");
            if (!"AVAILABLE".equals(product.getStatus()))
                throw new RuntimeException("Sản phẩm không khả dụng: " + product.getName());

            OrderDetail detail = new OrderDetail();
            detail.setOrder(order);
            detail.setProduct(product);
            detail.setQuantity(qty);
            detail.setUnitPrice(product.getPrice()); // snapshot price
            detail.setItemStatus("PENDING");
            s.persist(detail);

            // Update order subtotal
            recalculateOrder(s, order);

            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    public void removeItem(int orderDetailId, String cancelReason) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            OrderDetail detail = s.get(OrderDetail.class, orderDetailId);
            if (detail == null)
                throw new RuntimeException("Item không tồn tại");

            Order order = detail.getOrder();
            // If item is ORDERED, it must have a reason. If PENDING, just cancel directly.
            if ("ORDERED".equals(detail.getItemStatus())) {
                if (cancelReason == null || cancelReason.trim().isEmpty()) {
                    throw new RuntimeException("Cần lý do khi xóa món đã được gửi bếp");
                }
                detail.setCancelReason(cancelReason.trim());
            }
            detail.setItemStatus("CANCELLED");
            s.merge(detail);

            recalculateOrder(s, order);

            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /**
     * Recalculate order subtotal/total from non-cancelled order_details.
     */
    private void recalculateOrder(Session s, Order order) {
        List<OrderDetail> details = s.createQuery(
                "FROM OrderDetail WHERE order.id = :oid AND itemStatus IN ('PENDING', 'ORDERED')", OrderDetail.class)
                .setParameter("oid", order.getId()).list();

        BigDecimal subtotal = BigDecimal.ZERO;
        for (OrderDetail d : details) {
            subtotal = subtotal.add(d.getUnitPrice().multiply(BigDecimal.valueOf(d.getQuantity())));
        }
        order.setSubtotal(subtotal);
        order.setTotalAmount(subtotal.subtract(order.getDiscountAmount()));
        s.merge(order);
    }

    /**
     * Calculate subtotal for an order (sum of qty * unit_price for ORDERED items).
     */
    public BigDecimal calculateSubtotal(int orderId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            List<OrderDetail> items = s.createQuery(
                    "FROM OrderDetail WHERE order.id = :oid AND itemStatus IN ('PENDING', 'ORDERED')",
                    OrderDetail.class)
                    .setParameter("oid", orderId).list();

            BigDecimal subtotal = BigDecimal.ZERO;
            for (OrderDetail item : items) {
                subtotal = subtotal.add(item.getUnitPrice().multiply(BigDecimal.valueOf(item.getQuantity())));
            }
            return subtotal;
        }
    }

    /**
     * Confirm all PENDING items in an order (send to kitchen).
     */
    public void confirmItems(int orderId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            List<OrderDetail> pendingItems = s.createQuery(
                    "FROM OrderDetail WHERE order.id = :oid AND itemStatus = 'PENDING'", OrderDetail.class)
                    .setParameter("oid", orderId).list();

            for (OrderDetail item : pendingItems) {
                item.setItemStatus("ORDERED");
                s.merge(item);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /**
     * Finish order: OPEN -> SERVED.
     * Called when staff finishes serving all items and is ready for payment.
     */
    public void confirmOrder(int orderId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Order order = orderDao.findById(s, orderId);
            if (order == null)
                throw new RuntimeException("Order không tồn tại");
            if (!"OPEN".equals(order.getStatus()))
                throw new RuntimeException("Chỉ có thể xác nhận order đang OPEN");

            order.setStatus("SERVED");
            orderDao.update(s, order);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    public List<Order> findByDateRange(LocalDate from, LocalDate to) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return orderDao.findByDateRange(s,
                    from.atStartOfDay(),
                    to.atTime(LocalTime.MAX));
        }
    }
}
