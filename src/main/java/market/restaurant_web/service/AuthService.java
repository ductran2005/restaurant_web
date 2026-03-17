package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.UserDAO;
import market.restaurant_web.entity.User;
import market.restaurant_web.util.PasswordUtil;
import org.hibernate.Session;

public class AuthService {
    private final UserDAO userDao = new UserDAO();

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
     * Get role-based home URL for redirect after login.
     * Supports ADMIN, STAFF, CASHIER, CUSTOMER.
     */
    public static String getHomeUrl(String roleName) {
        if (roleName == null) {
            return "/";
        }
        return switch (roleName.toUpperCase()) {
            case "ADMIN" -> "/admin";
            case "STAFF" -> "/staff";
            case "CASHIER" -> "/cashier";
            case "CUSTOMER" -> "/user/home";
            default -> "/";
        };
    }
}
