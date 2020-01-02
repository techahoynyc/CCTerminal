import time
import picamera



def startCamera(cameraName, timer):
	with picamera.PiCamera() as camera:
		camera.resolution = (1024, 768)
		camera.start_preview()
		# Camera warm-up time
		time.sleep(timer)
		camera.capture('{}.jpg'.format(cameraName))


name = input("Give your picture a name: ")
timer = input("Set a timer in seconds for the camera: ")

startCamera(name, int(timer))
