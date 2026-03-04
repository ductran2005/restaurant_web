package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.AreaDao;
import market.restaurant_web.dao.TableDao;
import market.restaurant_web.entity.Area;
import market.restaurant_web.entity.DiningTable;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class TableService {
    private final AreaDao areaDao = new AreaDao();
    private final TableDao tableDao = new TableDao();

    public List<Area> findAllAreas() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return areaDao.findAllOrdered(s);
        }
    }

    public Area findAreaById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return areaDao.findById(s, id);
        }
    }

    public List<DiningTable> findAllTables() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return tableDao.findAll(s);
        }
    }

    public List<DiningTable> findTablesByArea(int areaId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return tableDao.findByArea(s, areaId);
        }
    }

    public List<DiningTable> findAvailableTables() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return tableDao.findAvailable(s);
        }
    }

    public DiningTable findTableById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return tableDao.findById(s, id);
        }
    }

    /**
     * Update table status.
     * DB constraint: status IN ('AVAILABLE','IN_USE')
     */
    public void updateTableStatus(int tableId, String status) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            DiningTable t = tableDao.findById(s, tableId);
            if (t != null) {
                t.setStatus(status);
                tableDao.update(s, t);
            }
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            s.close();
        }
    }

    public void saveArea(Area area) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (area.getId() == null)
                areaDao.save(s, area);
            else
                areaDao.update(s, area);
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            s.close();
        }
    }

    public void saveTable(DiningTable table) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (table.getId() == null)
                tableDao.save(s, table);
            else
                tableDao.update(s, table);
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            s.close();
        }
    }
}
