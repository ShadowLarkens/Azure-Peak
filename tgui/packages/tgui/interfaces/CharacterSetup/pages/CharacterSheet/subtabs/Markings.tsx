import { useBackend } from 'tgui/backend';
import { Box, Button, Section, Stack } from 'tgui-core/components';

import { ColorButton } from '../../../components/ColorButton';
import { CharacterSheetData } from '../data';

export const SubtabMarkings = (props) => {
  const { act, data } = useBackend<CharacterSheetData>();
  const { markings } = data;

  return (
    <Section fill scrollable>
      <Stack vertical>
        <Stack.Item>
          <Stack justify="right">
            <Stack.Item>
              <Button onClick={() => act('marking_use_preset')}>
                Marking Presets
              </Button>
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
