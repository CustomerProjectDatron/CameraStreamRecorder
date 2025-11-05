# Paketverwaltung (Next Packages)

Diese Dokumentation beschreibt Aufbau, Erstellung und Installation von Paketen sowie das erforderliche `metadata.json` Format.


## Struktur eines Pakets (.nextpkg)

Ein gültiges Paket ist eine ZIP-Datei mit der Dateiendung ".nextpkg" und folgendem Mindestinhalt in der ROOT-Ebene:
```
<PackageName>.nextpkg
 +- metadata.json          (Pflicht)
 +- readme.md              (Optional; überschreibt Description)
 +- <Dateien / Ordner gemäß FileMappings.Source>
 ¦   +- ...
 +- (Bilder für README, falls referenziert)
```

Wichtig:
- `metadata.json` und (falls vorhanden) `readme.md` müssen direkt im Root der ZIP liegen (nicht in Unterordnern).
- Alle in `FileMappings.Source` referenzierten relativen Pfade müssen exakt so im ZIP vorhanden sein.
- Groß-/Kleinschreibung wird beim Suchen nach `metadata.json` / `readme.md` ignoriert.

## Datei: metadata.json

### Schema
```
{
  "Name": "string (Pflicht)",
  "Author": "string (Pflicht)",
  "Description": "string (Optional – wird überschrieben wenn readme.md vorhanden)",
  "FileMappings": [
    {
      "Source": "relativer\\pfad\\zur\\datei.od.ordner",
      "Destination": "<prefix>:\\<optional\\relativer\\unterpfad>"
    },
    {
      "Source": "anderer\\pfad",
      "Destination": "<prefix>:\\<optional\\relativer\\unterpfad>"
    }
  ]
}
```

### Erlaubtes Destination-Schema

`Destination` MUSS mit genau einem der folgenden Präfixe beginnen:
- `machine:`   ? entspricht "Machine"-Ordner in next. Kundensichtbare Programme. Unterordner "Library" kann verwendet werden.
- `internal:`  ? Interne Bibliotheken, nicht kundensichtbar.
- `plugin:`    ? Ordner für externe Anwendungen die über SimPL gestartet werden können.


Beispiele für gültige Destination-Werte:
```
plugin:
plugin:\\MeinPlugin
machine:\\Libraries\\MeineLibrary
internal:\\NichtKundenSichtbareLibrary
```


### FileMappings – Kopierlogik


- `Destination` bestimmt den Zielordner, an den `Source` kopiert wird
- Existiert der Ordner oder die Ordnerstruktur nicht, wird sie automatisch angelegt.
- Ist `Source` ein Ordner, so werden **nur** seine Dateien und Unterordner kopiert. Der Ordner selbst mit seinem Namen wird nicht kopiert
- Eine Umbenennung von Dateien durch `Destination` ist nicht vorgesehen.

### Beispiel metadata.json
```
{
  "Name": "BeispielPlugin",
  "Author": "DATRON",
  "Description": "Fallback Beschreibung – wird ersetzt falls readme.md existiert.",
  "FileMappings": [
    {
      "Source": "plugin\\BeispielPlugin.exe",
      "Destination": "plugin:\\BeispielPlugin"
    },
    {
      "Source": "plugin\\settings.json",
      "Destination": "plugin:\\BeispielPlugin"
    },
    {
      "Source": "library",
      "Destination": "machine:\\Library\\BeispielLibrary"
    }
  ]
}
```

### Beispiel Verzeichnisstruktur (im Paket)
```
BeispielPlugin.nextpkg
 +- metadata.json
 +- readme.md
 +- plugin
 ¦   +- BeispielPlugin.exe
 ¦   +- settings.json
 +- library
     +- BeispielLibrary.simpl 
     +- Anleitung.md
     +- Samples
         +- Sample1.simpl
         +- Sample2.simpl
```

Installationsresultat (schematisch):
```
C:\Program Files (x86)\Datron\Plugins\BeispielPlugin\BeispielPlugin.exe
C:\Program Files (x86)\Datron\Plugins\BeispielPlugin\settings.json
C:\Data\Programs\Library\BeispielLibrary\BeispielLibrary.simpl
C:\Data\Programs\Library\BeispielLibrary\Anleitung.md
C:\Data\Programs\Library\BeispielLibrary\Samples\Sample1.simpl
C:\Data\Programs\Library\BeispielLibrary\Samples\Sample2.simpl
```

## README (optional)

- Datei: `readme.md` im Root.
- Wird vollständig als `PackageMetadata.Description` übernommen.
- unterstützt Markdown und wird vor der Installation in next angezeigt
- Bildreferenzen (Markdown `![](...)`) sind möglich (Pfade müssen im Paket existieren).

## Typische Fehlerquellen

| Fehlermeldung | Ursache | Lösung |
| ------------- | ------- | ------ |
| `Package file not found.` | Pfad zur ZIP falsch | Pfad prüfen |
| `Package metadata file not found.` | `metadata.json` fehlt oder falsch platziert | In Root hinzufügen |
| `Package metadata is invalid.` | Ungültiges JSON oder fehlende Pflichtfelder | JSON validieren |
| `Package metadata is invalid.` | Destination ohne gültiges Präfix | Präfix `machine:`, `internal:` oder `plugin:` verwenden |
| `Failed to install because of an IO error.` | Unerwartete IO-Exception (Sperre, Rechte) | Datei-/Rechte-Situation prüfen |
| `Package file could not be opened.` | ZIP-Datei beschädigt | ZIP-Datei prüfen |


## Erstellung eines Pakets – Schritt für Schritt

1. Arbeitsordner anlegen (Name = geplanter Paketname).
2. `metadata.json` gemäß Schema erstellen (Destination-Präfixe beachten).
3. (Optional) `readme.md` hinzufügen (Markdown, Bilder relative Pfade).
4. Alle referenzierten `Source`-Dateien/Ordner in diesen Root legen.
5. ZIP erzeugen (Inhalt = Root-Inhalt, nicht zusätzlichen übergeordneten Ordner einpacken) und auf `.nextpkg` umbenennen.
6. Datei benennen (z.B. `BeispielPlugin.nextpkg`).
7. Paket durch Installation in next prüfen.


---

Bei Änderungen am Schema bitte diese README aktualisieren.



