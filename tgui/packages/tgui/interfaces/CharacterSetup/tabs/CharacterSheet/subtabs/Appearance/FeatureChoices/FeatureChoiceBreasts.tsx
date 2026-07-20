import type { Customizer, CustomizerChoice } from 'cs/tabs/CharacterSheet/data';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

export interface BreastsCustomizer extends CustomizerChoice {
  breast_size: string;
  lactating: BooleanLike;
}

export const FeatureChoiceBreasts = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { breast_size, lactating } = choices as BreastsCustomizer;
  return (
    <Stack.Item>
      <LabeledList>
        <LabeledList.Item label="Breast Size">
          <Button
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'breast_size',
              })
            }
            fluid
          >
            {breast_size}
          </Button>
        </LabeledList.Item>
        {/* TODO: Remove */}
        <LabeledList.Item label="Lactation">
          <Button
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'lactating',
              })
            }
            fluid
          >
            {lactating ? 'Enabled' : 'Disabled'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Stack.Item>
  );
};
