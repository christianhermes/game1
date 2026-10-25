# AGENTS.md – Arbeitsregeln für Codex

**Aktiv:** ausschließlich `survival-game/godot/` (Godot 4). Die alten HTML/CSS/JavaScript-Dateien nicht lesen, ändern, testen oder als Referenz verwenden, sofern der Nutzer sie nicht ausdrücklich reaktiviert.

## Vor jeder Aufgabe lesen
1. Diese Datei (Arbeitsmodus und Prioritäten).
2. [SPIELVISION.md](SPIELVISION.md) nur soweit die betroffene Spielmechanik es erfordert (verbindliche Designentscheidungen).
3. [ENTWICKLUNGSPLAN.md](ENTWICKLUNGSPLAN.md) für aktuellen Meilenstein, Reihenfolge und Abnahme.
4. Relevanten **aktuellen Godot-Code**, Szenen, Ressourcen und Signale; der Code allein belegt, was implementiert ist.
5. [OFFLINE_AUFGABEN.md](OFFLINE_AUFGABEN.md) bei Bezug zu den bisherigen Übungsaufgaben; [godot/DATENFLUSS.md](godot/DATENFLUSS.md) als technische Erklärung, nicht als garantierten aktuellen Gesamtstand.

## Quellenhierarchie
1. Neueste ausdrückliche Nutzerentscheidung.
2. Aktueller Code für Aussagen über implementierte Funktionalität.
3. SPIELVISION.md für beschlossene Zielmechaniken.
4. Diese AGENTS.md für Arbeitsmodus.
5. ENTWICKLUNGSPLAN.md für **vorgeschlagene** Umsetzungsschritte.
6. Alte Aufgaben, Datenfluss-Dokumente und [Archiv](docs/archiv/) als historische Referenz.

Bei Widersprüchen nicht eigenmächtig umdeuten. **Planung ist kein Implementierungsauftrag.**

## Arbeitsmodus
- **Standard = Tutor:** Erkläre eine kleine, eigenständig lösbare Aufgabe, gib Hinweise und Abnahmekriterien. Keine Dateiänderung ohne ausdrücklichen Auftrag.
- **Ausführungsmodus:** Nur wenn der Nutzer explizit Änderungen beauftragt. Vorher Iststand prüfen, dann gezielt umsetzen; keine ungefragten Folgephasen.
- Bei „fertig“ zuerst den tatsächlich vorhandenen Code prüfen, nicht automatisch die nächste Aufgabe als erledigt markieren.
- Nur einen sichtbaren, spielbaren vertikalen Schnitt gleichzeitig; keine voreilige Generalisierung oder großen Frameworks.
- Bestehende Funktionen erhalten; bei Inventar/Materialtransport keine stillen Verluste, Duplikate oder Doppelverwendung.
- Godot-Szenen/Nodes für Weltobjekte, Resources für Daten, Signale für Änderungen; UI ist nicht Eigentümer der Bestände.

## Test- und Abschlussbericht
- `GEÄNDERT:` betroffene Dateien und Verhalten.
- `GETESTET:` tatsächlich durchgeführte Prüfungen; **keine** erfundenen Godot-Laufzeittests.
- `MANUELL TESTEN:` konkrete Schritte im Godot-Editor/Spiel.
- `OFFEN:` Risiken, Blockaden und nächster **vorgeschlagener** Schritt.

## Aktuelle Orientierung (kein automatischer Auftrag)
Die verbindliche neue Richtung ist: isometrische Siedlungsübersicht, derselbe Held als erster autonomer Bewohner, NPC-Arbeit und physische Lager/Transporte; Expeditionen mit direkter Steuerung. **Der Esel ist nicht mehr frühe Kernlogistik.** Vor einer neuen Aufgabe die tatsächlich vorhandene Kamera-, Befehls- und Job-Implementierung prüfen. Details: [SPIELVISION.md](SPIELVISION.md), priorisierte Schritte: [ENTWICKLUNGSPLAN.md](ENTWICKLUNGSPLAN.md).
