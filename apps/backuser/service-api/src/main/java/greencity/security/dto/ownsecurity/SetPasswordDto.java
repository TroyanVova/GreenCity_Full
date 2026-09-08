package greencity.security.dto.ownsecurity;

import greencity.annotations.PasswordValidation;
import jakarta.validation.constraints.NotBlank;
import lombok.*;

@Getter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@EqualsAndHashCode
public class SetPasswordDto {
    @NotBlank
    @PasswordValidation
    private String password;

    @NotBlank
    @PasswordValidation
    private String confirmPassword;
}
