# Video Transmission via Incremental Redundancy & Channel Coding

## Overview
This repository contains a MATLAB-based simulation of a channel encoder and decoder system designed for robust video stream transmission. The project extracts raw binary data from an `.avi` video file, simulates transmission over a noisy communication channel, and reconstructs the video at the receiver end. 

The primary focus is evaluating the performance of an **Incremental Redundancy** system utilizing convolutional codes and specific puncturing rules to dynamically adjust the code rate based on channel conditions.

## Key Features & Implementation
* **Binary Extraction:** Deconstructs video frames into RGB channels and converts the double precision data into discrete 1024-bit binary packets for transmission.
* **Convolutional Encoding:** Implements a rate 1/2 mother convolutional code using generators `133` and `171` (octal).
* **Dynamic Puncturing (Incremental Redundancy):** Applies specific puncturing rules to simulate variable code rates, including `8/9`, `4/5`, `2/3`, `4/7`, and `1/2`.
* **Channel Simulation:** Transmits the encoded packets through a Binary Symmetric Channel (BSC) with a configurable error probability ($p$) ranging from $0.0001$ to $0.2$.
* **Viterbi Decoding:** Uses a hard-decision Viterbi decoder with a traceback depth of 35 to correct errors and reconstruct the original video stream.

## Performance Evaluation
The system's efficiency was evaluated by plotting the **Coded Bit Error Probability** and **Data Throughput** against the channel error probability. 

**Key Observations:**
* As the channel error probability ($p$) increases, the overall bit error probability inherently increases while the data throughput decreases across all code rates.
* Higher code rates (e.g., transitioning to `8/9`) exhibit a much faster degradation—characterized by a steeper increase in error probability and a sharper decay in throughput—compared to lower, more robust code rates.

## Tech Stack
* **Language:** MATLAB
* **Key Functions:** `poly2trellis`, `convenc`, `bsc`, `vitdec`
