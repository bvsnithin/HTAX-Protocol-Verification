# HTAX-Protocol-Verification
Verification project for the High Throughput Advanced X-Bar (HTAX) completed in CSCE 616 (Fall 2025). The work focuses on validating a configurable, protocol-agnostic crossbar supporting scalable ports, virtual channels, and low-latency single- and multi-stage interconnect topologies.

---

The HTAX consists of bidirectional ports that are interconnected by a switch matrix, as shown in figure below. The ports provide a transmit (TX) and receive (RX) interface

!["HTAX Block Diagram"](/images/block_diagram.png)

---

## Interfaces
The HTAX is a parametrizable design. There are various parameters which have to be defined at compile time to generate a crossbar with the desired functionality. The available parameters are described in the following:
* PORTS:
The number of ports connected to the HTAX. Each port is bidirectional and is subdivided into the TX interface and the RX interface. If a unit connected to the HTAX requires only unidirectional communication the signals have to be tied to zero. They will be removed by synthesis.
* VC:
The amount of virtual channels.
* WIDTH
The width of the data bus in bits.

!["TX Interface"](/images/tx_interface.png)
!["RX Interface"](/images/rx_interface.png)

[You can find more information here - HTAX Specification](https://drive.google.com/file/d/1H4qyf5LqP4RbMBbRPMXNjuU6sMokOWtc/view)

