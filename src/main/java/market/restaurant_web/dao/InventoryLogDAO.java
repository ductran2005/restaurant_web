package market.restaurant_web.dao;

import market.restaurant_web.entity.InventoryLog;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class InventoryLogDAO extends GenericDAO<InventoryLog> {

    public InventoryLogDAO() {
        super(InventoryLog.class);
    }

    // ====== GET BY INVENTORY ID ======
    public List<InventoryLog> getByInventoryId(int inventoryId) {
        try (Session session = getSession()) {
            Query<InventoryLog> query = session.createQuery(
                    "FROM InventoryLog il WHERE il.inventory.inventoryId = :inventoryId ORDER BY il.createdAt DESC",
                    InventoryLog.class);
            query.setParameter("inventoryId", inventoryId);
            return query.list();
        }
    }
}
