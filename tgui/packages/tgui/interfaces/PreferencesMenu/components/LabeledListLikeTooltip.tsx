import type { ComponentProps } from 'react';
import { Box, Tooltip } from 'tgui-core/components';

type LabeledListLikeTooltipProps = {
  tooltip: ComponentProps<typeof Tooltip>['content'];
  tooltipPosition?: ComponentProps<typeof Tooltip>['position'];
} & ComponentProps<typeof Box>;

export const LabeledListLikeTooltip = (props: LabeledListLikeTooltipProps) => {
  const { tooltip, tooltipPosition, children, ...boxProps } = props;

  return (
    <Tooltip content={tooltip} position={tooltipPosition}>
      <Box
        {...boxProps}
        as="span"
        style={{
          borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
        }}
      >
        {children}
      </Box>
    </Tooltip>
  );
};
