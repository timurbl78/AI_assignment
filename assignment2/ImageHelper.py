import cv2
import numpy as np
import matplotlib.pyplot as plt
from PIL import Image


class ImageHelper:
    def __init__(self, path):
        self.input_image = Image.open(path)

        self.width, self.height = self.input_image.size
        self.pixels_number = self.width * self.height
        self.input_image_cv2 = self.to_cv2(self.input_image)

    def polygon_data_to_image(self, polygon_data):
        # transfer data to pil image
        image = Image.new('RGB', (self.width, self.height))

        for i in range(self.pixels_number):
            index = i * (2 + 4)

            x = polygon_data[index]
            y = polygon_data[index+1]
            index += 2

            red = polygon_data[index]
            green = polygon_data[index + 1]
            blue = polygon_data[index + 2]
            alpha = polygon_data[index + 3]

            image.putpixel((x, y), (red, green, blue))

        return image

    def get_diff(self, polygon_data):
        # fitness function
        # fitness = sum((pixel_i_input_image - pixel_i_current_image) ^ 2) / pixels_number
        # mean square error (MSE)
        image = self.polygon_data_to_image(polygon_data)
        return np.sum((self.to_cv2(image).astype("float") - self.input_image_cv2.astype("float")) ** 2) / float(
            self.pixels_number)

    def plot_images(self, image, index=None):
        # plot 2 images to compare:
        # input image and image from parameters
        fig = plt.figure("Comparison:")

        if index != None:
            plt.suptitle(f'Iteration {index}')

        ax = fig.add_subplot(1, 2, 1)
        plt.imshow(self.input_image)
        plt.tick_params(
            axis='both',
            which='both',
            bottom=False,
            left=False,
            top=False,
            right=False,
            labelbottom=False,
            labelleft=False,
        )

        fig.add_subplot(1, 2, 2)
        plt.imshow(image)
        plt.tick_params(
            axis='both',
            which='both',
            bottom=False,
            left=False,
            top=False,
            right=False,
            labelbottom=False,
            labelleft=False,
        )

        return plt

    def save_image(self, polygon_data, path):
        image = self.polygon_data_to_image(polygon_data)
        self.plot_images(image)
        plt.savefig(path)

    def to_cv2(self, image_pil_format):
        return cv2.cvtColor(np.array(image_pil_format), cv2.COLOR_RGB2BGR)

