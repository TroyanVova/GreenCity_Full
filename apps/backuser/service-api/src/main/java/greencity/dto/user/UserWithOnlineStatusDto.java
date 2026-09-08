package greencity.dto.user;

import jakarta.validation.constraints.NotNull;
import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@EqualsAndHashCode
@Builder
public class UserWithOnlineStatusDto {
    @NotNull
    private Long id;

    private boolean onlineStatus;
}
