package market.restaurant_web.dao;

import market.restaurant_web.entity.Area;
import org.hibernate.Session;
import java.util.List;

public class AreaDao extends GenericDao<Area> {
    public AreaDao() {
        super(Area.class);
    }

    public List<Area> findAllOrdered(Session session) {
        return session.createQuery(
                "FROM Area ORDER BY id", Area.class).list();
    }
}
