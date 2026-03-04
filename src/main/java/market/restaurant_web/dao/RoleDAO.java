package market.restaurant_web.dao;

import market.restaurant_web.entity.Role;
import org.hibernate.Session;
import org.hibernate.query.Query;

public class RoleDao extends GenericDao<Role> {
    public RoleDao() {
        super(Role.class);
    }

    public Role findByName(Session session, String roleName) {
        Query<Role> q = session.createQuery("FROM Role WHERE roleName = :n", Role.class);
        q.setParameter("n", roleName);
        return q.uniqueResult();
    }
}
