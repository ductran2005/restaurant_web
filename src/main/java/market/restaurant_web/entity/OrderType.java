package market.restaurant_web.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "order_types")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class OrderType {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "order_type_id")
    private int orderTypeId;

    @Column(name = "type_name", nullable = false, length = 50)
    private String typeName; // DINE_IN, TAKEAWAY, DELIVERY
}
