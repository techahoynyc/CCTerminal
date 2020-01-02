import time
import picamera

def timelapse(splits):
	with picamera.PiCamera() as camera:
		camera.start_preview()
		time.sleep(2)
		for filename in camera.capture_continuous('img{counter:03d}.jpg'):
			print('Captured %s' % filename)
			time.sleep(splits) # wait 5 minutes


splits = input("Take a photo every __ seconds: ")       
timelapse(float(splits))
