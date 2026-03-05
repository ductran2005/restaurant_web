package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.CategoryDAO;
import market.restaurant_web.entity.Category;
import org.hibernate.Hibernate;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class CategoryService {
    private final CategoryDAO dao = new CategoryDAO();

    public List<Category> findAll() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            List<Category> list = dao.findAll(s, "categoryName");
            for (Category c : list)
                Hibernate.initialize(c.getProducts());
            return list;
        }
    }

    public List<Category> findActive() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.findActive(s);
        }
    }

    public Category findById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.findById(s, id);
        }
    }

    public List<Category> search(String keyword) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            List<Category> list = dao.search(s, keyword);
            for (Category c : list)
                Hibernate.initialize(c.getProducts());
            return list;
        }
    }

    public void save(Category category) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (category.getId() == null) {
                dao.save(s, category);
            } else {
                dao.update(s, category);
            }
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            s.close();
        }
    }

    /** Soft-delete: set status to INACTIVE */
    public void delete(int id) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Category c = dao.findById(s, id);
            if (c != null) {
                c.setStatus("INACTIVE");
                dao.update(s, c);
            }
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            s.close();
        }
    }
}
