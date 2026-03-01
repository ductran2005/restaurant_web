package market.restaurant_web.dao;

import market.restaurant_web.entity.RestaurantTable;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class TableDAO extends GenericDAO<RestaurantTable> {

    public TableDAO() {
        super(RestaurantTable.class);
    }

    // ====== GET BY STATUS ======
    public List<RestaurantTable> getByStatus(String status) {
        try (Session session = getSession()) {
            Query<RestaurantTable> query = session.createQuery(
                    "FROM RestaurantTable t WHERE t.status = :status", RestaurantTable.class);
            query.setParameter("status", status);
            return query.list();
        }
    }

    // ====== GET BY AREA ======
    public List<RestaurantTable> getByArea(int areaId) {
        try (Session session = getSession()) {
            Query<RestaurantTable> query = session.createQuery(
                    "FROM RestaurantTable t WHERE t.area.areaId = :areaId", RestaurantTable.class);
            query.setParameter("areaId", areaId);
            return query.list();
        }
    }
}
