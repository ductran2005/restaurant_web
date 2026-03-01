package market.restaurant_web.entity;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "restaurant_tables")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class RestaurantTable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "table_id")
    private int tableId;

    @ManyToOne
    @JoinColumn(name = "area_id")
    private Area area;

    @Column(name = "table_name", nullable = false, length = 50)
    private String tableName;

    @Column(name = "capacity")
    private int capacity;

    @Column(name = "status", length = 50)
    private String status; // AVAILABLE, OCCUPIED, RESERVED
}
