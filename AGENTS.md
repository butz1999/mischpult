# AGENTS.md

Arbeitsregeln für Agenten in diesem Repository. Was gebaut wird und warum, steht in [doc/project.adoc](doc/project.adoc). Dieses Dokument regelt nur, wie der Agent arbeitet.

## Rolle

Embedded-Experte für Zephyr RTOS auf ESP32-S3. Schreibt stabilen, getesteten, dokumentierten C++-Code.

## Vorrang bei Widersprüchen

1. `doc/project.adoc` (Projektauftrag)
2. `doc/requirements.adoc`, dann `doc/system/system-design.adoc`, dann `doc/hw/hw-design.adoc`, `doc/ee/ee-design.adoc`, `doc/sw/sw-design.adoc`
3. Build-Konfiguration (`prj.conf`, Devicetree, `CMakeLists.txt`)
4. `AGENTS.md` (Arbeitsregeln)

Widersprüche explizit melden, keine stillen Annahmen.

## Umgebung

* Entwicklung unter WSL. Flashen und Seriell-Zugriff: WSL-Annahmen (z.B. usbipd) benennen.
* Build, Test und Flash mit `west` und `twister`.
* Toolchain: Zephyr SDK (GCC, `xtensa-espressif_esp32s3_zephyr-elf`). Lokal installiert ist `~/zephyr-sdk-1.0.1`.
* Zielplattform: ESP32-S3 DevKit (Board-Name vor der Verwendung prüfen).
* Host-Tests laufen auf `native_sim`.

## Projektstruktur

Die Struktur wird mit dem System Design festgelegt und hier nachgeführt. Bis dahin gilt:

* Dokumentation unter `doc/`
* Anwendung als Zephyr-Applikation, Tests mit Ztest unter `tests/`
* Prototypen der Machbarkeitsphase unter `feasibility/`
* `main.cpp` enthält möglichst keine Logik

## Zephyr-Regeln

* Hardware wird per Devicetree beschrieben, Konfiguration per Kconfig.
* Bestehende Zephyr-Treiber und -Subsysteme verwenden, keine eigenen Treiber, solange es nicht zwingend ist (siehe `doc/project.adoc`).
* Keine Pins oder Adressen im Code hartkodieren.
* Keine Busy-Waits. Zeitverhalten über Timer, Work-Queues oder Threads.
* Eigener Code allokiert nicht dynamisch. Kein `malloc`/`k_malloc`, kein `new`/`delete`, kein `alloca`, keine VLAs, keine STL-Container mit Heap (z.B. `std::vector`, `std::string`). Statische Zephyr-Mechanismen verwenden (`K_THREAD_DEFINE`, `K_MSGQ_DEFINE`, `K_MEM_SLAB_DEFINE`).
* Ausnahme: Allokation nur beim Aufstarten, mit Begründung. Bibliotheken dürfen den Heap intern nutzen. Die Pool-Grösse wird dann bewusst per Kconfig festgelegt.
* Rückgabewerte von Zephyr-APIs prüfen, Fehler loggen (`LOG_*`).
* Fehler in eigenem Code mit `std::expected<T, E>` zurückgeben, nicht mit Ausnahmen.
* Neue Kconfig-Optionen und Devicetree-Overlays kurz begründen.

## Code-Stil

* C++23 (per Kconfig, `CONFIG_CPP` und `CONFIG_STD_CPP23`), Kommentare auf Englisch. Ein anderer Standard braucht eine Begründung. Fällt die Standardbibliothek in Zephyr bei C++23 aus, ist C++20 der Rückfall.
* Moderne C++-Features nutzen, wo sinnvoll: `constexpr`, `enum class`, `std::array`, `std::span`, `std::expected`, `std::to_underlying`, `auto`, `nullptr`, `using`-Aliase.
* Nicht verwenden: `std::print`, `<format>`, `std::generator`, `std::move_only_function` und weitere Features, die Heap brauchen oder viel Code erzeugen.
* Ausnahmen (Exceptions) und RTTI bleiben ausgeschaltet.
* Zephyr-C-APIs werden direkt aus C++ aufgerufen. Eigene Header, die auch von C genutzt werden, brauchen `extern "C"`.
* Speicherbedarf und Ressourcen gehen immer vor C++-Komfort. Im Zweifel die schlankere Lösung.
* Zephyr-Namenskonventionen und `.clang-format` des Projekts. Auch für C++ gilt der Zephyr-Stil, solange das Projekt nichts anderes festlegt.
* Als letzten Schritt `clang-format -i` auf geänderte Dateien. Ist es nicht verfügbar, melden.
* Fachlogik (z.B. PID-Regler) hardwareunabhängig halten, damit sie auf `native_sim` testbar ist.
* Neue Bibliotheken nur, wenn nötig, und mit Begründung.

## Dokumentation und Code

* Doku und Code müssen übereinstimmen. Jede Änderung führt die betroffene Doku im selben Schritt nach.
* Regeln zu IDs und Verweisen: siehe Abschnitt Nachverfolgbarkeit.
* Dokumente sind AsciiDoc (`.adoc`) unter `doc/`, auf Deutsch geschrieben. Dateinamen, Code und Code-Kommentare sind englisch.
* Pro Disziplin ein Ordner unter `doc/` (`system/`, `hw/`, `ee/`, `sw/`) mit `<disziplin>-design.adoc` und `<disziplin>-tests.adoc`. Optional `sw/sw-detail-design.adoc`.
* Projektübergreifend liegen `doc/project.adoc`, `doc/requirements.adoc`, `doc/feasibility.adoc` und `doc/glossary.adoc` direkt unter `doc/`.
* Begriffe und die bevorzugte Schreibweise stehen in `doc/glossary.adoc`. Neue Fachbegriffe dort ergänzen.

## Nachverfolgbarkeit

Die massgebenden Regeln stehen in `doc/requirements.adoc`, Kapitel Nachverfolgbarkeit. Zusammenfassung:

* ID-Präfixe: `REQ` (Anforderung), `SYS`, `HW`, `EE`, `SW` (Spezifikationen), `TC` (Testfall). Jedes Präfix hat einen eigenen Nummernkreis, dreistellig mit führenden Nullen (`SW-007`).
* IDs werden nie geändert oder wiederverwendet. Gelöschte IDs bleiben im Dokument und werden als gelöscht gekennzeichnet.
* Inhaltliche Änderungen ändern die ID nicht. Es gibt bewusst keine Versionierung der IDs.
* Machbarkeitsstudien (`doc/feasibility.adoc`) haben keine IDs und keine Verweise.
* Ergebnisse der Machbarkeit können Anforderungen ändern, ergänzen oder streichen. Der Agent schlägt solche Änderungen an `doc/requirements.adoc` vor und führt sie nicht stillschweigend durch.
* Verweise stehen im nachgelagerten Artefakt und zeigen auf das vorgelagerte: `SYS`-Spezifikation auf `REQ`, `HW`/`EE`/`SW`-Spezifikation auf `REQ` und/oder `SYS`, Testfall auf Spezifikation (bei Bedarf `REQ`), Code auf die Spezifikation.
* Fertige, vorgelagerte Dokumente werden nicht angepasst, nur um auf neue Spezifikationen oder Tests zu verweisen.
* Anforderungen haben vorerst keine IDs, sie stehen als Aufzählung in `doc/requirements.adoc`. Die IDs werden vergeben, sobald die Spezifikationen geschrieben werden. Bis dahin keine `REQ`-IDs vergeben oder verwenden, auch nicht in Verweisen.
* Neue Anforderung, Spezifikation oder Testfall (sobald IDs gelten): nächste freie ID vergeben, nie raten. Ist die Nummer unklar, nachfragen.
* Jede neue `SYS`-Spezifikation nennt mindestens eine `REQ`, jede neue `HW`/`EE`/`SW`-Spezifikation mindestens eine `REQ` oder `SYS`, jeder neue Testfall mindestens eine Spezifikation oder `REQ`. Fehlt der Bezug, das melden, nichts erfinden.
* Das Format des Verweises im Code und die Verbindung von `TC-xxx` zu den Ztest-Namen werden festgelegt, sobald die ersten Tests geschrieben werden. Bis dahin nachfragen.

## Tests

* Ztest, Testnamen `test_<funktion>_<erwartetes_verhalten>`.
* Jede neue Logik bekommt Unit Tests, Hardware wird gemockt oder per Emulation ersetzt.
* Reihenfolge bei neuen Features: Datenmodell, reine Logik, Tests, Hardware-Anbindung, Verdrahtung in `main.cpp`.
* Standard-Testumgebung ist `native_sim`.

### Prototypen der Machbarkeit

* Prototypen liegen unter `feasibility/` und sind von der Testpflicht ausgenommen.
* Prototypen gelten als Wegwerf-Code. Sie fliessen nicht ungeprüft in den Produktivcode. Für die Übernahme wird die Logik neu geschrieben oder überarbeitet, mit Tests.
* Die Verifikationsregeln gelten weiterhin: Was geprüft wurde, wird belegt, nichts wird behauptet.
* `clang-format` gilt auch für Prototypen.
* Ergebnisse (Messwerte, Entscheide) werden in `doc/feasibility.adoc` festgehalten.

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
* In AsciiDoc native Mittel nutzen (Anker `[#id]`, `xref:`, Tabellen, `include::`), kein HTML. Keine versteckten Kommentare ohne Begründung. Die GitHub-Vorschau unterstützt nicht alles, was Asciidoctor kann (z.B. eingeschränktes `include::`), daher Neues dort prüfen.
* `AGENTS.md` und `CLAUDE.md` bleiben Markdown (Konvention der Werkzeuge).
