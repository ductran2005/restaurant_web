package market.restaurant_web;

import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;

public class TestConnection {

    public static void main(String[] args) {

        try {
            SessionFactory factory = new Configuration()
                    .configure() 
                    .buildSessionFactory();

            Session session = factory.openSession();

            System.out.println("Kết nối SQL thành công!");

            // chạy thử query - PostgreSQL syntax
            Object result = session.createNativeQuery("SELECT current_database()", String.class).getSingleResult();
            System.out.println("Database đang kết nối: " + result);

            // Kiểm tra version
            Object version = session.createNativeQuery("SELECT version()", String.class).getSingleResult();
            System.out.println("PostgreSQL version: " + version);

            // giữ connection 30s để kiểm tra
            Thread.sleep(30000);

            session.close();
            factory.close();

        } catch (Exception e) {
            System.out.println("Kết nối thất bại!");
            e.printStackTrace();
        }
    }
}