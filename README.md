# Remote Controlled Freeze Tag

This was the final lab for ECE 375 where we built a remote controlled car that could play freeze tag. The setup consisted of two ATMEGA 128 boards, one board was used for the controller and the other one was used for a robot car.

## How It works

The ATMEGA 128 comes with an IR sender and receiver. Our controller used the IR sender to send messages that our robot car would receive using the IR receiver. Because there were multiple robots we used a specific 8-bit code that would be sent with our data so that our car knew if the message was coming from our controller. The data that was sent would tell the car whether to move forward, turn right, turn left, stop, or send a freeze signal. When the car received this signal it would interrupt what it was doing and preform the new action. Last the car had a universal freeze code that if it received this specific message it would pause for 2 seconds.

## Files

There are two implementations for this the standard Lab8_code uses a simplistic busy wait while the chellengecode uses a timer/counter interrupt. The Lab8_challengecode also comes with a speed option for the car.

Lab8_code:

Lab8_Rx_code - receiver code for the car
Lab8_Tx_code - transmitter code for the controller

Lab8_challengecode:

Lab8_Tx_challengecode - transmitter code for the controller
Lab8_Rx_challengecode - receiver code for the car

## Built With

* [Atmel Studio 7](https://www.microchip.com/webdoc/GUID-ECD8A826-B1DA-44FC-BE0B-5A53418A47BD/index.html?GUID-8F63ECC8-08B9-4CCD-85EF-88D30AC06499) - The IDE used to write the code
* [AVR Assembly](https://www.microchip.com/webdoc/avrassembler/avrassembler.wb_instruction_list.html) - Assembly language used to program the application
* [LAB 8 instructions](https://www.microchip.com/webdoc/avrassembler/avrassembler.wb_instruction_list.html) - Goal of the project

## Authors

* **Jared Tence** - *Programmed it* - [Github](https://github.com/jmanosu)

## Acknowledgments

* ECE 375 was pretty cool thanks OSU
