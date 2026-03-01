package market.restaurant_web.dao;

import market.restaurant_web.utils.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;
import org.hibernate.query.Query;

import java.util.List;

/**
 * Generic DAO cung cấp các thao tác CRUD cơ bản dùng Hibernate.
 * 
 * @param <T> Kiểu entity
 */
public class GenericDAO<T> {

    private final Class<T> entityClass;

    public GenericDAO(Class<T> entityClass) {
        this.entityClass = entityClass;
    }

    protected Session getSession() {
        return HibernateUtil.getSessionFactory().openSession();
    }

    // ====== GET BY ID ======
    public T getById(int id) {
        try (Session session = getSession()) {
            return session.get(entityClass, id);
        }
    }

    // ====== GET ALL ======
    public List<T> getAll() {
        try (Session session = getSession()) {
            Query<T> query = session.createQuery("FROM " + entityClass.getSimpleName(), entityClass);
            return query.list();
        }
    }

    // ====== INSERT ======
    public void insert(T entity) {
        Transaction tx = null;
        try (Session session = getSession()) {
            tx = session.beginTransaction();
            session.persist(entity);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw e;
        }
    }

    // ====== UPDATE ======
    public void update(T entity) {
        Transaction tx = null;
        try (Session session = getSession()) {
            tx = session.beginTransaction();
            session.merge(entity);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw e;
        }
    }

    // ====== DELETE ======
    public void delete(T entity) {
        Transaction tx = null;
        try (Session session = getSession()) {
            tx = session.beginTransaction();
            session.remove(session.merge(entity));
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw e;
        }
    }

    // ====== DELETE BY ID ======
    public void deleteById(int id) {
        T entity = getById(id);
        if (entity != null) {
            delete(entity);
        }
    }

    // ====== FIND BY QUERY ======
    protected List<T> findByQuery(String hql, String paramName, Object paramValue) {
        try (Session session = getSession()) {
            Query<T> query = session.createQuery(hql, entityClass);
            query.setParameter(paramName, paramValue);
            return query.getResultList();
        }
    }

    // ====== COUNT ======
    public long count() {
        try (Session session = getSession()) {
            Query<Long> query = session.createQuery(
                    "SELECT COUNT(*) FROM " + entityClass.getSimpleName(), Long.class);
            return query.getSingleResult();
        }
    }
}
