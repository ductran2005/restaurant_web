package market.restaurant_web.service;

import market.restaurant_web.config.HibernateUtil;
import market.restaurant_web.dao.ConfigDao;
import market.restaurant_web.entity.SystemConfig;
import org.hibernate.Session;
import org.hibernate.Transaction;

import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

public class ConfigService {
    private final ConfigDao configDao = new ConfigDao();

    public List<SystemConfig> findAll() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return configDao.findAll(s);
        }
    }

    public String getValue(String key) {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            SystemConfig cfg = configDao.findByKey(s, key);
            return cfg != null ? cfg.getConfigValue() : null;
        }
    }

    public Map<String, String> getAllAsMap() {
        try (Session s = HibernateUtil.getSessionFactory().openSession()) {
            return configDao.findAll(s).stream()
                    .collect(Collectors.toMap(SystemConfig::getConfigKey, SystemConfig::getConfigValue));
        }
    }

    public void update(String key, String value) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            SystemConfig cfg = configDao.findByKey(s, key);
            if (cfg != null) {
                cfg.setConfigValue(value);
                configDao.saveOrUpdate(s, cfg);
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

    public void updateAll(Map<String, String> configs) {
        Session s = HibernateUtil.getSessionFactory().openSession();
        Transaction tx = s.beginTransaction();
        try {
            for (Map.Entry<String, String> entry : configs.entrySet()) {
                SystemConfig cfg = configDao.findByKey(s, entry.getKey());
                if (cfg != null) {
                    cfg.setConfigValue(entry.getValue());
                    configDao.saveOrUpdate(s, cfg);
                }
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
}
