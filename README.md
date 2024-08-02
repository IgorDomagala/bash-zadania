
# Skrypt do konfiguracji użytkowników i bezhasłowego logowania SSH

## Założenia

- Stacja robocza z zainstalowanym systemem Linux Ubuntu 24.04 LTS
- System jest zainstalowany na jednej partycji
- Dostęp do konta root (lub użytkownika z uprawnieniami sudo).

## Instrukcje

1. Skopiuj skrypt na swój serwer.
2. Sprawdź czy masz dostęp do konta root/uprawnień sudo
2. Upewnij się, że skrypt ma uprawnienia execute: `chmod +x zadania.sh`
3. Uruchom skrypt z dwoma argumentami odpowiadającymi nazwom użytkowników.

## Przykład użycia:

Ten przykład pozwoli na uruchomienie skryptu dla dwóch użytkowników o nazwach "test1" i "test2":

```bash
sudo ./zadania.sh test1 test2
```
Każda wykonywana w danej chwili operacja jest oznaczona na czerwono.

## Opis operacji wykonywanych przez skrypt:

1. **Instalacja pakietów i uruchomienie SSH:**
   - Skrypt aktualizuje listę pakietów i instaluje niezbędne narzędzia (`less`, `tcpdump`, `net-tools`, `openssh-server`).
   - Upewnia się, że serwer SSH działa i jest włączony przy starcie systemu.

2. **Dodanie użytkowników:**
   - Tworzy dwóch użytkowników z katalogami domowymi oraz powłoką bash.

3. **Generowanie kluczy SSH:**
   - Generuje pary kluczy SSH dla każdego z użytkowników.

4. **Konfiguracja bezhasłowego logowania:**
   - Konfiguruje bezhasłowe logowanie przez SSH między kontami.

5. **Przygotowanie pliku z losowymi danymi:**
   - Generuje plik 1MB z losowymi danymi w katalogu domowym pierwszego użytkownika

6. **Transfer pliku:**
   - Kopiuje plik z katalogu domowego pierwszego użytkownika do katalogu domowego drugiego przy użyciu SCP.

7. **Monitorowanie logów SSH:**
   - Wyciąga z logów systemowych wszystkie operacje użytkowników korzystających z SSH.


```
