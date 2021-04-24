import svgwrite
import cairosvg
import random
import copy
from svgpathtools import Path
from PIL import Image
from ImageHelper import ImageHelper


POPULATION_NUMBER = 50
ITERATION_NUMBER = 5000
IMAGE_SIZE = 512
ICON_SIZE = 16
POLYGONS_NUMBER_IN_ROW = IMAGE_SIZE // ICON_SIZE
CHUNK_SIZE = 2 + 4
NUM_OF_PARAMS = IMAGE_SIZE * IMAGE_SIZE * CHUNK_SIZE


# function to get all colors from initial image
# returns list of colors
def get_colors(pil_image):
    colors_tuple = pil_image.convert('RGBA').getcolors(maxcolors=1000000)
    colors = []
    for el in colors_tuple:
        for _ in range(el[0]):
            colors.append(el[1])
    sett = set(colors)
    return list(sett)


# function to replace random icon
# return list of data
def set_random(data):
    # create image by input data
    index = 0
    image = Image.new('RGBA', (512, 512), (255, 255, 255, 255))
    for q in range(IMAGE_SIZE):
        for w in range(IMAGE_SIZE):
            image.putpixel((data[index], data[index+1]), (data[index+2], data[index+3], data[index+4], data[index+5]))
            index += CHUNK_SIZE

    # choose random icon and replace it
    row = random.randint(0, POLYGONS_NUMBER_IN_ROW - 1) * ICON_SIZE
    column = random.randint(0, POLYGONS_NUMBER_IN_ROW - 1) * ICON_SIZE
    recolor_heart()
    heart = Image.open('./hearts/heart.png', 'r')
    image.paste(heart, (row, column))

    # convert image back to data and return it
    result = []
    for row in range(IMAGE_SIZE):
        for column in range(IMAGE_SIZE):
            r, g, b, a = image.getpixel((row, column))
            result.append(row)
            result.append(column)
            result.append(r)
            result.append(g)
            result.append(b)
            result.append(a)
    return result


# function to recolor heart
def recolor_heart():
    random_color = random.choice(colors_list)
    hex_color = rgb_to_hex(random_color[0], random_color[1], random_color[2])
    dwg = svgwrite.Drawing('heart.svg', viewBox=f'0 0 512 512', size=(f'{ICON_SIZE}', f'{ICON_SIZE}'), fill=hex_color)
    path = Path("M474.655,74.503C449.169,45.72,413.943,29.87,375.467,29.87c-30.225,0-58.5,12.299-81.767,35.566  c-15.522,15.523-28.33,35.26-37.699,57.931c-9.371-22.671-22.177-42.407-37.699-57.931c-23.267-23.267-51.542-35.566-81.767-35.566  c-38.477,0-73.702,15.851-99.188,44.634C13.612,101.305,0,137.911,0,174.936c0,44.458,13.452,88.335,39.981,130.418  c21.009,33.324,50.227,65.585,86.845,95.889c62.046,51.348,123.114,78.995,125.683,80.146c2.203,0.988,4.779,0.988,6.981,0  c2.57-1.151,63.637-28.798,125.683-80.146c36.618-30.304,65.836-62.565,86.845-95.889C498.548,263.271,512,219.394,512,174.936  C512,137.911,498.388,101.305,474.655,74.503z")
    dwg.add(dwg.path(path.d()))
    path = Path("M160.959,401.243c-36.618-30.304-65.836-62.565-86.845-95.889  c-26.529-42.083-39.981-85.961-39.981-130.418c0-37.025,13.612-73.631,37.345-100.433c21.44-24.213,49.775-39.271,81.138-43.443  c-5.286-0.786-10.653-1.189-16.082-1.189c-38.477,0-73.702,15.851-99.188,44.634C13.612,101.305,0,137.911,0,174.936  c0,44.458,13.452,88.335,39.981,130.418c21.009,33.324,50.227,65.585,86.845,95.889c62.046,51.348,123.114,78.995,125.683,80.146  c2.203,0.988,4.779,0.988,6.981,0c0.689-0.308,5.586-2.524,13.577-6.588C251.254,463.709,206.371,438.825,160.959,401.243z")
    dwg.add(dwg.path(path.d()))
    dwg.saveas('./hearts/heart.svg')

    cairosvg.svg2png(url="./hearts/heart.svg", write_to="./hearts/heart.png")


# rgb to hex format
def rgb_to_hex(r, g, b):
    return '#%02x%02x%02x' % (r, g, b)


imageTest = ImageHelper("out.png")
colors_list = get_colors(imageTest.input_image)
recolor_heart()
final_image = Image.new('RGBA', (512, 512), (255, 255, 255, 255))
img = Image.open('./hearts/heart.png', 'r')
img_w, img_h = img.size
final_image.paste(img, (0, 0))
i = 0
j = 0
# fill the picture with hearts
while i < 512:
    j = 0
    while j < 512:
        final_image.paste(img, (i, j))
        j += ICON_SIZE
    i += ICON_SIZE


# create populations
populations = []
for p in range(POPULATION_NUMBER):
    population = []
    for i in range(IMAGE_SIZE):
        for j in range(IMAGE_SIZE):
            r, g, b, a = final_image.getpixel((i, j))
            population.append(i)
            population.append(j)
            population.append(r)
            population.append(g)
            population.append(b)
            population.append(a)
    populations.append(population)

# main part
for i in range(ITERATION_NUMBER):  # for each iteration
    print(i, end=' ')

    m1 = 10 ** 8
    m2 = 10 ** 8
    m2_population = []
    m1_population = []
    for j in range(len(populations)):   # for each population
        # mutation
        # change populations randomly
        if j != 0 and j != len(populations) - 1:
            populations[j] = set_random(populations[j])
        # finding the two populations closest to the original (min fitness)
        # m1_population - top 1 fitness
        # m2_population - top 2 fitness
        qw = imageTest.get_diff(populations[j])
        if qw < m1:
            m2 = m1
            m1 = qw
            m2_population = copy.deepcopy(m1_population)
            m1_population = copy.deepcopy(populations[j])
        elif qw < m2:
            m2 = qw
            m2_population = copy.deepcopy(populations[j])

    # crossover
    new_populations = []
    for j in range(POPULATION_NUMBER):
        if j < POPULATION_NUMBER // 3:
            # add m1_population
            new_populations.append(m1_population)
        elif j < POPULATION_NUMBER // 1.5:
            # add m2_population
            new_populations.append(m2_population)
        else:
            # crossover m1_population and m2_population
            p1 = m1_population[0:CHUNK_SIZE * IMAGE_SIZE * IMAGE_SIZE // 2] + m2_population[CHUNK_SIZE * IMAGE_SIZE * IMAGE_SIZE // 2:IMAGE_SIZE * IMAGE_SIZE * POPULATION_NUMBER]
            new_populations.append(p1)

    populations = copy.deepcopy(new_populations)

    # just output every 50 iterations
    if i % 50 == 0:
        population = populations[0]
        imageTest.save_image(population, 'out-compare.png')
        cur_image = imageTest.polygon_data_to_image(population)
        plt = imageTest.plot_images(cur_image, i)
        plt.show()
        cur_image = cur_image.save("out.png")
        print()
        print(f'Iteration {i}, fitness: {imageTest.get_diff(population)}')
        print()
