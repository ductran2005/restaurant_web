package market.restaurant_web.service.impl;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.RestaurantTableDAO;
import market.restaurant_web.entity.RestaurantTable;
import market.restaurant_web.entity.TableStatus;
import market.restaurant_web.exception.BusinessException;
import market.restaurant_web.service.TableManagementService;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class TableManagementServiceImpl implements TableManagementService {
    private final RestaurantTableDAO tableDAO = new RestaurantTableDAO();

    @Override
    public List<RestaurantTable> getAllTables() {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            return tableDAO.findAll(session);
        }
    }

    @Override
    public RestaurantTable getTableById(Long id) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            RestaurantTable table = tableDAO.findById(session, id);
            if (table == null) {
                throw new BusinessException("Table not found with id: " + id);
            }
            return table;
        }
    }

    @Override
    public void reserveTable(Long tableId) {
        updateStatus(tableId, TableStatus.EMPTY, TableStatus.RESERVED, "Table must be EMPTY to be reserved.");
    }

    @Override
    public void cancelReservation(Long tableId) {
        updateStatus(tableId, TableStatus.RESERVED, TableStatus.EMPTY, "Table must be RESERVED to cancel reservation.");
    }

    @Override
    public void createOrder(Long tableId) {
        executeTransition(tableId, table -> {
            if (table.getStatus() != TableStatus.EMPTY && table.getStatus() != TableStatus.RESERVED) {
                throw new BusinessException(
                        "Order can only be created when table is EMPTY or RESERVED. Current status: "
                                + table.getStatus());
            }
            table.setStatus(TableStatus.OCCUPIED);
        });
    }

    @Override
    public void requestPayment(Long tableId) {
        updateStatus(tableId, TableStatus.OCCUPIED, TableStatus.WAITING_PAYMENT,
                "Table must be OCCUPIED to request payment.");
    }

    @Override
    public void payOrder(Long tableId) {
        updateStatus(tableId, TableStatus.WAITING_PAYMENT, TableStatus.DIRTY,
                "Table must be WAITING_PAYMENT to pay order.");
    }

    @Override
    public void cleanTable(Long tableId) {
        updateStatus(tableId, TableStatus.DIRTY, TableStatus.EMPTY, "Table must be DIRTY to be cleaned.");
    }

    @Override
    public void disableTable(Long tableId) {
        // Based on user prompt sequence: OCCUPIED -> disable -> DISABLED
        // Usually you can disable from EMPTY too, but I'll follow the prompt's implied
        // transition if strict.
        // However, a general disable usually works from EMPTY. I'll allow it from ANY
        // status just for robustness,
        // but the prompt says EMPTY -> ... -> OCCUPIED -> disable -> DISABLED.
        // I'll allow disabling from OCCUPIED as requested, but also EMPTY/DIRTY if it
        // makes sense.
        // Let's stick to the prompt's specific transitions.
        updateStatus(tableId, TableStatus.OCCUPIED, TableStatus.DISABLED,
                "Table must be OCCUPIED (or follow sequence) to be disabled.");
    }

    @Override
    public void enableTable(Long tableId) {
        updateStatus(tableId, TableStatus.DISABLED, TableStatus.EMPTY, "Table must be DISABLED to be enabled.");
    }

    private void updateStatus(Long tableId, TableStatus expected, TableStatus next, String errorMessage) {
        executeTransition(tableId, table -> {
            if (table.getStatus() != expected) {
                throw new BusinessException(errorMessage + " Current status: " + table.getStatus());
            }
            table.setStatus(next);
        });
    }

    private void executeTransition(Long tableId, java.util.function.Consumer<RestaurantTable> transition) {
        Session session = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = session.beginTransaction();
        try {
            RestaurantTable table = tableDAO.findById(session, tableId);
            if (table == null) {
                throw new BusinessException("Table not found with id: " + tableId);
            }
            transition.accept(table);
            tableDAO.update(session, table);
            tx.commit();
        } catch (BusinessException e) {
            tx.rollback();
            throw e;
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException("Database error: " + e.getMessage(), e);
        } finally {
            session.close();
        }
    }
}
