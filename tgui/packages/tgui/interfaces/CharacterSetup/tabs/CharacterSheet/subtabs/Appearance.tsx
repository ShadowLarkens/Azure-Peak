import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { CollapsibleShared } from '../../../components/CollapsibleShared';
import { ColorButton } from '../../../components/ColorButton';
import type { CharacterSheetData } from '../data';
import { FeatureChoice } from './Appearance/FeatureChoice';

export const SubtabAppearance = (props) => {
  return (
    <Section
      fill
      scrollable
      className="CharacterSetup__Section__NoChildPadding"
    >
      <Stack vertical>
        {Object.entries(TABS).map(([name, Body]) => (
          <Stack.Item key={name}>
            <CollapsibleShared
              title={name}
              stateKey={`charactersheet-appearance-collapsible-${name}`}
            >
              <Body />
            </CollapsibleShared>
          </Stack.Item>
        ))}
      </Stack>
    </Section>
  );
};

const SubtabAppearanceCardBody = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  console.log('SubtabAppearanceCardBody');

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Body Type">
          <Button onClick={() => act('bodytype')} fluid>
            {data.body_type}
          </Button>
        </LabeledList.Item>
        {data.use_skintones ? (
          <LabeledList.Item label={data.skin_tone_wording}>
            <Button onClick={() => act('s_tone')} fluid>
              Change
            </Button>
          </LabeledList.Item>
        ) : null}
        {data.use_mutcolor ? (
          <>
            <LabeledList.Item label="Mutant Color #1" verticalAlign="middle">
              <ColorButton
                onClick={() => act('mutant_color')}
                backgroundColor={`#${data.mcolor}`}
                tooltip={`#${data.mcolor}`}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Mutant Color #2" verticalAlign="middle">
              <ColorButton
                onClick={() => act('mutant_color2')}
                backgroundColor={`#${data.mcolor2}`}
                tooltip={`#${data.mcolor2}`}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Mutant Color #3" verticalAlign="middle">
              <ColorButton
                onClick={() => act('mutant_color3')}
                backgroundColor={`#${data.mcolor3}`}
                tooltip={`#${data.mcolor3}`}
              />
            </LabeledList.Item>
          </>
        ) : null}
        <LabeledList.Item label="Sprite Scale">
          <Button onClick={() => act('body_size')}>{data.body_size}%</Button>
        </LabeledList.Item>
        {data.allowed_taur_types.length ? (
          <LabeledList.Item label="Taur Body Type">
            {/* TODO: Preview Popup */}
            <Stack>
              <Stack.Item grow>
                <Button onClick={() => act('taur_type')} fluid>
                  {data.taur_name || 'None'}
                </Button>
              </Stack.Item>
              <Stack.Item>
                <ColorButton
                  onClick={() => act('taur_color')}
                  backgroundColor={`#${data.taur_color}`}
                  tooltip={`Taur Color: #${data.taur_color}`}
                />
              </Stack.Item>
            </Stack>
          </LabeledList.Item>
        ) : null}
      </LabeledList>
    </Section>
  );
};

const SubtabAppearanceCardFeatures = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const { customizers } = data;

  return (
    <Section>
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

// Markings
const SubtabAppearanceCardMarkings = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const { markings } = data;

  return (
    <Section>
      <Stack vertical>
        <Stack.Item>
          <Stack justify="right">
            <Stack.Item>
              <Button onClick={() => act('marking_use_preset')}>Presets</Button>
            </Stack.Item>
            <Stack.Item>
              <Button onClick={() => act('marking_reset_all_colors')}>
                Reset Colors
              </Button>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item>
          <Box className="CharacterSetup__MarkingsGrid">
            {markings.map((zone) => (
              <Section
                key={zone.zone}
                title={zone.name}
                style={{ overflow: 'hidden' }}
                buttons={
                  <Button
                    onClick={() => act('add_marking', { key: zone.zone })}
                    disabled={!zone.may_add}
                  >
                    Add
                  </Button>
                }
              >
                <Stack vertical>
                  {zone.keys ? (
                    zone.keys.map((marking) => (
                      <Stack.Item key={marking.key}>
                        <Stack>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('marking_move_up', {
                                  key: zone.zone,
                                  name: marking.key,
                                })
                              }
                              icon="arrow-up"
                              disabled={!marking.can_move_up}
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('marking_move_down', {
                                  key: zone.zone,
                                  name: marking.key,
                                })
                              }
                              icon="arrow-down"
                              disabled={!marking.can_move_down}
                            />
                          </Stack.Item>
                          <Stack.Item minWidth={0} grow>
                            <Button
                              onClick={() =>
                                act('change_marking', {
                                  key: zone.zone,
                                  name: marking.key,
                                })
                              }
                              ellipsis
                              fluid
                              tooltip={marking.key}
                            >
                              {marking.key}
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <ColorButton
                              onClick={() =>
                                act('marking_change_color', {
                                  key: zone.zone,
                                  name: marking.key,
                                })
                              }
                              backgroundColor={marking.color}
                              tooltip={marking.color}
                            />
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('marking_reset_color', {
                                  key: zone.zone,
                                  name: marking.key,
                                })
                              }
                              inline
                            >
                              R
                            </Button>
                          </Stack.Item>
                          <Stack.Item>
                            <Button
                              onClick={() =>
                                act('remove_marking', {
                                  key: zone.zone,
                                  name: marking.key,
                                })
                              }
                              inline
                              fluid
                              icon="x"
                            />
                          </Stack.Item>
                        </Stack>
                      </Stack.Item>
                    ))
                  ) : (
                    <Stack.Item italic>No markings selected.</Stack.Item>
                  )}
                </Stack>
              </Section>
            ))}
          </Box>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const TABS = {
  Body: SubtabAppearanceCardBody,
  Features: SubtabAppearanceCardFeatures,
  Markings: SubtabAppearanceCardMarkings,
};
