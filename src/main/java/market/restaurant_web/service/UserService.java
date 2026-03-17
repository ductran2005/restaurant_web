package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.RoleDAO;
import market.restaurant_web.dao.UserDAO;
import market.restaurant_web.entity.Role;
import market.restaurant_web.entity.User;
import market.restaurant_web.util.PasswordUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;
import java.util.List;

public class UserService {
    private final UserDAO userDao = new UserDAO();
    private final RoleDAO roleDao = new RoleDAO();

    public List<User> findAll() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return userDao.findAll(s, "id");
        }
    }

    public User findById(int id) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return userDao.findById(s, id);
        }
    }

    public List<User> search(String keyword, Integer roleId) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return userDao.search(s, keyword, roleId);
        }
    }

    public List<Role> findAllRoles() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return roleDao.findAll(s);
        }
    }

    public void save(User user) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (user.getId() == null) {
                userDao.save(s, user);
            } else {
                userDao.update(s, user);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    public void create(String username, String fullName, String password, String phone, String email, int roleId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            if (userDao.findByUsername(s, username) != null) {
                throw new RuntimeException("Tên đăng nhập đã tồn tại");
            }
            Role role = roleDao.findById(s, roleId);
            User user = new User();
            user.setUsername(username);
            user.setFullName(fullName);
            user.setPasswordHash(PasswordUtil.hash(password));
            user.setPhone(phone);
            user.setEmail(email);
            user.setRole(role);
            user.setStatus("ACTIVE");
            userDao.save(s, user);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    public void toggleStatus(int userId) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            User u = userDao.findById(s, userId);
            if (u != null) {
                u.setStatus("ACTIVE".equals(u.getStatus()) ? "INACTIVE" : "ACTIVE");
                userDao.update(s, u);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    public void resetPassword(int userId, String newPassword) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            User u = userDao.findById(s, userId);
            if (u != null) {
                u.setPasswordHash(PasswordUtil.hash(newPassword));
                u.setFailedLoginCount(0);
                u.setLockedUntil(null);
                userDao.update(s, u);
            }
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }

    /**
     * Update user profile: fullName, email, phone, roleId, and optionally password.
     */
    public void update(int userId, String fullName, String email, String phone, int roleId, String newPassword) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            User u = userDao.findById(s, userId);
            if (u == null) {
                throw new RuntimeException("Người dùng không tồn tại");
            }
            u.setFullName(fullName);
            u.setEmail(email);
            u.setPhone(phone);

            Role role = roleDao.findById(s, roleId);
            if (role != null) {
                u.setRole(role);
            }

            // Only update password if a new one is provided
            if (newPassword != null && !newPassword.isBlank()) {
                u.setPasswordHash(PasswordUtil.hash(newPassword));
            }

            userDao.update(s, u);
            tx.commit();
        } catch (Exception e) {
            if (tx != null)
                tx.rollback();
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            s.close();
        }
    }
}
