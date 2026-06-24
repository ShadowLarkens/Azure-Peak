import type {
  Customizer,
  CustomizerChoice,
} from 'pm/tabs/CharacterCreator/data';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';

export interface BreastsCustomizer extends CustomizerChoice {
  breast_size: string;
}

export const FeatureChoiceBreasts = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { breast_size } = choices as BreastsCustomizer;
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
      </LabeledList>
    </Stack.Item>
  );
};
