import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import type { Customizer, CustomizerChoice } from '../../../data';

export interface TesticleCustomizer extends CustomizerChoice {
  can_customize_size: BooleanLike;
  ball_size: string;
  virile: BooleanLike;
}

export const FeatureChoiceTesticles = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { can_customize_size, ball_size, virile } =
    choices as TesticleCustomizer;

  return (
    <Stack.Item>
      <LabeledList>
        {can_customize_size ? (
          <LabeledList.Item label="Ball Size">
            <Button
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'ball_size',
                })
              }
              fluid
            >
              {ball_size}
            </Button>
          </LabeledList.Item>
        ) : null}
        <LabeledList.Item label="Virile">
          <Button
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'virile',
              })
            }
            fluid
          >
            {virile ? 'Virile' : 'Sterile'}
          </Button>
        </LabeledList.Item>
      </LabeledList>
    </Stack.Item>
  );
};
