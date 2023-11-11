#!/bin/sh

# Ask the user if they want to set the server to a static IP
  # If the user does not agree, ask the questions again
curl -sfL https://github.com/charmbracelet/gum/releases/download/v0.11.0/gum_0.11.0_Linux_x86_64.tar.gz -o gum.tar.gz
while [ "$agree" != "y" ]; do
    echo "You have declined to agree with your responses. The questions will be asked again."
    read -p "Do you want to set this server to a StaticIP? (y/n) " static_ip
    if [ "$static_ip" = "y" ]; then
      echo "If yes, please specify IP in CIDR format e.g. 10.9.2.13/16"
      read -p "Enter IP in CIDR format: " ip_address
      echo "Are you adding this as a node to a Server?"
      read -p "Enter y/n: " adding_to_server
      echo "Here are your responses:
      * Static IP: $ip_address
      * Adding to server: $adding_to_server
      Do you agree? (y/n) "
      read -p "Enter y/n: " agree
    fi
  done
else

echo "$1"
read -p "Enter y/n: " static_ip

echo "Do you want to set this server to a StaticIP?"
read -p "Enter y/n: " static_ip

if [ "$static_ip" = "y" ]; then
  # Ask the user to specify the IP in CIDR format
  echo "If yes, please specify IP in CIDR format e.g. 10.9.2.13/16"
  read -p "Enter IP in CIDR format: " ip_address

  # Ask the user if they are adding this as a node to a server
  echo "Are you adding this as a node to a Server?"
  read -p "Enter y/n: " adding_to_server

  if [ "$adding_to_server" = "y" ]; then
    # Set the server to a static IP and add it as a node to the server
    echo "Setting server to static IP $ip_address and adding it as a node to the server..."
    # TODO: Implement the logic to set the server to a static IP and add it as a node to the server
  else
    # Set the server to a static IP but do not add it as a node to the server
    echo "Setting server to static IP $ip_address but not adding it as a node to the server..."
    # TODO: Implement the logic to set the server to a static IP but do not add it as a node to the server
  fi
else
  # Do not set the server to a static IP
  echo "Not setting server to a static IP..."
fi
