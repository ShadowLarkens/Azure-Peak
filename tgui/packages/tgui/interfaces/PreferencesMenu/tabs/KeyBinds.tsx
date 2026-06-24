import { LoadingScreen } from 'interfaces/common/LoadingScreen';
import { type ConstantData, useConstantPrefs } from 'pm/constant_data';
import type { KeyBind, KeybindsPageData } from 'pm/data';
import { useBackend } from 'tgui/backend';
import { Box, Button, LabeledList, Section } from 'tgui-core/components';

export const KeyBinds = (props) => {
  const { act, data } = useBackend<KeybindsPageData>();
  const { keybindings } = data;

  const [constantData] = useConstantPrefs();

  if (!constantData) {
    return (
      <Section fill scrollable>
        <LoadingScreen />
      </Section>
    );
  }

  return (
    <Section title="Keybinds" scrollable fill>
      <LabeledList>
        {keybindings.map((kb) => (
          <Keybind key={kb.name} kb={kb} constantData={constantData} />
        ))}
      </LabeledList>
      <Button color="bad" onClick={() => act('keybindings_reset')}>
        [Reset to default]
      </Button>
    </Section>
  );
};

const Keybind = (props: { kb: KeyBind; constantData: ConstantData }) => {
  const { act } = useBackend();
  const { kb, constantData } = props;

  return (
    <LabeledList.Item label={kb.full_name}>
      {kb.user_binds?.length ? (
        kb.user_binds.map((binding, idx) => (
          <Button
            key={idx}
            inline
            onClick={() =>
              // TODO: can we do this in the menu itself?
              act('keybindings_capture', {
                keybinding: kb.name,
                old_key: binding,
              })
            }
          >
            {binding}
          </Button>
        ))
      ) : (
        <Button
          inline
          onClick={() =>
            act('keybindings_capture', {
              keybinding: kb.name,
              old_key: 'Unbound',
            })
          }
        >
          Unbound
        </Button>
      )}
      {/* only show if it's not unbound */}
      {(kb.user_binds?.length || constantData.MAX_KEYS_PER_KEYBIND) <
      constantData.MAX_KEYS_PER_KEYBIND ? (
        <Button
          inline
          onClick={() => act('keybindings_capture', { keybinding: kb.name })}
        >
          Add Secondary
        </Button>
      ) : null}
      {kb.default_keys?.length ? (
        <Box inline>
          Default:&nbsp;
          {kb.default_keys.join(',')}
        </Box>
      ) : null}
    </LabeledList.Item>
  );
};
