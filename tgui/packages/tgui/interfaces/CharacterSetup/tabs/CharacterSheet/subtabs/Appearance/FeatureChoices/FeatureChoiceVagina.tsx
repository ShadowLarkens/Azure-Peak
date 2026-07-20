import type { Customizer, CustomizerChoice } from 'cs/tabs/CharacterSheet/data';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export interface VaginaCustomizer extends CustomizerChoice {
  fertility: BooleanLike;
}

export const FeatureChoiceVagina = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { fertility } = choices as VaginaCustomizer;
  return (
    <Stack.Item>
      <LabeledList>
        <LabeledList.Item label="Fertility">
          <Button
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'fertile',
              })
            }
            fluid
          >
            {fertility ? 'Fertile' : 'Sterile'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Stack.Item>
  );
};
