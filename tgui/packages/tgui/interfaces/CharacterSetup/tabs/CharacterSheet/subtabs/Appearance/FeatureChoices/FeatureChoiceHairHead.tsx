import type { Customizer } from 'cs/tabs/CharacterSheet/data';
import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { FeatureChoiceHair, type HairCustomizer } from './FeatureChoiceHair';

export interface HairHeadCustomizer extends HairCustomizer {
  has_custom_hair: BooleanLike;
}

export const FeatureChoiceHairHead = (props: { customizer: Customizer }) => {
  const { act } = useBackend();
  const { customizer } = props;
  const { choices } = customizer;
  const { has_custom_hair } = choices as HairHeadCustomizer;

  return (
    <>
      {/* a little unusual but this is valid */}
      <FeatureChoiceHair {...props} />
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
