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

\IfFontExistsTF{RPI Geist}{%
  \setmainfont{RPI Geist}%
}{%
  \ClassWarningNoLine{RPIletterhead}{Font 'RPI Geist' not found. Falling back to Latin Modern Roman}%
  \setmainfont{Latin Modern Roman}%
}

% this is using 1.2*fontsize as baseline skip
\renewcommand{\normalsize}{\fontsize{9.6}{11.52}\selectfont}
\normalsize

% Bold label size (9.12pt) used for headings like DEPARTMENT, CONTACT, TO, date, footers
\newcommand{\LH@labelsize}{\fontsize{9.12}{10.94}\selectfont}

% Savebox for measuring sidebar content height
\newsavebox{\LH@sidebarbox}

% --------------------------------------------------------------------------
% Generic defaults
% --------------------------------------------------------------------------
\newcommand{\LH@logoFile}{logos/RPI_Logo.pdf}
\newcommand{\LH@smallLogoFile}{logos/RPI_Logo.pdf}

\newcommand{\LH@date}{\LH@today}

\newcommand{\LH@departmentTitle}{DEPARTMENT}
\newcommand{\LH@departmentText}{Insert department or\\office name here}

\newcommand{\LH@contactTitle}{CONTACT}
\newcommand{\LH@contactText}{email@rpi.edu\\P +1 518 276 6000\\F 000 000 0000}

\newcommand{\LH@toTitle}{TO}
\newcommand{\LH@toText}{Name Surname\\100 Street Avenue\\New York, NY 10001}

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
          \usebox{\LH@sidebarbox}%
      };

      % --- TO block (fixed box, page 1 only)
      \node[anchor=north west, text width=\dimexpr\LH@toWidth-2\LH@cellPad\relax, align=left, inner sep=0pt]
        at ([xshift=\dimexpr\LH@toX+\LH@cellPad\relax,yshift=-\LH@toY]current page.north west) {%
          {\bfseries\LH@labelsize \LH@toTitle}\par
          \vspace{0.3em}
          \LH@toText
      };

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
  % IMPORTANT: make the text frame match the right-hand body column
  \LH@applybodygeometry

  % Pre-render sidebar content into a savebox to measure its height
  \savebox{\LH@sidebarbox}{%
    \parbox[t]{\dimexpr\LH@sidebarWidth-2\LH@cellPad\relax}{%
      \raggedright
      {\bfseries\LH@labelsize \LH@departmentTitle}\par
      \vspace{0.3em}
      \LH@departmentText\par
      \vspace{1.2em}
      {\bfseries\LH@labelsize \LH@contactTitle}\par
      \vspace{0.3em}
      \LH@contactText
    }%
  }%
  % Compute body Y = sidebar top + sidebar height (no extra gap)
  \setlength{\LH@bodyY}{\dimexpr \LH@sidebarY + \ht\LH@sidebarbox + \dp\LH@sidebarbox\relax}%

  % Page-1 overlay artwork / fixed text blocks
  \LH@drawfirstpageoverlay

  % Page-2+ continuation footer
  \LH@drawcontinuationfooter

  % Prevent duplicated page-1 footer (overlay already draws footer on page 1)
  \thispagestyle{empty}

  % Reasonable paragraph spacing for letter style
  \setlength{\parindent}{0pt}
  \setlength{\parskip}{0.55em}

  % Push page-1 body text below sidebar bottom.
  % Keep horizontal placement to geometry (do NOT manually set \textwidth/\oddsidemargin).
  \vspace*{\dimexpr \LH@bodyY - 1in - \topmargin - \headheight - \headsep - \parskip - \topskip\relax}
}

% --------------------------------------------------------------------------
% User-facing helper environment for letters
% --------------------------------------------------------------------------
\NewDocumentEnvironment{letterbody}{}{%
  % no-op: layout already handled globally
}{}

% --------------------------------------------------------------------------
% Optional helper macros for common letter parts
% --------------------------------------------------------------------------
\NewDocumentCommand{\lettersubject}{m}{%
  \vspace{0.4em}
  {\bfseries #1}\par
  \vspace{0.4em}
}

\NewDocumentCommand{\letteropening}{m}{%
  #1\par
}

\NewDocumentCommand{\letterclosing}{m}{%
  \vspace{1.2em}
  #1\par
}

\NewDocumentCommand{\lettersignature}{m}{%
  \vspace{2.5em}
  #1\par
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
    {Department of \mbox{Mechanical},\\Aerospace, and Nuclear\\Engineering}
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
