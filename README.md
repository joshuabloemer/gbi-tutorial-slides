## Installation

1. Setze einen (symbolischen) Link von dem Repo (das Verzeichnis wo die preamble.tex liegt) auf /opt/gbi-slides.
   
   - Linux: ln -s:
     
     - ln -s {pfad zum repo} /opt/gbi-slides
   
   - Windows: 
     
     - mkdir \opt
     
     - mklink /d \opt\gbi-slides {pfad zum repo}

2. Installiere ggf. [Ipe](https://ipe.otfried.org/), python >= 3.11 und latex.

3. Füge die IPE Installation zum PATH hinzu 

4. Kopiere die ipelets in den ipelets folder deiner IPE installation

5. `python ./make.py --all` sollte jetzt ohne Fehler laufen und in jedem tutXX Verzeichnis eine PDF-Datei generieren.

## Beispiel Installlation unter Windows
- Installiere IPE und [MikTeX](https://miktex.org/) unter Windows
- In CMD
  - `mkdir \opt`
  - `mklink /d \opt\gbi-slides {pfad zum repo}`
y
Jetzt müssten die Folien schon in IPE Editierbar und Exportierbar sein


Die Inhalte der Tutorien sind im ordner content aufgeteilt auf ein Dokument pro Thema. Um die Themen zusammenzufügen muss im Ordner tutXX eine tutXX.toml Datei angelegt werden in der der Titel des PDFs, die Beschreibung des Tutoriums, die Foliensätze und das xkcd was am Ende gezeigt werden soll festgelegt werden.

Danach können mit `python ./make.py` die PDFs exportiert werden. 

## PDFs exportieren

`python ./make.py --files tut01 ... tut0N`

Exportiert PDFs für die angegebenen Ordner

`python ./make.py --all`

Exportiert alle PDFs 

`python ./make.py --clean`

Löscht alle PDFs und generierten IPE Dateien

--all und -- files können mit --print kombiniert werden um PDFs ohne clicks zu exportieren, dafür wird für jede Seite nur die letzte View genommen.
## Bearbeiten

- Die .ipe-Dateien können einfach mit Ipe bearbeitet werden (z.B. ipe content/orga.ipe)
- Beachte [Doku von Ipe](https://ipe.otfried.org/manual/manual.html) (insb. über [Präsentationen](https://ipe.otfried.org/manual/manual_presentations.html)) 
- In jedem Foliensatz stehen die Makros aus preamble.tex zur Verfügung (z.B. \impl, \gdw oder \olim)

