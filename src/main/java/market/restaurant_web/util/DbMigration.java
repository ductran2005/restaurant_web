package market.restaurant_web.util;

import market.restaurant_web.config.HibernateUtil;
import org.hibernate.Session;
import org.hibernate.Transaction;

public class DbMigration {
    public static void main(String[] args) {
        try (Session session = HibernateUtil.getSessionFactory().openSession()) {
            Transaction tx = session.beginTransaction();

            // Step 1: Drop the check constraint that restricts status values
            try {
                session.createNativeMutationQuery("ALTER TABLE tables DROP CONSTRAINT CK_tables_status")
                        .executeUpdate();
                System.out.println("Constraint CK_tables_status dropped.");
            } catch (Exception e) {
                System.out.println("Info: Constraint CK_tables_status not found or already dropped.");
            }

            // Step 2: Migrate old data to new status values
            session.createNativeMutationQuery("UPDATE tables SET status = 'EMPTY' WHERE status = 'AVAILABLE'")
                    .executeUpdate();
            session.createNativeMutationQuery("UPDATE tables SET status = 'OCCUPIED' WHERE status = 'IN_USE'")
                    .executeUpdate();

            tx.commit();
            System.out.println("Migration successful!");
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
