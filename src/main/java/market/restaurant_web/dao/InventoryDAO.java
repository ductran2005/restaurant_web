package market.restaurant_web.dao;

import market.restaurant_web.entity.Inventory;

import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

public class InventoryDAO extends GenericDAO<Inventory> {

    public InventoryDAO() {
        super(Inventory.class);
    }

    // ====== GET BY PRODUCT ID ======
    public Inventory getByProductId(int productId) {
        try (Session session = getSession()) {
            Query<Inventory> query = session.createQuery(
                    "FROM Inventory i WHERE i.product.productId = :productId", Inventory.class);
            query.setParameter("productId", productId);
            return query.uniqueResult();
        }
    }

    // ====== SUBTRACT STOCK ======
    /**
     * Trừ tồn kho cho sản phẩm. Ném RuntimeException nếu không đủ hàng.
     */
    public void subtract(int productId, int qty) {
        Transaction tx = null;
        try (Session session = getSession()) {
            tx = session.beginTransaction();

            Inventory inv = session.createQuery(
                    "FROM Inventory i WHERE i.product.productId = :pid", Inventory.class)
                    .setParameter("pid", productId)
                    .uniqueResult();

            if (inv == null) {
                throw new RuntimeException("Không tìm thấy tồn kho cho productId=" + productId);
            }
            if (inv.getCurrentQty() < qty) {
                throw new RuntimeException("Không đủ tồn kho cho productId=" + productId
                        + " (còn " + inv.getCurrentQty() + ", cần " + qty + ")");
            }

            inv.setCurrentQty(inv.getCurrentQty() - qty);
            session.merge(inv);
            tx.commit();
        } catch (Exception e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }

    // ====== ADD STOCK ======
    public void addStock(int productId, int qty) {
        Transaction tx = null;
        try (Session session = getSession()) {
            tx = session.beginTransaction();

            Inventory inv = session.createQuery(
                    "FROM Inventory i WHERE i.product.productId = :pid", Inventory.class)
                    .setParameter("pid", productId)
                    .uniqueResult();

            if (inv == null) {
                throw new RuntimeException("Không tìm thấy tồn kho cho productId=" + productId);
            }

            inv.setCurrentQty(inv.getCurrentQty() + qty);
            session.merge(inv);
            tx.commit();
        } catch (Exception e) {
            if (tx != null) {
                tx.rollback();
            }
            throw e;
        }
    }
}
