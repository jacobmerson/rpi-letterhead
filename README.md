# RPI Letterhead Template

`RPIletterhead.cls` provides an RPI-branded letter format with a `letter` API similar to LaTeX's default `letter` class.

## Requirements
1. Install RPIGeist fonts from [brand.rpi.edu](https://brand.rpi.edu/document/13).
2. Compile with `lualatex` or `xelatex` (not `pdflatex`).

Example build commands:
- `lualatex letter.tex`
- `xelatex letter.tex`
- `latexmk -xelatex letter.tex`

## Example Usage
```tex
\documentclass[department=MANE]{RPIletterhead}

\date{06.30.2025}
\signature{Name\\Assistant Professor}
\subject{Optional subject line}

% Optional overrides for preset values:
\contactinfo{email@rpi.edu\\P +1 518 276 XXXX}

\begin{document}
\begin{letter}{Name Surname\\100 Street Avenue\\New York, NY 10001}
\opening{Dear Name,}
Body paragraph one.

Body paragraph two.

\closing{Sincerely,}
% Optional:
% \cc{Person A, Person B}
% \encl{CV}
\end{letter}
\end{document}
```

## Adding a New Department
Department support has two parts in `RPIletterhead.cls`: option declaration and preset definition.

1. Add the option token in the department option section near the top of the class:
```tex
\LH@declaredepartmentoption{CHEM}
```

2. Add a preset macro in the department preset section:
```tex
\newcommand{\LH@preset@CHEM}{%
  \LH@setpresetfields
    {logos/RPI_Lockup_CHEM_Lg.pdf}
    {Department of Chemistry and Chemical Biology}
    {chem@rpi.edu\\P +1 518 276 6000}
    {BUILDING NAME, 110 EIGHTH ST, TROY, NY 12180}%
}
```

3. Use it in a document:
```tex
\documentclass[department=CHEM]{RPIletterhead}
```

Notes:
- `\subject{...}` is header metadata in this template; set it before `\begin{letter}{...}` so it appears in the fixed TO/SUBJECT block.
- The option value in `department=...` must match the suffix in `\LH@preset@...` exactly.
- If a preset is missing for a declared department option, the class falls back to generic defaults and emits a warning.
- Keep logo assets in `logos/` and reference them with paths relative to the `.tex` file.
