package market.restaurant_web.service;

import market.restaurant_web.entity.RestaurantTable;
import java.util.List;

public interface TableManagementService {
    List<RestaurantTable> getAllTables();

    RestaurantTable getTableById(Long id);

    void reserveTable(Long tableId);

    void cancelReservation(Long tableId);

    void createOrder(Long tableId);

    void requestPayment(Long tableId);

    void payOrder(Long tableId);

    void cleanTable(Long tableId);

    void disableTable(Long tableId);

    void enableTable(Long tableId);
}
