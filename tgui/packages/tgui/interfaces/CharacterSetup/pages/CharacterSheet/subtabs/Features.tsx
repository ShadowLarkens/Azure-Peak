import { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { ColorButton } from '../../../components/ColorButton';
import { CharacterSheetData, Customizer, CustomizerChoice } from '../data';

export const SubtabFeatures = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();

  let customizers = data.customizers;

  return (
    <Section fill scrollable>
      <Box className="CharacterSetup__FeaturesGrid">
        {customizers.map((c) => (
          <Section
            key={c.name}
            title={c.name}
            buttons={
              <Button.Checkbox
                onClick={() =>
                  act('change_customizer', {
                    customizer: c.type,
                    customizer_task: 'toggle_missing',
                  })
                }
                checked={!c.disabled}
                selected={!c.disabled}
                inline
                style={
                  c.allows_disabling
                    ? undefined
                    : {
                        visibility: 'hidden',
                      }
                }
              />
            }
          >
            {c.disabled ? (
              <Box>Disabled</Box>
            ) : (
              <FeatureChoice customizer={c} />
            )}
          </Section>
        ))}
      </Box>
    </Section>
  );
};

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
                tooltip={c.color}
              />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
    </>
  );
};

export let FEATURE_CHOICE_LIST: Record<
  string,
  (customizer: Customizer) => ReactNode
> = {};

// INSTRUCTIONS FOR DOWNSTREAM: Add the following snippet in a nearby file
// interface NewCustomizer extends CustomizerChoice { ... }
// const FeatureChoiceNew = (choice: NewCustomizer) => { ... }
// FEATURE_CHOICE_LIST["FeatureChoiceNew"] = FeatureChoiceNew;

const FeatureChoiceSpecific = (props: { customizer: Customizer }) => {
  const { customizer } = props;
  const { choices } = customizer;
  let template = FEATURE_CHOICE_LIST[choices.template];

  if (template) {
    return template(customizer);
  } else {
    return null;
  }
};

interface HairCustomizer extends CustomizerChoice {
  hair_color: string;
  natural_color: string; // only display if natgrad != null && natgrad != "None"
  dye_color: string; // only display if dyegrad != null && dyegrad != "None"
  natgrad: string | null; // null indicates no gradient
  dyegrad: string | null; // null indicates no gradient
}
const FeatureChoiceHair = (customizer: Customizer) => {
  const { act } = useBackend();
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
              tooltip={hair_color}
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
                tooltip={natural_color}
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
                tooltip={dye_color}
              />
            </Stack.Item>
          ) : null}
        </Stack>
      </Stack.Item>
    </>
  );
};
FEATURE_CHOICE_LIST['FeatureChoiceHair'] = FeatureChoiceHair;

interface HairHeadCustomizer extends HairCustomizer {
  has_custom_hair: BooleanLike;
}
const FeatureChoiceHairHead = (customizer: Customizer) => {
  const { act } = useBackend();
  const { choices } = customizer;
  const { has_custom_hair } = choices as HairHeadCustomizer;

  return (
    <>
      {/* a little unusual but this is valid */}
      {FEATURE_CHOICE_LIST['FeatureChoiceHair'](customizer)}
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'custom_hair_editor',
                })
              }
              fluid
            >
              Customize Hair
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button
              disabled={!has_custom_hair}
              onClick={() =>
                act('change_customizer', {
                  customizer: customizer.type,
                  customizer_task: 'custom_hair_clear',
                })
              }
            >
              Clear
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </>
  );
};
FEATURE_CHOICE_LIST['FeatureChoiceHairHead'] = FeatureChoiceHairHead;

interface EyeCustomizer extends CustomizerChoice {
  eye_color: string;
  allows_heterochromia: BooleanLike;
  heterochromia: BooleanLike; // only show if allows_heterochromia
  second_color: string; // only show if heterochromia
}
const FeatureChoiceEyes = (customizer: Customizer) => {
  const { act } = useBackend();
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
            tooltip={eye_color}
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
                  tooltip={second_color}
                />
              </LabeledList.Item>
            ) : null}
          </>
        ) : null}
      </LabeledList>
    </Stack.Item>
  );
};
FEATURE_CHOICE_LIST['FeatureChoiceEyes'] = FeatureChoiceEyes;

interface PenisCustomizer extends CustomizerChoice {
  penis_size: string;
  penis_functional: BooleanLike;
}
const FeatureChoicePenis = (customizer: Customizer) => {
  const { act } = useBackend();
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
FEATURE_CHOICE_LIST['FeatureChoicePenis'] = FeatureChoicePenis;

interface TesticleCustomizer extends CustomizerChoice {
  can_customize_size: BooleanLike;
  ball_size: string;
  virile: BooleanLike;
}
const FeatureChoiceTesticles = (customizer: Customizer) => {
  const { act } = useBackend();
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
FEATURE_CHOICE_LIST['FeatureChoiceTesticles'] = FeatureChoiceTesticles;

interface BreastsCustomizer extends CustomizerChoice {
  breast_size: string;
  lactating: BooleanLike;
}
const FeatureChoiceBreasts = (customizer: Customizer) => {
  const { act } = useBackend();
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
FEATURE_CHOICE_LIST['FeatureChoiceBreasts'] = FeatureChoiceBreasts;

interface VaginaCustomizer extends CustomizerChoice {
  fertility: BooleanLike;
}
const FeatureChoiceVagina = (customizer: Customizer) => {
  const { act } = useBackend();
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
FEATURE_CHOICE_LIST['FeatureChoiceVagina'] = FeatureChoiceVagina;
