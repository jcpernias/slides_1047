%% Identification
%% ----------------------------------------------------------------------

% A very recent version of LaTeX is required to ensure that default
% input encoding is utf8. This saves to explicitely require utf8
% encoding and especial handling of some characters:
%
% \usepackage[utf8]{inputenc}
% \DeclareUnicodeCharacter{00A0}{~}

\NeedsTeXFormat{LaTeX2e}[2018/04/01]
\ProvidesClass{pres}[2021/07/18 v 0.1]

\RequirePackage{etoolbox}

%% Class options
%% --------------------------------------------------------------------------------
\newbool{langES}
\newbool{langEN}

\DeclareOption{es}{\booltrue{langES}\boolfalse{langEN}}
\DeclareOption{en}{\booltrue{langEN}\boolfalse{langES}}


\DeclareOption*{%
  \ClassError{pres}{Unknown option `\CurrentOption'}{%
    Check the options passed to the `pres' class}}
\ExecuteOptions{es}
\ProcessOptions*\relax

%% Class loading
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{english,spanish}{translator}
\PassOptionsToPackage{svgnames}{xcolor}
\PassOptionsToPackage{fleqn, tbtags, leqno}{amsmath}
\LoadClass[%
  presentation, %
  compress, %% Navigation bars as small as possible
  11pt %
]{beamer}


%% Beamer setup
%% --------------------------------------------------------------------------------

\usetheme[numbering=none,nofirafonts]{focus}
\usefonttheme{professionalfonts}

\setbeamercovered{invisible}

% Quotes and quotation
\setbeamerfont{quote}{shape=\upshape,family=\rmfamily}
\setbeamerfont{quotation}{shape=\upshape,family=\rmfamily}

\setbeamercolor{alerted text}{fg=DarkBlue}
\setbeamerfont{alerted text}{series=\bfseries}

\setbeamertemplate{itemize items}[triangle]
\setbeamertemplate{enumerate items}[circle]
\setbeamertemplate{footline}[default]

\setbeamercolor{enumerate item}{fg=green!20!black}
\setbeamertemplate{enumerate items}[default]

% \setbeamertemplate{section in toc}[circle]
% \setbeamertemplate{subsection in toc}[ball unnumbered]

%% Disable navigation symbols
\setbeamertemplate{navigation symbols}{}

%% TOC: disable decorations for section numbers
\setbeamertemplate{section in toc}{\inserttocsectionnumber.~\inserttocsection}
\setbeamertemplate{subsection in toc}{%
  \hspace{1em}\inserttocsectionnumber.%
  \inserttocsubsectionnumber.~\inserttocsubsection\par}

%% List formatting: same font size for nested lists.
\setbeamerfont*{itemize/enumerate subbody}{parent=itemize/enumerate body}
\setbeamerfont*{itemize/enumerate subsubbody}{parent=itemize/enumerate body}

\setbeamertemplate{itemize subitem}{%
  \scriptsize\raise1.25pt\hbox{\donotcoloroutermaths$\blacktriangleright$}}
\setbeamertemplate{itemize subsubitem}{%
  \scriptsize\raise1.25pt\hbox{\donotcoloroutermaths$\blacktriangleright$}}

\makeatletter
\let\@listii\@listi
\let\@listiii\@listi
\makeatother


% TODO Why cannot overwrite the Outline translation?
\deftranslation[to=English]{outline}{Outline}
\deftranslation[to=Spanish]{outline}{Esquema}
\newcommand*{\OutlineLabel}{\translate{outline}}

\AtBeginSection[]
{
  \begin{frame}
    \frametitle{\OutlineLabel}
    \tableofcontents[currentsection,subsectionstyle=show/show/hide]
  \end{frame}
}

\AtBeginSubsection[]
{
  \begin{frame}
    \frametitle{\OutlineLabel}
    \tableofcontents[currentsection, subsectionstyle=show/shaded/hide,]
  \end{frame}
}

\newcommand*{\firstframes}{%
  \begin{frame}[plain]\titlepage\end{frame}%
  \begin{frame}%<presentation>%
    \frametitle{\OutlineLabel}%
    \tableofcontents[hideallsubsections]%
  \end{frame}
}

\AtBeginDocument{\firstframes}



%% Load packages
%% --------------------------------------------------------------------------------
\PassOptionsToPackage{document}{ragged2e}
\RequirePackage{docs-full}
