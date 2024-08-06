#!/usr/bin/expect

set username [lindex $argv 0]
set password [lindex $argv 1]

spawn pdbedit -a -u $username
expect "new password:"
send "$password\r"
expect "retype new password:"
send "$password\r"
interact
