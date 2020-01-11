import xml.etree.ElementTree as ET

root = ET.parse("digits.svg").getroot()
canvas_height = root.attrib['height']

fills_dict = dict()

for tag in list(root):
    # Filter out tags without rounded corners (background fill)
    if 'rx' not in tag.attrib:
        continue

    # Get 'y'
    if 'y' in tag.attrib:
        y = tag.attrib['y']
    else:
        y = 0

    # Get x, height and fill
    x = tag.attrib['x']
    height = tag.attrib["height"]
    fill = tag.attrib['fill']

    # Bars of each digit have unique fill
    # Create dictionary. Each dict item is bars of one digit.
    if fill not in fills_dict:
        fills_dict[fill] = list()
    fills_dict[fill].append((x, y, height))

digit_index = 0
for key in fills_dict:

    # Find digit index (1234567890, 0 is the last one, special case)
    if digit_index + 1 == 10:
        digit_index = 0
    else:
        digit_index = digit_index + 1

    print("final List<DisplayBar> _digit_%s = [" % digit_index)

    sorted_tuples = sorted(fills_dict[key], key=lambda x: x[0])

    index = -1
    last_x = None

    for bar_tuple in sorted_tuples:
        y = bar_tuple[1]
        height = bar_tuple[2]

        if bar_tuple[0] != last_x:
            last_x = bar_tuple[0]
            index = index + 1

        if y == 0:
            # Top bar
            print("    DisplayBar(barNumber: %s, startY: %s, endY: %s / %s)," %
                  (index, y, height, canvas_height))
        else:
            # Bottom annd Inner bar
            print("    DisplayBar(barNumber: %s, startY: %s / %s, endY: (%s + %s) / %s)," %
                  (index, y, canvas_height, y, height, canvas_height))

    print("];")
    print()
