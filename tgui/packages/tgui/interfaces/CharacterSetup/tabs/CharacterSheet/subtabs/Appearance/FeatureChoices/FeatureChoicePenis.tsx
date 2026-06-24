import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { Customizer, CustomizerChoice } from '../../../data';

export interface PenisCustomizer extends CustomizerChoice {
  penis_size: string;
  penis_functional: BooleanLike;
}
export const FeatureChoicePenis = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { penis_size, penis_functional } = choices as PenisCustomizer;

  return (
    <Stack.Item>
      <LabeledList>
        <LabeledList.Item label="Penis Size">
          <Button
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'penis_size',
              })
            }
            fluid
          >
            {penis_size}
          </Button>
        </LabeledList.Item>
        <LabeledList.Item label="Functional">
          <Button
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'functional',
              })
            }
            fluid
          >
            {penis_functional ? 'YES' : 'NO'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Stack.Item>
  );
};
