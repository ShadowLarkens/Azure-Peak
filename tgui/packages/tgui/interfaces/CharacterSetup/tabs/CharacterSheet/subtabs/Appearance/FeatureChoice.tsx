import { ColorButton, ensureColorHash } from 'cs/components/ColorButton';
import type { Customizer } from 'cs/tabs/CharacterSheet/data';
import { useBackend } from 'tgui/backend';
import { Button, LabeledList, Stack } from 'tgui-core/components';

export const FeatureChoice = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;

  return (
    <Stack vertical>
      {customizer.customizer_choices_enabled ? (
        <Stack.Item>
          <Button
            onClick={() =>
              act('change_customizer', {
                customizer: customizer.type,
                customizer_task: 'change_choice',
              })
            }
            fluid
          >
            {customizer.choices.name}
          </Button>
        </Stack.Item>
      ) : null}
      <FeatureChoiceAccessory customizer={customizer} />
      <FeatureChoiceSpecific customizer={customizer} />
    </Stack>
  );
};

const FeatureChoiceAccessory = (props: { customizer: Customizer }) => {
  const { customizer } = props;
  const { choices } = customizer;
  const { accessory } = choices;
  const { act } = useBackend();

  if (!accessory) {
    return null;
  }

  return (
    <>
      <Stack.Item>
        <Stack align="center">
          {/* TODO: Merk left/right buttons? */}
          <Stack.Item>
            <Button
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'rotate',
                  rotate: 'prev',
                })
              }
              icon="arrow-left"
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'rotate',
                  rotate: 'next',
                })
              }
              icon="arrow-right"
            />
          </Stack.Item>
          <Stack.Item grow>
            {/* TODO: Popup selection w/ preview */}
            <Button
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'choose_acc',
                })
              }
              fluid
            >
              {accessory.name}
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      {accessory.colors ? (
        <Stack.Item>
          <LabeledList>
            {accessory.colors.map((c) => (
              <LabeledList.Item
                key={c.index}
                label={c.name}
                verticalAlign="middle"
              >
                <ColorButton
                  onClick={() =>
                    act('change_customizer', {
                      customizer: customizer.type,
                      customizer_task: 'acc_color',
                      color_index: c.index,
                    })
                  }
                  backgroundColor={c.color}
                  tooltip={ensureColorHash(c.color)}
                />
              </LabeledList.Item>
            ))}
            {/* TODO: check this looks good */}
            <LabeledList.Item>
              <Button
                onClick={() => {
                  act('change_customizer', {
                    customizer: customizer.type,
                    customizer_task: 'reset_colors',
                  });
                }}
              >
                Reset Colors
              </Button>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
      ) : null}
    </>
  );
};

const requireFeatureChoice = require.context('./FeatureChoices');

const FeatureChoiceSpecific = (props: { customizer: Customizer }) => {
  const { customizer } = props;
  const { choices } = customizer;

  // almost wholesale ripped from routes.tsx
  const name = choices.template;
  const interfacePathBuilders = [
    (name: string) => `./${name}.tsx`,
    (name: string) => `./${name}.jsx`,
    (name: string) => `./${name}.js`,
    (name: string) => `./${name}/index.tsx`,
    (name: string) => `./${name}/index.jsx`,
    (name: string) => `./${name}/index.js`,
  ];

  let esModule;
  while (!esModule && interfacePathBuilders.length > 0) {
    const interfacePathBuilder = interfacePathBuilders.shift()!;
    const interfacePath = interfacePathBuilder(name);
    try {
      esModule = requireFeatureChoice(interfacePath);
    } catch (err) {
      if (err.code !== 'MODULE_NOT_FOUND') {
        throw err;
      }
    }
  }

  if (!esModule) {
    return null;
  }

  const Component = esModule[name];
  if (!Component) {
    return null;
  }

  return <Component customizer={customizer} />;
};
