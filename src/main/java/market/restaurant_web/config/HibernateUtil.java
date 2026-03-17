package market.restaurant_web.config;

import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public class HibernateUtil {
    private static final SessionFactory sessionFactory;

    static {
        try {
            Configuration configuration = new Configuration().configure("hibernate.cfg.xml");
            
            // Override with environment variables if present (for Docker)
            String dbHost = System.getenv("DB_HOST");
            String dbPort = System.getenv("DB_PORT");
            String dbName = System.getenv("DB_NAME");
            String dbUser = System.getenv("DB_USER");
            String dbPassword = System.getenv("DB_PASSWORD");
            
            if (dbHost != null && dbPort != null && dbName != null) {
                String jdbcUrl = String.format(
                    "jdbc:postgresql://%s:%s/%s?sslmode=require&prepareThreshold=0",
                    dbHost, dbPort, dbName
                );
                configuration.setProperty("hibernate.connection.url", jdbcUrl);
                System.out.println("Using database from environment: " + jdbcUrl);
            }
            
            if (dbUser != null) {
                configuration.setProperty("hibernate.connection.username", dbUser);
            }
            
            if (dbPassword != null) {
                configuration.setProperty("hibernate.connection.password", dbPassword);
            }
            
            sessionFactory = configuration.buildSessionFactory();
        } catch (Throwable ex) {
            System.err.println("SessionFactory creation failed: " + ex);
            throw new ExceptionInInitializerError(ex);
        }
    }

    private HibernateUtil() {
    }

    public static SessionFactory getSessionFactory() {
        return sessionFactory;
    }

    public static void shutdown() {
        if (sessionFactory != null && !sessionFactory.isClosed()) {
            sessionFactory.close();
        }
    }
}
