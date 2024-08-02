#!/bin/bash

# Definiowanie kodów kolorów tła
RED_BACKGROUND='\033[41m'
RESET='\033[0m'

# Sprawdzenie czy przekazano odpowiednią liczbę argumentów
if [ "$#" -ne 2 ]; then
    echo -e "${RED_BACKGROUND}Użycie: $0 <user1> <user2>${RESET}"
    exit 1
fi

# Przyjęcie argumentów
USER1=$1
USER2=$2

# 1. Instalacja pakietów
echo -e "${RED_BACKGROUND}\n========== 1 - INSTALACJA PAKIETÓW I URUCHOMIENIE SSH ==========${RESET}\n"
sudo apt-get update
sudo apt-get install -y less tcpdump net-tools openssh-server

# Upewnienie się, że serwer SSH działa
sudo systemctl enable ssh
sudo systemctl start ssh

# 2. Dodanie użytkownika USER1 z katalogiem domowym i shellem
echo -e "${RED_BACKGROUND}\n========== 2 - DODANIE $USER1 ==========${RESET}\n"
sudo useradd -m -s /bin/bash $USER1

# 3. Dodanie użytkownika USER2 z katalogiem domowym i shellem
echo -e "${RED_BACKGROUND}\n========== 3 - DODANIE $USER2 ==========${RESET}\n"
sudo useradd -m -s /bin/bash $USER2

# 4. Wygenerowanie kluczy dla użytkownika USER1
echo -e "${RED_BACKGROUND}\n========== 4 - WYGENEROWANIE KLUCZA DLA $USER1 ==========${RESET}\n"
sudo -u $USER1 ssh-keygen -t rsa -b 2048 -f /home/$USER1/.ssh/id_rsa -N ""

# 5. Wygenerowanie pary kluczy dla użytkownika USER2
echo -e "${RED_BACKGROUND}\n========== 5 - WYGENEROWANIE KLUCZA DLA $USER2 ==========${RESET}\n"
sudo -u $USER2 ssh-keygen -t rsa -b 2048 -f /home/$USER2/.ssh/id_rsa -N ""

# 6. Konfiguracja bezhasłowego logowania przez scp USER1 na konto USER2
echo -e "${RED_BACKGROUND}\n==== 6 - KONFIGURACJA BEZHASŁOWEGO LOGOWANIA PRZEZ $USER1 NA KONTO $USER2 ==========${RESET}\n"
sudo -u $USER1 cat /home/$USER1/.ssh/id_rsa.pub | sudo -u $USER2 tee -a /home/$USER2/.ssh/authorized_keys

sudo -u $USER1 scp -o StrictHostKeyChecking=no /home/$USER1/.ssh/id_rsa.pub $USER2@localhost:/home/$USER2/${USER1}_id_rsa.pub

# 7. Konfiguracja bezhasłowego logowania przez scp USER2 na konto USER1
echo -e "${RED_BACKGROUND}\n===== 7 - KONFIGURACJA BEZHASŁOWEGO LOGOWANIA PRZEZ $USER2 NA KONTO $USER1 ==========${RESET}\n"
sudo -u $USER2 cat /home/$USER2/.ssh/id_rsa.pub | sudo -u $USER1 tee -a /home/$USER1/.ssh/authorized_keys

sudo -u $USER2 scp -o StrictHostKeyChecking=no /home/$USER2/.ssh/id_rsa.pub $USER1@localhost:/home/$USER1/${USER2}_id_rsa.pub

# 8. Konfiguracja przełączania USER1 na root bez podawania hasła
echo -e "${RED_BACKGROUND}\n===== 8 - KONFIGURACJA BEZHASŁOWEGO PRZEŁĄCZANIA $USER1 NA ROOT ==========${RESET}\n"
# Dodanie użytkownika do grupy sudo
sudo usermod -aG sudo $USER1

# Konfiguracja bezhasłowego sudo
echo "$USER1 ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER1

# 9. Przygotowanie pliku z losowymi danymi o wielkości 1MB w katalogu home użytkownika USER1
echo -e "${RED_BACKGROUND}\n======= 9 - PRZYGOTOWANIE PLIKU Z LOSOWYMI DANYMI W KATALOGU $USER1 ==========${RESET}\n"
sudo -u $USER1 dd if=/dev/urandom of=/home/$USER1/random_data_1MB bs=1M count=1

# 10. Skopiowanie pliku z konta użytkownika USER1 do katalogu home użytkownika USER2 przy użyciu SCP
echo -e "${RED_BACKGROUND}\n======= 10 - SKOPIOWANIE PLIKU Z $USER1 DO KATALOGU $USER2 ==========${RESET}\n"
sudo -u $USER1 scp -o StrictHostKeyChecking=no /home/$USER1/random_data_1MB $USER2@localhost:/home/$USER2/random_data_1MB

# 11. Wyciągnięcie z logów systemowych wszystkich operacji użytkowników korzystających z SSH
echo -e "${RED_BACKGROUND}\n======  11 - WYCIĄGNIĘCIE Z LOGÓW SYSTEMOWYCH WSZYSTKICH OPERACJI UŻYTKOWNIKÓW KORZYSTAJĄCYCH Z SSH ==========${RESET}\n"
journalctl | grep -i sshd

echo -e "${RED_BACKGROUND}\nWSZYSTKIE ZADANIA WYKONANE!${RESET}\n"


