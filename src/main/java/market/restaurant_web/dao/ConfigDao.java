package market.restaurant_web.dao;

import market.restaurant_web.entity.SystemConfig;
import org.hibernate.Session;
import java.util.List;

public class ConfigDao {

    public SystemConfig findByKey(Session s, String key) {
        return s.get(SystemConfig.class, key);
    }

    public List<SystemConfig> findAll(Session s) {
        return s.createQuery("FROM SystemConfig ORDER BY configKey", SystemConfig.class).list();
    }

    public void saveOrUpdate(Session s, SystemConfig cfg) {
        s.merge(cfg);
    }
}
