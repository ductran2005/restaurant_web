package market.restaurant_web.dao;

import market.restaurant_web.entity.DiningTable;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.util.List;

public class TableDao extends GenericDao<DiningTable> {
    public TableDao() {
        super(DiningTable.class);
    }

    public List<DiningTable> findByArea(Session session, int areaId) {
        Query<DiningTable> q = session.createQuery(
                "FROM DiningTable WHERE area.id = :aid ORDER BY tableName",
                DiningTable.class);
        q.setParameter("aid", areaId);
        return q.list();
    }

    public List<DiningTable> findByStatus(Session session, String status) {
        Query<DiningTable> q = session.createQuery(
                "FROM DiningTable WHERE status = :s ORDER BY tableName", DiningTable.class);
        q.setParameter("s", status);
        return q.list();
    }

    public List<DiningTable> findAvailable(Session session) {
        return findByStatus(session, "AVAILABLE");
    }

    public List<DiningTable> findAll(Session session) {
        return session.createQuery(
                "FROM DiningTable ORDER BY area.id, tableName", DiningTable.class)
                .list();
    }
}
