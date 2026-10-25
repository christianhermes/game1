# ENTWICKLUNGSPLAN – umsetzbare Roadmap für Codex

**Stand: 2026-10-25.** Dies ist eine **Vorschlagsreihenfolge**, kein Auftrag zur automatischen Umsetzung. Beschlossene Zielmechaniken stehen ausschließlich in [SPIELVISION.md](SPIELVISION.md); Arbeitsregeln in [AGENTS.md](AGENTS.md). Der ursprüngliche ausführliche Plan mit älteren Third-Person-/Esel-Phasen bleibt unverändert in [docs/archiv/ENTWICKLUNGSPLAN_2026-10-25.md](docs/archiv/ENTWICKLUNGSPLAN_2026-10-25.md) erhalten und ist **nicht verbindlich**.

## Aktueller Fokus
**Zuerst den Godot-Iststand validieren.** In den bisherigen Aufgaben sind bereits Bewohneraufträge, Bauplatzierung und zeitgesteuerte Bauarbeit beschrieben. Daher nicht blind dieselben Features erneut entwickeln. Danach **einen** fehlenden/instabilen vertikalen Schnitt aus der neuen Basisperspektive auswählen: isometrische Kamera und Mausbefehle → eigener Bewohner führt einen Auftrag zuverlässig aus. Die genaue nächste Aufgabe erst nach Codeprüfung festlegen.

## 3. Arbeitsprotokoll für Codex (verpflichtend)

### 3.1 Start jeder neuen Aufgabe
1. Nutzerziel in einem Satz wiedergeben.
2. Relevante Dateien und Szenen lesen; nicht allein auf Dateinamen oder Dokumentation vertrauen.
3. Feststellen: bereits vorhanden / teilweise / fehlt / unklar.
4. Relevante Abhängigkeiten, Regressionen und offene Designfragen nennen.
5. **Eine** zusammenhängende, sichtbare und testbare Ausbaustufe vorschlagen.
6. Bei Tutor-Modus: konkrete Aufgabe + Hinweise + Abnahmekriterien; nicht ungefragt editieren.
7. Bei ausdrücklich angefordertem Ausführungsmodus: gezielt implementieren, testen, Änderungen erklären.
8. Bei `fertig`/`done`/`ok`: zuerst die aktuelle Umsetzung prüfen, **danach** neue Aufgabe stellen.

### 3.2 Definition of Done (für jeden Meilenstein)
- Funktion aus Spielersicht nutzbar, nicht nur Klasse oder Variable vorhanden.
- Vorhandene Mechaniken bleiben funktionstüchtig.
- Fehler- und Grenzfälle sind definiert (leer, voll, ungültige ID, fehlendes Material, Unterbrechung).
- Szenen/Signale/Exports/Resources passen zusammen.
- Test in Godot dokumentiert, falls ausführbar; sonst ausdrücklich `NICHT LAUFZEITGETESTET`.
- Keine unbeabsichtigten Änderungen am Browser-Prototyp.
- Nur relevante Dateien verändert; Änderungen kurz nachvollziehbar erklärt.
- Dokumentation und Status erst nach Prüfung aktualisiert.
- Ein klarer nächster Schritt genannt, aber nicht automatisch begonnen.

### 3.3 Testbericht
Jede Implementierung endet mit:
`GEÄNDERT:` Dateien und Verhalten;
`GETESTET:` konkret ausgeführte statische/automatische/Editor-Tests;
`MANUELL TESTEN:` konkrete Schritte in Godot;
`OFFEN:` Risiken, Grenzen, Folgeentscheidungen.
Keine Tests erfinden.

### 3.4 Architekturregeln
- Godot-typisch: Szenen/Nodes für Weltobjekte, Resources für Stammdaten, Signale für Zustandsänderungen.
- Ein Zustand hat eine klare verantwortliche Datenquelle; UI zeigt ihn nur an.
- Keine große globale Allzweck-Klasse, kein vorschnelles generisches Framework.
- Zuerst einfacher vertikaler Gameplay-Schnitt, danach Generalisierung bei nachgewiesenem Bedarf.
- Gegenstandsbewegungen möglichst über überprüfbare Transaktionen: Entnahme nur bei ausreichender Menge, Einlagerung nur bei Platz, kein stiller Verlust oder Duplikation.
- Bei späterer Zeit-/Speicherarchitektur eindeutige IDs für persistente Weltobjekte vorsehen.
- Neue Systeme nicht unbemerkt an alte Browser-Globals koppeln.

## 4. Aktualisierte Roadmap auf einen Blick (Vorschlag zur Reihenfolge)

| Phase | Ergebnis | Priorität |
|---|---|---|
| P0 | Bestehenden Godot-Code testen, Kamera-/Input-Abhängigkeiten prüfen | Sofort |
| P1 | Isometrische Basiskamera, Mausauswahl, Befehls-UI | **Nächster empfohlener Meilenstein** |
| P2 | Eigener Charakter als erster NPC: Gehen, Auftrag annehmen, ausführen, abbrechen | Sehr hoch |
| P3 | Ruinen-V1: ein abtragbarer Schutthaufen mit Ressourcen, ein restaurierbarer Bauplatz | Hoch |
| P4 | Bauplan/Raster/Materiallieferung und Bauarbeit durch NPC; Materialvalidierung korrigieren | Hoch |
| P5 | Slots/Stacks, physische Kisten, verlustfreie Transaktionen | Hoch |
| P6 | NPC-Transport zwischen Fundstelle, Kiste, Baustelle und Werkstation; Reservierungen | Hoch |
| P7 | Zeitmodell, Save/Load und Hintergrundfortschritt bei Szenenwechsel | Hoch |
| P8 | Werkstationen: Bewohnerarbeit vs. passive Zeitproduktion, lokale Materialquellen | Hoch |
| P9 | Zusätzlicher NPC, Prioritäten, einfache Fähigkeiten; Rekrutierung als separater kleiner Schnitt | Mittel |
| P10 | Expedition mit direkter Steuerung; Basis läuft im Hintergrund weiter | Mittel |
| P11 | Raumdetektion und Funktionsräume (Hauptfunktion C, Pflichtobjekte, NPC-Arbeitsplätze, lokale Lager), danach Nahrung, Landwirtschaft, Forschung und besondere Rekrutierung | Später; frühere kleine Raum-V1 möglich, sobald Bauen/NPCs/Lager stehen |
| P12 | Isometrische NPC-Basisverteidigung | Sehr spät |
| P13 | Tiere, komplexere NPC-Beziehungen, direkte Übernahme bei Basisschlachten | Zukunft |

**Wichtig:** Die nachfolgenden historischen Detailkapitel P1–P13 wurden für den alten Third-Person-/Esel-Plan geschrieben. Sie sind **nicht mehr die verbindliche Implementierungsreihenfolge**. Nur allgemeingültige technische Abnahmeregeln (z. B. Materialintegrität, Raster, Inventar) weiterverwenden. Eselspezifische und spieler-manuelle Arbeitsanweisungen sind überholt. Die neuen Phasen oben haben Vorrang. Vor Implementierung jeweils nur den aktuellen Meilenstein im Detail spezifizieren und Code erneut prüfen.

---

## Noch zu entscheiden (nicht stillschweigend festlegen)
- Raster, Bauabbruch, Materialrückgabe und Raumdetektion.
- Slots, Stapelgrößen, Kistenkapazitäten und lokale Zugriffsradien.
- NPC-Navigation, Transportprioritäten, Reservierungen und Blockadeverhalten.
- Zeitmodell, Szenenwechsel, Save/Load und Hintergrundsimulation.
- Frische-Schwellen, Nahrung, Landwirtschaft und Kampfbalance.

**Regel:** Reversible V1-Optionen als Vorschlag kennzeichnen; wichtige Designfragen vom Nutzer entscheiden lassen.

## Abschlussprotokoll pro Meilenstein
Datum · Nutzerauftrag · geprüfte Dateien · Iststand · Änderungen · tatsächlich getestete Funktionen · manuelle Tests · offene Probleme · nächster Vorschlag. Abgeschlossen nur nach nachgewiesener Prüfung.

## Startanweisung für Codex
Lies AGENTS.md, die relevanten Abschnitte von SPIELVISION.md und diesen Plan. Prüfe dann Kamera, Input, Player, Job-Manager, Navigation, Baustelle und Hauptszene im **aktuellen** Godot-Code. Benenne bereits vorhandene Funktionen und echte Lücken. Schlage einen kleinen testbaren nächsten Schritt vor. **Keine Codeänderung ohne ausdrücklichen Auftrag.**
