# Home-Assistant Mischpult

Dieses Dokument beschreibt den Nachbau des Projektes von [Sacrebleu Studio](https://www.youtube.com/@sacrebleu.studio).

Es wird kein 1:1 Nachbau, sondern ein konzeptioneller, wiederverwendet werden folgende Komponenten:

* Motorisierte, lineare Mischpult Potentiometer
* Inkrementalgeber mit Druckschalter
* Runde Taster für Presets
* Display mit Touchscreen aber in runder Bauweise
* Konfiguration über Home-Assistant
* Knöpfe, Drehgeber und Potentiometer Positionen aus Home Assistant ansteuerbar
* LRA für ein haptisches Feedback

## Abgrenzung

Nicht Teil dieses Projektes sind:

* Ein 1:1 Nachbau des Originals
* Eine strikte Umsetzung von Cyber Security Massnahmen (siehe [Cyber Security](#cyber-security))
* Ein fertigungsreifes CAD Modell (nur Visualisierungs- und Design-Hilfe)

## System

Das Mischpult soll sich nahtlos in Home-Assistant (HA) einfügen. Es soll möglich sein, das Mischpult dynamisch zu konfigurieren und gleichzeitig sollten Input (Analog-Werte, Knöpfe, Inkrementalgeber) und Output (Sollposition) sich als sinnvolle Entities beeinflussen lassen.

### Software

Die Software soll mit Zephyr-OS implementiert werden. Die verwendete Hardware soll in das bestehende Zephyr-OS Ökosystem passen. Wenn möglich sollen keine eigenen Device Treiber implementiert werden müssen. Ebenso soll die Wahl des Zephyr-OS die Hardware Selektion beeinflussen, so dass die Micro-Controller-Ressourcen genügend gross sind, damit:

* Die Echtzeit-Aspekte der motorisierten Mischer (PID-Regler) abgedeckt werden können
* Die Einbindung ins lokale LAN gewährleistet ist
* Die Kommunikation zu Home-Assistant sichergestellt ist

### Hardware

Aktuell verfügbar ist ein ESP32-S3-DEV-KIT-N8R8, welches eingesetzt werden soll, aber nur, wenn es die Software Anforderungen vollumfänglich abdecken kann. Die Kriterien dazu werden im Anforderungsdokument festgelegt und in der Machbarkeitsphase geprüft.

### Elektronik

Dieses Projekt soll ausserdem zum Ziel haben, ein (oder bei Bedarf mehrere) PCB mit KiCad zu designen. Die verwendeten Bauteile sollten also wenn möglich als Bibliotheks-Bauteil vorhanden sein. Es soll dabei auf eine frei verfügbare Bauteil Bibliothek zurückgegriffen werden. Das PCB Design soll Neben- und nicht Haupt-Aspekt dieses Projektes sein. Es soll letztlich Zeit sparen und nicht Zeit verbraten.

## Prozess

Das HW Design wird mit Fusion 360 und KiCad gemacht. Hier soll bewusst die Fähigkeit geschult und repetiert werden, welche nötig ist, um ein PCB extern herzustellen. Das CAD Modell hat keinen konkreten Nutzen ausser als Visualisierungs- und Design Hilfe.

Die System- und Software Entwicklung soll mit agentischer KI passieren. Oberstes Credo soll hier sein: Dokumentation und Code *müssen* in jedem Fall übereinstimmen.

### Konsistenz von Dokumentation und Code

* Jede Anforderung erhält eine eindeutige ID (z.B. `REQ-012`).
* Design, Code und Tests referenzieren die IDs der Anforderungen, die sie umsetzen bzw. prüfen.
* Eine Änderung gilt erst als abgeschlossen, wenn die betroffene Dokumentation im selben Änderungsschritt nachgeführt ist.

### Tests

Zusätzlich zum Code sollen Testfälle (Unit Tests) geschrieben werden, so dass sichergestellt werden kann, dass bei inkrementellen Code-Änderungen keine Fehler eingebaut werden.

Es soll in kleinen, sinnvoll geschnittenen Implementations-Stücken implementiert und getestet werden. Insbesondere soll hier berücksichtigt werden, dass die PCB Beschaffung oder aber die Bestückung der Platinen eine gewisse Durchlaufzeit benötigen.

### Machbarkeitsphase

Ebenfalls berücksichtigt werden soll eine sinnvolle Machbarkeitsphase. Namentlich (aber nicht abschliessend aufgezählt) soll:

* Die Ansteuerung der DC-Motoren in den Potentiometern
* Die Anbindung an Home-Assistant
* Die Implementierung des LRA
* Die Implementierung eines geeigneten Reglers für die Positionierung der Potentiometer

vorgängig ausprobiert und bewiesen werden.

Weitere Machbarkeits-Studien, welche im Rahmen des detaillierten Design Prozesses als nötig erachtet werden, sind explizit in [feasibility.md](feasibility.md) aufzuführen und später in der Entwicklungs-Dokumentation zu erwähnen. Dort stehen auch die Abnahmekriterien und Ergebnisse aller Studien.

Eine Machbarkeitsstudie gilt als abgeschlossen, wenn ihre vorgängig festgelegten Abnahmekriterien erfüllt und das Ergebnis dokumentiert ist.

Anforderungen und Machbarkeit entstehen iterativ: Ergebnisse der Machbarkeitsphase (z.B. ob der ESP32-S3 genügt) fliessen in die Anforderungen zurück.

### Meilensteine

1. Anforderungen erfasst (erste Fassung, wird durch die Machbarkeit verfeinert)
2. Machbarkeitsphase abgeschlossen (inkl. Entscheid ESP32-S3)
3. System Design abgeschlossen
4. HW-, EE- und SW Design abgeschlossen, PCB bestellt
5. Implementierung und Integration abgeschlossen
6. System Tests bestanden

## Dokumentation

### Umfang der Dokumentation

Folgende Artefakte zur Dokumentation dieses Prozesses sind zu erstellen:
* Projektbeschreibung (dieses Dokument)
* [Anforderungen](requirements.md)
* [Machbarkeit](feasibility.md)
* [System Design](system/system-design.md)
* [HW Design](hw/hw-design.md)
* [EE Design](ee/ee-design.md)
* [SW Design](sw/sw-design.md)
* Wenn nötig SW Detail Design (`sw/sw-detail-design.md`)
* Sinnvolle Kommentare im Software Design
* [HW Tests](hw/hw-tests.md)
* [EE Tests](ee/ee-tests.md)
* [SW Tests](sw/sw-tests.md)
* [System Tests](system/system-tests.md)

### Ablage der Dokumentation

Zusammen mit dem Sourcecode in einem GitHub Repository.

### Form der Dokumentation

In maschinenlesbaren .md Files.

## Cyber Security

Das Thema soll ebenfalls keinen Haupt-Aspekt einnehmen, da das Projekt in einem einigermassen sicheren Umfeld (Heimnetz, Firewall, minimale Bedrohungslage, etc.) eingesetzt wird. Hier soll der Lern-Effekt als Studie zur Wissens- und Erkenntnis-Gewinnung dienen und nicht die strikte Umsetzung. Es dürfen bei diesem Thema also begründete Abstriche gemacht werden.
