%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{hdout}[2021/07/18 v 0.1]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}

\DeclareOption{es}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{en}{\booltrue{langEN}\boolfalse{langES}}


\DeclareOption*{%
  \ClassError{hdout}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `hdout' class}}
\ExecuteOptions{es}
\ProcessOptions*\relax

\InputIfFileExists{hdout.cfg}{}{}

%% Class loading
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{english,spanish}{translator}
\PassOptionsToPackage{svgnames}{xcolor}
\PassOptionsToPackage{fleqn, tbtags, leqno}{amsmath}
\LoadClass[%
a4paper,
twoside]{article}

%% Beamer
%% --------------------------------------------------------------------------------
\RequirePackage{beamerarticle}

%% Redefine beamer frames to paragraphs
\setbeamertemplate{frametitle}{%
  \paragraph{\insertframetitle}}

%% Fix column environment in article mode
\mode<article>{\renewenvironment{column}[1]{\begin{minipage}{#1}}{%
    \end{minipage}}}

%% Fix columns environment in article mode
\mode<article>{%
  \renewenvironment{columns}[1][]{\let\par\empty}{}}

%% Redefine beamer alert
\setbeamertemplate{alerted text begin}{\ifmmode\else\begin{bfseries}\fi}
  \setbeamertemplate{alerted text end}{\ifmmode\else\end{bfseries}\fi}

%% Disable hyphenation
%% --------------------------------------------------------------------------------
\RequirePackage{hyphsubst}
\HyphSubstLet{spanish}{nohyphenation}
\HyphSubstLet{english}{nohyphenation}


%% Disable indentation
%% --------------------------------------------------------------------------------
\parindent=0pt

%% More font sizes
%% --------------------------------------------------------------------------------
\RequirePackage{moresize}

%% Page layout
%% --------------------------------------------------------------------------------
\RequirePackage{geometry}
\geometry{twoside, hmargin={2cm,5.7cm},
  bindingoffset=0.7cm, vmargin=3cm}


%% Section headings formatting
%% --------------------------------------------------------------------------------
\RequirePackage[%
newparttoc, %
clearempty, %
pagestyles, %
outermarks, %
noindentafter, %
nobottomtitles*, %
compact]{titlesec}

%% Solves bug in titlesec version 2.10.1. Version 2.10.2 does not have
%% this bug. See http://tex.stackexchange.com/a/300259
\patchcmd{\ttlh@hang}{\parindent\z@}{\parindent\z@\leavevmode}{}{}
\patchcmd{\ttlh@hang}{\noindent}{}{}{}

\titleformat{name=\part}[display]{%
  \color{Section}\HUGE\sffamily\bfseries}{%
  \filleft\HUGE \partname\ \thepart}{1pc}{\filleft}

\titlespacing{name=\part}{0pt}{*20}{*6}


\titleformat{name=\section}[hang]{%
  \color{Section}\huge\sffamily\bfseries}{%
  \makebox[2pc][r]{\rmfamily\slshape\HUGE\thesection.}}{1pc}{}

\titlespacing{name=\section}{-3pc}{0pt}{*6}

\titleformat{name=\section, numberless}{%
  \color{Section}\LARGE\sffamily\bfseries}{}{0pc}{}

\titlespacing{name=\section, numberless}{0pc}{*7}{*6}

\titleformat{name=\subsection}{%
  \color{Subsection}\Large\sffamily\bfseries}{%
  \makebox[2pc][r]{\thesubsection.}}{1pc}{}

\titlespacing{name=\subsection}{-3pc}{*7}{*1.5}

\titleformat{name=\subsection, numberless}
{\color{Subsection}\Large\sffamily\bfseries}
{}{0pc}{}

\titlespacing{name=\subsection, numberless}{0pc}{*7}{*1.5}

\titleformat{name=\paragraph}[block]
{{\color{SlateGray}\titlerule[.25pt]}\vspace*{.8ex}%
  \normalfont\small\bfseries\sffamily\filright}
{\theparagraph}{0em}{\color{Paragraph}}

\titlespacing*{name=\paragraph}{0cm}{*3}{*1.5}



%% Page headers and footers
%% --------------------------------------------------------------------------------
\settitlemarks{section,subsection}

\newcommand*{\headfmt}{\color{Section}\small\bfseries\sffamily}
\newcommand*{\footfmt}{\small\bfseries\sffamily}

\newpagestyle{fancy}{%
  \renewcommand{\makeheadrule}{%
    \color{Section}\rule[-0.3\baselineskip]{\linewidth}{1.2pt}}
  \renewcommand{\makefootrule}{%
    \color{Section}\rule[0.8\baselineskip]{\linewidth}{1.2pt}}
  \sethead[\headfmt\ifthesection{%
    \thesection\ \sectiontitle}{\doctitle}\filright][][] % even
  {}{}{%
    \headfmt{}\ifthesubsection{%
      \thesubsection\ \subsectiontitle}{\thesection\ \sectiontitle}}    % odd
  \setfoot*{}{}{\footfmt\thepage}   % odd
}
\newpagestyle{first}{%
  \renewcommand{\makefootrule}{%
    \color{Section}\rule[0.8\baselineskip]{\linewidth}{1.2pt}}
  \setfoot*{}{}{\footfmt\thepage}   % odd
}

\newpagestyle{front}{%
  \setfoot*{}{\footfmt\thepage}{}   % odd
}
\widenhead*{0.8cm}{4.5cm}
\pagestyle{fancy}

%% TOC
%% --------------------------------------------------------------------------------
\RequirePackage{titletoc}
\contentsmargin{2pc}

\titlecontents{part}[0pc]
{\addvspace{1pc}\sffamily\large\bfseries}
{\partname\ \thecontentslabel:\enspace}
{}
{\hfill\contentspage}
[\addvspace{.25pc}]

\titlecontents{section}[0pc]
{\addvspace{1ex}\sffamily\bfseries}
{\contentslabel{2pc}}
{}
{\hfill\contentspage}

\dottedcontents{subsection}[3pc]{\sffamily}{3pc}{0.5pc}


%% Parts
%% --------------------------------------------------------------------------------
%\newcommand{\partbreak}{\cleardoublepage}
\titleclass{\part}{page}
\assignpagestyle{\part}{empty}
\newcommand{\partbreak}{%
%   \cleardoublepage\phantomsection%
   \thispagestyle{first}}
% \let\oldpart\part% Store \part in \oldpart
% \renewcommand{\part}{\thispagestyle{first}\oldpart}% Insert \clearpage before every \part

%% Title
%% --------------------------------------------------------------------------------
\RequirePackage{titling}
\pretitle{\begin{flushleft}\HUGE\sffamily\bfseries\color{Title}}
\posttitle{\par\end{flushleft}}

\preauthor{\begin{flushleft}\LARGE\sffamily\bfseries\color{Title}}
\postauthor{\par\end{flushleft}}

\predate{\begin{flushleft}\Large\sffamily\bfseries\color{Title}}
\postdate{\par\end{flushleft}}


%% Compose frontmatter
%% --------------------------------------------------------------------------------
%\AtBeginDocument{%
\AfterEndPreamble{%
  \hypersetup{pageanchor=false}
  \let\doctitle\thetitle
  \pagenumbering{gobble}
  \let\oldmaketitle\maketitle
  \renewcommand{\maketitle}{%
    \oldmaketitle%
    \thispagestyle{empty}%
    \newpage%
    \ccpage%
    \hypersetup{pageanchor=true}
    \newpage%
    \pagestyle{front}
    \pagenumbering{roman}
    \oldmaketitle%
    \tableofcontents%
    \cleardoublepage%
    \pagestyle{fancy}
    \pagenumbering{arabic}
    % \oldmaketitle
    \thispagestyle{first}
    \let\maketitle\oldmaketitle%
    \newcommand{\sectionbreak}{%
      \cleardoublepage\phantomsection%
      \thispagestyle{first}}}
  \maketitle%
}

\mode
<article>
{
  \renewcommand{\subtitle}[2][]{%
    \def\insertsubtitle{#2}\g@addto@macro\@title{\\<article>{\huge#2}}}
}

%% CC notice
%% --------------------------------------------------------------------------------
%% Two minipages side by side that fill the width of the line.
%% 1st arg (optional): width of the left cell (default 3.5cm).
%% 2nd arg: contents of the left cell.
%% 3rd arg: contents of the right cell.
\newlength{\@leftcell}
\newlength{\@rightcell}

\newcommand{\@twocells}[3][3.5cm]{
  {\scriptsize%
    \setlength{\@leftcell}{#1}%
    \setlength{\@rightcell}{\linewidth}%
    \addtolength{\@rightcell}{-\@leftcell}%
    \begin{minipage}{\@leftcell}#2\end{minipage}%
    \begin{minipage}{\@rightcell}#3\end{minipage}}}

%% License translations
\deftranslation[to=English]{CCstart}{This work is licensed under a}
\deftranslation[to=English]{CClink}{Creative Commons Attribution-ShareAlike
  4.0 International License.}
\deftranslation[to=Spanish]{CCstart}{Esta obra está bajo una}
\deftranslation[to=Spanish]{CClink}{licencia de Reconocimiento-CompartirIgual
  4.0 de Creative Commons.}


%% Inserts a page stating the CC license
\newcommand{\ccpage}{%
  \newpage%
  \vspace*{\stretch{5}}%
  \thispagestyle{empty}%
  \@twocells{\includegraphics[scale=1]{by-sa}}{%
    \translate{CCstart}
    \href{http://creativecommons.org/licenses/by-sa/4.0/}{%
      \translate{CClink}}}%
  \cleardoublepage{}}


%% Load packages
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{document}{ragged2e}
\RequirePackage{docs-full}

\def\Hy@xspace@end{}
