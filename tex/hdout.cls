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

%% Class loading
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{english,spanish}{translator}
\PassOptionsToPackage{svgnames}{xcolor}
\PassOptionsToPackage{fleqn, tbtags, leqno}{amsmath}
\LoadClass[a4paper, 11pt, twoside]{article}

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
  bindingoffset=0.7cm, vmargin=4cm}

%% List formatting
%% --------------------------------------------------------------------------------

%% Hack: avoid TeX hang when handling description environment (I)
%% See: http://tex.stackexchange.com/questions/31505/trouble-combining-enumitem-and-beamer
\let\olddescription\description
\let\oldenddescription\enddescription

\RequirePackage{enumitem}
\setlist[itemize]{leftmargin=*}
\setlist[itemize,1]{label={\textcolor{SteelBlue!80!White}{\RIGHTarrow}}}
\setlist[itemize,2]{%
  label={\textcolor{SteelBlue!80!White}{\footnotesize\RIGHTarrow}}}
\setlist[itemize,3]{%
  label={\textcolor{SteelBlue!80!White}{\textbullet}}}
\setlist[enumerate]{labelsep=*, leftmargin=1.5pc}
\setlist[enumerate,1]{label=\arabic*., ref=\arabic*}
\setlist[enumerate,2]{label=\beameroriginal\emph{\alph*}),%
  ref=\theenumi.\beameroriginal\emph{\alph*}}
\setlist[enumerate,3]{label=\roman*), ref=\theenumii.\roman*}
\setlist[description]{font=\sffamily\bfseries}

%% Hack: avoid TeX hang when handling description environment (and II)
\let\description\olddescription
\let\enddescription\oldenddescription

%% Section headings formatting
%% --------------------------------------------------------------------------------
\RequirePackage[%
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

\titleformat{name=\section}[hang]{%
  \color{Section}\LARGE\sffamily\bfseries}{%
  \makebox[1.25cm][l]{\rmfamily\slshape\HUGE\thesection.}}{0pt}{}

\titlespacing{name=\section}{-1.25cm}{0pt}{*1.5}

\titleformat{name=\section, numberless}{%
  \color{Section}\LARGE\sffamily\bfseries}{}{0pc}{}

\titlespacing{name=\section, numberless}{0pc}{*7}{*1.5}

\titleformat{name=\subsection}{%
  \color{Subsection}\Large\sffamily\bfseries}{%
  \makebox[2pc][r]{\thesubsection.}}{1pc}{}

\titlespacing{name=\subsection}
{-3pc}{7ex plus .2ex minus .4ex}{1.5ex minus .1ex}

\titleformat{name=\subsection, numberless}
{\color{Subsection}\Large\sffamily\bfseries}
{}{0pc}{}

\titlespacing{name=\subsection, numberless}
{0pc}{7ex plus .2ex minus .4ex}{1.5ex minus .1ex}

\titleformat{name=\paragraph}[block]
{{\color{SlateGray}\titlerule[.25pt]}\vspace*{.8ex}%
  \normalfont\small\bfseries\sffamily\filright}
{\theparagraph}{0em}{\color{Paragraph}}

\titlespacing*{name=\paragraph}
{0cm}{3ex plus .2ex minus .4ex}{1.5ex minus .1ex}



%% Page headers and footers
%% --------------------------------------------------------------------------------
\settitlemarks{section,subsection}

\newcommand*{\headfmt}{\color{DarkRed!30!Black}\small\bfseries\scshape\sffamily}
\newcommand*{\footfmt}{\small\bfseries\sffamily}

\newpagestyle{fancy}{%
  \sethead[\headfmt\ifthesection{%
    \thesection\ \sectiontitle}{\doctitle}\filright][][] % even
  {}{}{%
    \headfmt{}\ifthesubsection{%
      \thesubsection\ \subsectiontitle}{\thesection\ \sectiontitle}}    % odd
  \setfoot*{}{}{\footfmt\thepage}   % odd
}
\newpagestyle{first}{%
  \setfoot*{}{}{\footfmt\thepage}   % odd
}
\widenhead*{0.8cm}{4.5cm}
\pagestyle{fancy}

%% TOC
%% --------------------------------------------------------------------------------
\RequirePackage{titletoc}
\contentsmargin{2pc}
\titlecontents{section}[0pc]
{\addvspace{1ex}\sffamily\bfseries}
{\contentslabel{2pc}}
{}
{\hfill\contentspage}

\dottedcontents{subsection}[3pc]{\sffamily}{3pc}{0.5pc}

%% Title
%% --------------------------------------------------------------------------------
\RequirePackage{titling}
\pretitle{%
  \begin{flushleft}\Huge\sffamily\bfseries%
    \color{DarkRed!60!Black}%
  }
  \posttitle{\par\end{flushleft}}
\preauthor{\begin{flushleft}\Large\sffamily\bfseries\color{DarkRed!30!Black}}
  \postauthor{\par\end{flushleft}}
\predate{\begin{flushleft}\Large\sffamily\bfseries\color{DarkRed!30!Black}}
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
    \pagenumbering{roman}
    \oldmaketitle%
    \tableofcontents%
    \cleardoublepage%
    \pagenumbering{arabic}
    % \oldmaketitle
    \thispagestyle{first}
    \let\maketitle\oldmaketitle%
    \newcommand{\sectionbreak}{%
      \cleardoublepage\phantomsection%
      \thispagestyle{first}}}
  \maketitle%
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
\RequirePackage{docs-base}
\RequirePackage{docs-math}
\RequirePackage{docs-colors}
\RequirePackage{docs-units}
\RequirePackage{docs-tables}
\RequirePackage{docs-envs}
\RequirePackage{docs-blocks}
\RequirePackage{docs-hyper}

\def\Hy@xspace@end{}
