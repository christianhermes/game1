# Godot-Spielprototyp

Dieser Ordner enthält den aktiven Godot-4-Prototyp für Charaktersteuerung,
Basisübersicht, Interaktion, Farming, Verarbeitung und Bauen. Die alten
HTML/CSS/JavaScript-Dateien im übergeordneten Ordner werden vollständig
ignoriert und dienen auch nicht mehr als Referenz.

## Starten

1. `project.godot` im Godot Project Manager importieren.
2. Das Projekt öffnen.
3. Mit **F6** oder **F5** starten.

## Zwischen den Spielmodi wechseln

Mit **Tab** wird zwischen zwei Steuerungsarten gewechselt:

### Charaktermodus

- **WASD:** Charakter bewegen
- **F:** Mit einem nahen Objekt interagieren
- **E:** Ausgewähltes Essen benutzen
- **1–9 / Mausrad:** Hotbar auswählen

### Basismodus

- **WASD:** Kamera über die Basis bewegen
- **Q / E:** Kamera drehen
- **Mausrad:** Kamera zoomen
- **B:** Vorhandenen Baumodus ein- oder ausschalten

Der Baumodus zeigt momentan nur die bereits vorhandene Bauvorschau. Freie
Platzierung und Bewohneraufträge folgen in späteren, getrennten Schritten.

## Aktueller Szeneninhalt

- einfache 3D-Fläche mit Kollision
- Sonne und Umgebungslicht
- orthografische Kamera mit Charakterfolge und freier Basisübersicht
- beweglicher Player mit Interaktionsradius
- ein wiederverwendbares Weizenfeld
- einfache Werkstationen und eine Holzmauer-Baustelle

