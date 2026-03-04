package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.ProductDao;
import market.restaurant_web.entity.Product;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class ProductService {
    private final ProductDao dao = new ProductDao();

    public List<Product> findAll() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.findAll(s, "productName");
        }
    }

    public List<Product> findAvailable() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.findAvailable(s);
        }
    }

    public Product findById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.findById(s, id);
        }
    }

    public List<Product> search(String keyword, Integer categoryId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.search(s, keyword, categoryId);
        }
    }

    public List<Product> findByCategory(int categoryId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return dao.findByCategory(s, categoryId);
        }
    }

    public void save(Product product) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (product.getId() == null) {
                dao.save(s, product);
            } else {
                dao.update(s, product);
            }
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            s.close();
        }
    }

    /** Soft-delete: set status to UNAVAILABLE */
    public void delete(int id) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Product p = dao.findById(s, id);
            if (p != null) {
                p.setStatus("UNAVAILABLE");
                dao.update(s, p);
            }
            tx.commit();
        } catch (Exception e) {
            tx.rollback();
            throw new RuntimeException(e);
        } finally {
            s.close();
        }
    }

    /** Toggle status between AVAILABLE and UNAVAILABLE */
    public void toggleStatus(int productId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            Product p = dao.findById(s, productId);
            if (p != null) {
                p.setStatus("AVAILABLE".equals(p.getStatus()) ? "UNAVAILABLE" : "AVAILABLE");
                dao.update(s, p);
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
