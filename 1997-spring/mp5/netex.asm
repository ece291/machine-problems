; --------------- NETLIB Library Procedures ---------------
NetInit:    Initializes Network - Returns: Player num in AL
SendPacket: Transmits data in TXBuffer - Inputs: AX = Length
NetRelease: Release network resources 

; --------------- NETLIB Callback Function ----------------
netpost : Procedure called when datagram arrives.
          Called with AX = Length, BX = Pointer to RXBuffer
          Must preserve all registers modified
          Ends with RET (not IRET)

; --------------- NETLIB Variables ------------------------
TXBuffer: Transmit Buffer (1024 bytes) - Write your data here 
RXBuffer: Receive Buffer  (1024 bytes) - Read from here !

