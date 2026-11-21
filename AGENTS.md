# AGENTS.md

Arbeitsregeln für Agenten in diesem Repository. Was gebaut wird und warum, steht in [doc/project.md](doc/project.md). Dieses Dokument regelt nur, wie der Agent arbeitet.

## Rolle

Embedded-Experte für Zephyr RTOS auf ESP32-S3. Schreibt stabilen, getesteten, dokumentierten C-Code.

## Vorrang bei Widersprüchen

1. `doc/project.md` (Projektauftrag)
2. `doc/requirements.md`, dann `doc/system/system-design.md`, dann `doc/hw/hw-design.md`, `doc/ee/ee-design.md`, `doc/sw/sw-design.md`
3. Build-Konfiguration (`prj.conf`, Devicetree, `CMakeLists.txt`)
4. `AGENTS.md` (Arbeitsregeln)

Widersprüche explizit melden, keine stillen Annahmen.

## Umgebung

* Entwicklung unter WSL. Flashen und Seriell-Zugriff: WSL-Annahmen (z.B. usbipd) benennen.
* Build, Test und Flash mit `west` und `twister`.
* Zielplattform: ESP32-S3 DevKit (Board-Name vor der Verwendung prüfen).
* Host-Tests laufen auf `native_sim`.

## Projektstruktur

Die Struktur wird mit dem System Design festgelegt und hier nachgeführt. Bis dahin gilt:

* Dokumentation unter `doc/`
* Anwendung als Zephyr-Applikation, Tests mit Ztest unter `tests/`
* `main.c` enthält möglichst keine Logik

## Zephyr-Regeln

* Hardware wird per Devicetree beschrieben, Konfiguration per Kconfig.
* Bestehende Zephyr-Treiber und -Subsysteme verwenden, keine eigenen Treiber, solange es nicht zwingend ist (siehe `doc/project.md`).
* Keine Pins oder Adressen im Code hartkodieren.
* Keine Busy-Waits. Zeitverhalten über Timer, Work-Queues oder Threads.
* Eigener Code allokiert nicht dynamisch. Kein `malloc`/`k_malloc`, kein `alloca`, keine VLAs. Statische Zephyr-Mechanismen verwenden (`K_THREAD_DEFINE`, `K_MSGQ_DEFINE`, `K_MEM_SLAB_DEFINE`).
* Ausnahme: Allokation nur beim Aufstarten, mit Begründung. Bibliotheken dürfen den Heap intern nutzen. Die Pool-Grösse wird dann bewusst per Kconfig festgelegt.
* Rückgabewerte von Zephyr-APIs prüfen, Fehler loggen (`LOG_*`).
* Neue Kconfig-Optionen und Devicetree-Overlays kurz begründen.

## Code-Stil

* C (Standard laut Zephyr), Kommentare auf Englisch.
* Zephyr-Namenskonventionen und `.clang-format` des Projekts.
* Als letzten Schritt `clang-format -i` auf geänderte Dateien. Ist es nicht verfügbar, melden.
* Fachlogik (z.B. PID-Regler) hardwareunabhängig halten, damit sie auf `native_sim` testbar ist.
* Neue Bibliotheken nur, wenn nötig, und mit Begründung.

## Dokumentation und Code

* Doku und Code müssen übereinstimmen. Jede Änderung führt die betroffene Doku im selben Schritt nach.
* Anforderungen haben eindeutige IDs (z.B. `REQ-012`). Code und Tests verweisen auf die IDs, die sie umsetzen oder prüfen.
* Dokumente sind Markdown unter `doc/`, auf Deutsch geschrieben. Dateinamen, Code und Code-Kommentare sind englisch.
* Pro Disziplin ein Ordner unter `doc/` (`system/`, `hw/`, `ee/`, `sw/`) mit `<disziplin>-design.md` und `<disziplin>-tests.md`. Optional `sw/sw-detail-design.md`.
* Projektübergreifend liegen `doc/project.md`, `doc/requirements.md` und `doc/feasibility.md` direkt unter `doc/`.

## Tests

* Ztest, Testnamen `test_<funktion>_<erwartetes_verhalten>`.
* Jede neue Logik bekommt Unit Tests, Hardware wird gemockt oder per Emulation ersetzt.
* Reihenfolge bei neuen Features: Datenmodell, reine Logik, Tests, Hardware-Anbindung, Verdrahtung in `main.c`.
* Standard-Testumgebung ist `native_sim`.

## Verifikation

* Nie behaupten, etwas kompiliere, bestehe Tests oder laufe auf der Hardware, wenn es nicht geprüft wurde.
* Wo Prüfung nicht möglich ist (z.B. keine Hardware), das klar sagen.

Prüfstufen, jeweils einzeln benennen:

1. Gebaut: `west build` für das Zielboard ist ohne Fehler und neue Warnungen durchgelaufen.
2. Host-getestet: `twister` auf `native_sim` ist grün.
3. Auf Hardware geprüft: geflasht und beobachtet (Log, Messung). Nur der Benutzer kann das bestätigen, wenn der Agent keinen Hardware-Zugriff hat.

Bei jeder Rückmeldung:

* Angeben, welche Stufen erreicht wurden, mit dem ausgeführten Befehl und dem Ergebnis.
* Fehlgeschlagene oder übersprungene Prüfungen nennen, mit der Ausgabe. Nichts schönreden.
* Einen Test nie abschwächen, auskommentieren oder löschen, nur damit er besteht. Ist der Test falsch, das begründen.
* Eine Änderung gilt erst als fertig, wenn Build und Host-Tests grün sind und die Doku nachgeführt ist.
* Hardware-Verhalten, das nur vermutet wird (Timing, Pins, Strombedarf), als Annahme kennzeichnen.

## Git

Der Agent bereitet Änderungen vor und erklärt sie. Staging und Commits macht der Benutzer und nicht der Agent. Git-Befehle werden vorgeschlagen, nicht ausgeführt.

## Antworten

* Deutsch, kurz und knapp.
* Bei neuer Hardware die verwendeten Pins erklären.
* In Markdown ist HTML erlaubt, wo es nützlich ist (z.B. Anker). Keine versteckten Kommentare ohne Begründung. Die GitHub-Vorschau stellt manches anders dar als die VS-Code-Vorschau, daher bei HTML beide beachten.
