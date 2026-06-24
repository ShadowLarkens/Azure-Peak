import { ColorButton, ensureColorHash } from 'pm/components';
import type {
  Customizer,
  CustomizerChoice,
} from 'pm/tabs/CharacterCreator/data';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';

export interface HairCustomizer extends CustomizerChoice {
  hair_color: string;
  natural_color: string; // only display if natgrad != null && natgrad != "None"
  dye_color: string; // only display if dyegrad != null && dyegrad != "None"
  natgrad: string | null; // null indicates no gradient
  dyegrad: string | null; // null indicates no gradient
}

export const FeatureChoiceHair = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { hair_color, natural_color, dye_color, natgrad, dyegrad } =
    choices as HairCustomizer;

  return (
    <>
      <Stack.Item>
        <LabeledList>
          <LabeledList.Item label="Hair Color" verticalAlign="middle">
            <ColorButton
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'hair_color',
                })
              }
              backgroundColor={hair_color}
              tooltip={ensureColorHash(hair_color)}
            />
          </LabeledList.Item>
        </LabeledList>
      </Stack.Item>
      <Stack.Item style={{ borderBottom: '2px solid var(--color-border)' }}>
        Natural Gradient
      </Stack.Item>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item grow>
            {/* TODO: Preview */}
            <Button
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'natural_gradient',
                })
              }
              fluid
            >
              {natgrad}
            </Button>
          </Stack.Item>
          {natgrad !== null && natgrad !== 'None' ? (
            <Stack.Item>
              <ColorButton
                onClick={() =>
                  act('change_customizer', {
                    customizer: customizer.type,
                    customizer_task: 'natural_gradient_color',
                  })
                }
                backgroundColor={natural_color}
                tooltip={ensureColorHash(natural_color)}
              />
            </Stack.Item>
          ) : null}
        </Stack>
      </Stack.Item>
      <Stack.Item style={{ borderBottom: '2px solid var(--color-border)' }}>
        Dye Gradient
      </Stack.Item>
      <Stack.Item>
        <Stack align="center">
          <Stack.Item grow>
            {/* TODO: Preview */}
            <Button
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'dye_gradient',
                })
              }
              fluid
            >
              {dyegrad}
            </Button>
          </Stack.Item>
          {dyegrad !== null && dyegrad !== 'None' ? (
            <Stack.Item>
              <ColorButton
                onClick={() =>
                  act('change_customizer', {
                    customizer: customizer.type,
                    customizer_task: 'dye_gradient_color',
                  })
                }
                backgroundColor={dye_color}
                tooltip={ensureColorHash(dye_color)}
              />
            </Stack.Item>
          ) : null}
        </Stack>
      </Stack.Item>
    </>
  );
};
