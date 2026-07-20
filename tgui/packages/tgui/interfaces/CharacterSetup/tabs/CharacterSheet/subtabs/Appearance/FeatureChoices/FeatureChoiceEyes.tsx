import { ColorButton } from 'cs/components';
import { ensureColorHash } from 'cs/components/ColorButton';
import type { Customizer, CustomizerChoice } from 'cs/tabs/CharacterSheet/data';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export interface EyeCustomizer extends CustomizerChoice {
  eye_color: string;
  allows_heterochromia: BooleanLike;
  heterochromia: BooleanLike; // only show if allows_heterochromia
  second_color: string; // only show if heterochromia
}
export const FeatureChoiceEyes = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { eye_color, allows_heterochromia, heterochromia, second_color } =
    choices as EyeCustomizer;

  return (
    <Stack.Item>
      <LabeledList>
        <LabeledList.Item label="Eye Color" verticalAlign="middle">
          <ColorButton
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'eye_color',
              })
            }
            backgroundColor={eye_color}
            tooltip={ensureColorHash(eye_color)}
          />
        </LabeledList.Item>
        {allows_heterochromia ? (
          <>
            <LabeledList.Item label="Heterochromia">
              <Button.Checkbox
                onClick={() =>
                  act('change_customizer', {
                    customizer: customizer.type,
                    customizer_task: 'heterochromia',
                  })
                }
                checked={heterochromia}
                selected={heterochromia}
              />
            </LabeledList.Item>
            {heterochromia ? (
              <LabeledList.Item label="Second Color" verticalAlign="middle">
                <ColorButton
                  onClick={() =>
                    act('change_customizer', {
                      customizer: customizer.type,
                      customizer_task: 'second_eye_color',
                    })
                  }
                  backgroundColor={second_color}
                  tooltip={ensureColorHash(second_color)}
                />
              </LabeledList.Item>
            ) : null}
          </>
        ) : null}
      </LabeledList>
    </Stack.Item>
  );
};
