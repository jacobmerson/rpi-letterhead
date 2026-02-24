\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{MANEletterhead2}[2026/02/23 RPI MANE institutional letterhead prototype (corrected)]

\LoadClass[10pt]{article}

\RequirePackage[letterpaper]{geometry}

\RequirePackage{fontspec}
\RequirePackage{graphicx}
\RequirePackage{xcolor}
\RequirePackage{tikz}
\RequirePackage{eso-pic}
\RequirePackage{lastpage}
\RequirePackage{xparse}
\RequirePackage{etoolbox}

\setmainfont{RPI Geist}

% this is using 1.2*fontsize as baseline skip
\renewcommand{\normalsize}{\fontsize{9.6}{11.52}\selectfont}
\normalsize

% Bold label size (9.12pt) used for headings like DEPARTMENT, CONTACT, TO, date, footers
\newcommand{\LH@labelsize}{\fontsize{9.12}{10.94}\selectfont}

% Savebox for measuring sidebar content height
\newsavebox{\LH@sidebarbox}

\newcommand{\LH@logoFile}{RPI_Lockup_MechanicalAerospaceandNuclearEngineering_Lg.pdf}
\newcommand{\LH@smallLogoFile}{RPI_Logo.pdf}

%\newcommand{\LH@schoolName}{SCHOOL OR PORTFOLIO\\NAME GOES HERE}
\newcommand{\LH@date}{\LH@today}

\newcommand{\LH@departmentTitle}{DEPARTMENT}
\newcommand{\LH@departmentText}{Insert department or\\office name here}

\newcommand{\LH@contactTitle}{CONTACT}
\newcommand{\LH@contactText}{email@rpi.edu\\P +1 518 276 6000\\F 000 000 0000}

\newcommand{\LH@toTitle}{TO}
\newcommand{\LH@toText}{Name Surname\\100 Street Avenue\\New York, NY 10001}

\newcommand{\LH@footerPageOneLeft}{RPI.EDU}
\newcommand{\LH@footerPageOneCenter}{BUILDING, FLOOR 00, 110 EIGHTH ST TROY NY 12180}

\newcommand{\LH@footerContCenter}{BUILDING, FLOOR 00, 110 EIGHTH ST TROY NY 12180}
\newcommand{\LH@footerContRightText}{RPI.EDU}

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
\NewDocumentCommand{\footerpageonecenter}{m}{\renewcommand{\LH@footerPageOneCenter}{#1}}
\NewDocumentCommand{\footercontinuationcenter}{m}{\renewcommand{\LH@footerContCenter}{#1}}
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

% --------------------------------------------------------------------------
% Apply body-column geometry (this is the key fix)
% Ensures LaTeX's real text frame matches the intended right column.
% --------------------------------------------------------------------------
\newcommand{\LH@applybodygeometry}{%
  \newgeometry{%
    letterpaper,
    left=\dimexpr\LH@bodyX+0.08in\relax,
    right=\dimexpr\paperwidth-\LH@bodyX-\LH@bodyWidth+0.08in\relax,
    top=\LH@contBodyY,
    bottom=1.25in,
    headheight=0pt,
    headsep=0pt,
    footskip=0pt
  }%
}

% --------------------------------------------------------------------------
% Helper: draw first-page overlay (logo/date/sidebar/to block/footer)
% --------------------------------------------------------------------------
\newcommand{\LH@drawfirstpageoverlay}{%
  \AddToShipoutPictureFG*{%
    \begin{tikzpicture}[remember picture,overlay]
      % --- Top-left logo / lockup (placeholder positioning)
      \node[anchor=north west, inner sep=0pt] at ([xshift=0.32in,yshift=-0.19in]current page.north west) {%
          \includegraphics[height=0.84in]{\LH@logoFile}%
      };

      % --- Date (top-right)
      % for some reason this is slightly inside and down from the top of the logo
      \node[anchor=north east, inner sep=0pt] at ([xshift=-0.27in,yshift=-0.21in]current page.north east) {%
        {\bfseries\LH@labelsize \LH@date}%
      };

      % --- Sidebar: Department + Contact (fixed box, page 1 only)
      \node[anchor=north west, inner sep=0pt]
        at ([xshift=\LH@sidebarX,yshift=-\LH@sidebarY]current page.north west) {%
          \usebox{\LH@sidebarbox}%
      };

      % --- TO block (fixed box, page 1 only)
      \node[anchor=north west, text width=\dimexpr\LH@toWidth-0.16in\relax, align=left, inner sep=0pt]
        at ([xshift=\dimexpr\LH@toX+0.08in\relax,yshift=-\LH@toY]current page.north west) {%
          {\bfseries\LH@labelsize \LH@toTitle}\par
          \vspace{0.3em}
          \LH@toText
      };

      % --- First-page footer (overlay only; page 1 fancy footer disabled below)
      \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@sidebarX,yshift=0.4in]current page.south west) {%
        {\bfseries\LH@labelsize \LH@footerPageOneLeft}%
      };
      \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@bodyX,yshift=0.4in]current page.south west) {%
        {\bfseries\LH@labelsize \LH@footerPageOneCenter}%
      };
      \node[anchor=north east, inner sep=0pt] at ([xshift=-0.35in,yshift=0.4in]current page.south east) {%
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
        \node[anchor=north west, inner sep=0pt] at ([xshift=0.25in,yshift=0.4in]current page.south west) {%
          \IfFileExists{\LH@smallLogoFile}{%
            \includegraphics[height=0.18in]{\LH@smallLogoFile}%
          }{%
            \textbf{RPI}%
          }%
        };

        % Center footer text left-aligned with body column
        \node[anchor=north west, inner sep=0pt] at ([xshift=\LH@bodyX,yshift=0.4in]current page.south west) {%
          {\bfseries\LH@labelsize \LH@footerContCenter\ \ \textbullet\ \ \LH@footerContRightText}%
        };

        % Page number at physical right margin
        \node[anchor=north east, inner sep=0pt] at ([xshift=-0.25in,yshift=0.4in]current page.south east) {%
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
    \parbox[t]{\dimexpr\LH@sidebarWidth-0.16in\relax}{%
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
\endinput
