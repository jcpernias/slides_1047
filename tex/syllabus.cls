%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{syllabus}[2018/10/15 v 0.1 Part of docs-bundle]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}

\DeclareOption{Spanish}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{English}{\booltrue{langEN}\boolfalse{langES}}

\DeclareOption*{%
  \ClassError{syllabus}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `syllabus' class}}
\ExecuteOptions{Spanish}
\ProcessOptions*\relax

%% Class loading
%% --------------------------------------------------------------------------------
\LoadClass[a4paper, 12pt]{article}


%% Load packages
%% --------------------------------------------------------------------------------
\RequirePackage{docs-base}
\RequirePackage{docs-pages}
\RequirePackage{docs-math}
\RequirePackage{docs-colors}
\RequirePackage{docs-rules}
\RequirePackage{docs-lists}
\RequirePackage{docs-units}
\RequirePackage{docs-tables}
\RequirePackage{docs-hyper}



%% TOC
%% -----------------------------------------------------------------

\RequirePackage{titletoc}
\contentsmargin{2pc}
\titlecontents{section}[0pc]
{\addvspace{1ex}\sffamily\bfseries}
{\contentslabel{2pc}}
{}
{\hfill\contentspage}



%% Title
%% --------------------------------------------------------------------------------

\RequirePackage{titling}

\pretitle{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
\posttitle{\par\end{flushleft}}

\preauthor{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
\postauthor{\par\end{flushleft}}

\predate{\begin{flushleft}\Large\sffamily\bfseries\color{Title}}
\postdate{\par\end{flushleft}}



\AtBeginDocument{%
  \color{MainText}
  \pagenumbering{roman}
  \let\oldmaketitle\maketitle            
  \renewcommand{\maketitle}{%
    \oldmaketitle%
    \tableofcontents%
    \thispagestyle{empty}%
    \cleardoublepage{}%
    \vspace*{1em}
    \cleardoublepage{}%    
    \pagenumbering{arabic}
    \oldmaketitle
    \let\maketitle\oldmaketitle%
  }
  \maketitle
} 



%% Section headings 
%% -----------------------------------------------------------------
\RequirePackage[pagestyles, outermarks, nobottomtitles*, compact]{titlesec}


\titleformat{name=\section}[hang]{%
  \color{Section}\Large\sffamily\bfseries}{%
  \makebox[1.25cm][l]{\thesection.}}{0pt}{}

\titlespacing*{name=\section}{-1.25cm}{*7}{*1.5}

\titleformat{name=\section, numberless}
{\color{Section}\Large\sffamily\bfseries}
{}{0pt}{}

\titlespacing*{name=\section, numberless}{0pc}{*7}{*1.5}

\titleformat{\subsection}
{\color{Subsection}\large\sffamily\bfseries}
{\makebox[1cm][l]{\thesubsection.}}{0.3cm}{}


\titlespacing*{\subsection}{0pt}{*3.5}{*1.5}


\titleformat{name=\paragraph, numberless}[block]
{\color{Paragraph}\normalfont\bfseries\sffamily\scshape}
{}{0em}{}[\titlerule]

\titlespacing*{name=\paragraph, numberless}{0pc}{*5}{*3}

\titleformat{name=\subparagraph, numberless}[block]
{\hspace{-\parindent}\color{Subparagraph}\normalfont\bfseries\sffamily}
{}{0em}{}

\titlespacing*{name=\subparagraph, numberless}{\parindent}{*3}{*1}



