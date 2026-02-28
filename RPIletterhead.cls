\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{RPIletterhead}[2026/02/24 RPI generic institutional letterhead]

% --------------------------------------------------------------------------
% Department option processing
% --------------------------------------------------------------------------
\def\LH@dept{none}
\newcommand{\LH@declaredepartmentoption}[1]{%
  \DeclareOption{department=#1}{\def\LH@dept{#1}}%
}
\LH@declaredepartmentoption{MANE}
\LH@declaredepartmentoption{FOCI}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{article}}
\ProcessOptions\relax

\LoadClass[10pt]{article}

\RequirePackage[letterpaper]{geometry}

\RequirePackage{iftex}
\RequirePackage{fontspec}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\RequirePackage{eso-pic}
\RequirePackage{lastpage}
\RequirePackage{xparse}
\RequirePackage{etoolbox}

\ifPDFTeX
  \ClassError{RPIletterhead}{This class requires XeLaTeX or LuaLaTeX (fontspec is used)}{Compile with xelatex or lualatex.}
\fi

\IfFileExists{fonts/RPIGeist-Regular.otf}{%
  \setmainfont{RPIGeist-Regular.otf}[
    Path=fonts/,
    BoldFont=RPIGeist-Bold.otf,
    ItalicFont=RPIGeist-RegularItalic.otf,
    BoldItalicFont=RPIGeist-BoldItalic.otf
  ]%
}{%
  \IfFontExistsTF{RPI Geist}{%
    \setmainfont{RPI Geist}%
  }{%
    \ClassWarningNoLine{RPIletterhead}{Font 'RPI Geist' not found. Falling back to Latin Modern Roman}%
    \setmainfont{Latin Modern Roman}%
  }%
}

% Normal body text: 9.6pt with 1.2× leading (11.52pt baseline skip)
\renewcommand{\normalsize}{\fontsize{9.6}{11.52}\selectfont}
\normalsize

% Label size: 0.95 × 9.6pt = 9.12pt, used for headings (DEPARTMENT, CONTACT, TO, date, footers)
% Baseline skip: 1.2 × 9.12pt ≈ 10.94pt
\newcommand{\LH@labelsize}{\fontsize{9.12}{10.94}\selectfont}

% Savebox for measuring sidebar content height
\newsavebox{\LH@sidebarbox}
\newsavebox{\LH@deptbox}
\newsavebox{\LH@contactbox}
% Savebox for measuring TO and SUBJECT blocks in the right column
\newsavebox{\LH@tobox}
\newsavebox{\LH@subjectbox}

% --------------------------------------------------------------------------
% Generic defaults
% --------------------------------------------------------------------------
\newcommand{\LH@logoFile}{logos/RPI_Logo.pdf}
\newcommand{\LH@smallLogoFile}{logos/RPI_Logo.pdf}

\newcommand{\LH@date}{\LH@today}
\newcommand{\LH@signature}{}

\newcommand{\LH@departmentTitle}{DEPARTMENT}
\newcommand{\LH@departmentText}{Insert department or\\office name here}

\newcommand{\LH@contactTitle}{CONTACT}
\newcommand{\LH@contactText}{email@rpi.edu\\P +1 518 276 6000\\F 000 000 0000}

\newcommand{\LH@toTitle}{TO}
\newcommand{\LH@toText}{Name Surname\\100 Street Avenue\\New York, NY 10001}
\newcommand{\LH@subjectTitle}{SUBJECT}
\newcommand{\LH@subjectText}{}

\newcommand{\LH@footerPageOneLeft}{RPI.EDU}
\newcommand{\LH@footerCenter}{BUILDING, 110 EIGHTH ST TROY NY 12180}
\newcommand{\LH@footerContRightText}{RPI.EDU}

% Shared fallback used when logo assets are missing
\newcommand{\LH@logoFallbackText}{\textbf{RPI}}

% --------------------------------------------------------------------------
% Date formatting (zero padded mm.dd.yyyy)
% --------------------------------------------------------------------------
\newcommand{\LH@twodigits}[1]{\ifnum#1<10 0\fi\number#1}
\newcommand{\LH@today}{\LH@twodigits{\month}.\LH@twodigits{\day}.\number\year}

% --------------------------------------------------------------------------
% Public setters
% --------------------------------------------------------------------------
\NewDocumentCommand{\letterheadlogo}{m}{\renewcommand{\LH@logoFile}{#1}}
\NewDocumentCommand{\letterheadsmalllogo}{m}{\renewcommand{\LH@smallLogoFile}{#1}}
\NewDocumentCommand{\letterdate}{m}{\renewcommand{\LH@date}{#1}}
\renewcommand{\date}[1]{\renewcommand{\LH@date}{#1}}
\NewDocumentCommand{\signature}{m}{\renewcommand{\LH@signature}{#1}}

\NewDocumentCommand{\department}{m}{\renewcommand{\LH@departmentText}{#1}}
\NewDocumentCommand{\contactinfo}{m}{\renewcommand{\LH@contactText}{#1}}
\NewDocumentCommand{\recipient}{m}{\renewcommand{\LH@toText}{#1}}

\NewDocumentCommand{\footerpageoneleft}{m}{\renewcommand{\LH@footerPageOneLeft}{#1}}
\NewDocumentCommand{\footercenter}{m}{\renewcommand{\LH@footerCenter}{#1}}
\NewDocumentCommand{\footercontinuationright}{m}{\renewcommand{\LH@footerContRightText}{#1}}

% --------------------------------------------------------------------------
% Layout dimensions (tune these to match brand template)
% Coordinates are absolute from top-left page corner for overlay nodes.
% --------------------------------------------------------------------------
% .25in + .08 cell margin
\newlength{\LH@sidebarX}      \setlength{\LH@sidebarX}{.33in}
\newlength{\LH@sidebarY}      \setlength{\LH@sidebarY}{2in}
\newlength{\LH@sidebarWidth}  \setlength{\LH@sidebarWidth}{1.62in}

\newlength{\LH@toX}           \setlength{\LH@toX}{1.87in}
\newlength{\LH@toY}           \setlength{\LH@toY}{2in}
\newlength{\LH@toWidth}       \setlength{\LH@toWidth}{5in}

\newlength{\LH@bodyX}         \setlength{\LH@bodyX}{1.87in}
\newlength{\LH@bodyY}         % body y set based on height of the contact info
\newlength{\LH@bodyWidth}     \setlength{\LH@bodyWidth}{5in}
\newlength{\LH@contactY}
\newlength{\LH@subjectY}
\newlength{\LH@toBottomY}
\newlength{\LH@subjectBottomY}

\newlength{\LH@contBodyY}     \setlength{\LH@contBodyY}{1.87in}

% Shared offsets/padding used throughout the overlay layout
\newlength{\LH@cellPad}           \setlength{\LH@cellPad}{0.08in}
\newlength{\LH@footerYOffset}     \setlength{\LH@footerYOffset}{0.4in}
\newlength{\LH@leftMarginX}       \setlength{\LH@leftMarginX}{0.25in}
\newlength{\LH@rightMarginX}      \setlength{\LH@rightMarginX}{0.25in}
\newlength{\LH@firstPagePageNumX} \setlength{\LH@firstPagePageNumX}{0.35in}

\newlength{\LH@logoTopX}          \setlength{\LH@logoTopX}{0.32in}
\newlength{\LH@logoTopY}          \setlength{\LH@logoTopY}{0.19in}
\newlength{\LH@logoTopHeight}     \setlength{\LH@logoTopHeight}{0.84in}

\newlength{\LH@dateTopX}          \setlength{\LH@dateTopX}{0.27in}
\newlength{\LH@dateTopY}          \setlength{\LH@dateTopY}{0.21in}

\newlength{\LH@contLogoHeight}    \setlength{\LH@contLogoHeight}{0.18in}

% --------------------------------------------------------------------------
% Apply body-column geometry (this is the key fix)
% Ensures LaTeX's real text frame matches the intended right column.
% --------------------------------------------------------------------------
\newcommand{\LH@applybodygeometry}{%
  \newgeometry{%
    letterpaper,
    left=\dimexpr\LH@bodyX+\LH@cellPad\relax,
    right=\dimexpr\paperwidth-\LH@bodyX-\LH@bodyWidth+\LH@cellPad\relax,
    top=\LH@contBodyY,
    bottom=1.25in,
    headheight=0pt,
    headsep=0pt,
    footskip=0pt
  }%
}

% Include a logo file with a consistent fallback if the asset is unavailable.
\newcommand{\LH@includeLogo}[3]{%
  \IfFileExists{#1}{%
    \includegraphics[height=#2]{#1}%
  }{%
    #3%
  }%
}

% Measure first-page fixed blocks and compute first-page body start.
% SUBJECT is aligned to CONTACT by using the same Y coordinate.
% Body starts below whichever fixed block extends lowest.
\newcommand{\LH@measurefirstpageblocks}{%
  \savebox{\LH@deptbox}{%
    \parbox[t]{\dimexpr\LH@sidebarWidth-2\LH@cellPad\relax}{%
      \raggedright
      {\bfseries\LH@labelsize \LH@departmentTitle}\par
      \vspace{0.3em}
      \LH@departmentText\par
      \vspace{1.2em}
    }%
  }%
  \savebox{\LH@contactbox}{%
    \parbox[t]{\dimexpr\LH@sidebarWidth-2\LH@cellPad\relax}{%
      \raggedright
      {\bfseries\LH@labelsize \LH@contactTitle}\par
      \vspace{0.3em}
      \LH@contactText
    }%
  }%
  \savebox{\LH@sidebarbox}{%
    \parbox[t]{\dimexpr\LH@sidebarWidth-2\LH@cellPad\relax}{%
      \usebox{\LH@deptbox}\usebox{\LH@contactbox}%
    }%
  }%
  \savebox{\LH@tobox}{%
    \parbox[t]{\dimexpr\LH@toWidth-2\LH@cellPad\relax}{%
      \raggedright
      {\bfseries\LH@labelsize \LH@toTitle}\par
      \vspace{0.3em}
      \LH@toText
    }%
  }%
  \savebox{\LH@subjectbox}{%
    \parbox[t]{\dimexpr\LH@toWidth-2\LH@cellPad\relax}{%
      \raggedright
      \ifdefempty{\LH@subjectText}{}{%
        {\bfseries\LH@labelsize \LH@subjectTitle:}~\LH@subjectText
      }%
    }%
  }%
  \setlength{\LH@contactY}{\dimexpr \LH@sidebarY + \ht\LH@deptbox + \dp\LH@deptbox\relax}%
  \setlength{\LH@subjectY}{\LH@contactY}%
  \setlength{\LH@bodyY}{\dimexpr \LH@contactY + \ht\LH@contactbox + \dp\LH@contactbox\relax}%
  \setlength{\LH@toBottomY}{\dimexpr \LH@toY + \ht\LH@tobox + \dp\LH@tobox\relax}%
  \ifdefempty{\LH@subjectText}{%
    \setlength{\LH@subjectBottomY}{0pt}%
  }{%
    \setlength{\LH@subjectBottomY}{\dimexpr \LH@subjectY + \ht\LH@subjectbox + \dp\LH@subjectbox\relax}%
  }%
  \ifdim\LH@toBottomY>\LH@bodyY\relax
    \setlength{\LH@bodyY}{\LH@toBottomY}%
  \fi
  \ifdim\LH@subjectBottomY>\LH@bodyY\relax
    \setlength{\LH@bodyY}{\LH@subjectBottomY}%
  \fi
}

% --------------------------------------------------------------------------
% Helper: draw first-page overlay (logo/date/sidebar/to block/footer)
% --------------------------------------------------------------------------
\newcommand{\LH@drawfirstpageoverlay}{%
  \AddToShipoutPictureFG*{%
    \begin{tikzpicture}[remember picture,overlay]
      % --- Top-left logo / lockup (placeholder positioning)
      \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@logoTopX,yshift=-\LH@logoTopY]current page.north west) {%
          \LH@includeLogo{\LH@logoFile}{\LH@logoTopHeight}{\LH@logoFallbackText}%
      };

      % --- Date (top-right)
      % for some reason this is slightly inside and down from the top of the logo
      \node[anchor=north east, inner sep=0pt] at ([xshift=-\LH@dateTopX,yshift=-\LH@dateTopY]current page.north east) {%
        {\bfseries\LH@labelsize \LH@date}%
      };

      % --- Sidebar: Department + Contact (fixed box, page 1 only)
      \node[anchor=north west, inner sep=0pt]
        at ([xshift=\LH@sidebarX,yshift=-\LH@sidebarY]current page.north west) {%
          \usebox{\LH@deptbox}%
      };
      \node[anchor=north west, inner sep=0pt]
        at ([xshift=\LH@sidebarX,yshift=-\LH@contactY]current page.north west) {%
          \usebox{\LH@contactbox}%
      };

      % --- TO block (fixed box, page 1 only)
      \node[anchor=north west, inner sep=0pt]
        at ([xshift=\dimexpr\LH@toX+\LH@cellPad\relax,yshift=-\LH@toY]current page.north west) {%
          \usebox{\LH@tobox}%
      };
      \ifdefempty{\LH@subjectText}{}{%
        \node[anchor=north west, inner sep=0pt]
          at ([xshift=\dimexpr\LH@toX+\LH@cellPad\relax,yshift=-\LH@subjectY]current page.north west) {%
            \usebox{\LH@subjectbox}%
        };
      }

      % --- First-page footer (overlay only; page 1 fancy footer disabled below)
      \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@sidebarX,yshift=\LH@footerYOffset]current page.south west) {%
        {\bfseries\LH@labelsize \LH@footerPageOneLeft}%
      };
      \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@bodyX,yshift=\LH@footerYOffset]current page.south west) {%
        {\bfseries\LH@labelsize \LH@footerCenter}%
      };
      \node[anchor=north east, inner sep=0pt] at ([xshift=-\LH@firstPagePageNumX,yshift=\LH@footerYOffset]current page.south east) {%
        {\bfseries\LH@labelsize \thepage}%
      };
    \end{tikzpicture}%
  }%
}

% --------------------------------------------------------------------------
% Continuation page style (page 2+)
% --------------------------------------------------------------------------
\newcommand{\LH@drawcontinuationfooter}{%
  \AddToShipoutPictureFG{%
    \ifnum\value{page}>1\relax
      \begin{tikzpicture}[remember picture,overlay]
        % Left small logo at page margin
        \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@leftMarginX,yshift=\LH@footerYOffset]current page.south west) {%
          \LH@includeLogo{\LH@smallLogoFile}{\LH@contLogoHeight}{\LH@logoFallbackText}%
        };

        % Center footer text left-aligned with body column
        \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@bodyX,yshift=\LH@footerYOffset]current page.south west) {%
          {\bfseries\LH@labelsize \LH@footerCenter\ \ \textbullet\ \ \LH@footerContRightText}%
        };

        % Page number at physical right margin
        \node[anchor=north east, inner sep=0pt] at ([xshift=-\LH@rightMarginX,yshift=\LH@footerYOffset]current page.south east) {%
          {\bfseries\LH@labelsize \thepage}%
        };
      \end{tikzpicture}%
    \fi
  }%
}

\pagestyle{empty}

% --------------------------------------------------------------------------
% Main text area control
% --------------------------------------------------------------------------
\AtBeginDocument{%
  % Apply body-column geometry before any page content is set,
  % so page 1 uses the correct text frame.
  \LH@applybodygeometry

  % Measure fixed first-page blocks used by overlay + body start.
  \LH@measurefirstpageblocks

  % Page-1 overlay artwork / fixed text blocks
  \LH@drawfirstpageoverlay

  % Page-2+ continuation footer
  \LH@drawcontinuationfooter

  % Prevent duplicated page-1 footer (overlay already draws footer on page 1)
  \thispagestyle{empty}
}

% --------------------------------------------------------------------------
% Letter-class-like API
% --------------------------------------------------------------------------
\NewDocumentEnvironment{letter}{m}{%
  \renewcommand{\LH@toText}{#1}%
  % Recompute TO(+SUBJECT) height for this letter's recipient/subject.
  \LH@measurefirstpageblocks
  % Body typography
  \setlength{\parindent}{0pt}
  \setlength{\parskip}{0.55em}
  % Start first-page body text below sidebar bottom.
  % Use class coordinates directly so the shift is stable regardless of runtime page-length internals.
  \vspace*{\dimexpr \LH@bodyY - \LH@contBodyY - \parskip - \topskip\relax}
}{}

% --------------------------------------------------------------------------
% Letter-class-like content commands
% --------------------------------------------------------------------------
\NewDocumentCommand{\opening}{m}{%
  #1\par
}

\NewDocumentCommand{\closing}{m}{%
  \vspace{1.2em}
  #1\par
  \vspace{2.5em}
  \ifdefempty{\LH@signature}{}{\LH@signature\par}
}

\NewDocumentCommand{\cc}{m}{%
  \vspace{1.2em}
  \textbf{cc:}~#1\par
}

\NewDocumentCommand{\encl}{m}{%
  \vspace{0.3em}
  \textbf{encl:}~#1\par
}

\NewDocumentCommand{\ps}{m}{%
  \vspace{1.2em}
  \textbf{P.S.}~#1\par
}

\NewDocumentCommand{\subject}{m}{%
  \renewcommand{\LH@subjectText}{#1}
}

% --------------------------------------------------------------------------
% Department presets
% --------------------------------------------------------------------------
\newcommand{\LH@setpresetfields}[4]{%
  \renewcommand{\LH@logoFile}{#1}%
  \renewcommand{\LH@departmentText}{#2}%
  \renewcommand{\LH@contactText}{#3}%
  \renewcommand{\LH@footerCenter}{#4}%
}

\newcommand{\LH@preset@MANE}{%
  \LH@setpresetfields
    {logos/RPI_Lockup_MechanicalAerospaceandNuclearEngineering_Lg.pdf}
    {Department of Mechanical, Aerospace, and Nuclear Engineering}
    {mane@rpi.edu\\P +1 518 276 6000}
    {2049 JONSSON ENGINEERING CENTER, 110 EIGHTH ST, TROY, NY 12180-3590}%
}

\newcommand{\LH@preset@FOCI}{%
  \LH@setpresetfields
    {logos/RPI_Lockup_FOCI_Md.png}
    {Future of Computing\\Institute}
    {foci@rpi.edu\\P +1 518 276 6000}
    {110 8TH ST TROY NY 12180}%
}

% Apply the selected department preset (if one was selected and exists).
\newcommand{\LH@applyselectedpreset}{%
  \ifdefstring{\LH@dept}{none}{}{%
    \@ifundefined{LH@preset@\LH@dept}{%
      \ClassWarningNoLine{RPIletterhead}{No preset defined for department '\LH@dept'. Using generic defaults}%
    }{%
      \csname LH@preset@\LH@dept\endcsname
    }%
  }%
}
\LH@applyselectedpreset

\endinput
