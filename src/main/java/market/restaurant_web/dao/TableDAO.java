package market.restaurant_web.dao;

import market.restaurant_web.entity.DiningTable;
import market.restaurant_web.entity.TableStatus;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.util.List;

public class TableDAO extends GenericDAO<DiningTable> {
    public TableDAO() {
        super(DiningTable.class);
    }

    public List<DiningTable> findByArea(Session session, int areaId) {
        Query<DiningTable> q = session.createQuery(
                "FROM DiningTable WHERE area.id = :aid ORDER BY tableName",
                DiningTable.class);
        q.setParameter("aid", areaId);
        return q.list();
    }

    public List<DiningTable> findByStatus(Session session, TableStatus status) {
        Query<DiningTable> q = session.createQuery(
                "FROM DiningTable WHERE status = :s ORDER BY tableName", DiningTable.class);
        q.setParameter("s", status);
        return q.list();
    }

    public List<DiningTable> findAvailable(Session session) {
        return findByStatus(session, TableStatus.EMPTY);
    }

    public List<DiningTable> findAll(Session session) {
        return session.createQuery(
                "FROM DiningTable ORDER BY area.id, tableName", DiningTable.class)
                .list();
    }

    public DiningTable findByName(Session session, String name) {
        List<DiningTable> list = session.createQuery(
                "FROM DiningTable WHERE tableName = :n", DiningTable.class)
                .setParameter("n", name)
                .list();
        return list.isEmpty() ? null : list.get(0);
    }
}
