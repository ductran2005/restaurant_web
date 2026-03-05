package market.restaurant_web.dao;

import market.restaurant_web.entity.User;
import org.hibernate.Session;
import org.hibernate.query.Query;
import java.util.List;

public class UserDAO extends GenericDAO<User> {

    public UserDAO() {
        super(User.class);
    }

    public User findByUsername(Session session, String username) {
        Query<User> q = session.createQuery(
                "FROM User WHERE username = :u", User.class);
        q.setParameter("u", username);
        return q.uniqueResult();
    }

    public List<User> findByRole(Session session, int roleId) {
        Query<User> q = session.createQuery(
                "FROM User WHERE role.id = :r ORDER BY id", User.class);
        q.setParameter("r", roleId);
        return q.list();
    }

    public List<User> search(Session session, String keyword, Integer roleId) {
        StringBuilder hql = new StringBuilder("FROM User WHERE 1=1");
        if (keyword != null && !keyword.isEmpty()) {
            hql.append(" AND (LOWER(fullName) LIKE :kw OR LOWER(username) LIKE :kw)");
        }
        if (roleId != null) {
            hql.append(" AND role.id = :roleId");
        }
        hql.append(" ORDER BY id");
        Query<User> q = session.createQuery(hql.toString(), User.class);
        if (keyword != null && !keyword.isEmpty()) {
            q.setParameter("kw", "%" + keyword.toLowerCase() + "%");
        }
        if (roleId != null) {
            q.setParameter("roleId", roleId);
        }
        return q.list();
    }
}
