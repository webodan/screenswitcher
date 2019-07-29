#!/usr/bin/env python2

import pygtk
pygtk.require('2.0')
import gtk
import os
import getpass
import glib

def yieldsleep(func):
	def start(*args, **kwds):
		iterable = func(*args, **kwds)
		def step(*args, **kwds):
			try:
				time = next(iterable)
				glib.timeout_add_seconds(time, step)
			except StopIteration:
				pass
		glib.idle_add(step)
	return start

class cb_exit:
	def disable_buttons(self):
		self.crtmon.set_sensitive(False)
		self.hdmon.set_sensitive(False)
		self.hdtv.set_sensitive(False)

	def crtmon_action(self):
		os.system("exec /home/dan/switchmon.sh --crtmon")
		gtk.main_quit()

	def hdmon_action(self):
		os.system("/home/dan/switchmon.sh --hdmon")
		gtk.main_quit()

	def hdtv_action(self):
		os.system("/home/dan/switchmon.sh --hdtv")

	@yieldsleep
	def button_press(self, btn, action_function):
		self.disable_buttons()
		self.window.disconnect(self.keypress_action)
		
		while self.execute_timeout > 0:
			self.status.set_text("Executing in {0} minutes...".format(self.execute_timeout))
			self.execute_timeout -= 1
			yield 60
		
		action_function()

	def create_window(self):
		self.window = gtk.Window()
		title = "Choose a display to run:"
		self.window.set_title(title)
		self.window.set_border_width(4)
		self.window.set_size_request(540, 80)
		self.window.set_resizable(False)
		self.window.set_keep_above(True)
		self.window.stick
		self.window.set_position(1)
		self.window.connect("delete_event", gtk.main_quit)
		windowicon = self.window.render_icon(gtk.STOCK_FULLSCREEN, gtk.ICON_SIZE_MENU)
		self.window.set_icon(windowicon)
		
		self.execute_timeout = 0
		
		#Create HBox for buttons
		self.button_box = gtk.HBox()
		self.button_box.show()
		
		#CRT Monitor button
		self.crtmon = gtk.Button("CRT Monitor")
		self.crtmon.set_border_width(3)
		self.crtmon.connect("clicked", self.button_press, self.crtmon_action)
		self.button_box.pack_start(self.crtmon)
		self.crtmon.show()
		
		#HD Monitor button
		self.hdmon = gtk.Button("HD Monitor")
		self.hdmon.set_border_width(3)
		self.hdmon.connect("clicked", self.button_press, self.hdmon_action)
		self.button_box.pack_start(self.hdmon)
		self.hdmon.show()
		
		#HD TV button
		self.hdtv = gtk.Button("HD TV")
		self.hdtv.set_border_width(3)
		self.hdtv.connect("clicked", self.button_press, self.hdtv_action)
		self.button_box.pack_start(self.hdtv)
		self.hdtv.show()
		
		#Create HBox for status label
		self.label_box = gtk.HBox()
		self.label_box.show()
		self.status = gtk.Label()
		self.status.show()
		self.label_box.pack_start(self.status)
		
		#Create VBox and pack the above HBox's
		self.vbox = gtk.VBox()
		self.vbox.pack_start(self.button_box)
		self.vbox.pack_start(self.label_box)
		self.vbox.show()
		
		self.window.add(self.vbox)
		self.keypress_action = self.window.connect("key-press-event", self.keypress)
		self.window.show()

	def keypress(self, widget, event, data=None):
		key = gtk.gdk.keyval_name(event.keyval)
		if key == "Up":
			self.execute_timeout += 1
		elif key == "Down":
			if self.execute_timeout > 0:
				self.execute_timeout -= 1
		else:
			return
		self.status.set_text("...and delay for {0} minutes".format(self.execute_timeout))

	def __init__(self):
		self.create_window()


def main():
    gtk.main()

if __name__ == "__main__":
    go = cb_exit()
    main()
