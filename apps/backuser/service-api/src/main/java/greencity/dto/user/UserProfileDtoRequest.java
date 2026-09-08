package greencity.dto.user;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.NoArgsConstructor;
import lombok.Getter;
import lombok.Setter;
import lombok.EqualsAndHashCode;
import lombok.Builder;

@AllArgsConstructor
@NoArgsConstructor
@Getter
@Setter
@EqualsAndHashCode
@Builder
public class UserProfileDtoRequest {
    @Size(min = 1, max = 30, message = "name must have no less than 1 and no more than 30 symbols")
    @Pattern(regexp = "^(?!\\.)(?!.*\\.$)(?!.*?\\.\\.)(?!.*?\\-\\-)(?!.*?\\'\\')[-'ʼ ґҐіІєЄїЇА-Яа-я+\\w.]{1,30}$",
        message = "name must contain only \"ЁёІіЇїҐґЄєА-Яа-яA-Za-z-'0-9 .\", dot can only be in the center of the name")
    private String name;
    @Size(min = 1, max = 85)
    @Pattern(regexp = "[ЁёІіЇїҐґЄєА-Яа-яA-Za-z-'\\s)(!,]{1,85}")
    private String city;
    @Size(max = 170)
    private String userCredo;
    private Boolean showLocation;
    private Boolean showEcoPlace;
    private Boolean showShoppingList;
}
