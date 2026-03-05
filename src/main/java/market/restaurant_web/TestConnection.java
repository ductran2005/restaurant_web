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

            // chạy thử query
            Object result = session.createNativeQuery("SELECT DB_NAME()").getSingleResult();
            System.out.println("Database đang kết nối: " + result);

            // giữ connection 30s để SQL Server thấy
            Thread.sleep(30000);

            session.close();
            factory.close();

        } catch (Exception e) {
            System.out.println("Kết nối thất bại!");
            e.printStackTrace();
        }
    }
}