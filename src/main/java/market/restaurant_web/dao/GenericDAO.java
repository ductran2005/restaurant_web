package market.restaurant_web.dao;

import market.restaurant_web.config.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.util.List;

/**
 * Generic DAO providing common CRUD operations.
 * All methods receive a Session parameter for transaction control at service
 * layer.
 */
public abstract class GenericDAO<T> {

    private final Class<T> entityClass;

    protected GenericDAO(Class<T> entityClass) {
        this.entityClass = entityClass;
    }

    public Session openSession() {
        return HibernateUtil.getSessionFactory().openSession();
    }

    public T findById(Session session, Object id) {
        return session.get(entityClass, id);
    }

    public List<T> findAll(Session session) {
        Query<T> query = session.createQuery("FROM " + entityClass.getSimpleName(), entityClass);
        return query.list();
    }

    public List<T> findAll(Session session, String orderBy) {
        Query<T> query = session.createQuery(
                "FROM " + entityClass.getSimpleName() + " ORDER BY " + orderBy, entityClass);
        return query.list();
    }

    public List<T> findWithPagination(Session session, int page, int size) {
        Query<T> query = session.createQuery("FROM " + entityClass.getSimpleName(), entityClass);
        query.setFirstResult((page - 1) * size);
        query.setMaxResults(size);
        return query.list();
    }

    public long count(Session session) {
        Query<Long> query = session.createQuery(
                "SELECT COUNT(*) FROM " + entityClass.getSimpleName(), Long.class);
        return query.uniqueResult();
    }

    public void save(Session session, T entity) {
        session.persist(entity);
    }

    public T update(Session session, T entity) {
        return session.merge(entity);
    }

    public void delete(Session session, T entity) {
        session.remove(entity);
    }

    protected Class<T> getEntityClass() {
        return entityClass;
    }
}
