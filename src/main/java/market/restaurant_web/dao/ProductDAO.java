package market.restaurant_web.dao;

import market.restaurant_web.entity.Product;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.util.List;

public class ProductDAO extends GenericDAO<Product> {
    public ProductDAO() {
        super(Product.class);
    }

    public List<Product> findByCategory(Session session, int categoryId) {
        Query<Product> q = session.createQuery(
                "FROM Product WHERE category.id = :cid ORDER BY productName", Product.class);
        q.setParameter("cid", categoryId);
        return q.list();
    }

    public List<Product> findAvailableByCategory(Session session, int categoryId) {
        Query<Product> q = session.createQuery(
                "FROM Product WHERE category.id = :cid AND status = 'AVAILABLE' ORDER BY productName", Product.class);
        q.setParameter("cid", categoryId);
        return q.list();
    }

    public List<Product> findAvailable(Session session) {
        return session.createQuery(
                "FROM Product WHERE status = 'AVAILABLE' ORDER BY category.categoryName, productName",
                Product.class).list();
    }

    public List<Product> search(Session session, String keyword, Integer categoryId) {
        StringBuilder hql = new StringBuilder("FROM Product WHERE 1=1");
        if (keyword != null && !keyword.isEmpty()) {
            hql.append(" AND LOWER(productName) LIKE :kw");
        }
        if (categoryId != null) {
            hql.append(" AND category.id = :cid");
        }
        hql.append(" ORDER BY productName");
        Query<Product> q = session.createQuery(hql.toString(), Product.class);
        if (keyword != null && !keyword.isEmpty()) {
            q.setParameter("kw", "%" + keyword.toLowerCase() + "%");
        }
        if (categoryId != null) {
            q.setParameter("cid", categoryId);
        }
        return q.list();
    }
}
