package market.restaurant_web.dao;

import market.restaurant_web.entity.RestaurantTable;
import org.hibernate.Session;
import java.util.List;

public class RestaurantTableDAO extends GenericDAO<RestaurantTable> {
    public RestaurantTableDAO() {
        super(RestaurantTable.class);
    }

    public List<RestaurantTable> findAll(Session session) {
        return session.createQuery("FROM RestaurantTable ORDER BY tableNumber", RestaurantTable.class).list();
    }
}
