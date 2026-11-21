# Home-Assistant Mischpult

Dieses Dokument beschriebt den Nachbau des Projektes von (Sacrebleu Studio)[https://www.youtube.com/@sacrebleu.studio].

Es wird kein 1:1 Nachbau, sondern ein konzeptioneller, wiederverwendet werden folgende Komponenten:

* Motorisierte, lineare Mischpult Potentiometer
* Inkrementalgeber mit Druckschalter
* Runde Taster für Presets
* Display mit Touchscreen aber in runder Bauweise
* Konfiguration über Home-Assistant
* Knöpfe, Drehgeber und Potentiometer Positionen aus Home Assistant ansteuerbar
* LRA für ein haptisches Feedback

## System

Das Mischpult soll sich natlos in Home-Assistant (HA) einfügen. Es soll möglich sein, das Mischpult dynamsich zu konfigurieren und gleichzeitig sollten Input (Analog-Werte, Knöpfe, Inkrementalgeber) und Output (Sollposition) sich als sinnvolle Entities beeinflussen lassen.

### Software

Die Software soll mit Zephyr-OS implemetniert werden. Die verwendete Hardware soll in das bestehende Zephyr-OS Ökosystem passen. Wenn möglich sollen keine eigenen Device Treiber implementiert werden müssen. Ebenso soll die Wahl des Zephyr-OS die Hardware Selektion beeinflussen, so dass die Micro-Controller-Ressourcen gegügend gross sind, damit:

* Die Echtzeit-Aspekte der motorisierten Mischer (PID-Regler) abdecken kann
* Die Einbindung ins lokale LAN gewährleisten kann
* Die Kommunikation zu Home-Assistant sicherstellt

### Hardware

Aktuell verfügbar ist ein ESP32-S3-DEV-KIT-N8R8, welches eingesetzt werden soll, aber nur, wenn es die Software Anforderungen vollumfänglich abdecken kann.

### Elektronik

Dieses Projekt soll ausserdem zum Ziel haben, ein (oder bei Bearf mehrere) PCB mit KiCad zu designen. Die verwendeten Bauteile sollten also wenn möglich als Bibliotheks-Bauteil vorhanden sein. Es soll dabei auf eine frei verfügbare Bauteil Bibliothek zurück gegriffen werden. Das PCB Design soll Neben- und nicht Haupt-Aspekt dieses Projektes sein. Es soll letztlich Zeit sparen und nicht Zeit verbraten.

## Prozess

Das HW Design wird mit Fusion 360 und KiCad gemacht. Hier soll bewusst die Fähigkeit geschult und Repetiert werden, welche nötig ist, um ein PCB extern herzustellen. Das CAD Modell hat keinen konkreten Nutzen ausser als Visualisierungs- und Design Hilfe.

Die System- und Software Entwicklung soll mit agentischer KI passieren. Oberstes Kredo soll hier sein: Dokumentation und Code *müssen* in jedem Fall übereinstimmen.

Zusätzlich zum Code sollen Testfälle (Unit Tests) geschrieben werden, so dass sicher gestellt werden kann, dass bei inkrementellen Code-Änderungen keine Fehler eingebaut werden.

Es soll in kleinen, sinnvoll geschnittenen Implementations-Stücken implementiert und getestet werden. Insbesondere soll hier berücksichtigt werden, dass die PCB Beschaffung oder aber die Bestückung der Platinen eine gewisse Durchlaufzeit benötigen.

Ebenfalls berücksichtig werden soll eine sinnvolle Machbarkeitsphase. Namentlich (aber nicht abschliessend aufgezählt) soll:

* Die Ansteuerung der DC-Motoren in den Potentiometern
* Die Anbindung an Home-Assistant
* Die Implementierung des LRA
* Die Implementierung eines Geeigneten Reglers für die Positionierung der Potentiometer

vorgängig ausprobiert und bewiesen werden.

Weitere Machbarkeits-Studien, welche im Rahmen des detailierten Design Prozess als nötig erachtet werden, sind explizit hier aufzuführen und später im der Entwicklungs-Dokumentation zu erwähnen.

## Dokumentaiton

Folgende Artefakte zur Dokumentation dieses Prozesses sind zu erstellen:
* Projektbeschreibung (dieses Dokument)
* Anforderungen
* System Design
* HW Design
* EE Design
* SW Design
* Wenn nötig SW Detail Design
* Sinnvolle Kommentare im Software Design
* EE Tests
* SW Tests
* System Tests
  
## Cyber Security

Das Thema soll ebenfalls keinen Haupt-Aspekt einnehmen. Da das Projekt in einem einigermassen sicheren Umfeld (Heimnetz, Firewall, minimale Bedrohungslage, etc.) eingesetzt wird. Hier ist der Lern-Effekt als Studie zur Wissens- und Erkenntnis-Gewinnung dienen und nicht zur strikten Umsetzung. Es dürfen bei diesem Thema also begründete Abstriche gemacht werden.