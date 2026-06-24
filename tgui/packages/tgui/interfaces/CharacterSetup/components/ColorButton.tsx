import { Button } from 'tgui-core/components';

/**
 * This is a standardized {@link Button} that displays a full square of one color.
 */
export const ColorButton = (
  props: React.ComponentProps<typeof Button> & { backgroundColor: string },
) => {
  let { height, minWidth, fluid, color, backgroundColor, style } = props;

  if (height === undefined) {
    height = '100%';
  }

  if (minWidth === undefined) {
    minWidth = 2.1183; // calculated from margins + min-width of icon buttons
  }

  if (fluid === undefined) {
    fluid = true;
  }

  if (color === undefined) {
    color = 'transparent';
  }

  if (style === undefined) {
    style = {
      border: '1px solid #fff',
      outline: '1px solid var(--color-border)',
    };
  } else {
    style = {
      border: '1px solid #fff',
      outline: '1px solid var(--color-border)',
      ...style,
    };
  }

  return (
    <Button
      height={height}
      minWidth={minWidth}
      fluid={fluid}
      color={color}
      style={style}
      {...props}
    />
  );
};
