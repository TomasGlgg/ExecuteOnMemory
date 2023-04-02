from socket import socket

s = socket()
s.bind(('', 8888))
s.listen()
print('Listening')

data = open('test.elf', 'rb').read()

while True:
    con, addr = s.accept()
    print('Connected:', addr)
    con.send(len(data).to_bytes(8, 'little') + data)
