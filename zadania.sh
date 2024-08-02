#!/bin/bash

# Sprawdzenie czy przekazano odpowiednia liczbe argumentow


if [ "$#" -ne 2 ]; then
    echo "Uzycie: $0 <user1> <user2>"
    exit 1
fi

# Przyjecie argumentow

USER1=$1
USER2=$2


# 1. Instalacja pakietow
echo "
========== 1 - INSTALACJA PAKIETOW I URUCHOMIENIE SSH ============
"
sudo apt-get update
sudo apt-get install -y less tcpdump net-tools openssh-server

# Upewnienie sie ze serwer SSH dziala
sudo systemctl enable ssh
sudo systemctl start ssh


# 2. Dodanie uzytkownika USER1 z katalogiem domowym i shellem
echo "
========== 2 - DODANIE $USER1 ============
"
sudo useradd -m -s /bin/bash $USER1


# 3. Dodanie uzytkownika USER2 z katalogiem domowym i shellem
echo "
========== 3 - DODANIE $USER2 ============
"
sudo useradd -m -s /bin/bash $USER2


# 4. Wygenerowanie kluczy dla uzytkownika USER1
echo "
========== 4 - WYGENEROWANIE KLUCZA DLA $USER1 =========
"

sudo -u $USER1 ssh-keygen -t rsa -b 2048 -f /home/$USER1/.ssh/id_rsa -N ""


# 5. Wygenerowanie pary kluczy dla uzytkownika USER2
echo "
========== 5 - WYGENEROWANIE KLUCZA DLA $USER2 =========
"

sudo -u $USER2 ssh-keygen -t rsa -b 2048 -f /home/$USER2/.ssh/id_rsa -N ""


# 6. Konfiguracja bezhaslowego logowania przez scp USER1 na konto USER2
echo "
==== 6 - KONFIGURACJA BEZHASLOWEGO LOGOWANIA PRZEZ $USER1 NA KONTO $USER2 =========
"
sudo -u $USER1 cat /home/$USER1/.ssh/id_rsa.pub | sudo -u $USER2 tee -a /home/$USER2/.ssh/authorized_keys

sudo -u $USER1 scp -o StrictHostKeyChecking=no /home/$USER1/.ssh/id_rsa.pub $USER2@localhost:/home/$USER2/${USER1}_id_rsa.pub


# 7. Konfiguracja bezhaslowego logowania przez scp USER2 na konto USER1
echo "
===== 7 - KONFIGURACJA BEZHASLOWEGO LOGOWANIA PRZEZ $USER2 NA KONTO $USER1 =========
"
sudo -u $USER2 cat /home/$USER2/.ssh/id_rsa.pub | sudo -u $USER1 tee -a /home/$USER1/.ssh/authorized_keys

sudo -u $USER2 scp -o StrictHostKeyChecking=no /home/$USER2/.ssh/id_rsa.pub $USER1@localhost:/home/$USER1/${USER2}_id_rsa.pub


# 8. Konfiguracja przelaczenia USER1 na root bez podawania hasla
echo "
===== 8 - KONFIGURACJA BEZHASLOWEGO PRZELACZANIA $USER1 NA ROOT =========
"
# Dodanie użytkownika do grupy sudo
sudo usermod -aG sudo $USER1

# Konfiguracja bezhasłowego sudo
echo "$USER1 ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER1


# 9. Przygotowanie pliku z losowymi danymi o wielkosci 1MB w katalogu home uzytkownika USER1
echo "
======= 9 - PRZYGOTOWANIE PLIKU Z LOSOWYMI DANMI W KATALOGU $USER1 ===========
"
sudo -u $USER1 dd if=/dev/urandom of=/home/$USER1/random_data_1MB bs=1M count=1


# 10. Skopiowanie pliku z konta uzytkownika USER1 do katalogu home uzytkownika USER2 przy uzyciu SCP
echo "
======= 10 - SKOPIOWANIE PLIKU Z $USER1 DO KATALOGU $USER2 ===========
"
sudo -u $USER1 scp -o StrictHostKeyChecking=no /home/$USER1/random_data_1MB $USER2@localhost:/home/$USER2/random_data_1MB


# 11. Wyciagniecie z logow systemowych wszystkich operacji uzytkownikow korzystajacych z SSH
echo "
======  11 - WYCIAGNIECIE Z LOGOW SYSTEMOWYCH WSZYSTKICH OPERACJI UZYTKOWNIKOW KORZYSTAJACYCH Z SSH ============
"
journalctl | grep -i sshd


echo "
WSZYSTKIE ZADANIA WYKONANE!
"


