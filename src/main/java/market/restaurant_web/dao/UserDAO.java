package market.restaurant_web.dao;

import market.restaurant_web.entity.User;
import market.restaurant_web.utils.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.query.Query;

import java.util.List;

public class UserDAO extends GenericDAO<User> {
    public UserDAO() {
        super(User.class);
    }

    public User findByUsername(String username) {
        Session session = HibernateUtil.getSessionFactory().openSession();
        try {
            Query<User> query = session.createQuery(
                    "FROM User WHERE username = :username", User.class);
            query.setParameter("username", username);
            return query.uniqueResult();
        } finally {
            session.close();
        }
    }

    public User findByEmail(String email) {
        Session session = HibernateUtil.getSessionFactory().openSession();
        try {
            Query<User> query = session.createQuery(
                    "FROM User WHERE email = :email", User.class);
            query.setParameter("email", email);
            return query.uniqueResult();
        } finally {
            session.close();
        }
    }

    public List<User> findByRole(int roleId) {
        return findByQuery("FROM User WHERE role.roleId = :roleId", "roleId", roleId);
    }

    public List<User> findByStatus(String status) {
        return findByQuery("FROM User WHERE status = :status", "status", status);
    }
}
