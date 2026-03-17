package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.AreaDAO;
import market.restaurant_web.dao.OrderDAO;
import market.restaurant_web.dao.TableDAO;
import market.restaurant_web.entity.Area;
import market.restaurant_web.entity.DiningTable;
import market.restaurant_web.entity.Order;
import market.restaurant_web.entity.TableStatus;
import market.restaurant_web.exception.BusinessException;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;
import java.util.function.BiConsumer;

public class TableService {
    private final AreaDAO areaDao = new AreaDAO();
    private final TableDAO tableDao = new TableDAO();
    private final OrderDAO orderDao = new OrderDAO();

    public List<Area> findAllAreas() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            List<Area> list = areaDao.findAllOrdered(s);
            for (Area a : list)
                Hibernate.initialize(a.getTables());
            return list;
        }
    }

    public List<DiningTable> findAllTables() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return tableDao.findAll(s);
        }
    }

    public DiningTable findTableById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return tableDao.findById(s, id);
        }
    }

    // --- Required Transition Methods ---

    public void reserveTable(int tableId) {
        executeTransition(tableId, (s, table) -> {
            if (table.getStatus() != TableStatus.EMPTY && table.getStatus() != TableStatus.AVAILABLE) {
                throw new BusinessException("Table must be EMPTY to reserve. Current: " + table.getStatus());
            }
            table.setStatus(TableStatus.RESERVED);
        });
    }

    public void cancelReservation(int tableId) {
        executeTransition(tableId, (s, table) -> {
            if (table.getStatus() != TableStatus.RESERVED) {
                throw new BusinessException("Table must be RESERVED to cancel. Current: " + table.getStatus());
            }
            table.setStatus(TableStatus.EMPTY);
        });
    }

    /**
     * Called by OrderService when order is created.
     * Allowed from EMPTY, AVAILABLE or RESERVED.
     */
    public void createOrder(int tableId) {
        executeTransition(tableId, (s, table) -> {
            TableStatus ts = table.getStatus();
            if (ts != TableStatus.EMPTY && ts != TableStatus.AVAILABLE && ts != TableStatus.RESERVED) {
                throw new BusinessException(
                        "Order can only be created for EMPTY or RESERVED tables. Current: " + ts);
            }
            // table.setStatus(TableStatus.OCCUPIED);
            // We keep it EMPTY/RESERVED until first item is added (handled by OrderService)
        });
    }

    public void requestPayment(int tableId) {
        executeTransition(tableId, (s, table) -> {
            TableStatus st = table.getStatus();
            if (st != TableStatus.OCCUPIED && st != TableStatus.IN_USE) {
                throw new BusinessException("Table must be OCCUPIED to request payment. Current: " + st);
            }
            table.setStatus(TableStatus.WAITING_PAYMENT);

            // Transition Order to SERVED
            Order order = orderDao.findOpenByTable(s, tableId);
            if (order != null) {
                order.setStatus("SERVED");
                orderDao.update(s, order);
            }
        });
    }

    public void payOrder(int tableId) {
        executeTransition(tableId, (s, table) -> {
            if (table.getStatus() != TableStatus.WAITING_PAYMENT) {
                throw new BusinessException("Table must be WAITING_PAYMENT to pay. Current: " + table.getStatus());
            }
            table.setStatus(TableStatus.DIRTY);
        });
    }

    public void cleanTable(int tableId) {
        executeTransition(tableId, (s, table) -> {
            if (table.getStatus() != TableStatus.DIRTY) {
                throw new BusinessException("Table must be DIRTY to clean. Current: " + table.getStatus());
            }
            table.setStatus(TableStatus.EMPTY);
        });
    }

    public void disableTable(int tableId) {
        executeTransition(tableId, (s, table) -> {
            TableStatus ts = table.getStatus();
            if (ts != TableStatus.EMPTY && ts != TableStatus.AVAILABLE && ts != TableStatus.OCCUPIED
                    && ts != TableStatus.IN_USE) {
                throw new BusinessException(
                        "Only EMPTY or OCCUPIED tables can be disabled. Current: " + ts);
            }
            table.setStatus(TableStatus.DISABLED);
        });
    }

    public void enableTable(int tableId) {
        executeTransition(tableId, (s, table) -> {
            if (table.getStatus() != TableStatus.DISABLED) {
                throw new BusinessException("Table must be DISABLED to enable. Current: " + table.getStatus());
            }
            table.setStatus(TableStatus.EMPTY);
        });
    }

    public Area findAreaById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return areaDao.findById(s, id);
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

    public boolean isTableNameDuplicate(String tableName, Integer excludeId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            DiningTable existing = tableDao.findByName(s, tableName);
            if (existing == null)
                return false;
            return excludeId == null || !existing.getId().equals(excludeId);
        }
    }

    public boolean isAreaNameDuplicate(String areaName, Integer excludeId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            Area existing = s.createQuery("FROM Area WHERE areaName = :n", Area.class)
                    .setParameter("n", areaName)
                    .uniqueResult();
            if (existing == null)
                return false;
            return excludeId == null || !existing.getId().equals(excludeId);
        }
    }

    public List<DiningTable> findAvailableTables() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return s.createQuery("FROM DiningTable WHERE status = :s", DiningTable.class)
                    .setParameter("s", TableStatus.EMPTY)
                    .list();
        }
    }

    private void executeTransition(int tableId, BiConsumer<Session, DiningTable> transition) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            DiningTable t = tableDao.findById(s, tableId);
            if (t == null)
                throw new BusinessException("Table not found: " + tableId);
            transition.accept(s, t);
            tableDao.update(s, t);
            tx.commit();
        } catch (BusinessException e) {
            tx.rollback();
            throw e;
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException("Database error: " + e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    // --- Legacy / Misc Methods ---

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
