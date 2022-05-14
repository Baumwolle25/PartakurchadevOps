# Übung: Pixeldecoder:
# Das unten stehende Programm soll ein hinterlegtes Bild auf der LED-Matrix ausgeben.
# Leider ist die Funktion 'decode', welche die Pixelinformationen richtig umkodiert, verloren gegangen!
# Ihre Aufgabe ist es, die Funktion zu implementieren. Decode wird mit einem Wert in Register a0 aufgerufen.
# Der Wert enthält die Spalten(X)- und Zeilen(Y)informationen über den jeweiligen Pixel und welche Farbe R = Rotwert, G = Grünwert, B = Blauwert dieser annehmen soll.
# Das Argument in a0 wird ihnen nach dem folgenden Schema übergeben.
# a0 = XY RR GG BB
# Sie müssen die Zeilen und Spalteninformationen extrahieren und in dem Register a1 nach dem folgenden Schema zurückgeben:
# a1 = 0x XX XX YY YY
# Die Werte sind in Big-Endian kodiert, die niederwertigsten Stellen sind also rechts.
# In Register a2 sollen Sie die Farbinformationen nach folgendem Schema zurückgeben.
# a2 = 0x NN RR GG BB
# Das Byte 'NN' darf einen beliebigen Wert annehmen.
# Bei erfolgreichem Programmablauf wird ein Bild auf der LED-Matrix ausgegeben.
# Viel Spaß!

.text
         la s0, image
begin:   lw s2, 0(s0)
         beq s2, zero, end
         mv a0, s2
         jal decode
         li a0, 0x100
         ecall
         addi s0, s0, 4
         j begin


end:     li a0, 10
         ecall


# +=============================+
# |           decode            |
# +----------Parameter----------+
# | a0 = Kodierung der          |
# | Pixelwerte nach Schema      |
# | 0xXYRRGGBB                  |
# +--------Rückgabewerte--------+
# | a1 = X und Y Werte nach     |
# | Schema 0xXXXXYYYY           |
# | a2 = RGB Werte nach Schema  |
# | 0x NNRRGGBB (N = beliebig)  |
# +=============================+

# Tipp: Überschreiben Sie keine saved Register.
decode:
# +===================Start Ihres Codes===================+
         nop




         ret
# +===================Ende Ihres Codes===================+

.data
image:   .word 0x4122B14C
         .word 0x5122B14C
         .word 0x3222B14C
         .word 0x4222B14C
         .word 0x6222B14C
         .word 0x2322B14C
         .word 0x4322B14C
         .word 0x5322B14C
         .word 0x7322B14C
         .word 0x1422B14C
         .word 0x2422B14C
         .word 0x3422B14C
         .word 0x5422B14C
         .word 0x6422B14C
         .word 0x8422B14C
         .word 0x3522B14C
         .word 0x4522B14C
         .word 0x6522B14C
         .word 0x2622B14C
         .word 0x4622B14C
         .word 0x5622B14C
         .word 0x7622B14C
         .word 0x1722B14C
         .word 0x2722B14C
         .word 0x3722B14C
         .word 0x5722B14C
         .word 0x6722B14C
         .word 0x8722B14C

         .word 0x52EFE4B0
         .word 0x33EFE4B0
         .word 0x63EFE4B0
         .word 0x44EFE4B0
         .word 0x74EFE4B0
         .word 0x55EFE4B0
         .word 0x36EFE4B0
         .word 0x66EFE4B0
         .word 0x47EFE4B0
         .word 0x77EFE4B0

         .word 0x48B97A57
         .word 0x58B97A57
         .word 0x49B97A57
         .word 0x59B97A57

         .word 0x88ED1C24

         .word 0x15FFC90E
         .word 0