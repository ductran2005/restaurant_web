package market.restaurant_web.dao;

import market.restaurant_web.entity.Order;
import market.restaurant_web.entity.OrderDetail;
import market.restaurant_web.entity.Product;
import org.hibernate.Session;
import org.hibernate.Transaction;
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

    // ====== ADD OR INCREASE ======
    /**
     * Thêm món vào đơn. Nếu món đã có trong đơn thì tăng số lượng,
     * nếu chưa thì tạo dòng mới.
     * (Migrated từ restaurant-ipos-java)
     */
    public void addOrIncrease(int orderId, int productId, int qty) {
        Transaction tx = null;
        try (Session session = getSession()) {
            tx = session.beginTransaction();

            Order order = session.get(Order.class, orderId);
            Product product = session.get(Product.class, productId);

            if (order == null) {
                throw new RuntimeException("Không tìm thấy đơn hàng: " + orderId);
            }
            if (product == null) {
                throw new RuntimeException("Không tìm thấy sản phẩm: " + productId);
            }

            // Tìm xem món đã có trong đơn chưa
            OrderDetail existing = session.createQuery(
                    "FROM OrderDetail d WHERE d.order.orderId = :oid AND d.product.productId = :pid",
                    OrderDetail.class)
                    .setParameter("oid", orderId)
                    .setParameter("pid", productId)
                    .setMaxResults(1)
                    .uniqueResult();

            if (existing != null) {
                // Đã có → tăng số lượng
                existing.setQuantity(existing.getQuantity() + qty);
                session.merge(existing);
            } else {
                // Chưa có → tạo mới
                OrderDetail detail = new OrderDetail();
                detail.setOrder(order);
                detail.setProduct(product);
                detail.setQuantity(qty);
                detail.setUnitPrice(product.getPrice());
                detail.setItemStatus("ORDERED");
                session.persist(detail);
            }

            tx.commit();
        } catch (Exception e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }
}
