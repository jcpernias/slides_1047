%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{exam}[2018/10/10 v 0.1 Part of docs-bundle]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}
\newbool{answers}
\newbool{shortanswers}

\boolfalse{answers}
\boolfalse{shortanswers}


\DeclareOption{Spanish}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{English}{\booltrue{langEN}\boolfalse{langES}}
\DeclareOption{noanswers}{\boolfalse{answers}\boolfalse{shortanswers}}
\DeclareOption{answers}{\booltrue{answers}\boolfalse{shortanswers}}
\DeclareOption{shortanswers}{\boolfalse{answers}\booltrue{shortanswers}}

\DeclareOption*{%
  \ClassError{exam}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `exam' class}}
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
\RequirePackage{docs-marks}
\RequirePackage{docs-tables}
\RequirePackage{docs-hyper}
\RequirePackage{docs-answers}



%% Page layout
%% --------------------------------------------------------------------------------
\geometry{reset, hscale=0.72, vscale=0.75,
  bindingoffset=0in, hcentering=true}


%% List
%% --------------------------------------------------------------------------------
% Do not break a page in the middle of a question list?
\setlist[enumerate, 2]{beginpenalty=10000, midpenalty=10000}



%% Title
%% --------------------------------------------------------------------------------

\newcommand*{\testname}[1]{\renewcommand\@testname{#1}}
\newcommand*{\@testname}{}

\newcommand*{\subject}[1]{\renewcommand\@subject{#1}}
\newcommand*{\@subject}{}

\newcommand*{\testtype}[1]{\renewcommand\@testtype{#1}}
\newcommand*{\@testtype}{1}

\RequirePackage[useregional=num]{datetime2}

\newcommand*{\testdate}[1]{\renewcommand\@testdate{\DTMdate{#1}}}
\newcommand*{\@testdate}{\today}


\RequirePackage{tikzpagenodes}
\RequirePackage{fancyhdr}

\newcommand*\@circled[1]{\tikz[remember picture, overlay]{%
    \draw (current page.south west) ++(0.75cm, 0.75cm)%
    node[shape=circle,draw,inner sep=0.2pt, font=\tiny] {#1};}}


\setlength{\headheight}{15.2pt}

\pagestyle{fancy}
\fancyhf{}
\lhead{\sffamily\textsc{\,\@subject}}
% \chead{\textsc{\@testname}}
\rhead{\@testdate}
\cfoot{---\,\thepage\,---}

\fancypagestyle{first}{ %
  \fancyhf{} % remove everything
  \begin{tikzpicture}[remember picture, overlay]
    \fill [black!5!white] (current page header area.north west)
    rectangle (current page header area.south east);
  \end{tikzpicture}
  \lhead{\sffamily\color{black}\textsc{\,\@subject}}
  % \rhead{\sffamily\color{black!60!white}\textsc{\@testname\,}}
  \rhead{\sffamily\color{black}\@testdate\,}
  \lfoot{\color{black}\@circled{\@testtype}}
  \renewcommand{\headrulewidth}{0.0pt}
}



%% Cover
%% ================================================================================

\RequirePackage{adjustbox}

\newadjustboxenv*{header}{%
  minipage={0.975\linewidth},center,vspace={0em \baselineskip},
  innercode={\sffamily}{}}

\newadjustboxenv*{instructions}{%
  minipage={0.95\linewidth},center,vspace={1em \baselineskip},
  innercode={\sffamily\bfseries}{}}

\AtBeginDocument{%
  \color{MainText}%
  \pagenumbering{arabic}%
  \thispagestyle{first}%
}
