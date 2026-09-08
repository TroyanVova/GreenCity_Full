package greencity.dto.user;

import greencity.enums.Role;
import jakarta.validation.constraints.NotNull;
import lombok.*;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@EqualsAndHashCode
public class UserRoleDto {
    @NotNull
    private Long id;

    @NotNull
    private Role role;
}
