import { useBackend } from 'tgui/backend';
import { Button, Stack } from 'tgui-core/components';

/**
 * Save/Undo button stack used across the character creator.
 */
export const SaveUndo = (props) => {
  const { act } = useBackend();

  return (
    <>
      <Stack.Item>
        <Button icon="floppy-disk" fluid onClick={() => act('save')}>
          Save
        </Button>
      </Stack.Item>
      <Stack.Item>
        <Button icon="rotate-left" fluid onClick={() => act('load')}>
          Undo (Reload Slot)
        </Button>
      </Stack.Item>
    </>
  );
};
