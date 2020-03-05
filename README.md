# FPGA-Morse-Code-Display
A School Project written in VHDL for rendering Morse Code on the LED's of an FPGA.

[![Click here to see a demonstration](https://cdn-b-east.streamable.com/image/2opzx_1.jpg?token=WOIzrBknnISiWQjM6lYBHQ&expires=1583454900)](https://streamable.com/2opzx "Demonstration")

(Click to watch a demonstration, the code reads "this is so sad")

# Description

Using switches and buttons you can encode a message in binary and then play it out in Morse Code. This was originally designed for a [Prometheus FPGA](https://www.isabekov.pro/prometheus-fpga/).

# Instructions 

To type in a letter, you encode it in binary using the switches on your board (anything greater than 26 is counted as 0 or space)
Next you use the "add" button to add it to memory. You can now encode the next character and then press "add" again or "delete" to undo. Once you're done, hit "play" to display the message. You can also clear the memory with the "reset" button. Finally the last two buttons are used to switch between letter and number mode.
![Button bindings](https://github.com/madprogramer/FPGA-Morse-Code-Display/blob/master/ButtonMapping.png "Button Mapping") See Project Report.pdf for further details.

# Background

This was originally made as the final project for the lab section of ELEC 204 Digital Design at Koç University. The code is annotated and should probably be adaptable for other FPGA boards as well.
