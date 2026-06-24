import type { Color } from 'pm/data';
import { Button } from 'tgui-core/components';

// have to do this because asaycolor sometimes but only sometimes has the hash
export const ensureColorHash = (text: Color) => {
  if (!text.startsWith('#')) {
    return `#${text}`;
  }
  return text;
};

/**
 * This is a standardized {@link Button} that displays a full square of one color.
 */
export const ColorButton = (
  props: React.ComponentProps<typeof Button> & { backgroundColor: Color },
) => {
  let {
    height,
    minWidth,
    fluid,
    color,
    icon,
    style,
    backgroundColor,
    ...rest
  } = props;

  backgroundColor = ensureColorHash(backgroundColor);

  if (height === undefined) {
    height = '100%';
  }

  if (fluid === undefined) {
    fluid = true;
  }

  if (color === undefined) {
    color = 'transparent';
  }

  // this forces it to be the right width
  if (icon === undefined) {
    icon = 'square';
  }

  if (style === undefined) {
    style = {
      border: '1px solid #fff',
      outline: '1px solid var(--color-border)',
      color: backgroundColor,
    };
  } else {
    style = {
      border: '1px solid #fff',
      outline: '1px solid var(--color-border)',
      color: backgroundColor,
      ...style,
    };
  }

  return (
    <Button
      height={height}
      minWidth={minWidth}
      fluid={fluid}
      color={color}
      icon={icon}
      backgroundColor={backgroundColor}
      style={style}
      {...rest}
    />
  );
};
