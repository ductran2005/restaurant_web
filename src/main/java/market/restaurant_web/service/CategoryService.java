package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.CategoryDao;
import market.restaurant_web.entity.Category;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class CategoryService {
    private final CategoryDao dao = new CategoryDao();

    public List<Category> findAll() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.findAll(s, "categoryName");
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
            return dao.search(s, keyword);
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
