package market.restaurant_web.dao;

import market.restaurant_web.entity.Role;
import market.restaurant_web.utils.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.query.Query;

public class RoleDAO extends GenericDAO<Role> {
    public RoleDAO() {
        super(Role.class);
    }

    public Role findByRoleName(String roleName) {
        Session session = HibernateUtil.getSessionFactory().openSession();
        try {
            Query<Role> query = session.createQuery(
                    "FROM Role WHERE roleName = :roleName", Role.class);
            query.setParameter("roleName", roleName);
            return query.uniqueResult();
        } finally {
            session.close();
        }
    }
}
