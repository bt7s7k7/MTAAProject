# DigiSenior backend

## Setup

Na spustenie tohto programu je potrebné NodeJS verzie aspoň 20.11.1 a yarn package manager. Tiež je potrebný prístup k databázy PostgreSQL aspoň 16.2. 

  1. Nainstalovať dependencies
  ```bash
  yarn
  ```
  2. Pripraviť údaje, ktoré sa necommitujú do repository
     1. Spustiť `node ace apply:secrets`
     2. Vo vygenerovanom súbore `secrets.json` doplniť informácie
     3. Stiahnuť `firebase-key.json` z firebase console
     4. Spustiť `node ace apply:secrets`
  
  3. Spustiť databázovú migráciu a seedovanie databázy
  ```bash
  node ace migration:fresh
  node ace db:seed
  ```

## Spustenie

Vo východzej konfigurácií je server spustení na porte 3333, čo je možné zmeniť v `.env` v prípade konfliktu.

```bash
yarn dev
```

## Testovanie

Na vypísanie všetkých endpointov je možné následovným príkazom:

```bash
node ace list:routes
```

Na roote stránky servera, pre výdhozie nastavenie `http://localhost:3333` je testovacia stránka umožnujúca prístup k funkcionalite backendu. Pri spustení podľa tohto dokumentu je backend vo vývojovom móde takže k chybám budú vložené aj diagnostické údaje, ktoré v produkcií nie sú viditeľné.

Testovacia stránka je rozdelená na segment kde je možné vykonávať akcie a segment ukazujúci výstup z predošlého volania endpointu alebo v prípade chyby jej údaje. 

K dispozícií sú tieto stránky:

  - Login ⇒ možnosť prihlásenia a registrácie
     - V seede databázy bolo vytvorených niekoľko používateľských účtov, pre ľahší prístup sú k dispozícií tlačidlá **Use Joy** a **Use Kale** ktoré automaticky vložia prihlasovacie údaje a prihlásia sa.
     - Systém ukladá posledný access token takže po znovunačítaní stránky je možné sa autorizovať cez tlačidlo **Load saved token** 
  - Levels ⇒ výpis možných level, ktoré používateľ môže dosiahnuť
  - Friend + Activities ⇒ umožnuje zobrazenie priateľov, pozvánok na priateľstvo a aktivít
     - Zoznamy sú načítané tlačidlami **Get Friends** a **Get Home Activities**
     - Po akcií vykonávajúcu zmenu týchto zoznamov je nutné ich znovu načítač
     - Pri každom záznamu priateľstva je tlačidlo na zrušenie priateľstva
     - Pri každom zázname pozvánky sú tlačidlá na prijatie a zrušenie priateľstva
     - Pri každom zázname aktivity je možné jej dať like, zrušiť like alebo ju vymazať
     - Testovacia stránka netestuje či je možné akciu vykonať, spätnú väzbu dostanete z backendu
  - Add Friends ⇒ možné vyhľadať a poslať pozvánku novému priateľovy  
  - User Photo ⇒ možnosť uploadnúť a pozrieť profilovku používateľa
  - Websocket ⇒ po pripojení na websocket server posiela nový stav relevaných entít
     - Môžte si na v novom okne otvoriť stránku a prihlásiť sa za používateľa alebo jeho priateľa
     - Akcie ako vytvorenie aktivity, like, pozvanie na priateľstvo atď. budú poslané
