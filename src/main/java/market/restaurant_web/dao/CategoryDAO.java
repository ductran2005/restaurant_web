package market.restaurant_web.dao;

import market.restaurant_web.entity.Category;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.util.List;

public class CategoryDao extends GenericDao<Category> {
    public CategoryDao() {
        super(Category.class);
    }

    public List<Category> findActive(Session session) {
        return session.createQuery(
                "FROM Category WHERE status = 'ACTIVE' ORDER BY categoryName", Category.class).list();
    }

    public List<Category> search(Session session, String keyword) {
        Query<Category> q = session.createQuery(
                "FROM Category WHERE LOWER(categoryName) LIKE :kw ORDER BY categoryName", Category.class);
        q.setParameter("kw", "%" + keyword.toLowerCase() + "%");
        return q.list();
    }
}
