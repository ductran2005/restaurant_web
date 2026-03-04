package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.*;
import market.restaurant_web.entity.*;
import market.restaurant_web.util.PasswordUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class AuthService {
    private final UserDao userDao = new UserDao();
    private final RoleDao roleDao = new RoleDao();

    /**
     * Login by username + password.
     * Returns User entity if success, null if fail.
     * Checks status='ACTIVE' instead of old isActive boolean.
     */
    public User login(String username, String password) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            User user = userDao.findByUsername(session, username);
            if (user == null)
                return null;
            if (!user.isActive())
                return null;
            // Check if account is locked
            if (user.getLockedUntil() != null
                    && user.getLockedUntil().isAfter(java.time.LocalDateTime.now())) {
                return null;
            }
            if (!PasswordUtil.verify(password, user.getPasswordHash()))
                return null;
            return user;
        }
    }

    /**
     * Register a new staff/user.
     * DB no longer has permissions/role_permissions tables,
     * so no permission codes loading here.
     */
    public User register(String username, String fullName, String password, String roleName) {
        Session session = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = null;
        try {
            tx = session.beginTransaction();

            // Check username unique
            if (userDao.findByUsername(session, username) != null) {
                throw new RuntimeException("Tên đăng nhập đã được sử dụng");
            }

            Role role = roleDao.findByName(session, roleName != null ? roleName : "STAFF");
            User user = new User();
            user.setUsername(username);
            user.setFullName(fullName);
            user.setPasswordHash(PasswordUtil.hash(password));
            user.setRole(role);
            user.setStatus("ACTIVE");
            userDao.save(session, user);

            tx.commit();
            return user;
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            session.close();
        }
    }

    /**
     * Get role-based home URL for redirect after login.
     */
    public static String getHomeUrl(String roleName) {
        return switch (roleName) {
            case "ADMIN" -> "/admin";
            case "STAFF" -> "/staff";
            case "CASHIER" -> "/cashier";
            default -> "/";
        };
    }
}
