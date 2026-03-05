package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.AreaDAO;
import market.restaurant_web.dao.TableDAO;
import market.restaurant_web.entity.Area;
import market.restaurant_web.entity.DiningTable;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class TableService {
    private final AreaDAO areaDao = new AreaDAO();
    private final TableDAO tableDao = new TableDAO();

    public List<Area> findAllAreas() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            List<Area> list = areaDao.findAllOrdered(s);
            for (Area a : list)
                Hibernate.initialize(a.getTables());
            return list;
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

    /** Check if table_name already exists (exclude self when updating) */
    public boolean isTableNameDuplicate(String tableName, Integer excludeId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            DiningTable existing = tableDao.findByName(s, tableName);
            if (existing == null)
                return false;
            return excludeId == null || !existing.getId().equals(excludeId);
        }
    }

    /** Check if area_name already exists (exclude self when updating) */
    public boolean isAreaNameDuplicate(String areaName, Integer excludeId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Area existing = s.createQuery(
                    "FROM Area WHERE areaName = :n", Area.class)
                    .setParameter("n", areaName)
                    .uniqueResult();
            if (existing == null)
                return false;
            return excludeId == null || !existing.getId().equals(excludeId);
        }
    }
}
